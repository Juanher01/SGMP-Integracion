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
| `AUDITORIA_M02_EVENTOS_POR_SEGUNDO` | Backend (bitácora M02) | Comportamiento | No sensible | Umbral de eventos por segundo (ventana de 5 s) a partir del cual los eventos INFO de la bitácora de auditoría se encolan y se persisten por lotes. Default del código: `100` (BE `src/biological_assets/application/use_cases/_registrar_evento_bitacora.py:87`). |
| `ALEMBIC_DATABASE_URL` | Backend (migraciones) | Conexión | **Secreta** | URL de conexión de Alembic con el rol dueño de los objetos. Opcional: si no está definida, Alembic usa `DATABASE_URL` (BE `alembic/env.py:40`). Contiene credenciales. |
| `AGROFUSION_ISSUER` | Backend (SSO AgroFusion) | Autenticación / Seguridad | No sensible | Emisor esperado en el claim `iss` del token de handoff SSO. El default de `os.getenv` en el código (BE `src/identity_access/infrastructure/adapters/agrofusion_sso_adapter.py:37`) **no** cubre una variable definida y vacía; ese caso lo resuelve el compose con `${AGROFUSION_ISSUER:-agrofusion-auth}` (BE `docker-compose.yml:78` y `docker-compose.prod.yml:152`@2b9ee221; `docker-compose.test.yml:65@5697ebbe`; en `main`, `docker-compose.prod.yml` ya lo tiene y `docker-compose.yml` llega con el release). Valor: `agrofusion-auth` en DEV, TEST y PROD. HU-IMP-CFG-03. |
| `AGROFUSION_PROJECT_CODE` | Backend (SSO AgroFusion) | Autenticación / Seguridad | No sensible | Código con que el proyecto está registrado en AgroFusion; se valida contra el claim `aud`. Uno por entorno, en mayúsculas y comparado exactamente: DEV `SIGAB-DEV` (registrado), TEST `SIGAB-TEST`, PROD `SIGAB` (por registrar en AgroFusion al 2026-11-14). En minúscula debe coincidir con la ruta del frontend del entorno, porque AgroFusion devuelve al usuario a `https://inmero.co/{código en minúscula}/sso` (`/sigab-dev`, `/sigab-test`, `/sigab`). Fuente: BE `.env.example:159-161@2b9ee221`; doc. 05 de Desarrollo §2-§3. Obligatoria para activar el SSO: sin ella, `POST /sesiones/sso` responde 503 `SSO_NO_CONFIGURADO` (BE `src/identity_access/infrastructure/routers/sesiones_routers.py:172@2b9ee221`; l.166 en `main@0abbeeef`). HU-IMP-CFG-03. |
| `AGROFUSION_SSO_PUBLIC_KEY_PATH` | Backend (SSO AgroFusion) | Autenticación / Seguridad | Interna | **Ruta** dentro del contenedor a la clave pública RS256 (`.pem`), no la clave. El archivo se monta: Despliegue lo sube en Dokploy como File Mount `agrofusion_sso_public.pem` (queda en `../files/`) y el compose lo monta de solo lectura en `/app/secrets/agrofusion_sso_public.pem`, que es el valor que debe tener la variable. El `.pem` es público, pero hay que proteger su integridad. Sin la variable: 503 `SSO_NO_CONFIGURADO`; con la variable y sin archivo legible (o si la ruta es una carpeta): 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE`. TEST y PROD: ruta estándar `/app/secrets/agrofusion_sso_public.pem`. **Desviación temporal de DEV** (doc. 05 §4.3): en DEV se desplegó antes de crear el File Mount y `../files/agrofusion_sso_public.pem` quedó como carpeta vacía (Dokploy v0.30.7 no la reemplaza y no avisa). Solución aplicada en Dokploy, sin cambiar el compose: File Path `agrofusion_sso_public.pem/clave.pem` y valor `/app/secrets/agrofusion_sso_public.pem/clave.pem`. Verificado el 2026-11-17: `POST /api-sgpmp-dev/sesiones/sso` → 401 `SSO_TOKEN_INVALIDO`. **Reversión** a la ruta estándar cuando se borre la carpeta en el servidor o Dokploy pase a v0.31.0 o posterior. Montaje en compose: `dev` (`docker-compose.yml:109`, `docker-compose.prod.yml:189`@2b9ee221) y `test` (`docker-compose.test.yml:86@5697ebbe`); `main` no lo monta hasta el release (PR #941). HU-IMP-CFG-03. |
| `AGROFUSION_HUB_CLIENT_ID` | Backend (M2M AgroFusion, legado) | Autenticación / Seguridad | Interna | **Obsoleta en `dev` y `test`**: el código no la lee (`git grep` vacío en `*.py@2b9ee221` y `@5697ebbe`); desde RF-101 las credenciales del cliente AgroFusion se registran en la base de datos. **En uso en `main`** (PROD): `main.py:671` y `src/shared/agrofusion_auth.py:19@0abbeeef` (sin ella, el M2M no se monta). `docker-compose.test.yml:66@5697ebbe` todavía la pasa (se retira en ST-02 de HU-IMP-CFG-03). **No retirarla de PROD antes del lanzamiento** (release PR #941). |
| `AGROFUSION_HUB_CLIENT_SECRET` | Backend (M2M AgroFusion, legado) | Autenticación / Seguridad | **Secreta** | Igual que `AGROFUSION_HUB_CLIENT_ID`: obsoleta en `dev` y `test`; en uso en `main` (`src/shared/agrofusion_auth.py:20@0abbeeef`) hasta el release PR #941. `docker-compose.test.yml:67@5697ebbe` todavía la pasa. **No retirarla de PROD antes del lanzamiento.** |
| `SGPMP_ENTORNO` | Backend (M07 integración contable) | Comportamiento | No sensible | Ambiente que viaja en `SourceSystem.Environment` del documento AAEF; en `PROD` el contrato exige anexo aprobado. Valores: DEV `DEV`, TEST `TEST`, PROD `PROD`. Default del código: `DEV` (BE `src/accounting_integration/infrastructure/configuracion.py:18@12965211`). Compose: `docker-compose.yml:80` `${SGPMP_ENTORNO:-DEV}` y `docker-compose.prod.yml:154` `${SGPMP_ENTORNO:-PROD}`@6cee5fc4 (commit `b2b9097b`). **Falta en `docker-compose.test.yml@12965211`**: TEST se identifica como `DEV` (issue #1180, INC-BE-09). La agrega el PR #1204 de Desarrollo (`${SGPMP_ENTORNO:-TEST}`, l. 71@b8968e68; abierto al 2026-11-20); hace falta Deploy, no Restart. En `main` no existe aún (llega con el release #941). Seguimiento: HU-IMP-CFG-04. |
| `M07_LIMITE_BYTES` | Backend (M07 integración contable) | Comportamiento | No sensible | Tamaño máximo del documento AAEF, en bytes. Opcional; default `20971520` (20 MB, límite de SIGCON por lote) (BE `configuracion.py:20@2b9ee221`). Solo comentada en las plantillas (`.env.example:172`); **sin compose** en ningún entorno: diferencia justificada mientras se use el default. Si Desarrollo pide ajustarla por entorno, debe entrar al `environment:`. |
| `M07_TIMEOUT_SEGUNDOS` | Backend (M07 integración contable) | Comportamiento | No sensible | Tiempo máximo de la consulta en la base, en segundos. Opcional; default `5` (BE `configuracion.py:21@2b9ee221`). Solo comentada en las plantillas (`.env.example:173`); sin compose (misma justificación que `M07_LIMITE_BYTES`). |
| `M07_COMPROBANTE_NIC41_HABILITADO` | Backend (M07 integración contable) | Comportamiento | No sensible | Habilita el comprobante NIC 41 (documento tipo `06`). Opcional; default `false` (BE `configuracion.py:22@2b9ee221`). **No activar mientras SIGCON no acepte el tipo 06** (doc. 05 §3). Solo comentada en las plantillas (`.env.example:175`); sin compose. |
| `M04_FIRMA_MODELOS_KEY` | Backend (M04 predicción) | Autenticación / Seguridad | **Secreta** | Clave HMAC con que se firman y verifican los artefactos de modelos (SEG-M04-01, issue #1161 de Desarrollo; commit `d417c0c6`). La lee BE `src/prediction/domain/services/firma_artefacto.py:24,28@12965211`. Sin valor el contenedor arranca, pero registrar una versión responde 503 `FIRMA_MODELOS_NO_CONFIGURADA` (`registrar_version_modelo_use_case.py:405`) y activarla o asignarla, 422 `FIRMA_ARTEFACTO_INVALIDA` (`version_modelo.py:207`). Debe ser la misma clave con que se registran los modelos del entorno: si cambia, las versiones ya registradas dejan de validar. Compose: `docker-compose.yml:82` y `docker-compose.prod.yml:156` `${…:-}`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 73@b8968e68). Sin guarda `:?` en PROD por decisión del líder (2026-11-20; posible mejora). En `main` no existe aún (release #941). |
| `IOT_INFERENCIA_M04_URL` | Backend (M04 telemetría) | Conexión | Interna | URL del motor de inferencia M04 (RF-56/RF-66). BE `src/telemetry/infrastructure/adapters/motor_inferencia_http_adapter.py:110@12965211`. Vacía: el backend usa un stub y los paquetes quedan PENDIENTE, sin aviso al usuario; con `http://` registra CRITICAL y también usa el stub. **Cargarla solo cuando el motor del entorno tenga modelos** (`modelos_cargados > 0`): con el motor sin modelos los paquetes pasan a FALLIDO al 5.º intento y no vuelven a la cola; el backend no consulta el `healthz` del motor. Compose: `docker-compose.yml:88`, `docker-compose.prod.yml:162`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 78). |
| `IOT_INFERENCIA_M04_TOKEN` | Backend (M04 telemetría) | Autenticación / Seguridad | **Secreta** | Token compartido con el motor M04: el backend lo envía al motor (`motor_inferencia_http_adapter.py:117`) y lo exige en las llamadas del motor al backend (`src/shared/broker_auth.py:70`)@12965211. Vacío: las llamadas entrantes responden 503 `TOKEN_SERVICIO_NO_CONFIGURADO` y las salientes van sin `Authorization`. Mismo valor que en el motor; se carga con la URL o antes. Compose: `docker-compose.yml:89`, `docker-compose.prod.yml:163`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 79). |
| `IOT_INFERENCIA_TLS_MIN` | Backend (M04 telemetría) | Autenticación / Seguridad | No sensible | Versión mínima de TLS hacia el motor: `1.2` o `1.3`; default `1.3` (`motor_inferencia_http_adapter.py:114@12965211`). Otro valor: log CRITICAL y stub. No hace falta cargarla. Compose `${…:-1.3}`: `docker-compose.yml:90`, `docker-compose.prod.yml:164`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 80). |
| `IOT_INFERENCIA_CA_FILE` | Backend (M04 telemetría) | Autenticación / Seguridad | Interna | Ruta a una CA privada para validar el certificado del motor; vacía, usa las CAs del sistema (`motor_inferencia_http_adapter.py:115@12965211`). Una ruta inexistente produce 500 en el router de eventos edge y una excepción en cada ciclo del worker. Solo si el motor usa una CA privada, montando el archivo. Compose: `docker-compose.yml:91`, `docker-compose.prod.yml:165`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 81). |
| `IOT_AUDITORIA_RESPALDO_PATH` | Backend (M04 telemetría, RF-53) | AIoT / Analítica | Interna | Archivo SQLite donde se respaldan los eventos de auditoría IoT cuando falla la base (BE `src/telemetry/infrastructure/adapters/respaldo_auditoria_iot_sqlite_adapter.py:18@12965211`; el default del código es relativo, `var/auditoria_iot/fallas.sqlite3`). **Variable de imagen**: `ENV` en `Dockerfile:61@12965211` con `/app/storage/auditoria_iot/fallas.sqlite3`, carpeta con dueño UID 1000 (l. 55-56). DEV la fija literal y con volumen (`docker-compose.yml:92@6cee5fc4`); PROD no la pasa (vale la de la imagen). El PR #1204 la sobrescribe en TEST con la ruta relativa (l. 82@b8968e68), que el usuario del contenedor no puede escribir: la corrige ST-04b de HU-IMP-CFG-04 (commit en la rama de #1204 o PR hacia ella; si se fusiona sin ella, ST-04c). No cargarla en Dokploy. Sin volumen en TEST ni en PROD (HU-IMP-AMB-10, borrador). |
| `OTA_URL_SECRET` | Backend (OTA, DEV-15) | Autenticación / Seguridad | **Secreta** | Secreto con que se firma la URL de descarga del artefacto OTA (BE `src/prediction/infrastructure/adapters/ota_edge_adapters.py:94@12965211`). Sin él o sin `OTA_URL_BASE`, `POST /prediccion/ota/distribuciones` responde 503 `OTA_NO_CONFIGURADA` (`crear_distribucion_ota_use_case.py:79`). Se carga junto con `OTA_URL_BASE` cuando se vaya a usar OTA. Compose: `docker-compose.yml:94`, `docker-compose.prod.yml:167`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 84). Falta en `.env.prod.example` de `dev` (ST-05 de HU-IMP-CFG-04). |
| `OTA_URL_BASE` | Backend (OTA, DEV-15) | Conexión | No sensible | URL pública del backend del entorno, sin `/` final, con la que se arma la URL firmada (`ota_edge_adapters.py:96@12965211`). Si falta, el mismo 503 que `OTA_URL_SECRET`. La confirma Despliegue. Compose: `docker-compose.yml:95`, `docker-compose.prod.yml:168`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 85). Falta en `.env.prod.example` de `dev` (ST-05). |
| `OTA_URL_TTL_SEGUNDOS` | Backend (OTA, DEV-15) | Comportamiento | No sensible | Vigencia de la URL firmada, en segundos; default `86400` (BE `src/prediction/application/use_cases/ota/_aviso_fase.py:32@12965211`). Un valor no numérico produce 500 al crear o avisar una distribución. No hace falta cargarla. Compose `${…:-86400}`: `docker-compose.yml:96`, `docker-compose.prod.yml:169`@6cee5fc4; TEST: lo agrega el PR #1204 (l. 86). Falta en `.env.prod.example` de `dev` (ST-05). |
| `LOGOS_STORAGE_PATH` | Backend (RF-26) | Comportamiento | Interna | Carpeta de los logos subidos; default `/tmp/sgpmp_logos` (BE `src/shared/almacen_logos.py:45@12965211`; el directorio se crea al arrancar y, si falla, solo queda en el log). DEV y el compose de PROD usan `/app/storage/modelos/logos` (`docker-compose.yml:76`, `docker-compose.prod.yml:150`@6cee5fc4; en `main`, l. 69 y 145@0abbeeef). TEST: lo agrega el PR #1204 con `${…:-/tmp/sgpmp_logos}` (l. 75), **sin volumen**: los logos se pierden en cada Deploy (INC-BE-02, HU-IMP-AMB-10). No hace falta cargarla. |
| `FORWARDED_ALLOW_IPS` | Backend (imagen) | Conexión | Interna | Redes del proxy en las que confía uvicorn para leer la IP real del cliente (restricción por IP y límites). **Variable de imagen**, no de compose ni de Dokploy: `ENV` en BE `Dockerfile:72@2b9ee221` (l.66 en `main@0abbeeef`) con las redes privadas RFC 1918. La consume uvicorn; `src/shared/middlewares.py:33` la cita. Cambiarla exige reconstruir la imagen. |
| `VITE_API_BASE_URL` | Frontend | Conexión | No sensible | URL base utilizada por el frontend para acceder al backend. |
| `VITE_SW` | Frontend | Comportamiento | No sensible | Controla el comportamiento del Service Worker según el flujo actual del frontend. |
| `VITE_BASE_PATH` | Frontend (build arg) | Conexión | No sensible | Subruta pública del frontend detrás de Traefik: DEV `/sigab-dev`, TEST `/sigab-test`, PROD `/sigab` (default `/`). Define el `base` de Vite y la subruta que recorta nginx. Cadena completa en las tres ramas: `vite.config.ts:14`, `Dockerfile:13,45` (`ARG`), `docker-compose.yml:9` (`build.args`)@601d5a84; también `docker-compose.test.yml:11@247b1183`. **Sin documentar en `.env.example`** (T5 de `VERIF-DOC-agrofusion.md` §6, sin HU). Cambiarla exige reconstruir la imagen. |
| `VITE_AGROFUSION_LOGIN_URL` | Frontend | Conexión | No sensible | **Sin uso** en las tres ramas: solo la leen `src/auth/config/sso.ts` y `src/vite-env.d.ts`, y `ssoConfigurado`/`agrofusionLoginUrl` no se importan en ningún archivo (`git grep` en `601d5a84`, `247b1183`, `fe88f82d`); el botón "Continuar con AgroFusion" se retiró en `9c278e32`. No tiene `ARG` ni `build.args` y no hace falta: el SSO entra por la ruta `/sso` del frontend, que no depende de ella. Documentada en `.env.example:36`. Pendiente de Desarrollo: eliminarla o reintroducir el botón (INC-FE-01, derivada a Desarrollo, sin impacto). |
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

