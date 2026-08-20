# Seguimiento técnico — HU-IMP-AMB-02
## Catálogo unificado de variables de entorno

**Responsable:** Juan Esteban Hernández Lozano
**Rama de trabajo:** `feat/env-unificado`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-02 — Catálogo unificado de variables de entorno
**Estado:** ⏳ En progreso

---

# 1. Objetivo

Consolidar los archivos de ejemplo de variables de entorno de DEV, TEST y PROD en un catálogo coherente, completo y consistente para frontend, backend, JWT, gateway AIoT y MQTT.

Entregables esperados de la HU:

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
| ST-03 | Reconciliar nombres de base de datos y puertos | ⏳ Pendiente |
| ST-04 | Catálogo por sensibilidad, `FR-IMP-CE-04` y `docs/VARIABLES-ENTORNO.md` | ⏳ Pendiente |

---

# 3. Dependencia con HU-IMP-AMB-01

HU-02 se creó a partir de `feat/compose-base` porque HU-01 todavía está pendiente de revisión del Líder y no ha sido fusionada a `main`.

Antes del Pull Request definitivo de HU-02, la rama deberá reubicarse sobre el `main` que contenga HU-01 aprobada.

---

# 4. Inventario inicial de archivos de ambiente

Se encontraron:

```text
env/.env.dev
env/.env.dev.example
env/.env.test
env/.env.test.example
env/.env.prod
env/.env.prod.example
```

Los archivos reales no están versionados.

`git ls-files` confirmó que solo están bajo control de versiones:

```text
env/.env.dev.example
env/.env.prod.example
env/.env.test.example
```

`git check-ignore` confirmó que:

```text
env/.env.dev
env/.env.test
env/.env.prod
```

están protegidos por `.gitignore`.

---

# 5. ST-01 — Contrato del frontend

**Estado:** ✅ Completada

## 5.1 Fuente utilizada

Se tomó como referencia `origin/dev` del repositorio `SGPMP-FRONT-END-PWA`.

No existe un `.env.example` versionado en esa rama. Por ello el contrato se reconstruyó a partir de:

```text
README.md
CLAUDE.md
src/
```

## 5.2 Variables frontend confirmadas

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

## 5.3 Cambios realizados

Se eliminó de los tres `.env.*.example`:

```text
VITE_APP_ENV
```

porque no apareció en código ni documentación actual de `origin/dev`.

Se agregó:

```text
VITE_AGROFUSION_LOGIN_URL=
```

porque `src/auth/pages/LoginPage.tsx` la consume mediante `import.meta.env.VITE_AGROFUSION_LOGIN_URL`.

Se conservó:

```text
VITE_SW
```

porque está documentada para controlar el Service Worker.

Valores conservados:

```text
DEV  → false
TEST → false
PROD → true
```

## 5.4 Validaciones

`VITE_APP_ENV`:

```text
Sin resultados
```

`VITE_AGROFUSION_LOGIN_URL`:

```text
Presente en DEV
Presente en TEST
Presente en PROD
```

Los tres archivos quedaron con el mismo conjunto de variables `VITE_*`.

## 5.5 Ajuste complementario posterior

Durante ST-02 se detectó que DEV solo inyectaba `VITE_API_BASE_URL` al contenedor frontend.

Se amplió `compose/compose.dev.yml` para suministrar también el resto del contrato `VITE_*` necesario durante la ejecución de Vite en DEV:

