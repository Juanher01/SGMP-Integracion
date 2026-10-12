# Auditoría de credenciales y desbloqueo local — HU-05

**Fecha:** 2026-08-20  
**Rama de integración:** `feat/aiot-gateway-mosquitto`  
**Estado:** PARCIALMENTE AVANZADA

## 1. Alcance

Se revisaron `SGMP-Integracion`, `BROKER-MQTT-SGPMP`, `DBIntegrador-master`, `sgpmp-backend` y las referencias disponibles de `SGPMP-FRONT-END-PWA`. Se inspeccionaron estados Git, Compose, `.env*`, Dockerfiles, scripts, documentación, código del Gateway, configuración MQTT, roles PostgreSQL y pruebas.

No se copiaron secretos completos a este documento ni se modificaron credenciales, usuarios, contratos MQTT o esquemas de base de datos.

## 2. Estado de repositorios

| Repositorio | Estado observado | Conclusión |
|---|---|---|
| `SGMP-Integracion` | Rama `feat/aiot-gateway-mosquitto`; cambios en los dos compose, `database/` y el plan | Se conservan cambios existentes. |
| `BROKER-MQTT-SGPMP` | Git en `develop...origin/develop`; `.env.example` versionado | Dependencia local disponible. |
| `DBIntegrador-master` | No es repositorio Git | Dependencia local sin trazabilidad Git. |
| `sgpmp-backend` | Detached HEAD; cambios no relacionados presentes | Se auditó como dependencia, sin modificarlo. |
| `SGPMP-FRONT-END-PWA` | Rama `main`; cambios locales no relacionados | No fue necesario modificarlo. |

## 3. Credenciales y mecanismos encontrados

| Fuente | Variable/identidad | Clasificación | Ambiente | ¿Usable en DEV? | Riesgo/decisión |
|---|---|---|---|---|---|
| `DBIntegrador-master/docker-compose.yml` | Usuario PostgreSQL administrador | ENCONTRADA_PERO_REQUIERE_CONFIRMACION | Local/DBA | No automáticamente | Está asociado a una contraseña escrita en Compose; no se debe reutilizar sin autorización del DBA. |
| `DBIntegrador-master/docker-compose.yml` | Contraseña `POSTGRES_PASSWORD` | SECRET_REAL o DESCONOCIDA | Local/DBA | No automáticamente | Se encontró en texto plano en un archivo externo; no se reproduce ni se copia. Debe rotarse/confirmarse por DBA. |
| `DBIntegrador-master/backup_roles.sql` | `dba`, `member_dev`, `member_impl`, `member_iot`, `member_qa`, `member_deploy` y grupos | VALIDADO | DBA | No automáticamente | Hay roles LOGIN y hashes SCRAM. Los hashes no son contraseñas reutilizables. Faltan permisos efectivos por esquema. |
| `DBIntegrador-master/backup_roles.sql` | Cláusulas `PASSWORD` | HASH | DBA | No | No se copian ni se convierten en credenciales de aplicación. |
| `DBIntegrador-master/roles.sql/` | Fuente alternativa de roles | BLOQUEADO | DBA | No | Es un directorio no legible durante la auditoría. DBA debe confirmar si es la fuente oficial. |
| `SGMP-Integracion/.sgpmp-local/dbintegrador/.env` | `DBA_PASSWORD` | LOCAL_DEV_PUEDE_USARSE solo bajo autorización | Local HU-04 | Solo para el procedimiento local ya acordado | Está ignorado por Git y su valor no se expuso. No demuestra que sea válido para `DB_IOT_USER`. |
| `BROKER-MQTT-SGPMP/.env.example` | `DATABASE_URL` con valores de ejemplo | PLACEHOLDER/EXAMPLE | Local Gateway | No para la BD integrada | Es configuración de ejemplo del Gateway, no evidencia de que esos usuario, contraseña, host o base existan en DBIntegrador. |
| `BROKER-MQTT-SGPMP/.env.example` | `API_TOKEN` de cambio obligatorio | PLACEHOLDER | Local Gateway | Solo para prueba aislada del proceso, no para integración | El código exige el token; el valor de ejemplo no es un secreto autorizado. |
| `BROKER-MQTT-SGPMP/.env.example` | `MQTT_USERNAME` y `MQTT_PASSWORD` vacíos | PLACEHOLDER/NO AUTENTICACIÓN | DEV local | Sí con Mosquitto anónimo | Coincide con `allow_anonymous true`; no es apto para PROD. |
| `SGMP-Integracion/env/.env.dev` | `DB_APP_USER`, `DB_APP_PASSWORD`, `DB_IOT_USER`, `DB_IOT_PASSWORD`, `GATEWAY_API_TOKEN` | PLACEHOLDER VACÍO | DEV | No | Compose produce URLs sin credenciales. No completar arbitrariamente. |
| `SGMP-Integracion/env/.env.test.example` | Imágenes y secretos de TEST | PLACEHOLDER VACÍO | TEST | No | `DATABASE_IMAGE`, `GATEWAY_IMAGE`, `BACKEND_IMAGE` y `FRONTEND_IMAGE` no están definidos. |
| `SGMP-Integracion/env/.env.prod.example` | Secretos, imágenes y MQTT TLS | PLACEHOLDER VACÍO | PROD | No aplica | Deben ser administrados externamente por Despliegue. |
| `docs/RUNBOOK-local.md` y reportes históricos | `dba` y contraseña de desarrollo redactada | ENCONTRADA_PERO_REQUIERE_CONFIRMACION | DEV histórico | No automáticamente | Es evidencia de una prueba previa, no contrato vigente de DBIntegrador. |

