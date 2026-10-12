# Seguimiento técnico — HU-IMP-AMB-02
## Catálogo unificado de variables de entorno

**Rama de trabajo:** `feat/env-unificado`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-02 —Catálogo unificado de variables de entorno
**Estado:** ✅ Completada técnicamente — pendiente de commit final y revisión

---

# 1. Objetivo

Construir un catálogo unificado de variables de entorno para DEV, TEST y PROD, cubriendo frontend, backend, JWT, PostgreSQL, gateway AIoT y MQTT; resolver discrepancias de nomenclatura y puertos; clasificar cada variable por función y sensibilidad; y producir los documentos de cierre.

---

# 2. Estado de subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Incorporar variables del frontend desde `origin/dev` | ✅ Completada |
| ST-02 | Incorporar variables MQTT y de seguridad | ✅ Completada |
| ST-03 | Reconciliar nombres de base de datos y puertos | ✅ Completada |
| ST-04 | Catálogo por sensibilidad, `FR-IMP-CE-04` y `docs/VARIABLES-ENTORNO.md` | ✅ Completada |

---

# 3. Historial de commits previos

```text
15c84cc feat(env): incorpora contrato frontend en ejemplos
2c8e482 feat(env): integra seguridad y contrato mqtt
1b88d21 feat(env): unifica nombres de bd y puertos
```

HU-02 se creó temporalmente a partir de `feat/compose-base` debido a que HU-01 todavía debía ser revisada antes de fusionarse a `main`.

---

# 4. ST-01 — Frontend

Se comprobó `origin/dev` del repositorio frontend.

No existía `.env.example` versionado, por lo que el contrato se reconstruyó desde código y documentación.

Resultado:

```text
VITE_API_BASE_URL
VITE_SW
VITE_AGROFUSION_LOGIN_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_APP_ID
VITE_VAPID_KEY
```

Se eliminó:

```text
VITE_APP_ENV
```

y se agregó:

```text
VITE_AGROFUSION_LOGIN_URL
```

Los tres ambientes quedaron con el mismo contrato frontend.

---

# 5. ST-02 — MQTT y seguridad

Se revisó el contrato real del gateway AIoT y del backend.

Se incorporaron:

```text
SECRET_KEY
JWT_EXPIRE_HOURS
RF71_INTERNAL_KEY
GATEWAY_API_TOKEN
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

Se eliminaron:

```text
JWT_SECRET_KEY
JWT_ALGORITHM
```

porque el backend usa `SECRET_KEY`, `JWT_EXPIRE_HOURS` y fija `HS256` en código.

Las variables fueron cableadas realmente en Docker Compose.

Validaciones:

```text
DEV  MQTT_TLS=false
TEST MQTT_TLS=false
PROD MQTT_TLS=true

DEV  docker compose config --quiet OK
TEST docker compose config --quiet OK
```

---

# 6. ST-03 — BD, nombres y puertos

Se revisó DBIntegrador y se confirmó:

```text
usuario administrador = dba
base integrada = dba
puerto interno = 5432
puerto 5433 = publicación del Compose independiente
```

Se eliminó la nomenclatura:

```text
APP_ENV
POSTGRES_*
BACKEND_HOST
BACKEND_PORT
BACKEND_HOST_PORT
FRONTEND_HOST_PORT
GATEWAY_DATABASE_URL
```

Se adoptó:

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

Los tres ambientes utilizan:

```text
DB_HOST=database
DB_PORT=5432
DB_NAME=dba
DB_ADMIN_USER=dba
```

No se inventaron roles de aplicación o AIoT.

El gateway construye su `DATABASE_URL` desde `DB_IOT_*`, y el backend desde `DB_APP_*`.

La matriz real de puertos host quedó controlada por los overrides Compose y no por los `.env.*.example`.

---

# 7. ST-04 — Inventario final

Se ejecutó un inventario de:

1. nombres presentes en los tres `.env.*.example`;
2. variables de entorno realmente consumidas por backend;
3. variables interpoladas por Docker Compose;
4. consistencia de nombres entre DEV, TEST y PROD.

Se comprobó que el backend realmente consume:

```text
DATABASE_URL
ENV
FIREBASE_CREDENTIALS_PATH
FRONTEND_URL
JWT_EXPIRE_HOURS
MODELOS_STORAGE_PATH
RF71_INTERNAL_KEY
SECRET_KEY
SMTP_HOST
SMTP_PASSWORD
SMTP_PORT
SMTP_USER
```

No se encontró una segunda capa `BaseSettings` en backend que introdujera variables adicionales.

---

# 8. Ajustes finales de ST-04

Se retiraron:

```text
DEBUG
LOG_LEVEL
```

porque no son consumidas actualmente como variables de entorno.

Se incorporaron:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE

FRONTEND_URL
FIREBASE_CREDENTIALS_PATH
SMTP_HOST
SMTP_PORT
SMTP_USER
SMTP_PASSWORD
MODELOS_STORAGE_PATH
```

