# VARIABLES-ENTORNO
## Catálogo unificado de variables de entorno — SGPMP

**Historia de Usuario:** HU-IMP-AMB-02
**Rama:** `feat/env-unificado`
**Estado:** Final para cierre de HU-02

---

## 1. Objetivo

Este documento define el contrato unificado de variables de entorno utilizado por los ambientes DEV, TEST y PROD del proyecto SGPMP.

Los tres archivos de ejemplo:

```text
env/.env.dev.example
env/.env.test.example
env/.env.prod.example
```

deben conservar el mismo conjunto de nombres de variables. Únicamente deben variar los valores específicos de cada ambiente.

Las variables se clasifican según:

### Tipo

- **Conexión:** direcciones, puertos, URLs y parámetros utilizados para comunicar servicios.
- **Comportamiento:** parámetros que modifican el modo de ejecución o despliegue.
- **Autenticación / Seguridad:** credenciales, tokens, claves, usuarios y controles de seguridad.
- **AIoT / Analítica:** parámetros propios del gateway, MQTT, telemetría o almacenamiento de modelos.

### Sensibilidad

- **No sensible:** puede documentarse con un valor de ejemplo.
- **Interna:** no es una contraseña, pero describe infraestructura, cuentas, rutas o topología interna.
- **Secreta:** nunca debe almacenarse con su valor real dentro del repositorio.

---

## 2. Reglas generales

1. Los archivos `.env.dev`, `.env.test` y `.env.prod` reales no se versionan.
2. Solo se versionan los archivos `.env.*.example`.
3. Una variable clasificada como **Secreta** debe quedar vacía o con un placeholder no real en archivos de ejemplo.
4. TEST y PROD consumen imágenes versionadas mediante variables `*_IMAGE`.
5. DEV construye localmente los componentes principales, aunque conserva el mismo contrato de nombres.
6. PostgreSQL se consume internamente mediante `database:5432`.
7. El puerto `5433` de DBIntegrador corresponde únicamente al acceso desde el host cuando esa entrega se ejecuta independientemente.
8. El nombre de base utilizado por la integración es `dba`.
9. Los puertos publicados hacia el host pertenecen a los overrides Compose y no se duplican en los `.env.*.example`.
10. Las variables `VITE_*` son visibles al cliente una vez construida la aplicación. Por ello **ninguna variable `VITE_*` debe contener secretos privados**.

---

## 3. Catálogo de variables

