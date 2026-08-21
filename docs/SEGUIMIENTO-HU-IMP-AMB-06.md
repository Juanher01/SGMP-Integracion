# Seguimiento técnico — HU-IMP-AMB-06
## Montaje del ambiente DEV

**Rama:** `feat/ambiente-dev`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-06 — Montaje del ambiente DEV
**Estado final:** ✅ COMPLETADA

---

# 1. Objetivo

Montar y validar el ambiente DEV integrando las definiciones heredadas de HU-01 y HU-02, la base de datos entregada por HU-04 y la capa AIoT entregada por HU-05, garantizando un arranque reproducible y la conectividad efectiva entre los servicios.

---

# 2. Estado final de subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Build local backend/frontend con `.env.dev` | ✅ Completada |
| ST-02 | Integrar capa BD de HU-04 y capa AIoT de HU-05 | ✅ Completada |
| ST-03 | Verificación integral, healthchecks y evidencias finales | ✅ Completada |

---

# 3. ST-01 — Build DEV

Se validó:

```text
docker compose config --quiet   ✅
build backend                   ✅
build frontend                  ✅
```

Imágenes:

```text
sgpmp-dev-backend:latest
sgpmp-dev-frontend:latest
```

El archivo real `./.env.dev` permanece ignorado por Git.

---

# 4. ST-02 — Integración HU-04

HU-04 se consumió mediante worktree aislado:

```text
implementacion-hu04 → detached HEAD ce7fd5d
```

Instancia de integración:

```text
Contenedor: SGP-HU06-DB
PostgreSQL: 18
Base: dba
Puerto host: 5433
Puerto interno: 5432
```

Resultados:

```text
✅ restauración de backup7_1_0.dump
✅ schemas modulo1 a modulo9
✅ 187 tablas
✅ roles restaurados
✅ pg_cron
✅ backend → PostgreSQL
✅ DATABASE_URL de Compose → PostgreSQL
✅ backend healthy
✅ backend /docs HTTP 200
✅ frontend HTTP 200
✅ frontend → backend
✅ CORS localhost:5173
```

DEV consume la base externamente mediante:

```text
DB_HOST=host.docker.internal
DB_PORT=5433
DB_NAME=dba
DB_APP_USER=dba
```

El servicio `database` interno queda disponible solo bajo el perfil opcional:

```text
internal-db
```

Checkpoint previo:

```text
230f434 feat(dev): integra base de datos externa de HU-04
```

---

# 5. Integración HU-05

Rama recibida:

```text
origin/feat/aiot-gateway-mosquitto
```

Commit propio:

```text
779690b feat: advance HU-05 AIoT gateway and Mosquitto integration
```

Worktree aislado:

```text
implementacion-hu05 → detached HEAD 779690b
```

No se realizó merge ni cherry-pick de HU-05.

Se clonó el repositorio AIoT oficial:

```text
SerBy48/BROKER-MQTT-SGPMP
rama: develop
```

Ubicación local:

```text
../BROKER-MQTT-SGPMP
```

Artefactos verificados:

```text
Dockerfile                  ✅
docker/mosquitto.conf       ✅
```

`compose/compose.dev.yml` quedó apuntando a:

```text
../../BROKER-MQTT-SGPMP
```

---

# 6. Contrato AIoT y PostgreSQL

Se detectó inicialmente:

```text
DB_IOT_USER=placeholder
```

La base restaurada contiene:

```text
member_iot   LOGIN=true
member_iot → grp_iot
member_iot   INHERIT=true
grp_iot      LOGIN=false
```

Para HU-06 se configuró localmente:

```text
DB_IOT_USER=member_iot
DB_IOT_PASSWORD=<secreto local no versionado>
```

La contraseña se reconcilió únicamente en `SGP-HU06-DB`.

Validación:

```text
GATEWAY DB OK: database=dba user=member_iot
```

El contrato versionado DEV quedó con:

```text
DB_IOT_USER=member_iot
DB_IOT_PASSWORD=
```

---

# 7. Hallazgo de permisos AIoT

Inicialmente:

```text
modulo3 → member_iot USAGE=false
modulo3 → grp_iot USAGE=false
modulo9 → member_iot USAGE=false
modulo9 → grp_iot USAGE=false
```

Los objetos requeridos existían:

```text
modulo3.heartbeats
modulo3.transmisiones_mqtt
modulo3.fn_ingesta_telemetria
```

Se aplicaron permisos mínimos exclusivamente en `SGP-HU06-DB` al grupo `grp_iot`:

```text
USAGE modulo3
USAGE modulo9

SELECT modulo9.dispositivos_iot
SELECT modulo9.variables_ambientales
SELECT modulo9.sensores
SELECT modulo3.estados_dispositivos_iot

INSERT/SELECT modulo3.heartbeats
INSERT modulo3.transmisiones_mqtt

EXECUTE modulo3.fn_ingesta_telemetria
```

Resultado:

```text
modulo3_usage          = true
modulo9_usage          = true
dispositivos_select    = true
heartbeats_insert      = true
transmisiones_insert   = true
```

Desde Gateway:

```text
SCHEMAS AIOT VISIBLES: modulo3, modulo9
READ OK: modulo9.dispositivos_iot
READ OK: modulo9.variables_ambientales
READ OK: modulo9.sensores
READ OK: modulo3.estados_dispositivos_iot
```

Este ajuste corresponde únicamente a la instancia local de integración HU-06 y debe reportarse al responsable de HU-04/DBA.

---

# 8. Mosquitto DEV

Estado:

```text
sgpmp-mosquitto-dev
status=running
health=healthy
```

