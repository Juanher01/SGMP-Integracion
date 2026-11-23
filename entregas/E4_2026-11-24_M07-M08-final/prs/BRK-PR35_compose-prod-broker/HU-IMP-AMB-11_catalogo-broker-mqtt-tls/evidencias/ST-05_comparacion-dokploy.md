# ST-05 — Comparación con las variables de Dokploy (HU-IMP-AMB-11)

> Preparación, solo lectura (2026-11-22); columna Dokploy llenada el 2026-11-23.
> **Corte del PR #27:** `78ad93f` (ST-01 a ST-04) y `9763e04` (`BACKEND_URL` del gateway como URL pública del backend), rama `docs/amb-11-ejecucion-catalogo-broker`.
> Fuentes del compose (`git fetch` del 2026-11-22): broker `main@2181993` (`docker-compose.prod.yml`, `docker-compose.motor-ia.yml`) y `test@662e096` (`docker-compose.test.yml`, `app/config.py`); backend `main@bcc3cd17` y `test@c698c656` (`docker-compose.prod.yml` / `docker-compose.test.yml`), más la cabeza del PR #1204 (`097f6d80`) para TEST. Reverificado el 2026-11-23: backend `test@1ee56516` sin cambios en `docker-compose.test.yml` desde `c698c656`. Sensibilidad según `registros/variables/VARIABLES-ENTORNO.md` corregido (PR #27).
> **Fuente de la columna Dokploy:** lista de variables de Dokploy del servidor SIGAB (DEV, TEST y PROD) compartida por Despliegue (Danna) el 2026-11-23, resumida sin valores en el contexto de la sesión. En la columna, solo «con valor», «vacía» o «no cargada»; en todo el archivo, nunca valores sensibles (las secciones de diferencias y hallazgos citan algunos valores no sensibles, como dominios y rutas). **Celda en blanco** = esa lista no la informa (no se supone nada). Las filas de `gateway` y `mosquitto` quedan «pendiente: Dokploy de Arekkazu»: el broker se despliega en otro Dokploy y su lista se pidió a AIoT (Alex).
> Una fila por variable que el servicio toma del entorno de Dokploy (en `environment:`, puertos u otras claves del servicio) y por cada variable que el compose fija con un literal (Dokploy no la cambia). No incluye el servicio `db` del backend.
> ¹ = la variable no tiene fila en §3 del catálogo; la sensibilidad sale del nombre.

**Notas de lectura.**
- El motor de IA tiene un solo compose (`docker-compose.motor-ia.yml`), igual en `main` y en `test`; se repite en las dos tablas.
- En TEST el gateway recibe **todo** el `.env` de Dokploy (`env_file: .env`): la tabla lista lo que lee el código (`app/config.py`) y su default. El `environment:` explícito (`MQTT_HOST`, `MQTT_PORT`) pisa al `.env`. En PROD, en cambio, el gateway solo recibe lo que nombra su `environment:`.
- `BROKER_SERVICE_TOKEN` es opcional (`:-`) en el backend y obligatoria (`:?`) en el gateway de PROD: debe tener el **mismo** valor en los dos.
- TEST cambiará con CFG-04 ST-04c (volúmenes y rutas en `/app/storage/...`, retiro de `AGROFUSION_HUB_*`); la tabla refleja `test@c698c656` y el PR #1204.

## PROD