```text
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

Este cambio se documenta como complemento de ST-01 porque garantiza que las variables ya inventariadas puedan llegar efectivamente al frontend DEV.

---

# 6. ST-02 — MQTT y seguridad

**Estado:** ✅ Completada

## 6.1 Fuente AIoT utilizada

Se revisaron:

```text
BROKER-MQTT-SGPMP-develop/app/config.py
BROKER-MQTT-SGPMP-develop/.env.example
```

El gateway utiliza Pydantic Settings y declara el siguiente contrato.

### Base de datos / esquemas

```text
DATABASE_URL
DB_SCHEMA_INGEST
DB_SCHEMA_REGISTRY
```

### Broker MQTT

```text
MQTT_HOST
MQTT_PORT
MQTT_USERNAME
MQTT_PASSWORD
MQTT_TLS
MQTT_CLIENT_ID
MQTT_RECONNECT_DELAY
```

### Topics MQTT

```text
MQTT_TOPIC_PREFIX
MQTT_TOPIC_TELEMETRY
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_COMMAND
MQTT_TOPIC_STATUS
```

### API del gateway

```text
API_TOKEN
API_HOST
API_PORT
```

Las variables de BD, esquemas y puertos se reservan para ST-03 cuando corresponda.

---

# 7. Contrato MQTT incorporado

Los tres `.env.*.example` incorporaron:

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

Valores base de DEV y TEST:

```text
MQTT_HOST=mosquitto
MQTT_PORT=1883
MQTT_TLS=false
MQTT_CLIENT_ID=sgpmp
MQTT_RECONNECT_DELAY=5
MQTT_TOPIC_PREFIX=sgpmp
MQTT_TOPIC_TELEMETRY=telemetry
MQTT_TOPIC_HEARTBEAT=heartbeat
MQTT_TOPIC_COMMAND=command
MQTT_TOPIC_STATUS=status
```

En PROD:

```text
MQTT_TLS=true
```

`MQTT_HOST` y `MQTT_PORT` se mantienen como placeholders pendientes del contrato definitivo de producción con AIoT/Despliegue.

No se registran credenciales reales en los `.example`.

---

# 8. Token de seguridad del gateway

El gateway espera internamente:

```text
API_TOKEN
```

La infraestructura utiliza el nombre externo:

```text
GATEWAY_API_TOKEN
```

y Compose realiza la traducción:

```text
GATEWAY_API_TOKEN → API_TOKEN
```

Esto evita usar un nombre genérico de token fuera del contenedor.

Los tres `.env.*.example` contienen:

```text
GATEWAY_API_TOKEN=
```

sin valor real.

---

# 9. JWT y seguridad del backend

Se revisó `src/shared/jwt.py`.

El backend utiliza realmente:

```text
SECRET_KEY
JWT_EXPIRE_HOURS
```

El algoritmo no proviene del entorno. Está fijado en código:

```text
HS256
```

Por ello se eliminaron de los tres `.env.*.example`:

```text
JWT_SECRET_KEY
JWT_ALGORITHM
```

y se incorporaron:

```text
SECRET_KEY=
JWT_EXPIRE_HOURS=24
```

El valor `24` corresponde al default actual del código.

También se confirmó el uso real de:

```text
RF71_INTERNAL_KEY
```

para validación del header interno `X-RF71-Internal-Key`.

Se agregó:

```text
RF71_INTERNAL_KEY=
```

sin valor real.

---

# 10. Cableado efectivo en Docker Compose

No se dejó el catálogo únicamente como documentación.

## 10.1 Gateway

`compose/docker-compose.yml` fue ajustado para pasar al gateway:

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

`MQTT_TLS` dejó de estar hardcodeado en los overrides TEST y PROD y pasa a resolverse desde el archivo de ambiente.

## 10.2 Backend

Los overrides DEV, TEST y PROD pasan al backend:

```text
SECRET_KEY
JWT_EXPIRE_HOURS
RF71_INTERNAL_KEY
```

además de sus variables ya existentes.

---

# 11. Validaciones de ST-02

## 11.1 JWT antiguo eliminado

La búsqueda de:

```text
JWT_SECRET_KEY
JWT_ALGORITHM
```

en los tres `.env.*.example` no produjo resultados.

## 11.2 Seguridad nueva

Se confirmó la presencia de:

```text
SECRET_KEY
JWT_EXPIRE_HOURS
RF71_INTERNAL_KEY
GATEWAY_API_TOKEN
```

en DEV, TEST y PROD.

## 11.3 Contrato MQTT

Los tres ambientes contienen exactamente:

```text
MQTT_CLIENT_ID
MQTT_HOST
MQTT_PASSWORD
MQTT_PORT
MQTT_RECONNECT_DELAY
MQTT_TLS
MQTT_TOPIC_COMMAND
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_PREFIX
MQTT_TOPIC_STATUS
MQTT_TOPIC_TELEMETRY
MQTT_USERNAME
```

## 11.4 TLS por ambiente

```text
DEV  → MQTT_TLS=false
TEST → MQTT_TLS=false
PROD → MQTT_TLS=true
```

## 11.5 Gateway DEV resuelto

Docker Compose resolvió:

```text
MQTT_HOST=mosquitto
MQTT_PORT=1883
MQTT_RECONNECT_DELAY=5
MQTT_TLS=false
MQTT_TOPIC_COMMAND=command
MQTT_TOPIC_HEARTBEAT=heartbeat
MQTT_TOPIC_PREFIX=sgpmp
MQTT_TOPIC_STATUS=status
MQTT_TOPIC_TELEMETRY=telemetry
```

Las credenciales vacías de DEV se mantuvieron como cadenas vacías, de acuerdo con la configuración anónima actual del broker local.

## 11.6 Backend DEV resuelto

Se confirmó:

```text
JWT_EXPIRE_HOURS=24
```

y la presencia de `RF71_INTERNAL_KEY` en los tres overrides.

## 11.7 Sintaxis Compose

```text
DEV  → config --quiet sin errores
TEST → config --quiet sin errores
```

La validación integral de PROD queda pendiente de disponer del conjunto completo de variables de producción.

---

# 12. Hallazgos para ST-03

Todavía existen discrepancias deliberadamente no resueltas:

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
DATABASE_URL
GATEWAY_DATABASE_URL
DB_*
ENV
ENVIRONMENT
```

También deben reconciliarse los puertos definidos en los `.env.*.example` con la matriz real establecida en HU-01.

Estos puntos corresponden a ST-03.

---

# 13. Estado general

```text
HU-IMP-AMB-02
├── ST-01 ✅ Frontend
├── ST-02 ✅ MQTT / seguridad
├── ST-03 ⏳ BD / nombres / puertos
└── ST-04 ⏳ Catálogo / sensibilidad / FR-IMP-CE-04
```