Puertos:

```text
1883 → MQTT
9001 → WebSocket
```

Prueba funcional:

```text
HU06_MQTT_OK
```

Resultado:

```text
✅ publish
✅ subscribe
✅ listener MQTT
✅ listener WebSocket
```

---

# 9. Gateway DEV

Estado:

```text
sgpmp-gateway-dev
status=running
health=healthy
```

Puerto:

```text
8002 → 8000
```

Healthcheck:

```text
GET /v1/healthz → HTTP 200
```

Conectividad MQTT:

```text
GATEWAY MQTT TCP OK: mosquitto:1883
```

Checkpoint ST-02:

```text
a964eb9 feat(dev): integra capa AIoT de HU-05
```

**ST-02 completada.**

---

# 10. ST-03 — Arranque integral reproducible

Se confirmó inicialmente:

```text
SGP-HU06-DB
status=running
health=healthy
```

Se ejecutó:

```text
docker compose ... down
```

Compose eliminó únicamente los servicios DEV y su red.

La base externa permaneció:

```text
SGP-HU06-DB
status=running
health=healthy
```

Posteriormente:

```text
docker compose ... up -d --build
```

Resultado:

```text
sgpmp-backend-dev      running / healthy
sgpmp-frontend-dev     running
sgpmp-gateway-dev      running / healthy
sgpmp-mosquitto-dev    running / healthy
```

Servicios activos:

```text
mosquitto
gateway
backend
frontend
```

No se levantó una base interna.

Endpoints:

```text
BACKEND HEALTH: HTTP 200
FRONTEND: HTTP 200
GATEWAY HEALTH: HTTP 200
MOSQUITTO: status=running health=healthy
```

---

# 11. ST-03 — Verificación funcional posterior al reinicio

Backend → PostgreSQL:

```text
BACKEND DB OK: database=dba user=dba
```

Gateway → PostgreSQL:

```text
GATEWAY DB OK: database=dba user=member_iot
```

Gateway → Mosquitto:

```text
GATEWAY MQTT TCP OK: mosquitto:1883
```

MQTT publish/subscribe:

```text
HU06_ST03_MQTT_OK
```

Logs:

```text
===== sgpmp-backend-dev =====
OK: sin errores críticos detectados

===== sgpmp-gateway-dev =====
OK: sin errores críticos detectados

===== sgpmp-mosquitto-dev =====
OK: sin errores críticos detectados
```

---

# 12. Evidencias finales

Se generó el directorio:

```text
evidencias/hu06/
```

Archivos esperados y validados:

```text
backend-db.txt
compose-config.txt
compose-ps.txt
compose-services.txt
database-status.txt
gateway-db.txt
gateway-mqtt.txt
http-status.txt
logs-critical-scan.txt
mqtt-pubsub.txt
version.txt
```

Resultados finales:

```text
COMPOSE DEV CONFIG: OK
BACKEND HEALTH: HTTP 200
FRONTEND: HTTP 200
GATEWAY HEALTH: HTTP 200
BACKEND DB OK: database=dba user=dba
GATEWAY DB OK: database=dba user=member_iot
GATEWAY MQTT TCP OK: mosquitto:1883
HU06_FINAL_MQTT_OK
sin errores críticos detectados
```

---

# 13. Arquitectura DEV validada

```text
Frontend :5173
      │
      ▼
Backend :8000
      │
      ▼
PostgreSQL HU-04
host.docker.internal:5433

Gateway :8002
   │           │
   │           └────► PostgreSQL HU-04
   │                  usuario member_iot
   │
   ▼
Mosquitto :1883 / :9001
```

Servicios gestionados por Compose DEV:

```text
backend
frontend
gateway
mosquitto
```

Dependencia externa:

```text
SGP-HU06-DB
```

---

# 14. Hallazgos y limitaciones

1. La restauración HU-04 contenía los roles AIoT, pero no ACL efectivas sobre `modulo3` y `modulo9` para `grp_iot`.
2. Los permisos mínimos requeridos se aplicaron exclusivamente en la instancia local `SGP-HU06-DB`.
3. `DB_IOT_USER` se validó como `member_iot`.
4. Las contraseñas y tokens reales se mantienen únicamente en `.env.dev`, archivo ignorado por Git.
5. Mosquitto DEV opera sin autenticación, de acuerdo con la configuración local recibida; esto no implica aprobación de esa política para TEST o PROD.
6. HU-06 no modifica los alcances propios de HU-04 ni HU-05.

---

# 15. Validación de seguridad del repositorio

Se comprobó:

```text
.env.dev ignorado por .gitignore
```

No se versionaron:

```text
contraseñas PostgreSQL
GATEWAY_API_TOKEN real
credenciales SMTP
credenciales Firebase
tokens reales
```

`env/.env.dev.example` mantiene únicamente el contrato no sensible.

---

# 16. Resultado final

```text
ST-01 ✅
ST-02 ✅
ST-03 ✅
HU-IMP-AMB-06 ✅ COMPLETADA
```

El ambiente DEV quedó:

```text
✅ reproducible
✅ construible desde Compose
✅ backend healthy
✅ frontend accesible
✅ Gateway healthy
✅ Mosquitto healthy
✅ Backend → PostgreSQL
✅ Gateway → PostgreSQL
✅ Gateway → MQTT
✅ MQTT publish/subscribe
✅ sin base PostgreSQL duplicada en el Compose normal
✅ sin errores críticos detectados en logs
✅ evidencias finales generadas
```

La rama `feat/ambiente-dev` queda lista para revisión del líder antes de cualquier integración a la rama principal.