## 4. Gateway: contrato real

- El Dockerfile usa Python 3.11 slim, dependencias fijadas y expone el puerto interno `8000`.
- `app/config.py` exige `DATABASE_URL` y `API_TOKEN`; MQTT tiene defaults para host local, puerto `1883`, TLS desactivado, cliente `sgpmp` y reconexión de `5` segundos.
- El Compose de integración transforma `DB_IOT_*` en `DATABASE_URL` y `GATEWAY_API_TOKEN` en `API_TOKEN`.
- Las rutas verificadas son `GET /v1/healthz`, `POST /v1/commands` y `GET /v1/devices`; las dos últimas exigen Bearer token.
- Los topics construidos son `sgpmp/<serial>/telemetry`, `heartbeat`, `status` y `command`. El Gateway se suscribe a telemetría, heartbeat y status; publica comandos.
- La persistencia usa `modulo3.fn_ingesta_telemetria`, `modulo3.heartbeats`, `modulo3.transmisiones_mqtt` y consultas de registro en `modulo9`.
- Los payloads de telemetría y heartbeat del README/código están marcados como propuestos/TODO. No deben tratarse como contrato definitivo.
- No existe mecanismo implementado para desactivar la autenticación HTTP: `API_TOKEN` es obligatorio en la configuración.

## 5. Mosquitto

`BROKER-MQTT-SGPMP/docker/mosquitto.conf` define:

- listener MQTT `1883`;
- listener WebSocket `9001`;
- `allow_anonymous true`;
- sin `password_file`;
- sin ACL;
- sin TLS;
- sin persistencia declarada en ese archivo.

**Conclusión:** puede usarse para una prueba de conectividad local DEV, exclusivamente dentro de un entorno controlado. No es configuración apta para TEST/PROD sin decisión y artefactos de seguridad de AIoT/Despliegue.

## 6. Backend y Frontend

La auditoría no encontró llamadas HTTP reales del backend a `/v1/commands`, `/v1/devices` o `/v1/healthz`, ni variables `GATEWAY_URL` o `GATEWAY_API_TOKEN` implementadas para ese flujo.

La configuración remota de dispositivos usa `MqttStubAdapter`, que siempre devuelve `False` y deja el estado pendiente. Por tanto, el flujo actual es:

```text
Backend -> base de datos / MqttStubAdapter
Gateway -> Mosquitto -> dispositivos
```

No está demostrado el flujo `Backend -> Gateway` descrito en la arquitectura objetivo. El Frontend consume el Backend; no se identificó una dependencia directa con el Gateway.

## 7. Restauración y PostgreSQL

- `DBIntegrador-master` declara `postgres:18`, base `dba`, usuario administrador `dba`, contenedor `SGP` y el dump `backup7_1_0.dump`.
- Su README contiene inconsistencias entre `SGP` y `SGPMP` en comandos posteriores.
- `SGMP-Integracion/scripts/restaurar-bd.sh` aún referencia la estructura antigua `docuemntacionDB/DOCKER`, el contenedor `SGPMP` y una contraseña de prueba hardcodeada. No se ejecutó ni se adaptó.
- Existe una copia local ignorada en `.sgpmp-local/dbintegrador/` con `docker-compose.hu04.yml`, dump y roles, pero requiere confirmar su procedencia y contrato.
- `pg_restore` y `psql` no están instalados en el host, por lo que no se pudo inspeccionar el catálogo del dump directamente.
- No se modificaron roles, permisos, tablas, funciones ni esquemas.