| Servicio | Variable | Crítica | Obligatoria u opcional | Sensible | Valor esperado (catálogo corregido) | Dokploy (Despliegue) |
|---|---|---|---|---|---|---|
| mosquitto | `MQTT_DEVICE_PASSWORD` ¹ |  | opcional (`:-` vacía) | sí (por nombre) | con valor solo si se usa la función (secreto) (no está en el catálogo) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_DEVICE_USERNAME` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_HOST_PORT` ¹ |  | obligatoria (`:?`) — en `ports` | no | puerto de host que define Despliegue (regla 9: no se cataloga) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_PASSWORD` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_PUERTO_PUBLICO` |  | opcional (`:-8883`) | no | default del compose (`8883`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_USERNAME` |  | obligatoria (`:?`) | no | con valor | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_WS_HOST_PORT` ¹ |  | obligatoria (`:?`) — en `ports` | no | puerto de host que define Despliegue (regla 9: no se cataloga) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_WS_PUERTO_PUBLICO` |  | opcional (`:-9002`) | no | default del compose (`9002`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `BACKEND_URL` | **crítica** | obligatoria (`:?`) | no | URL **pública** del backend del entorno, con su prefijo y sin `/` final: el broker está en otro servidor (D1; catálogo en `9763e04`) | pendiente: Dokploy de Arekkazu |
| gateway | `BROKER_SERVICE_TOKEN` | **crítica** | obligatoria (`:?`) | sí | con valor; **el mismo** que el backend del mismo entorno | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TLS` | **crítica** | opcional (`:-false`) | no | `false` (TLS del gateway hacia Mosquitto por la red interna; con `true` el gateway queda `healthy` sin ingerir) | pendiente: Dokploy de Arekkazu |
| gateway | `API_HOST` ¹ |  | opcional (`:-0.0.0.0`) | no | default del compose (`0.0.0.0`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `API_PORT` ¹ |  | opcional (`:-8000`) | no | default del compose (`8000`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `BACKEND_TIMEOUT_SECONDS` |  | opcional (`:-10`) | no | default del compose (`10`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `DB_HOST` |  | obligatoria (`:?`) | no | con valor | pendiente: Dokploy de Arekkazu |
| gateway | `DB_IOT_PASSWORD` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | pendiente: Dokploy de Arekkazu |
| gateway | `DB_IOT_USER` |  | obligatoria (`:?`) | no | con valor | pendiente: Dokploy de Arekkazu |
| gateway | `DB_NAME` |  | obligatoria (`:?`) | no | con valor | pendiente: Dokploy de Arekkazu |
| gateway | `DB_SCHEMA_INGEST` |  | opcional (`:-modulo3`) | no | default del compose (`modulo3`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `DB_SCHEMA_REGISTRY` |  | opcional (`:-modulo9`) | no | default del compose (`modulo9`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_ACK_REQUIERE_ID_COMANDO` |  | opcional (`:-false`) | no | default del compose (`false`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_ACK_TIMEOUT_SECONDS` ¹ |  | opcional (`:-30`) | no | default del compose (`30`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_CLIENT_ID` |  | opcional (`:-sgpmp`) | no | default del compose (`sgpmp`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_DEVICE_PASSWORD` ¹ |  | opcional (`:-` vacía) | sí (por nombre) | con valor solo si se usa la función (secreto) (no está en el catálogo) | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_DEVICE_USERNAME` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_HOST` |  | fija en el compose (`mosquitto`) | no | la fija el compose; un valor en Dokploy no la cambia | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_PASSWORD` |  | obligatoria (`:?`) | sí | con valor (secreto); la misma que Mosquitto | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_PORT` |  | fija en el compose (`1883`) | no | la fija el compose; un valor en Dokploy no la cambia | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_RECONNECT_DELAY` |  | opcional (`:-5`) | no | default del compose (`5`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_COMMAND` |  | opcional (`:-command`) | no | default del compose (`command`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_HEARTBEAT` |  | opcional (`:-heartbeat`) | no | default del compose (`heartbeat`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_PREFIX` |  | opcional (`:-sgpmp`) | no | default del compose (`sgpmp`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_RESULTADO` |  | opcional (`:-resultado`) | no | default del compose (`resultado`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_STATUS` |  | opcional (`:-status`) | no | default del compose (`status`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_TELEMETRY` |  | opcional (`:-telemetry`) | no | default del compose (`telemetry`); cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_USERNAME` |  | obligatoria (`:?`) | no | con valor; el mismo usuario que Mosquitto | pendiente: Dokploy de Arekkazu |
| motor-ia | `BACKEND_URL` | **crítica** | opcional (`:-` vacía) | no | URL del backend del mismo entorno (no es la `BACKEND_URL` del gateway) | |
| motor-ia | `IOT_INFERENCIA_M04_TOKEN` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | |
| motor-ia | `MOTOR_IA_DIR_MODELOS` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | no cargada (comentada) |
| motor-ia | `UVICORN_ROOT_PATH` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | |
| backend | `AGROFUSION_ISSUER` | **crítica** | opcional (`:-agrofusion-auth`) | no | default `agrofusion-auth`; no cargar salvo que AgroFusion cambie el emisor | |
| backend | `AGROFUSION_PROJECT_CODE` | **crítica** | opcional (`:-` vacía) | no | `SIGAB` (en minúscula debe coincidir con la ruta del frontend) | con valor |
| backend | `AGROFUSION_SSO_PUBLIC_KEY_PATH` | **crítica** | opcional (`:-` vacía) | no | ruta del File Mount de la clave pública del SSO (ver catálogo); sin ella, SSO 503 | |
| backend | `ALLOWED_ORIGINS` ¹ | **crítica** | obligatoria (`:?`) | no | `https://inmero.co` (solo esquema y dominio, sin ruta ni barra final) | |
| backend | `BROKER_SERVICE_TOKEN` | **crítica** | opcional (`:-` vacía) | sí | con valor; **el mismo** que el gateway del mismo entorno (sin él, el backend responde 503 al reenvío del broker) | con valor |
| backend | `FRONTEND_URL` | **crítica** | obligatoria (`:?`) | no | URL pública del frontend del entorno (la define Despliegue; por confirmar con curl) | |
| backend | `SGPMP_ENTORNO` | **crítica** | opcional (`:-PROD`) | no | `PROD` (o sin cargar: default del compose) | con valor |
| backend | `COOKIE_SAMESITE` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | |
| backend | `COOKIE_SECURE` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | |
| backend | `ENV` ¹ |  | fija en el compose (`production`) | no | la fija el compose; un valor en Dokploy no la cambia | |
| backend | `FIREBASE_CREDENTIALS_PATH` |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `IOT_AUDITORIA_RESPALDO_PATH` |  | fija en el compose (`/app/storage/auditoria_iot/fallas.sqlite3`) | no | la fija el compose; un valor en Dokploy no la cambia | |
| backend | `IOT_INFERENCIA_CA_FILE` |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `IOT_INFERENCIA_M04_TOKEN` |  | opcional (`:-` vacía) | sí | con valor solo si se usa la función (secreto) | |
| backend | `IOT_INFERENCIA_M04_URL` |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (ver catálogo) | con valor |
| backend | `IOT_INFERENCIA_TLS_MIN` |  | opcional (`:-1.3`) | no | default del compose (`1.3`); cargar solo si debe ser otro | |
| backend | `JWT_EXPIRE_HOURS` |  | opcional (`:-8`) | no | default del compose (`8`); cargar solo si debe ser otro | |
| backend | `JWT_LEEWAY_SECONDS` ¹ |  | opcional (`:-30`) | no | default del compose (`30`); cargar solo si debe ser otro | |
| backend | `LOGOS_STORAGE_PATH` |  | opcional (`:-/app/storage/modelos/logos`) | no | default del compose (`/app/storage/modelos/logos`); cargar solo si debe ser otro | con valor |
| backend | `M04_FIRMA_MODELOS_KEY` |  | opcional (`:-` vacía) | sí | con valor solo si se usa la función (secreto) | |
| backend | `MODELOS_STORAGE_PATH` |  | opcional (`:-/app/storage/modelos`) | no | default del compose (`/app/storage/modelos`); cargar solo si debe ser otro | |
| backend | `MQTT_BROKER_HTTP_TIMEOUT` ¹ |  | opcional (`:-35`) | no | default del compose (`35`); cargar solo si debe ser otro | con valor |
| backend | `MQTT_BROKER_TOKEN` ¹ |  | opcional (`:-` vacía) | sí (por nombre) | con valor solo si se usa la función (secreto) (no está en el catálogo) | con valor |
| backend | `MQTT_BROKER_URL` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | con valor |
| backend | `OTA_URL_BASE` |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `OTA_URL_SECRET` |  | opcional (`:-` vacía) | sí | con valor solo si se usa la función (secreto) | |
| backend | `OTA_URL_TTL_SEGUNDOS` |  | opcional (`:-86400`) | no | default del compose (`86400`); cargar solo si debe ser otro | |
| backend | `POSTGRES_DB` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | |
| backend | `POSTGRES_PASSWORD` ¹ |  | obligatoria (`:?`) | sí (por nombre) | con valor (secreto; nunca en el repositorio) | |
| backend | `POSTGRES_USER` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | con valor |
| backend | `RECAPTCHA_SECRET_KEY` ¹ |  | obligatoria (`:?`) | sí (por nombre) | con valor (secreto; nunca en el repositorio) | |
| backend | `REFRESH_TOKEN_EXPIRE_DAYS` ¹ |  | opcional (`:-7`) | no | default del compose (`7`); cargar solo si debe ser otro | |
| backend | `RF71_INTERNAL_KEY` |  | opcional (`:-` vacía) | sí | con valor solo si se usa la función (secreto) | |
| backend | `ROOT_PATH` ¹ |  | opcional (`:-/api`) | no | default del compose (`/api`); cargar solo si debe ser otro | |
| backend | `SECRET_KEY` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | |
| backend | `SMTP_HOST` |  | opcional (`:-smtp.gmail.com`) | no | default del compose (`smtp.gmail.com`); cargar solo si debe ser otro | |
| backend | `SMTP_PASSWORD` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | |
| backend | `SMTP_PORT` |  | opcional (`:-587`) | no | default del compose (`587`); cargar solo si debe ser otro | |
| backend | `SMTP_USER` |  | obligatoria (`:?`) | no | con valor | |

## TEST

| Servicio | Variable | Crítica | Obligatoria u opcional | Sensible | Valor esperado (catálogo corregido) | Dokploy (Despliegue) |
|---|---|---|---|---|---|---|
| mosquitto | `MQTT_HOST_PORT` ¹ |  | opcional (`:-1885`) — en `ports` | no | puerto de host que define Despliegue (regla 9: no se cataloga) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_PASSWORD` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_USERNAME` |  | obligatoria (`:?`) | no | con valor | pendiente: Dokploy de Arekkazu |
| mosquitto | `MQTT_WS_HOST_PORT` ¹ |  | opcional (`:-9002`) — en `ports` | no | puerto de host que define Despliegue (regla 9: no se cataloga) | pendiente: Dokploy de Arekkazu |
| gateway | `BACKEND_URL` | **crítica** | por `env_file`; default del código: vacía | no | URL **pública** del backend del entorno, con su prefijo y sin `/` final: el broker está en otro servidor (D1; catálogo en `9763e04`) | pendiente: Dokploy de Arekkazu |
| gateway | `BROKER_SERVICE_TOKEN` | **crítica** | por `env_file`; default del código: vacía | sí | con valor; **el mismo** que el backend del mismo entorno | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TLS` | **crítica** | por `env_file`; default del código: `False` | no | `false` (TLS del gateway hacia Mosquitto por la red interna; con `true` el gateway queda `healthy` sin ingerir) | pendiente: Dokploy de Arekkazu |
| gateway | `API_HOST` ¹ |  | por `env_file`; default del código: `0.0.0.0` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `API_PORT` ¹ |  | por `env_file`; default del código: `8000` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `BACKEND_TIMEOUT_SECONDS` |  | por `env_file`; default del código: `10.0` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `DATABASE_URL` ¹ |  | obligatoria por el código (sin default) | sí (incluye la contraseña) | con valor: URL `postgresql+asyncpg://` con el rol AIoT (en PROD la arma el compose desde `DB_*`) | pendiente: Dokploy de Arekkazu |
| gateway | `DB_SCHEMA_INGEST` |  | por `env_file`; default del código: `modulo3` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `DB_SCHEMA_REGISTRY` |  | por `env_file`; default del código: `modulo9` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_ACK_REQUIERE_ID_COMANDO` |  | por `env_file`; default del código: `False` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_ACK_TIMEOUT_SECONDS` ¹ |  | por `env_file`; default del código: `30` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_CLIENT_ID` |  | por `env_file`; default del código: `sgpmp` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_COLA_CAPACIDAD` ¹ |  | por `env_file`; default del código: `1000` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_COLA_WORKERS` ¹ |  | por `env_file`; default del código: `4` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_DEVICE_PASSWORD` ¹ |  | por `env_file`; default del código: ninguno | sí (por nombre) | con valor solo si se usa la función (secreto) (no está en el catálogo) | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_DEVICE_USERNAME` ¹ |  | por `env_file`; default del código: ninguno | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_HOST` |  | fija en el compose (`mosquitto`) | no | la fija el compose; un valor en Dokploy no la cambia | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_PASSWORD` |  | por `env_file`; default del código: ninguno | sí | con valor (secreto); la misma que Mosquitto | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_PORT` |  | fija en el compose (`1883`) | no | la fija el compose; un valor en Dokploy no la cambia | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_RECONNECT_DELAY` |  | por `env_file`; default del código: `5` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_COMMAND` |  | por `env_file`; default del código: `command` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_EVENTO` ¹ |  | por `env_file`; default del código: `evento` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_HEARTBEAT` |  | por `env_file`; default del código: `heartbeat` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_OTA` ¹ |  | por `env_file`; default del código: `ota` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_PREFIX` |  | por `env_file`; default del código: `sgpmp` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_RESULTADO` |  | por `env_file`; default del código: `resultado` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_STATUS` |  | por `env_file`; default del código: `status` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_TELEMETRY` |  | por `env_file`; default del código: `telemetry` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_TOPIC_VISION` ¹ |  | por `env_file`; default del código: `vision` | no | default del código; cargar solo si debe ser otro | pendiente: Dokploy de Arekkazu |
| gateway | `MQTT_USERNAME` |  | por `env_file`; default del código: ninguno | no | con valor; el mismo usuario que Mosquitto | pendiente: Dokploy de Arekkazu |
| motor-ia | `BACKEND_URL` | **crítica** | opcional (`:-` vacía) | no | URL del backend del mismo entorno (no es la `BACKEND_URL` del gateway) | |
| motor-ia | `IOT_INFERENCIA_M04_TOKEN` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | |
| motor-ia | `MOTOR_IA_DIR_MODELOS` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | |
| motor-ia | `UVICORN_ROOT_PATH` ¹ |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (no está en el catálogo) | |
| backend | `AGROFUSION_ISSUER` | **crítica** | opcional (`:-agrofusion-auth`) | no | default `agrofusion-auth`; no cargar salvo que AgroFusion cambie el emisor | |
| backend | `AGROFUSION_PROJECT_CODE` | **crítica** | opcional (`:-` vacía) | no | `SIGAB-TEST` | vacía |
| backend | `AGROFUSION_SSO_PUBLIC_KEY_PATH` | **crítica** | opcional (`:-` vacía) | no | ruta del File Mount de la clave pública del SSO (ver catálogo); sin ella, SSO 503 | vacía |
| backend | `ALLOWED_ORIGINS` ¹ | **crítica** | opcional (`:-` vacía) | no | origen del frontend de TEST: `https://api.inmero.co` (curl 2026-11-23; solo esquema y dominio, sin ruta ni barra final) | con valor |
| backend | `BROKER_SERVICE_TOKEN` | **crítica** | opcional (`:-` vacía) | sí | con valor; **el mismo** que el gateway del mismo entorno (sin él, el backend responde 503 al reenvío del broker) | con valor |
| backend | `FRONTEND_URL` | **crítica** | obligatoria (`:?`) | no | URL pública del frontend de TEST: `https://api.inmero.co/sigab-test` (curl 2026-11-23) | con valor |
| backend | `SGPMP_ENTORNO` | **crítica** | opcional (`:-TEST`) — **solo con el PR #1204** (abierto) | no | `TEST` (o sin cargar, cuando el compose la pase: PR #1204) | |
| backend | `AGROFUSION_HUB_CLIENT_ID` |  | opcional (`:-` vacía) | no | sin uso en el código de `test`: no cargar; la retira CFG-04 ST-04c | |
| backend | `AGROFUSION_HUB_CLIENT_SECRET` |  | opcional (`:-` vacía) | sí | sin uso en el código de `test`: no cargar; la retira CFG-04 ST-04c | |
| backend | `COOKIE_SAMESITE` ¹ |  | sin default (vacía si falta) | no | con valor (no está en el catálogo) | |
| backend | `COOKIE_SECURE` ¹ |  | sin default (vacía si falta) | no | con valor (no está en el catálogo) | |
| backend | `ENABLE_TEST_SANDBOX` ¹ |  | opcional (`:-false`) | no | default del compose (`false`); cargar solo si debe ser otro | |
| backend | `ENV` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | |
| backend | `FIREBASE_CREDENTIALS_PATH` |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `IOT_INFERENCIA_CA_FILE` |  | opcional (`:-` vacía) — **solo con el PR #1204** (abierto) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `IOT_INFERENCIA_M04_TOKEN` |  | opcional (`:-` vacía) — **solo con el PR #1204** (abierto) | sí | con valor solo si se usa la función (secreto) | |
| backend | `IOT_INFERENCIA_M04_URL` |  | opcional (`:-` vacía) — **solo con el PR #1204** (abierto) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `IOT_INFERENCIA_TLS_MIN` |  | opcional (`:-1.3`) — **solo con el PR #1204** (abierto) | no | default del compose (`1.3`); cargar solo si debe ser otro | |
| backend | `JWT_EXPIRE_HOURS` |  | opcional (`:-8`) | no | default del compose (`8`); cargar solo si debe ser otro | |
| backend | `JWT_LEEWAY_SECONDS` ¹ |  | sin default (vacía si falta) | no | con valor (no está en el catálogo) | |
| backend | `LOGOS_STORAGE_PATH` |  | opcional (`:-/tmp/sgpmp_logos`) — **solo con el PR #1204** (abierto) | no | si está cargada con `/tmp`, borrarla antes del Deploy de ST-04c (respuesta de Despliegue pendiente) | no cargada |
| backend | `M04_FIRMA_MODELOS_KEY` |  | opcional (`:-` vacía) — **solo con el PR #1204** (abierto) | sí | con valor solo si se usa la función (secreto) | |
| backend | `MODELOS_STORAGE_PATH` |  | opcional (`:-/tmp/sgpmp_modelos`) | no | **borrar** antes del Deploy de CFG-04 ST-04c (Despliegue confirmó que está cargada con `/tmp/sgpmp_modelos`, 2026-11-22) | con valor |
| backend | `MQTT_BROKER_TOKEN` ¹ |  | obligatoria (`:?`) | sí (por nombre) | con valor (secreto; nunca en el repositorio) | con valor |
| backend | `MQTT_BROKER_URL` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | con valor |
| backend | `OTA_URL_BASE` |  | opcional (`:-` vacía) — **solo con el PR #1204** (abierto) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `OTA_URL_SECRET` |  | opcional (`:-` vacía) — **solo con el PR #1204** (abierto) | sí | con valor solo si se usa la función (secreto) | |
| backend | `OTA_URL_TTL_SEGUNDOS` |  | opcional (`:-86400`) — **solo con el PR #1204** (abierto) | no | default del compose (`86400`); cargar solo si debe ser otro | |
| backend | `POSTGRES_DB` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | |
| backend | `POSTGRES_PASSWORD` ¹ |  | obligatoria (`:?`) | sí (por nombre) | con valor (secreto; nunca en el repositorio) | |
| backend | `POSTGRES_USER` ¹ |  | obligatoria (`:?`) | no | con valor (no está en el catálogo) | con valor |
| backend | `RECAPTCHA_SECRET_KEY` ¹ |  | obligatoria (`:?`) | sí (por nombre) | con valor (secreto; nunca en el repositorio) | |
| backend | `REFRESH_TOKEN_EXPIRE_DAYS` ¹ |  | opcional (`:-7`) | no | default del compose (`7`); cargar solo si debe ser otro | |
| backend | `RF71_INTERNAL_KEY` |  | opcional (`:-` vacía) | sí | con valor solo si se usa la función (secreto) | |
| backend | `ROOT_PATH` ¹ |  | opcional (`:-/api`) | no | default del compose (`/api`); cargar solo si debe ser otro | |
| backend | `SECRET_KEY` |  | obligatoria (`:?`) | sí | con valor (secreto; nunca en el repositorio) | |
| backend | `SMTP_HOST` |  | opcional (`:-smtp.gmail.com`) | no | default del compose (`smtp.gmail.com`); cargar solo si debe ser otro | |
| backend | `SMTP_PASSWORD` |  | opcional (`:-` vacía) | sí | con valor solo si se usa la función (secreto) | |
| backend | `SMTP_PORT` |  | opcional (`:-587`) | no | default del compose (`587`); cargar solo si debe ser otro | |
| backend | `SMTP_USER` |  | opcional (`:-` vacía) | no | vacía salvo que se use la función (ver catálogo) | |
| backend | `TEST_SANDBOX_SECRET` ¹ |  | opcional (`:-` vacía) | sí (por nombre) | con valor solo si se usa la función (secreto) (no está en el catálogo) | |

## Diferencias con lo esperado

| Entorno | Diferencia | Quién actúa |
|---|---|---|
| PROD y TEST | El broker (gateway y Mosquitto) **no** está en el servidor del backend y la base: `MQTT_BROKER_URL` del backend tiene valor y apunta a otro servidor. `BACKEND_URL` del gateway debe ser la URL pública del backend de cada entorno (catálogo corregido en `9763e04`); el compose PROD del broker pide la interna (H-01 ampliado, §8 del catálogo). | Implementación (hecho en el catálogo); AIoT para el compose del broker (HU-IMP-CFG-01) |
| PROD y TEST | `BROKER_SERVICE_TOKEN` del backend: con valor. Falta confirmar que el gateway tenga **el mismo**. | AIoT (Alex), con la lista del Dokploy de Arekkazu |
| PROD | `MQTT_BROKER_URL` y `MQTT_BROKER_TOKEN` (opcionales en el compose): con valor. `MQTT_BROKER_HTTP_TIMEOUT`: cargada aunque tiene default en el compose (sin efecto si coincide). | Sin acción |
| PROD | `IOT_INFERENCIA_M04_URL` con valor en el backend, pero `MOTOR_IA_DIR_MODELOS` está comentada en el motor (sin modelos): los paquetes de inferencia quedarían `FALLIDO`. | AIoT (Alex); ya avisado |
| PROD | `LOGOS_STORAGE_PATH`, `SGPMP_ENTORNO` y `AGROFUSION_PROJECT_CODE`: con valor, como se esperaba. | Sin acción |
| TEST | `AGROFUSION_PROJECT_CODE` y `AGROFUSION_SSO_PUBLIC_KEY_PATH`: **vacías** (SSO sin configurar; se esperaba `SIGAB-TEST` y la ruta del File Mount). | Despliegue |
| TEST | `LOGOS_STORAGE_PATH`: **no cargada**. Responde la pregunta pendiente de ST-04c: no hay que borrarla. | Despliegue (ya registrada en CFG-04) |
| TEST | `MODELOS_STORAGE_PATH`: con valor (`/tmp`). | Despliegue: eliminarla antes del Deploy (CFG-04 ST-04c) |
| TEST | Variables del broker cargadas en el backend, sin fila en la tabla: `MQTT_USERNAME`, `MQTT_PASSWORD`, `MQTT_HOST` y `MQTT_HOST_PORT` (con valor). El backend no las lee: `git grep -w` en `src/`, `docker-compose.test.yml` y `Dockerfile` de `test@1ee56516` sin coincidencias (solo aparecen en scripts de `tests/`). | Despliegue (pueden retirarse; decisión suya) |
| PROD y TEST | Gateway y Mosquitto: pendiente la lista del Dokploy de Arekkazu (`MQTT_TLS`, `BACKEND_URL`, `BROKER_SERVICE_TOKEN`, `DB_HOST` y su puerto, y si gateway y Mosquitto están en el mismo stack). Pendiente registrado en §8 del catálogo. **Bloquea solo el cierre de esas filas, no el PR #27.** | AIoT (Alex) |

## Hallazgos fuera de alcance

No son de HU-IMP-AMB-11; se registran para su dueño.

- **Frontend de TEST (Despliegue):** el dominio en Dokploy es `https://api.inmero.co/sigab-test`, con `FRONTEND_URL` y `VITE_BASE_PATH` coherentes con él y `ALLOWED_ORIGINS=https://api.inmero.co`. Lo desactualizado es la tabla de dominios de `PI4/CLAUDE.md` (decía `inmero.co/sigab-test`).
- **Backend de DEV y PROD (Despliegue):** dominio con `www.` (`www.api.inmero.co/api-sgpmp-dev`, `www.api.inmero.co/sigab`); TEST sin `www.`. `VITE_API_BASE_URL` de PROD con `www.`.
- **Motor de IA de TEST (Despliegue):** el dominio aparece escrito `api.inmero.comotor-ia-test`; por confirmar.
- **Motor de IA de PROD (AIoT):** `MOTOR_IA_DIR_MODELOS` comentada con `IOT_INFERENCIA_M04_URL` cargada en el backend (ver «Diferencias»). Avisado a Alex.
- **DEV (Despliegue):** `AGROFUSION_HUB_*` siguen cargadas sin uso; la ruta de la clave del SSO conserva la desviación conocida.
- **Bases de datos (DBA / Despliegue):** las tres usan `POSTGRES_USER` con el mismo rol de aplicación y publican puerto al host. Se trata en Taiga #5478 (HU-IMP-CFG-05).
