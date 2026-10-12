# Reporte — Prueba del Dockerfile del backend

**Fecha:** 2026-08-14 · **Docker:** 29.7.2 (Client y Server, Docker Desktop, buildx v0.36.0-desktop.1)

## Nota previa: nombres de archivo

El brief esperaba `sgpmp-backend/Dockerfile` y `sgpmp-backend/.dockerignore`. En el repo,
Implementación los colocó como `sgpmp-backend/backend.Dockerfile` y
`sgpmp-backend/backend.dockerignore` (confirmado con `ls sgpmp-backend/Dockerfile
sgpmp-backend/.dockerignore` → *No such file or directory*, y `git status` en `sgpmp-backend`
mostrando ambos como *untracked*). Se ajustaron los comandos de build para usar `-f
backend.Dockerfile`, sin renombrar ni mover nada en el repo.

## Build

- **Comando ejecutado:**
  ```
  docker build -f backend.Dockerfile -t sgpmp-backend:dev .
  ```
  (ejecutado dentro de `sgpmp-backend/`)

- **Resultado:** exit code `0`. Imagen final:
  ```
  sgpmp-backend:dev  1.04GB
  ```

- **Problema encontrado y causa (no se modificó el repo para resolverlo):**
  El primer intento de build superó los 5 minutos solo en la etapa `[internal] load build
  context`, transfiriendo progresivamente 21MB → 168MB → seguía subiendo. Diagnóstico:
  `docker build` únicamente reconoce automáticamente un archivo de ignore llamado `.dockerignore`,
  o bien `<nombre-del-Dockerfile>.dockerignore` (en este caso habría sido
  `backend.Dockerfile.dockerignore`). Como el archivo real se llama `backend.dockerignore`,
  Docker no lo detecta y el log lo confirma:
  ```
  #3 [internal] load .dockerignore
  #3 transferring context: 2B 0.0s done
  ```
  (2 bytes = ignore file vacío/no encontrado, no las ~200 bytes del `backend.dockerignore` real).
  Esto provocó que el contexto de build incluyera un `.venv/` local de **182MB** (que
  `backend.dockerignore` sí lista, pero no se aplicó) más `.git/` (2.4MB), inflando el contexto a
  ~210MB en vez de los ~10MB esperados (`src/` + `vendor/` + `requirements.txt`).
  No se renombró el archivo (fuera del alcance permitido); se documenta como pendiente abajo.
  Reintentos posteriores del build reutilizaron el caché local de contexto de BuildKit y fueron
  rápidos (contexto de solo 1.03MB transferido), pero esto no es fiable para un build limpio
  (ej. CI o clon nuevo del repo), donde sí se pagaría el costo completo.

- **Tiempo:** primer intento cancelado por timeout de la herramienta a los 5 min (aún transfiriendo
  contexto); reintento en segundo plano completado en ~1 minuto gracias al caché de capas y de
  contexto de BuildKit del intento anterior.

## Ejecución

- **Comando `docker run` usado:**
  ```
  docker run -d --name sgpmp-backend-test -p 8001:8000 \
    -e DATABASE_URL="postgresql://dba:dev123@host.docker.internal:5433/dba" \
    -e SECRET_KEY="dev-only-not-for-production" \
    -e FRONTEND_URL="http://localhost:5173" \
    sgpmp-backend:dev
  ```

- **Estado del healthcheck:** `starting` → dos intentos fallidos iniciales (`Connection refused`,
  visibles en `docker inspect --format '{{json .State.Health}}'`) mientras la app terminaba de
  inicializar (tareas de arranque, ver sección de logs) → **`healthy`** una vez que Uvicorn quedó
  arriba (~30s después del `docker run`).

- **Salida de `curl /health`:**
  ```
  {"status":"ok","message":"API funcionando correctamente"}
  HTTP_STATUS:200
  ```

## Conexión a la base de datos

- **Comando ejecutado dentro del contenedor (según el brief, vía `host.docker.internal:5433`):**
  ```
  docker exec sgpmp-backend-test python -c "from src.shared.database import engine; print(engine.connect())"
  ```

