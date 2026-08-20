# Seguimiento técnico — HU-IMP-AMB-02
## Catálogo unificado de variables de entorno

**Rama de trabajo:** `feat/env-unificado`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-02 — Catálogo unificado de variables de entorno
**Estado:** ⏳ En progreso

---

# 1. Objetivo

Consolidar los archivos de ejemplo de variables de entorno de DEV, TEST y PROD en un catálogo coherente, completo y consistente para frontend, backend, JWT, gateway AIoT y MQTT.

Entregables esperados:

```text
env/.env.dev.example
env/.env.test.example
env/.env.prod.example
docs/VARIABLES-ENTORNO.md
FR-IMP-CE-04
```

---

# 2. Estado de subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Incorporar variables del frontend desde `origin/dev` | ✅ Completada |
| ST-02 | Incorporar variables MQTT y de seguridad | ✅ Completada |
| ST-03 | Reconciliar nombres de base de datos y puertos | ✅ Completada |
| ST-04 | Catálogo por sensibilidad, `FR-IMP-CE-04` y `docs/VARIABLES-ENTORNO.md` | ⏳ Pendiente |

---

# 3. Dependencia con HU-IMP-AMB-01

HU-02 se creó a partir de `feat/compose-base` porque HU-01 todavía está pendiente de revisión del Líder y no ha sido fusionada a `main`.

Antes del Pull Request definitivo de HU-02, la rama deberá reubicarse sobre el `main` que contenga HU-01 aprobada.

---

# 4. ST-01 — Contrato frontend

**Estado:** ✅ Completada

Se tomó como referencia `origin/dev` del repositorio `SGPMP-FRONT-END-PWA`.

No existe un `.env.example` versionado en esa rama. Por ello el contrato se reconstruyó a partir de:

```text
README.md
CLAUDE.md
src/
```

Variables confirmadas:

```text
VITE_AGROFUSION_LOGIN_URL
VITE_API_BASE_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_APP_ID
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_SW
VITE_VAPID_KEY
```

Cambios realizados:

```text
VITE_APP_ENV → eliminada
VITE_AGROFUSION_LOGIN_URL → agregada
VITE_SW → conservada
```

Los tres ambientes quedaron con el mismo contrato `VITE_*`.

Durante ST-02 también se completó el cableado del contrato `VITE_*` hacia el frontend DEV.

---

# 5. ST-02 — MQTT y seguridad

**Estado:** ✅ Completada

## 5.1 Gateway AIoT

Se revisaron:

```text
BROKER-MQTT-SGPMP-develop/app/config.py
BROKER-MQTT-SGPMP-develop/.env.example
```

Contrato MQTT confirmado:

```text
MQTT_HOST
MQTT_PORT
MQTT_USERNAME
MQTT_PASSWORD
MQTT_TLS
MQTT_CLIENT_ID
MQTT_RECONNECT_DELAY
MQTT_TOPIC_PREFIX
MQTT_TOPIC_TELEMETRY
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_COMMAND
MQTT_TOPIC_STATUS
```

También se confirmó:

```text
API_TOKEN
```

En infraestructura se utiliza:

```text
GATEWAY_API_TOKEN
```

y Compose traduce:

```text
GATEWAY_API_TOKEN → API_TOKEN
```

## 5.2 Backend / JWT

El backend utiliza realmente:

```text
SECRET_KEY
JWT_EXPIRE_HOURS
RF71_INTERNAL_KEY
```

Se eliminaron:

```text
JWT_SECRET_KEY
JWT_ALGORITHM
```

porque el algoritmo JWT está fijado en código como `HS256`.

Se incorporaron:

```text
SECRET_KEY=
JWT_EXPIRE_HOURS=24
RF71_INTERNAL_KEY=
```

## 5.3 TLS

```text
DEV  → MQTT_TLS=false
TEST → MQTT_TLS=false
PROD → MQTT_TLS=true
```

## 5.4 Cableado Compose

Se cablearon efectivamente las variables MQTT hacia el gateway y las variables JWT/seguridad hacia el backend.

Validaciones:

```text
DEV  → docker compose config --quiet OK
TEST → docker compose config --quiet OK
```

---

# 6. ST-03 — Reconciliación de nombres de BD y puertos

**Estado:** ✅ Completada

## 6.1 Problema identificado

Los `.env.*.example` originales utilizaban:

```text
APP_ENV
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_HOST_PORT
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
BACKEND_HOST
BACKEND_PORT
BACKEND_HOST_PORT
FRONTEND_HOST_PORT
GATEWAY_DATABASE_URL
```

mientras que la integración Compose ya utilizaba principalmente:

```text
DB_HOST
DB_PORT
DB_NAME
DB_ADMIN_USER
DB_APP_USER
DB_APP_PASSWORD
```

También existían discrepancias entre:

```text
postgres-dev / postgres-test
database

sgpmp_dev / sgpmp_test
dba

5432 / 5433

FRONTEND_HOST_PORT=5174
TEST real = 8081:80
```

---

# 7. Fuente oficial de base de datos

Se revisó `DBIntegrador-master/docker-compose.yml`.

Se confirmó:

```text
POSTGRES_USER=dba
puerto publicado host=5433
puerto interno PostgreSQL=5432
cron.database_name=dba
```

Por tanto, dentro del stack integrado la comunicación entre contenedores debe utilizar:

```text
database:5432
```

El puerto `5433` pertenece únicamente al acceso desde el host cuando DBIntegrador se ejecuta de forma independiente.

---

# 8. Convención unificada de base de datos

Los tres `.env.*.example` quedaron con:

```text
ENVIRONMENT
DB_HOST
DB_PORT
DB_NAME
DB_ADMIN_USER
DB_APP_USER
DB_APP_PASSWORD
DB_IOT_USER
DB_IOT_PASSWORD
DB_SCHEMA_INGEST
DB_SCHEMA_REGISTRY
```

Valores comunes:

```text
DB_HOST=database
DB_PORT=5432
DB_NAME=dba
DB_ADMIN_USER=dba
DB_SCHEMA_INGEST=modulo3
DB_SCHEMA_REGISTRY=modulo9
```

Los roles de aplicación y AIoT permanecen como placeholders:

```text
DB_APP_USER=
DB_APP_PASSWORD=
DB_IOT_USER=
DB_IOT_PASSWORD=
```

No se inventaron nombres de usuario ni contraseñas.

---

# 9. Normalización de ambiente

Se reemplazó:

```text
APP_ENV
```

por:

```text
ENVIRONMENT
```

Valores:

```text
DEV  → ENVIRONMENT=dev
TEST → ENVIRONMENT=test
PROD → ENVIRONMENT=prod
```

El backend actual utiliza internamente `ENV`, por lo que la adaptación se realiza en los overrides Compose cuando corresponde.

---

# 10. Eliminación de variables de puertos duplicadas

Se retiraron de los `.env.*.example`:

```text
BACKEND_HOST
BACKEND_PORT
BACKEND_HOST_PORT
FRONTEND_HOST_PORT
POSTGRES_HOST_PORT
```

Los puertos publicados quedan definidos exclusivamente en los overrides Compose.

Matriz real validada:

```text
DEV
backend    host 8000 → container 8000
frontend   host 5173 → container 5173
gateway    host 8002 → container 8000
mosquitto  host 1883 → container 1883
websocket  host 9001 → container 9001
```

```text
TEST
backend    host 8001 → container 8000
frontend   host 8081 → container 80
gateway    host 8003 → container 8000
mosquitto  host 1884 → container 1883
websocket  host 9002 → container 9001
```

La base de datos no publica puerto dentro de esta integración.

PROD no publica puertos directamente desde Compose.

---

# 11. Normalización de `DATABASE_URL`

Se eliminó:

```text
GATEWAY_DATABASE_URL
```

El backend construye su URL desde:

```text
DB_APP_USER
DB_APP_PASSWORD
DB_HOST
DB_PORT
DB_NAME
```

El gateway construye:

```text
postgresql+asyncpg://${DB_IOT_USER}:${DB_IOT_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
```

Con esto se evita mantener una URL completa duplicada en el catálogo.

---

# 12. Esquemas AIoT

Los esquemas dejaron de estar únicamente hardcodeados y pasaron al contrato de ambiente:

```text
DB_SCHEMA_INGEST=modulo3
DB_SCHEMA_REGISTRY=modulo9
```

Compose los suministra al gateway.

---

# 13. Validaciones de ST-03

## 13.1 Nomenclatura antigua

La búsqueda de:

```text
APP_ENV
POSTGRES_*
BACKEND_HOST
BACKEND_PORT
BACKEND_HOST_PORT
FRONTEND_HOST_PORT
GATEWAY_DATABASE_URL
```

en `env/.env.*.example` y `compose/` no produjo resultados.

## 13.2 Contrato común de BD

DEV, TEST y PROD contienen exactamente:

```text
ENVIRONMENT
DB_HOST
DB_PORT
DB_NAME
DB_ADMIN_USER
DB_APP_USER
DB_APP_PASSWORD
DB_IOT_USER
DB_IOT_PASSWORD
DB_SCHEMA_INGEST
DB_SCHEMA_REGISTRY
```

## 13.3 `GATEWAY_DATABASE_URL`

No se encontraron referencias restantes.

## 13.4 Gateway

Se confirmó en los tres overrides:

```text
DATABASE_URL: postgresql+asyncpg://${DB_IOT_USER}:${DB_IOT_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
```

## 13.5 Sintaxis

```text
DEV  → docker compose config --quiet OK
TEST → docker compose config --quiet OK
```

---

# 14. Estado actual de HU-IMP-AMB-02

```text
HU-IMP-AMB-02
├── ST-01 ✅ Frontend
├── ST-02 ✅ MQTT / seguridad
├── ST-03 ✅ BD / nombres / puertos
└── ST-04 ⏳ Catálogo / sensibilidad / FR-IMP-CE-04
```

La siguiente actividad corresponde a ST-04, donde se construirá el catálogo formal de variables, su clasificación por tipo y sensibilidad, `docs/VARIABLES-ENTORNO.md` y el artefacto `FR-IMP-CE-04`.
