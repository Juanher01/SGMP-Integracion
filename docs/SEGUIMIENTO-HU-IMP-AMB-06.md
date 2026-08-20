# Seguimiento técnico — HU-IMP-AMB-06
## Montaje del ambiente DEV

**Rama:** `feat/ambiente-dev`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-06 — Montaje del ambiente DEV
**Estado:** ⏳ En progreso

---

# 1. Objetivo

Montar y validar el ambiente DEV de extremo a extremo utilizando las definiciones de HU-01 y HU-02 e integrando posteriormente las capas entregadas por HU-04 (base de datos) y HU-05 (AIoT).

Si una dependencia externa impide continuar, se documentará el punto exacto, la evidencia y la razón del bloqueo.

---

# 2. Dependencias

```text
HU-01 — Compose base
HU-02 — Catálogo unificado de variables
HU-04 — Restauración / capa de base de datos
HU-05 — Capa AIoT / gateway / broker
```

Estado conocido:

```text
HU-01 → feat/compose-base, publicada y pendiente de revisión/merge
HU-02 → feat/env-unificado, publicada y pendiente de revisión/merge
HU-04 → feat/db-restauracion-dbintegrador, completada técnicamente y publicada
HU-05 → pendiente de confirmar para integración final
```

HU-06 se creó desde `feat/env-unificado` para conservar temporalmente la dependencia:

```text
main
  └── feat/compose-base
       └── feat/env-unificado
            └── feat/ambiente-dev
```

---

# 3. Estado de subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Build local de backend/frontend con configuración DEV | ✅ Completada |
| ST-02 | Integrar capa BD de HU-04 y capa AIoT de HU-05 | ⏳ En preparación |
| ST-03 | Verificación integral, healthchecks y evidencias | ⏳ Pendiente |

---

# 4. ST-01 — Build local DEV

**Estado:** ✅ Completada

## 4.1 Prechequeo

Se confirmó:

```text
Rama activa: feat/ambiente-dev
Working tree: clean
```

Estructura Compose:

```text
compose/
├── docker-compose.yml
├── compose.dev.yml
├── compose.test.yml
└── compose.prod.yml
```

Dockerfiles disponibles:

```text
dockerfiles/backend/Dockerfile
dockerfiles/frontend/Dockerfile
dockerfiles/frontend/nginx.conf
```

La resolución DEV fue validada mediante:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --quiet
```

Resultado:

```text
Sin errores
```

Servicios reconocidos:

```text
database
backend
frontend
mosquitto
gateway
```

---

# 5. Build backend

Se ejecutó:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   build backend
```

Resultado:

```text
Image sgpmp-dev-backend Built
```

Imagen confirmada:

```text
sgpmp-dev-backend:latest
sha256:08fa8acab0a932d2c3810b1c421bd23d4de873aaa6b3dfce8a30811142df7dc6
```

El build utilizó:

```text
python:3.12-slim
```

y finalizó correctamente.

---

# 6. Build frontend

Se ejecutó:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   build frontend
```

Resultado:

```text
Image sgpmp-dev-frontend Built
```

Imagen confirmada:

```text
sgpmp-dev-frontend:latest
sha256:2755c3e39f126fbd40aa64476ddb956882f1e61c69504157bd29ed681697eaff
```

El build utilizó:

```text
node:22-slim
```

y finalizó correctamente.

---

# 7. Hallazgo — archivos `.env.dev` duplicados

Se detectaron dos archivos locales ignorados por Git:

```text
./.env.dev
env/.env.dev
```

Ninguno está versionado.

`git check-ignore` confirmó que ambos están cubiertos por:

```text
.gitignore → .env.dev
```

El archivo:

```text
./.env.dev
```

es el archivo actualizado utilizado actualmente por los comandos:

```bash
--env-file .env.dev
```

Este contiene el contrato nuevo construido en HU-02:

```text
ENVIRONMENT
DB_*
SECRET_KEY
JWT_EXPIRE_HOURS
RF71_INTERNAL_KEY
VITE_*
GATEWAY_API_TOKEN
MQTT_*
SMTP_*
FIREBASE_CREDENTIALS_PATH
MODELOS_STORAGE_PATH
...
```

El archivo:

```text
env/.env.dev
```

corresponde a una versión anterior y conserva nomenclatura obsoleta:

```text
APP_ENV
POSTGRES_*
JWT_SECRET_KEY
JWT_ALGORITHM
VITE_APP_ENV
BACKEND_HOST_PORT
FRONTEND_HOST_PORT
DEBUG
LOG_LEVEL
```

### Convención adoptada para HU-06

```text
./.env.dev             → configuración real local de DEV
env/.env.dev.example   → plantilla versionada
```

`env/.env.dev` se considera una copia local obsoleta y no debe utilizarse para ejecutar el ambiente.

---

# 8. Resultado ST-01

```text
Backend build local  → ✅
Frontend build local → ✅
Compose DEV válido   → ✅
Contrato .env usado  → ✅ ./ .env.dev
```

ST-01 queda completada sin necesidad todavía de integrar HU-04 o HU-05.

---

# 9. Preparación de ST-02

HU-04 está disponible en:

```text
feat/db-restauracion-dbintegrador
```

La entrega reporta:

```text
PostgreSQL 18
base dba
usuario dba
puerto host 5433
backup7_1_0.dump
roles restaurados
pg_cron habilitado
```

Existe una diferencia arquitectónica pendiente de reconciliación:

### HU-01/HU-02

```text
Compose contiene servicio database
backend/gateway → database:5432
```

### HU-04

```text
DBIntegrador se restaura como capa separada
backend → host.docker.internal:5433
```

No se hará merge completo de HU-04 sobre HU-06 porque ambas ramas fueron desarrolladas en paralelo y HU-04 modifica archivos `.env.*.example` que HU-02 ya normalizó.

El siguiente paso será probar la entrega HU-04 de forma aislada y determinar cómo debe consumirse desde DEV sin reintroducir configuraciones obsoletas.

---

# 10. Estado actual

```text
HU-IMP-AMB-06
├── ST-01 ✅ Build local DEV
├── ST-02 ⏳ Integración BD / AIoT
└── ST-03 ⏳ Verificación integral
```