Actualización 2026-11-17 (HU-IMP-CFG-03; corte BE `dev@2b9ee221` · `test@5697ebbe` · `main@0abbeeef`, FE `dev@601d5a84` · `test@247b1183` · `main@fe88f82d`):

- **SSO de AgroFusion en TEST y PROD**: variables SSO sin cargar en el contenedor (`POST /sesiones/sso` → 503 en los dos); File Mount por confirmar con Despliegue. Ficha para Despliegue: `registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md`.
- **Desviación temporal de DEV** en `AGROFUSION_SSO_PUBLIC_KEY_PATH` (`…/agrofusion_sso_public.pem/clave.pem`): revertir cuando se borre la carpeta en el servidor o Dokploy pase a v0.31.0 o posterior.
- **`SGPMP_ENTORNO` en el compose de TEST** y retiro de `AGROFUSION_HUB_*` de `docker-compose.test.yml` y `.env.test.example`: ST-02 de HU-IMP-CFG-03 (PR a `test`, no aplicado). *Trasladado a HU-IMP-CFG-04 el 2026-11-20 (ver abajo).*
- **`.env.prod.example:235`** de `dev` y `test` sigue diciendo `SGPMP-DEV`: T1 de HU-IMP-CFG-03 (PR a `dev`).
- **`AGROFUSION_HUB_*` en PROD**: siguen en uso en `main` hasta el release PR #941; no se retiran antes.
- **`VITE_BASE_PATH`** sin documentar en el `.env.example` del frontend; **`VITE_AGROFUSION_LOGIN_URL`** sin uso (decide Desarrollo).
- **`M07_LIMITE_BYTES` / `M07_TIMEOUT_SEGUNDOS`**: confirmar con Desarrollo si se ajustan por entorno; si es así, deben entrar al `environment:`.