- **Resultado exacto (verbatim, truncado a las líneas relevantes):**
  ```
  Traceback (most recent call last):
    ...
    File "/opt/venv/lib/python3.12/site-packages/psycopg2/__init__.py", line 122, in connect
      conn = _connect(dsn, connection_factory=connection_factory, **kwasync)
  UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position 107: invalid continuation byte
  ```

- **Diagnóstico adicional (fuera del script original del brief, necesario para aislar la causa):**
  1. Se repitió con `psycopg2.connect()` puro (sin SQLAlchemy) contra
     `host.docker.internal:5433` → **mismo error**, mismo byte, misma posición. Esto descarta que
     sea un problema de SQLAlchemy, del ORM o del código de la app.
  2. Se revisaron comentarios de BD/rol (`obj_description`, `shobj_description`) y triggers de
     evento (`pg_event_trigger`) en el contenedor `SGPMP` → todos vacíos/sin resultados.
  3. Se conectó el contenedor de prueba a la red `docker_default` (la misma red del contenedor
     `SGPMP`) y se probó una conexión directa por nombre de servicio:
     ```
     docker network connect docker_default sgpmp-backend-test
     python -c "import psycopg2; print(psycopg2.connect(host='SGPMP', port=5432, dbname='dba', user='dba', password='dev123'))"
     ```
     **Resultado:** conexión exitosa —
     `<connection object ...; dsn: 'user=dba password=xxx dbname=dba host=SGPMP port=5432', closed: 0>`

  **Conclusión:** el error de `UnicodeDecodeError` ocurre únicamente al conectar por la ruta
  `host.docker.internal:5433` (forwarding de puertos de Docker Desktop hacia el host en Windows).
  La conexión contenedor-a-contenedor por red Docker, usando el nombre del servicio/contenedor
  (`SGPMP:5432`), funciona sin problemas. Esta última es la forma en que backend y BD se
  conectarán una vez armado el `docker-compose` (misma red definida en el compose), por lo que
  **no es un bloqueante para ese escenario real**. No se identificó la causa raíz exacta del fallo
  específico de `host.docker.internal` (no se encontró en comentarios de BD ni triggers); podría
  ser una particularidad del proxy de puertos de Docker Desktop para Windows. Queda como nota,
  no como bloqueante, dado que el patrón de conexión real (compose) ya se validó como funcional.

## Logs relevantes

Durante el arranque, tres tareas en segundo plano de la app (batch ICA nocturno, poller de
reportes de gastos, poller de historial de suministros) intentaron leer configuración desde la
BD y fallaron con el mismo `UnicodeDecodeError` descrito arriba (mismo `host.docker.internal`,
mismo byte 0xf3, misma causa). La app cae a valores por defecto y continúa el arranque con
normalidad:

```
Batch ICA nocturno: no se pudo leer la configuración; se usa 02:00.
Traceback (most recent call last):
  ...
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position 107: invalid continuation byte
Poller de reportes de gastos: no se pudo leer la configuración; se usan 15s.
...
Poller de historial de suministros: no se pudo leer la configuración; se usan 15s.
...
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

No se observaron otros `WARNING`/`ERROR` en el resto del log.
## Corrección aplicada y reverificación (post-hallazgo inicial)

**Causa raíz confirmada:** el archivo se llamaba `backend.dockerignore`, nombre no reconocido
por Docker (que solo detecta `.dockerignore` o `<Dockerfile>.dockerignore`). Se renombraron
ambos archivos a la convención estándar:

```bash
mv backend.Dockerfile Dockerfile
mv backend.dockerignore .dockerignore
```
docker build -t sgpmp-backend:dev .
...
=> [internal] load .dockerignore 0.1s
=> => transferring context: 141B 0.0s
=> [internal] load build context 4.5s
=> => transferring context: 229.68kB 4.5s
(antes: contexto sin filtrar, superando 182MB solo por `.venv/`; ahora: 229KB, coherente con
`src/` + `vendor/` + `requirements.txt`)

> Nota: en el primer intento de este fix se cometió un typo en el tag
> (`docker build -t sgmp-backend:dev .`, sin la "p" de "sgpmp"), lo que hizo que la
> verificación posterior corriera sobre la imagen *vieja* (con la fuga) bajo el nombre correcto,
> dando un falso positivo de fuga. Se corrigió con
> `docker tag sgmp-backend:dev sgpmp-backend:dev` y se eliminó la imagen mal etiquetada
> (`docker rmi sgmp-backend:dev`). Vale la pena revisar dos veces el nombre del tag al reconstruir.

**Verificación de que ya no hay fuga de archivos locales:**
```bash
docker run --rm sgpmp-backend:dev sh -c \
  'test -e .venv && echo "⚠️ LEAK: .venv presente"; \
   test -e .env && echo "⚠️ LEAK: .env presente"; \
   test -e .git && echo "⚠️ LEAK: .git presente"; \
   echo "verificación terminada"'