La prueba `python -m pytest -q` del Gateway se ejecutó con `DATABASE_URL` y `API_TOKEN` temporales solo de proceso. La colección falló porque el intérprete Python del host no tiene instalado `asyncpg`; `requirements.lock` sí lo declara. Esto es un bloqueo de dependencias del entorno local, no una autorización para cambiar credenciales.

## 8. Capacidad de desbloqueo local

| Componente | Credenciales/mecanismo encontrado | ¿Puede funcionar local? | Acción segura |
|---|---|---|---|
| PostgreSQL | Compose DBA, roles con hashes y `.sgpmp-local` con secreto ignorado | Parcial | Puede avanzarse con el procedimiento HU-04 solo después de confirmar DBA y roles; no conectar el Gateway con credenciales no autorizadas. |
| Gateway | Defaults MQTT, `DATABASE_URL` y `API_TOKEN` obligatorios; ejemplos placeholder | Parcial | Puede construirse y probarse estáticamente; health aislado requiere variables temporales de prueba, no valida BD. |
| Mosquitto | Anónimo en `1883`, WebSocket `9001` | Sí, solo DEV local | Probar conectividad sin autenticación; no promover la configuración a TEST/PROD. |
| Backend | No tiene cliente HTTP del Gateway; MQTT es stub | Sí, independiente | Validar su propia conexión a BD; no declarar integración Backend/Gateway. |
| Frontend | URL del Backend en configuración Vite | Sí, independiente | No bloquea la auditoría AIoT. |

## 9. Bloqueos

### Bloqueo real

- Autorización de usuarios y contraseñas de PostgreSQL para `DB_APP_*` y `DB_IOT_*`.
- Confirmación de la fuente oficial de roles y del procedimiento de restauración.
- Token autorizado para `GATEWAY_API_TOKEN`.
- Permisos efectivos del rol AIoT sobre `modulo3` y `modulo9`.
- Contrato definitivo de payloads y validación de los flujos M03/M04/M09.
- Configuración autenticada/TLS para TEST y PROD.
- Imágenes versionadas para TEST y PROD.

### Bloqueo evitable localmente

- La ruta incorrecta `BROKER-MQTT-SGPMP-develop` ya fue corregida en DEV y TEST.
- Mosquitto puede probarse localmente sin autenticación, con alcance exclusivo DEV.
- El Gateway puede construirse y su configuración puede validarse sin levantar PostgreSQL funcional.

### Pendiente de validación

- `docker compose up` progresivo en DEV.
- Healthcheck real de database, Mosquitto y Gateway.
- Conectividad MQTT real y persistencia en PostgreSQL.
- Catálogo del dump y existencia de funciones/tablas AIoT.

## 10. Recomendación

No copiar los valores encontrados en DBIntegrador, reportes históricos o `.env.example` hacia `env/.env.dev`. Solicitar al DBA una autorización explícita para un usuario/contraseña local, y a AIoT un token de DEV. Mientras tanto, adelantar build/config y una prueba aislada del Gateway/Mosquitto con valores temporales de proceso que no se guarden ni representen credenciales de integración.

## 11. Evidencia ejecutada

- `git status --short --branch`, `git diff --stat` y diff de los compose.
- Inventario de archivos de configuración y búsqueda redactada de patrones de credenciales.
- Lectura de Compose, Dockerfiles, `.env.example`, `AGENTS.md`, README, código del Gateway y backend.
- Revisión de roles con valores redactados.
- Confirmación de que `DBIntegrador-master` no es Git.
- Confirmación de que `pg_restore`/`psql` no están disponibles en el host.
- `python -m pytest -q` en el Gateway: error de colección porque faltan `DATABASE_URL` y `API_TOKEN` en el proceso de prueba.
- `python -m pytest -q` en el Gateway con variables temporales: error de colección por `ModuleNotFoundError: asyncpg`; no se modificó el entorno ni el repositorio externo.
- `docker compose ... config` DEV: válido en la ejecución anterior.
- `docker compose ... config` TEST/PROD: bloqueado por imágenes vacías.

## 12. Estado de HU-05

**[PARCIALMENTE AVANZADA]**

La integración de Compose, Gateway y Mosquitto está adelantada y puede probarse parcialmente en local. La validación funcional completa sigue bloqueada por credenciales/autorizaciones de PostgreSQL y API, restauración no verificada, contrato de payload pendiente, ausencia de integración Backend -> Gateway y configuración de seguridad de TEST/PROD.