Las variables backend fueron cableadas en DEV, TEST y PROD.

No se incorporaron automáticamente variables obsoletas o no consumidas del `.env.example` histórico del backend.

---

# 9. Validaciones finales

## 9.1 Mismo contrato entre ambientes

Resultado:

```text
DEV vs TEST → sin diferencias
DEV vs PROD → sin diferencias
```

## 9.2 Compose frente al catálogo

Se compararon todas las variables `${...}` de `compose/` frente al catálogo de `env/.env.dev.example`.

Resultado:

```text
Variables requeridas por Compose pero ausentes del catálogo → ninguna
```

## 9.3 Variables eliminadas

La búsqueda de:

```text
DEBUG
LOG_LEVEL
```

en los `.env.*.example` no produjo resultados.

## 9.4 Variables backend nuevas

Se confirmó la presencia en los tres ambientes de:

```text
FRONTEND_URL
FIREBASE_CREDENTIALS_PATH
SMTP_HOST
SMTP_PORT
SMTP_USER
SMTP_PASSWORD
MODELOS_STORAGE_PATH
```

## 9.5 Cableado Compose

Se confirmó que:

```text
FIREBASE_CREDENTIALS_PATH
SMTP_HOST
SMTP_PORT
SMTP_USER
SMTP_PASSWORD
MODELOS_STORAGE_PATH
```

son suministradas al backend en DEV, TEST y PROD.

## 9.6 Validación de sintaxis

```text
DEV  → docker compose config --quiet OK
TEST → docker compose config --quiet OK
```

---

# 10. Documentos producidos

ST-04 produce:

```text
docs/VARIABLES-ENTORNO.md
docs/FR-IMP-CE-04.md
docs/SEGUIMIENTO-HU-IMP-AMB-02.md
```

`VARIABLES-ENTORNO.md` documenta el contrato técnico completo.

`FR-IMP-CE-04.md` registra formalmente la clasificación de variables por:

```text
Conexión
Comportamiento
Autenticación / Seguridad
AIoT / Analítica
```

y por sensibilidad:

```text
No sensible
Interna
Secreta
```

---

# 11. Estado de criterios de aceptación

| Criterio | Estado |
|---|---|
| Tres `.env.*.example` completos y consistentes para backend, frontend, JWT y MQTT | ✅ |
| Cada variable clasificada por tipo y sensibilidad | ✅ |
| Discrepancias de nombre de BD y puerto resueltas | ✅ |
| `FR-IMP-CE-04` producido | ✅ |
| `docs/VARIABLES-ENTORNO.md` producido | ✅ |
| Secretos reales excluidos del repositorio | ✅ |

---

# 12. Dependencias pendientes externas a HU-02

HU-02 define el contrato, pero los siguientes valores siguen dependiendo de otras entregas:

```text
DB_APP_USER
DB_APP_PASSWORD
DB_IOT_USER
DB_IOT_PASSWORD

DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE

FRONTEND_URL de PROD
VITE_API_BASE_URL de PROD
VITE_AGROFUSION_LOGIN_URL definitiva

MQTT_HOST de PROD
MQTT_PORT de PROD
credenciales MQTT de PROD

archivo real apuntado por FIREBASE_CREDENTIALS_PATH
```

Estos pendientes no impiden cerrar HU-02 porque el contrato de variables ya está definido y validado.

---

# 13. Estado final

```text
HU-IMP-AMB-02
├── ST-01 ✅
├── ST-02 ✅
├── ST-03 ✅
└── ST-04 ✅
```

**Estado técnico:** completada.

Antes del Pull Request definitivo debe mantenerse la coordinación con HU-01: la rama `feat/env-unificado` fue creada sobre `feat/compose-base`, por lo que deberá revisarse su base cuando HU-01 sea aprobada/fusionada.