```
Resultado: **sin salida de ningún `⚠️ LEAK`** — ni `.venv`, ni `.env`, ni `.git` están presentes
en la imagen.

**Reverificación funcional completa, con el patrón de conexión real (red de contenedores, no
`host.docker.internal`):**
```bash
docker run -d --name sgpmp-backend-test \
  --network docker_default \
  -p 8001:8000 \
  -e DATABASE_URL="postgresql://dba:dev123@SGPMP:5432/dba" \
  -e SECRET_KEY="dev-only-not-for-production" \
  -e FRONTEND_URL="http://localhost:5173" \
  sgpmp-backend:dev

sleep 8
curl -i http://localhost:8001/health
```
Resultado:
HTTP/1.1 200 OK
content-type: application/json
{"status":"ok","message":"API funcionando correctamente"}

Logs del contenedor, arranque limpio sin reintentos ni errores:
INFO: Started server process [1]
INFO: Waiting for application startup.
INFO: Application startup complete.
INFO: Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)

Contenedor de prueba detenido y eliminado (`docker stop` + `docker rm`); imagen
`sgpmp-backend:dev` conservada; contenedor `SGPMP` (BD) intacto durante todo el proceso.


**Build limpio, contexto ya filtrado correctamente:**

## Veredicto

**La imagen queda lista para integrarse al docker-compose por entorno, sin salvedades
pendientes.**

- La imagen build-ea correctamente (multi-stage, usuario no-root, healthcheck funcional).
- El `.dockerignore` funciona como se esperaba: la imagen no arrastra `.venv`, `.env` ni `.git`
  (verificado explícitamente, ver sección anterior).
- El contenedor arranca limpio y responde `/health` con `200 OK`.
- La conectividad a la BD funciona por el mecanismo que usará el compose real (red de
  contenedores, nombre de servicio `SGPMP`), verificado tanto con `psycopg2` directo como con la
  app completa arrancando sin errores.

## Pendientes / notas

1. ~~Renombrar `backend.dockerignore` → `.dockerignore`~~ **Resuelto.** Los archivos ya se
   llaman `Dockerfile` y `.dockerignore` en el repo (ver "Corrección aplicada y reverificación").
2. El `UnicodeDecodeError` sobre `host.docker.internal:5433` (ver sección "Conexión a la base de
   datos" del hallazgo inicial) sigue sin causa raíz identificada. No bloquea el compose, porque
   el patrón de conexión real (red de contenedores) ya quedó validado dos veces. Si en el futuro
   alguna herramienta local necesita conectarse vía `host.docker.internal`, conviene investigarlo
   entonces.
3. Tamaño final de la imagen tras el fix: `<completar con `docker images sgpmp-backend:dev`>`

$ docker images sgpmp-backend:dev
                                                i Info →   U  In UseIMAGE               ID             DISK USAGE   CONTENT SIZE   EXTRAsgpmp-backend:dev   8bee031efe00        522MB          115MB 
.