| Variable | Componente | Tipo | Sensibilidad | Descripción |
|---|---|---|---|---|
| `ENVIRONMENT` | Infraestructura | Comportamiento | No sensible | Identifica el ambiente: `dev`, `test` o `prod`. |
| `DATABASE_IMAGE` | Docker Compose | Comportamiento | Interna | Imagen versionada del servicio de base de datos para ambientes que consumen registry. |
| `BACKEND_IMAGE` | Docker Compose | Comportamiento | Interna | Imagen versionada del backend. |
| `FRONTEND_IMAGE` | Docker Compose | Comportamiento | Interna | Imagen versionada del frontend. |
| `GATEWAY_IMAGE` | Docker Compose | Comportamiento | Interna | Imagen versionada del gateway AIoT. |
| `DB_HOST` | Backend / Gateway | Conexión | Interna | Host interno PostgreSQL. En el stack integrado: `database`. |
| `DB_PORT` | Backend / Gateway | Conexión | No sensible | Puerto interno PostgreSQL. Valor normalizado: `5432`. |
| `DB_NAME` | Backend / Gateway | Conexión | Interna | Nombre de la base integrada. Valor actual: `dba`. |
| `DB_ADMIN_USER` | PostgreSQL | Autenticación / Seguridad | Interna | Usuario administrador utilizado por comprobaciones y tareas administrativas. |
| `DB_APP_USER` | Backend | Autenticación / Seguridad | Interna | Rol de aplicación que utilizará el backend. Valor definitivo sujeto a HU-04. |
| `DB_APP_PASSWORD` | Backend | Autenticación / Seguridad | **Secreta** | Contraseña del rol de aplicación. |
| `DB_IOT_USER` | Gateway AIoT | Autenticación / Seguridad | Interna | Rol de base de datos usado por la capa AIoT. Valor definitivo sujeto a HU-04/HU-05. |
| `DB_IOT_PASSWORD` | Gateway AIoT | Autenticación / Seguridad | **Secreta** | Contraseña del rol AIoT. |
| `DB_SCHEMA_INGEST` | Gateway AIoT | AIoT / Analítica | Interna | Esquema utilizado para ingestión. Valor actual: `modulo3`. |
| `DB_SCHEMA_REGISTRY` | Gateway AIoT | AIoT / Analítica | Interna | Esquema de registro. Valor actual: `modulo9`. |
| `FRONTEND_URL` | Backend | Conexión | Interna | URL del frontend utilizada por CORS y por enlaces generados por el backend. |
| `SECRET_KEY` | Backend | Autenticación / Seguridad | **Secreta** | Clave utilizada para firmar/verificar JWT. |
| `JWT_EXPIRE_HOURS` | Backend | Comportamiento | No sensible | Duración de los JWT en horas. Default actual: `24`. |
| `RF71_INTERNAL_KEY` | Backend | Autenticación / Seguridad | **Secreta** | Clave interna validada mediante el header `X-RF71-Internal-Key`. |
| `FIREBASE_CREDENTIALS_PATH` | Backend | Autenticación / Seguridad | Interna | Ruta interna al archivo de credenciales Firebase. La ruta no es el secreto; el archivo sí debe protegerse. |
| `SMTP_HOST` | Backend | Conexión | Interna | Servidor SMTP. Default actual del código: `smtp.gmail.com`. |
| `SMTP_PORT` | Backend | Conexión | No sensible | Puerto SMTP. Default actual: `587`. |
| `SMTP_USER` | Backend | Autenticación / Seguridad | Interna | Cuenta utilizada para autenticación SMTP. |
| `SMTP_PASSWORD` | Backend | Autenticación / Seguridad | **Secreta** | Contraseña de la cuenta SMTP. |
| `MODELOS_STORAGE_PATH` | Backend / Predicción | AIoT / Analítica | Interna | Ruta donde se almacenan versiones de modelos. Default actual: `/tmp/sgpmp_modelos`. |
| `VITE_API_BASE_URL` | Frontend | Conexión | No sensible | URL base utilizada por el frontend para acceder al backend. |
| `VITE_SW` | Frontend | Comportamiento | No sensible | Controla el comportamiento del Service Worker según el flujo actual del frontend. |
| `VITE_AGROFUSION_LOGIN_URL` | Frontend | Conexión | No sensible | URL de redirección para inicio de sesión AgroFusion. |
| `VITE_FIREBASE_API_KEY` | Frontend | Conexión | No sensible | Identificador de configuración cliente de Firebase. Al ser `VITE_*`, se expone al cliente. |
| `VITE_FIREBASE_AUTH_DOMAIN` | Frontend | Conexión | No sensible | Dominio de autenticación Firebase. |
| `VITE_FIREBASE_PROJECT_ID` | Frontend | Conexión | No sensible | Identificador del proyecto Firebase. |
| `VITE_FIREBASE_STORAGE_BUCKET` | Frontend | Conexión | No sensible | Bucket utilizado por el cliente Firebase. |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | Frontend | Conexión | No sensible | Identificador de mensajería Firebase. |
| `VITE_FIREBASE_APP_ID` | Frontend | Conexión | No sensible | Identificador de aplicación Firebase. |
| `VITE_VAPID_KEY` | Frontend | Autenticación / Seguridad | No sensible | Clave pública VAPID usada por el cliente. No debe sustituirse por una clave privada. |
| `GATEWAY_API_TOKEN` | Gateway AIoT | Autenticación / Seguridad | **Secreta** | Token externo de infraestructura que Compose entrega al gateway como `API_TOKEN`. |
| `MQTT_HOST` | Gateway / Mosquitto | Conexión | Interna | Host del broker MQTT. DEV/TEST usan `mosquitto`. |
| `MQTT_PORT` | Gateway / Mosquitto | Conexión | No sensible | Puerto MQTT del broker. DEV/TEST usan `1883`. PROD queda sujeto a configuración TLS definitiva. |
| `MQTT_USERNAME` | Gateway / Mosquitto | Autenticación / Seguridad | Interna | Usuario MQTT cuando el broker requiera autenticación. |
| `MQTT_PASSWORD` | Gateway / Mosquitto | Autenticación / Seguridad | **Secreta** | Contraseña MQTT. |
| `MQTT_TLS` | Gateway / Mosquitto | Autenticación / Seguridad | No sensible | Habilita o deshabilita TLS. DEV/TEST `false`; PROD `true`. |
| `MQTT_CLIENT_ID` | Gateway / Mosquitto | AIoT / Analítica | Interna | Identificador del cliente MQTT. Default actual: `sgpmp`. |
| `MQTT_RECONNECT_DELAY` | Gateway / Mosquitto | Comportamiento | No sensible | Tiempo de espera entre intentos de reconexión. Default actual: `5`. |
| `MQTT_TOPIC_PREFIX` | Gateway / Mosquitto | AIoT / Analítica | Interna | Prefijo común de topics. Default: `sgpmp`. |
| `MQTT_TOPIC_TELEMETRY` | Gateway / Mosquitto | AIoT / Analítica | Interna | Sufijo del topic de telemetría. |
| `MQTT_TOPIC_HEARTBEAT` | Gateway / Mosquitto | AIoT / Analítica | Interna | Sufijo del topic de heartbeat. |
| `MQTT_TOPIC_COMMAND` | Gateway / Mosquitto | AIoT / Analítica | Interna | Sufijo del topic de comandos. |
| `MQTT_TOPIC_STATUS` | Gateway / Mosquitto | AIoT / Analítica | Interna | Sufijo del topic de estado. |

