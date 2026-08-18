# Reporte — Prueba del docker-compose (entorno dev)

**Fecha:** 2026-08-18 · **Docker:** 29.7.2 (build a7dcaa6), Server 29.7.2

## Prerrequisitos

- `docker-compose.yml`, `docker-compose.dev.yml`, `.env.dev`: presentes en `SGMP-Integracion`.
- `../sgpmp-backend/Dockerfile`, `../SGPMP-FRONT-END-PWA/Dockerfile`: presentes.
- `docker info --format '{{.ServerVersion}}'` → `29.7.2`.
- Contenedor `SGPMP` (BD del DBA): existía pero estaba **detenido** (`Exited (0) 3 days ago`).
  Se arrancó con `docker start SGPMP` (sin recrear, volumen intacto). Quedó `Up`, puerto
  `0.0.0.0:5433->5432/tcp`.
- Red `docker_default`: existía (`bridge`, local) — confirmado con `docker network ls | grep docker_default`.

Todos los prerrequisitos se cumplieron; no fue necesario detenerse en este paso.

## Levantamiento (`up --build`)

```
docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev up --build -d
```

- Exit code: `0`.
- Build de ambas imágenes exitoso (`sgmp-integracion-backend`, `sgmp-integracion-frontend`);
  la mayoría de las capas vinieron de caché (`CACHED`) salvo el `load build context` de cada una.
- Orden de arranque respetado: `sgpmp-backend-dev` se creó y arrancó primero, esperó a quedar
  `Healthy`, y solo entonces se creó/arrancó `sgpmp-frontend-dev` (confirma que
  `depends_on: backend: condition: service_healthy` funciona con el `HEALTHCHECK` del
  Dockerfile del backend).

## Estado de los contenedores

```
NAME                 IMAGE                       SERVICE    STATUS                        PORTS
sgpmp-backend-dev    sgmp-integracion-backend    backend    Up About a minute (healthy)   0.0.0.0:8000->8000/tcp
sgpmp-frontend-dev   sgmp-integracion-frontend   frontend   Up 8 seconds                  0.0.0.0:5173->5173/tcp
```

`docker inspect --format '{{.State.Health.Status}}' sgpmp-backend-dev` → `healthy`.

## Backend

```
curl -i http://localhost:8000/health
```

```
HTTP/1.1 200 OK
content-type: application/json

{"status":"ok","message":"API funcionando correctamente"}
```

## Conexión a la base de datos (vía red del compose)

```
docker exec sgpmp-backend-dev python -c "from src.shared.database import engine; print(engine.connect())"
```

```
<sqlalchemy.engine.base.Connection object at 0x7f9b09f0fbf0>
```

Conexión exitosa usando la `DATABASE_URL` ensamblada por el compose
(`postgresql://dba:***@SGPMP:5432/dba`) a través de la red `docker_default`, sin depender de
`host.docker.internal`.

## Frontend

```
curl -i http://localhost:5173/
```

```
HTTP/1.1 200 OK
Content-Type: text/html
...
<!DOCTYPE html>
<html lang="en">
  <head>
    <script type="module">import { injectIntoGlobalHook } from "/@react-refresh";
    ...
    <title>Ionic App</title>
    ...
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

Servidor Vite dev respondiendo con hot-reload activo (`@react-refresh`, `@vite/client`).

```
docker exec sgpmp-frontend-dev printenv VITE_API_BASE_URL
```

```
http://localhost:8000
```

Coincide exactamente con el valor de `VITE_API_BASE_URL` en `.env.dev`.

## Enlace front↔back end-to-end

```
curl -s -i http://localhost:8000/sesiones/ \
  -X POST -H "Content-Type: application/json" \
  -H "Origin: http://localhost:5173" \
  -d '{"correo_electronico":"smoke-test-noexiste@example.com","contrasena":"x"}'
```

```
HTTP/1.1 401 Unauthorized
access-control-allow-credentials: true
access-control-allow-origin: http://localhost:5173
vary: Origin

{"error_code":"CREDENCIALES_INVALIDAS","message":"Credenciales incorrectas. Verifica tu correo electrónico y contraseña.","fields":[],"timestamp":"2026-08-18T13:59:06.434341+00:00"}
```

`401` + `access-control-allow-origin: http://localhost:5173` como se esperaba: CORS y la
consulta a la BD (validación de credenciales inexistentes) funcionan igual que en las pruebas
manuales previas, ahora con el backend orquestado por compose.

## Logs

**Backend** — sin `WARNING`/`ERROR`:

```
INFO:     Will watch for changes in these directories: ['/app']
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [1] using StatReload
INFO:     Started server process [22]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     127.0.0.1:39840 - "GET /health HTTP/1.1" 200 OK
INFO:     172.18.0.1:55028 - "GET /health HTTP/1.1" 200 OK
INFO:     127.0.0.1:40812 - "GET /health HTTP/1.1" 200 OK
INFO:     172.18.0.1:55282 - "POST /sesiones/ HTTP/1.1" 401 Unauthorized
```

**Frontend** — sin `WARNING`/`ERROR`:

```
  VITE v5.4.21  ready in 1733 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://172.18.0.4:5173/
```

## Ajustes aplicados

Ninguno. No hizo falta modificar `docker-compose.yml`, `docker-compose.dev.yml` ni `.env.dev`;
el trío levantó de punta a punta al primer intento.

## Veredicto

**Sí.** `docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev up --build -d`
levanta backend + frontend con un solo comando, conectándose correctamente a la red externa
`docker_default` y al contenedor `SGPMP` de la BD (sin definirlo en este compose), respeta el
`depends_on: condition: service_healthy` esperando a que el backend esté sano antes de arrancar
el frontend, y el `down` posterior limpia ambos contenedores sin tocar `SGPMP`.

## Pendientes / notas

- No bloqueante: en `.env.dev` (línea 32) el comentario dice que las variables `VITE_*` "se
  HORNEAN en el build (docker-compose las pasa como build args, no runtime)", pero eso describe
  el comportamiento del target `build`/`prod` del Dockerfile del frontend. En `dev`,
  `docker-compose.dev.yml` usa `build.target: dev` + `environment` (no `build.args`), y el
  Dockerfile del frontend confirma que en el target `dev` Vite sí lee `VITE_API_BASE_URL` en
  tiempo de ejecución — que es justo lo que se verificó en el paso 7. El comentario de
  `.env.dev` quedó desactualizado/es engañoso para quien lo lea aislado del compose, pero no
  afecta el funcionamiento. Sugerencia (no aplicada): aclarar en ese comentario que la
  "horneada en build" solo aplica a test/prod, no a dev.
- Sin hallazgos bloqueantes que requieran cambios en `sgpmp-backend` o `SGPMP-FRONT-END-PWA`.
