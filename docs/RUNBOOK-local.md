# Runbook — Levantar el ecosistema SGPMP en local

Hay dos formas de levantar el trío **Base de Datos + Backend + Frontend**: con **docker compose**
(un solo comando, recomendado) o **a mano** (paso a paso, útil para diagnóstico o para trabajar
con hot-reload de Python/Vite fuera de contenedores). Ambas están probadas y documentadas.

> Rutas de ejemplo con el workspace en `d:/USER/Documentos/Proyectos/PI4`. Ajusta a la tuya.

---

## 0. Requisitos (una sola vez)

- **Docker Desktop** instalado.
- Los 4 repos clonados **como hermanos**, en la misma carpeta padre: `docuemntacionDB`,
  `sgpmp-backend` (rama `dev`), `SGPMP-FRONT-END-PWA` (rama `dev`), `SGMP-Integracion`.
- Los `Dockerfile`/`.dockerignore`/`nginx.conf` colocados en `sgpmp-backend/` y
  `SGPMP-FRONT-END-PWA/` (ver `docs/dockerFiles/` en `SGMP-Integracion` mientras se fusionan
  los PR oficiales a esos repos).
- Los archivos `.env.dev` / `.env.test` / `.env.prod` en la **raíz** de `SGMP-Integracion`
  (no se suben a Git — pide los valores reales si no los tienes; `.env.example` documenta qué
  variables existen).
- Para la Opción B además: Node ≥ 18 + pnpm (`corepack enable`), y Python 3.12 con el venv del
  backend ya creado (`sgpmp-backend/.venv`).

---

## 1. Liberar el puerto 5433

El contenedor de BD publica el **5433**. Si tienes PostgreSQL instalado en Windows, ocupa ese
puerto y el contenedor no levanta. Detén los servicios locales desde **PowerShell como
administrador**:

```powershell
Stop-Service -Name "postgresql-x64-16"
Stop-Service -Name "postgresql-x64-18"
netstat -ano | findstr :5433    # no debe devolver nada
```

> Al terminar la jornada puedes volver a levantarlos con `Start-Service` si los necesitas para
> otra cosa. Repite este chequeo si reiniciaste Windows — suelen re-arrancar solos.

## 2. Arrancar Docker Desktop

Ábrelo y espera a que el ícono quede en estado **running** antes de seguir.

## 3. Base de datos (siempre, en ambas opciones)

Hay dos modos: **reset limpio** (recrea la BD desde el dump) o **retomar** (reusa la que ya
restauraste). El compose de Implementación **no** define un servicio de BD — se conecta al
contenedor del DBA ya corriendo, así que este paso es previo y obligatorio en cualquier caso.

### 3a. Primera vez / reset limpio

Desde la **raíz del workspace** (para que el script encuentre `./docuemntacionDB`):

```bash
cd /d/USER/Documentos/Proyectos/PI4
bash SGMP-Integracion/scripts/restaurar-bd.sh
```

### 3b. Retomar (ya lo habías restaurado antes)

```bash
docker start SGPMP
docker ps                # confirma que SGPMP está Up en 0.0.0.0:5433->5432
```

> El script del 3a **borra y recrea** la BD cada vez (hace `down -v`). Úsalo solo cuando quieras
> empezar de cero; para el día a día, `docker start SGPMP` es más rápido.

---

## Opción A — con docker compose (recomendado)

Un solo comando levanta backend + frontend juntos, conectados a la BD del paso 3.

```bash
cd /d/USER/Documentos/Proyectos/PI4/SGMP-Integracion
docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev up --build -d
```

Verificar que ambos quedaron sanos:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev ps
curl http://localhost:8000/health   # -> {"status":"ok",...}
curl -i http://localhost:5173/      # -> 200, HTML de Vite
```

Abre **`http://localhost:5173`** en el navegador (usa `localhost`, no `127.0.0.1` — Vite escucha
solo en IPv6). Debe cargar el login; un intento de inicio de sesión dispara un `POST /sesiones/`
que responde 401 — confirma la cadena completa front → backend → BD.

**Apagar** (conserva la BD y sus datos, solo baja backend/frontend):

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev down
```

> Para `test` (cuando `.env.test` tenga valores reales, no placeholders), el mismo patrón con
> `docker-compose.test.yml` y `--env-file .env.test`. `prod` es andamiaje — no pensado para
> encenderse todavía.

---

## Opción B — a mano, paso a paso (diagnóstico / hot-reload sin Docker)

Útil cuando algo falla dentro de un contenedor y quieres aislar la causa, o si prefieres editar
Python/TypeScript con recarga nativa fuera de Docker.

### B.1 Backend

```bash
cd /d/USER/Documentos/Proyectos/PI4/sgpmp-backend
git checkout dev
source .venv/Scripts/activate      # verás (.venv) en el prompt
```

Asegúrate de que exista `sgpmp-backend/.env` con:

```bash
DATABASE_URL=postgresql://dba:dev123@localhost:5433/dba
SECRET_KEY=dev-only-not-for-production
FRONTEND_URL=http://localhost:5173
```

```bash
python main.py                     # uvicorn en http://localhost:8000, no cierres esta terminal
```

### B.2 Frontend

En **otra** terminal (deja backend y BD corriendo):

```bash
cd /d/USER/Documentos/Proyectos/PI4/SGPMP-FRONT-END-PWA
git checkout dev
```

Asegúrate de que exista `.env` con `VITE_API_BASE_URL=http://localhost:8000` y las variables
`VITE_FIREBASE_*` / `VITE_VAPID_KEY` vacías.

```bash
pnpm install                       # solo la primera vez
pnpm dev                           # Vite en http://localhost:5173, no cierres esta terminal
```

### B.3 Verificar y apagar

Misma verificación del navegador que en la Opción A. Para apagar: `Ctrl+C` en cada terminal, y
`docker stop SGPMP` para la BD.

---

## Solución de problemas

- **El contenedor de BD no levanta / puerto ocupado:** repite el paso 1.
- **`docker compose up` falla con "network docker_default ... not found":** la BD no está
  corriendo — repite el paso 3 antes de reintentar.
- **`did not match any files` al hacer `git add`:** el archivo no está en la ruta indicada;
  verifícalo con `ls`.
- **Un `.sh` "no ejecuta" o da error raro con `$'\r'`:** quedó en CRLF. Arréglalo con
  `sed -i 's/\r$//' <archivo>`.
- **`python` no encontrado o venv raro (Opción B):** confirma que el prompt muestra `(.venv)`;
  si no, `source .venv/Scripts/activate`.
- **La app no responde en `127.0.0.1:5173`:** normal — usa `localhost:5173`.
- **Error de CORS:** el backend solo permite `http://localhost:5173`. Si Vite arrancó en otro
  puerto, ajústalo o libera el 5173.
- **Backend conecta pero como `dba`:** es lo previsto por ahora; el cambio a `backend_dev` queda
  pendiente de confirmar permisos con el DBA.