Actualización 2026-11-20 (HU-IMP-CFG-04; corte BE `dev@6cee5fc4` · `test@12965211` · `main@0abbeeef` · PR #1204 `b8968e68`):

- **Diez filas nuevas** en §3 (M04, motor de inferencia, OTA y logos) y fila de `SGPMP_ENTORNO` al día. Ficha para Despliegue: `registros/variables/fichas/HU-IMP-CFG-04_2026-11-20.md`.
- **`SGPMP_ENTORNO` en TEST**: la agrega el PR #1204 de Desarrollo (abierto); TEST informa `DEV` hasta que se fusione y se haga Deploy (issue #1180, INC-BE-09).
- **`.env.test.example`**: variables de #1204 y retiro de `AGROFUSION_HUB_*` en ST-04a (PR a `test`). El retiro de `AGROFUSION_HUB_*` del compose de TEST va en ST-04c, después de #1204.
- **`IOT_AUDITORIA_RESPALDO_PATH`**: el PR #1204 la deja relativa en TEST (l. 82); se señaló en #1204; la corrige ST-04b (commit en la rama de #1204 o PR hacia ella) y, si #1204 se fusiona sin la corrección, ST-04c.
- **`OTA_URL_*` en `.env.prod.example` de `dev`**: faltan (ST-05).
- **Volúmenes de logos, modelos y respaldo de auditoría** en TEST y PROD: HU-IMP-AMB-10 (borrador; depende de Desarrollo).

Estos valores deben completarse cuando las historias dependientes entreguen sus contratos definitivos.
