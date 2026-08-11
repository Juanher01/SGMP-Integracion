# Runbook — Levantar el ecosistema SGPMP en local

Guía paso a paso para levantar el trío **Base de Datos → Backend → Frontend** en una máquina Windows (Git Bash). El orden importa: cada capa depende de la anterior.

> Rutas de ejemplo con el workspace en `d:/USER/Documentos/Proyectos/PI4`. Ajusta a la tuya.

---

## 0. Requisitos (una sola vez)

- **Docker Desktop** instalado.
- **Node ≥ 18** y **pnpm** (`corepack enable`).
- **Python 3.12** con el venv del backend ya creado (`sgpmp-backend/.venv`).
- Los 4 repos clonados en el workspace: `docuemntacionDB`, `sgpmp-backend` (rama `dev`), `SGPMP-FRONT-END-PWA` (rama `dev`), `SGMP-Integracion`.
- Los `.env` creados (ver pasos 3 y 4). Van en LF y están en `.gitignore`.

---

## 1. Liberar el puerto 5433

El contenedor de BD publica el **5433**. Si tienes PostgreSQL instalado en Windows, ocupa ese puerto y el contenedor no levanta. Detén los servicios locales desde **PowerShell como administrador**:

```powershell
Stop-Service -Name "postgresql-x64-16"
Stop-Service -Name "postgresql-x64-18"
netstat -ano | findstr :5433    # no debe devolver nada
```

> Al terminar la jornada puedes volver a levantarlos con `Start-Service` si los necesitas para otra cosa.

---

## 2. Arrancar Docker Desktop

Ábrelo y espera a que el ícono quede en estado **running** antes de seguir.

---

## 3. Base de datos

Hay dos modos: **reset limpio** (recrea la BD desde el dump) o **retomar** (reusa la que ya restauraste).

### 3a. Primera vez / reset limpio

Desde la **raíz del workspace** (para que el script encuentre `./docuemntacionDB`):

```bash
cd /d/USER/Documentos/Proyectos/PI4
bash SGMP-Integracion/scripts/restaurar-bd.sh
```

El script levanta el contenedor `SGPMP` (PostgreSQL 17.10 + pg_cron + roles), restaura el dump y verifica. Al final imprime el conteo de tablas por esquema y las cadenas de conexión.

### 3b. Retomar (ya lo habías restaurado antes)

Si el contenedor ya existe (tras un reinicio, por ejemplo), no hace falta rehacer todo — solo arráncalo, conserva sus datos:

```bash
docker start SGPMP
docker ps                # confirma que SGPMP está Up en 0.0.0.0:5433->5432
```

> El script del 3a **borra y recrea** la BD cada vez (hace `down -v`). Úsalo solo cuando quieras empezar de cero; para el día a día, `docker start SGPMP` es más rápido.

---

## 4. Backend

En una terminal Git Bash:

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

Levanta el servidor (queda corriendo; **no cierres esta terminal**):

```bash
python main.py                     # uvicorn en http://localhost:8000
```

Verifica en otra terminal:

```bash
curl http://localhost:8000/health  # -> {"status":"ok",...}
```

---

## 5. Frontend

En **otra** terminal Git Bash (deja backend y BD corriendo):

```bash
cd /d/USER/Documentos/Proyectos/PI4/SGPMP-FRONT-END-PWA
git checkout dev
```

Asegúrate de que exista `.env` con `VITE_API_BASE_URL=http://localhost:8000` y las variables `VITE_FIREBASE_*` / `VITE_VAPID_KEY` vacías.

Instala dependencias **solo la primera vez** (tarda; descarga Cypress y compañía):

```bash
pnpm install
```

Levanta el servidor de desarrollo (queda corriendo; **no cierres esta terminal**):

```bash
pnpm dev                           # Vite en http://localhost:5173
```

---

## 6. Verificar el trío

1. Abre en el navegador **`http://localhost:5173`** — usa `localhost`, **no** `127.0.0.1` (Vite escucha solo en IPv6; y el CORS del backend está puesto sobre `localhost`).
2. Debe cargar la pantalla de **login**.
3. Abre DevTools (F12) → **Network**, intenta iniciar sesión con cualquier dato: verás un `POST /sesiones/` hacia `:8000` que responde **401** (credenciales inválidas). Ese 401 confirma la cadena completa **front → backend → BD**.

---

## 7. Apagar

```bash
# En la terminal del frontend:   Ctrl+C
# En la terminal del backend:    Ctrl+C
docker stop SGPMP                  # detiene la BD (conserva los datos)
```

> `docker stop` conserva el contenedor y su volumen, así que la próxima vez retomas con el paso **3b**. Solo usa el script (3a) si quieres una BD limpia.

---

## Solución de problemas

- **El contenedor no levanta / puerto ocupado:** repite el paso 1 (los PostgreSQL locales suelen re-arrancar solos tras un reinicio de Windows).
- **`did not match any files` al hacer `git add`:** el archivo no está en la ruta indicada; verifícalo con `ls`.
- **Un `.sh` "no ejecuta" o da error raro con `$'\r'`:** quedó en CRLF. Arréglalo con `sed -i 's/\r$//' <archivo>`.
- **`python` no encontrado o venv raro:** confirma que el prompt muestra `(.venv)`; si no, `source .venv/Scripts/activate`.
- **La app no responde en `127.0.0.1:5173`:** normal — usa `localhost:5173`.
- **Error de CORS:** el backend solo permite `http://localhost:5173`. Si Vite arrancó en otro puerto, ajústalo o libera el 5173.
- **Backend conecta pero como `dba`:** es lo previsto por ahora; el cambio a `backend_dev` queda pendiente de confirmar permisos con el DBA.