---

## 4. Valores diferenciados por ambiente

### DEV

```text
ENVIRONMENT=dev
DB_HOST=database
DB_PORT=5432
DB_NAME=dba
FRONTEND_URL=http://localhost:5173
VITE_API_BASE_URL=http://localhost:8000
VITE_SW=false
MQTT_HOST=mosquitto
MQTT_PORT=1883
MQTT_TLS=false
```

DEV construye localmente backend, frontend, database y gateway.

### TEST

```text
ENVIRONMENT=test
DB_HOST=database
DB_PORT=5432
DB_NAME=dba
FRONTEND_URL=http://localhost:8081
VITE_API_BASE_URL=http://localhost:8001
VITE_SW=false
MQTT_HOST=mosquitto
MQTT_PORT=1883
MQTT_TLS=false
```

TEST consume imágenes versionadas por medio de:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE
```

### PROD

```text
ENVIRONMENT=prod
DB_HOST=database
DB_PORT=5432
DB_NAME=dba
VITE_SW=true
MQTT_TLS=true
```

En PROD se dejan como configuración externa valores dependientes del entorno real, entre ellos:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE
FRONTEND_URL
VITE_API_BASE_URL
VITE_AGROFUSION_LOGIN_URL
MQTT_HOST
MQTT_PORT
```

Las credenciales y secretos reales deben ser administrados fuera del repositorio.

---

## 5. Traducciones realizadas por Compose

### Gateway

El catálogo utiliza:

```text
GATEWAY_API_TOKEN
```

y Compose lo entrega al contenedor como:

```text
API_TOKEN
```

La URL PostgreSQL del gateway se construye mediante:

```text
DB_IOT_USER
DB_IOT_PASSWORD
DB_HOST
DB_PORT
DB_NAME
```

con driver:

```text
postgresql+asyncpg://
```

### Backend

La URL PostgreSQL del backend se construye mediante:

```text
DB_APP_USER
DB_APP_PASSWORD
DB_HOST
DB_PORT
DB_NAME
```

El backend utiliza internamente:

```text
ENV
```

para una comprobación específica de producción. El override Compose realiza la adaptación necesaria sin exigir al catálogo mantener dos nombres de ambiente.

---

## 6. Variables descartadas

Durante la consolidación se retiraron variables no respaldadas por el código/configuración actual:

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
JWT_SECRET_KEY
JWT_ALGORITHM
VITE_APP_ENV
GATEWAY_DATABASE_URL
DEBUG
LOG_LEVEL
```

También se revisó el `.env.example` histórico del backend. No se incorporaron automáticamente variables que no fueron encontradas como consumidas por el código actual, entre ellas:

```text
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_REDIRECT_URI
MICROSOFT_CLIENT_ID
MICROSOFT_CLIENT_SECRET
MICROSOFT_REDIRECT_URI
AUDIT_SERVICE_URL
EXTERNAL_USERS_API_URL
FIREBASE_CREDENTIALS
FIREBASE_STORAGE_BUCKET
```

Si Desarrollo vuelve a utilizar alguna de ellas, deberá incorporarse nuevamente al contrato mediante una modificación controlada.

---

## 7. Validaciones realizadas

Se comprobó:

```text
DEV vs TEST  → mismo conjunto de nombres
DEV vs PROD  → mismo conjunto de nombres
```

También se compararon las variables interpoladas por Compose frente al catálogo DEV:

```text
Variables requeridas por Compose sin documentar → ninguna
```

Además:

```text
DEBUG / LOG_LEVEL en archivos example → ninguna referencia
```

y:

```text
DEV  → docker compose config --quiet OK
TEST → docker compose config --quiet OK
```

---

## 8. Dependencias pendientes externas a HU-02

Este catálogo define el contrato, pero no inventa datos que corresponden a otras historias.

Pendientes de coordinación:

- nombres definitivos de `DB_APP_USER` y `DB_IOT_USER`;
- contraseñas de roles;
- imágenes/tags reales para TEST/PROD;
- ubicación definitiva del broker PROD y su puerto TLS;
- materialización/montaje del archivo indicado por `FIREBASE_CREDENTIALS_PATH`;
- dominios/URLs finales de PROD.

Estos valores deben completarse cuando las historias dependientes entreguen sus contratos definitivos.
