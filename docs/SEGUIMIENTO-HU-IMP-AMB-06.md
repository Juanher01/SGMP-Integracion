# Seguimiento técnico — HU-IMP-AMB-06
## Montaje del ambiente DEV

**Rama:** `feat/ambiente-dev`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-06 — Montaje del ambiente DEV
**Estado:** ⏳ En progreso

---

# 1. Objetivo

Montar y validar el ambiente DEV integrando las definiciones heredadas de HU-01 y HU-02, la base de datos entregada por HU-04 y la capa AIoT entregada por HU-05.

---

# 2. Estado de subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Build local backend/frontend con `.env.dev` | ✅ Completada |
| ST-02 | Integrar capa BD de HU-04 y capa AIoT de HU-05 | ✅ Completada |
| ST-03 | Verificación integral, healthchecks y evidencias finales | ⏳ Pendiente |

---

# 3. ST-01 — Build DEV

Se validó correctamente:

```text
docker compose config --quiet   ✅
build backend                   ✅
build frontend                  ✅
```

Imágenes locales:

```text
sgpmp-dev-backend:latest
sgpmp-dev-frontend:latest
```

El archivo real `./.env.dev` permanece ignorado por Git.

---

# 4. ST-02 — Integración HU-04

HU-04 fue consumida mediante worktree aislado:

```text
implementacion-hu04 → detached HEAD ce7fd5d
```

Instancia de integración HU-06:

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

DEV consume PostgreSQL externamente mediante:

```text
DB_HOST=host.docker.internal
DB_PORT=5433
DB_NAME=dba
DB_APP_USER=dba
```

El servicio `database` interno permanece disponible únicamente mediante el perfil opcional `internal-db`.

Checkpoint previo:

```text
230f434 feat(dev): integra base de datos externa de HU-04
```

---

# 5. Recepción e inspección de HU-05

Rama remota:

```text
origin/feat/aiot-gateway-mosquitto
```

Commit propio identificado:

```text
779690b feat: advance HU-05 AIoT gateway and Mosquitto integration
```

Se creó un worktree aislado:

```text
implementacion-hu05 → detached HEAD 779690b
```

No se hizo merge ni cherry-pick de HU-05.

La integración de HU-06 tomó únicamente los elementos necesarios para DEV.

---

# 6. Dependencia AIoT oficial

Se clonó el repositorio esperado por HU-05:

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

La copia previa `../BROKER-MQTT-SGPMP-develop/` se conservó intacta.

`compose/compose.dev.yml` fue actualizado para usar:

```text
../../BROKER-MQTT-SGPMP
```

tanto para el build del Gateway como para la configuración de Mosquitto.

---

# 7. Contrato AIoT local y autenticación PostgreSQL

Inicialmente se detectó:

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

Para la instancia local HU-06 se configuró:

```text
DB_IOT_USER=member_iot
DB_IOT_PASSWORD=<secreto local no versionado>
```

La contraseña fue reconciliada únicamente en `SGP-HU06-DB`.

No se modificaron:

```text
backup_roles.sql
backup7_1_0.dump
rama HU-04
rama HU-05
```

Validación desde el contenedor Gateway:

```text
GATEWAY DB OK: database=dba user=member_iot
```

---

# 8. Hallazgo de permisos AIoT

Aunque `member_iot` era un login válido y pertenecía a `grp_iot`, inicialmente no existían privilegios efectivos de esquema:

```text
modulo3 → member_iot USAGE=false
modulo3 → grp_iot USAGE=false
modulo9 → member_iot USAGE=false
modulo9 → grp_iot USAGE=false
```

Los esquemas pertenecían a `dba` y no presentaban ACL para `grp_iot`.

Los objetos requeridos sí existían:

```text
modulo3.heartbeats
modulo3.transmisiones_mqtt
modulo3.fn_ingesta_telemetria
```

---

# 9. Adaptación local de permisos

Se aplicaron permisos mínimos exclusivamente sobre la instancia `SGP-HU06-DB`.

A `grp_iot`:

```text
USAGE modulo3                             ✅
USAGE modulo9                             ✅
SELECT modulo9.dispositivos_iot           ✅
SELECT modulo9.variables_ambientales      ✅
SELECT modulo9.sensores                   ✅
SELECT modulo3.estados_dispositivos_iot   ✅
INSERT/SELECT modulo3.heartbeats           ✅
INSERT modulo3.transmisiones_mqtt          ✅
EXECUTE modulo3.fn_ingesta_telemetria      ✅
```

Se mantuvo el modelo:

```text
member_iot
   ↓ INHERIT
grp_iot
   ↓
permisos AIoT
```

PostgreSQL confirmó:

```text
modulo3_usage          = true
modulo9_usage          = true
dispositivos_select    = true
heartbeats_insert      = true
transmisiones_insert   = true
```

Desde el Gateway:

```text
SCHEMAS AIOT VISIBLES: modulo3, modulo9
```

Lecturas verificadas:

```text
READ OK: modulo9.dispositivos_iot
READ OK: modulo9.variables_ambientales
READ OK: modulo9.sensores
READ OK: modulo3.estados_dispositivos_iot
```

Este ajuste corresponde exclusivamente a la instancia de integración HU-06 y debe reportarse al responsable de HU-04/DBA como hallazgo; no se considera una modificación oficial de HU-04.

---

# 10. Build y validación de Mosquitto

`docker compose ... config --quiet` pasó sin errores.

Gateway reconstruido desde el repositorio AIoT oficial:

```text
Image sgpmp-dev-gateway Built
```

Mosquitto DEV:

```text
Contenedor: sgpmp-mosquitto-dev
Imagen: eclipse-mosquitto:2
Estado: running
Health: healthy
Proyecto Compose: sgpmp-dev
```

Puertos publicados:

```text
1883 → MQTT
9001 → WebSocket MQTT
```

Logs:

```text
Opening ipv4 listen socket on port 1883
Opening ipv6 listen socket on port 1883
Opening ipv4 listen socket on port 9001
Opening ipv6 listen socket on port 9001
mosquitto version 2.1.2 running
```

Los clientes `mosquitto_pub` y `mosquitto_sub` están disponibles dentro del contenedor.

Prueba publish/subscribe:

```text
Topic: sgpmp/hu06/test
Payload: HU06_MQTT_OK
Resultado recibido: HU06_MQTT_OK
```

Resultado:

```text
✅ broker operativo
✅ listener MQTT
✅ listener WebSocket
✅ publish
✅ subscribe
```

---

# 11. Gateway DEV permanente

Gateway levantado con:

```text
sgpmp-gateway-dev
```

Estado:

```text
project=sgpmp-dev
status=running
health=healthy
```

Puerto:

```text
8002 → 8000
```

Logs:

```text
Application startup complete.
Uvicorn running on 0.0.0.0:8000
GET /v1/healthz → 200 OK
```

Validación desde host:

```text
http://localhost:8002/v1/healthz
HTTP 200
```

Conectividad Gateway → Mosquitto usando las variables reales del contenedor:

```text
GATEWAY MQTT TCP OK: mosquitto:1883
```

---

# 12. Estado consolidado del ambiente DEV al cierre de ST-02

`docker compose ... ps`:

```text
sgpmp-backend-dev     running / healthy
sgpmp-frontend-dev    running
sgpmp-gateway-dev     running / healthy
sgpmp-mosquitto-dev   running / healthy
```

Puertos:

```text
backend     8000 → 8000
frontend    5173 → 5173
gateway     8002 → 8000
mosquitto   1883 → 1883
mosquitto   9001 → 9001
```

La base de datos no aparece en `docker compose ps` porque se consume externamente mediante:

```text
SGP-HU06-DB
host.docker.internal:5433
```

---

# 13. Cierre de ST-02

Resultado:

```text
HU-04 / PostgreSQL                     ✅
Backend → PostgreSQL                   ✅
Frontend                               ✅
Frontend → Backend                     ✅
HU-05 / repositorio AIoT               ✅
Gateway build                          ✅
Gateway → PostgreSQL                   ✅
member_iot / grp_iot                   ✅
modulo3 / modulo9                      ✅
Mosquitto DEV                          ✅
MQTT publish/subscribe                 ✅
Gateway → Mosquitto                    ✅
Gateway /v1/healthz                    ✅
```

**ST-02 queda técnicamente completada.**

---

# 14. Pendiente para ST-03

La siguiente subtarea será la verificación integral del ambiente DEV:

1. ejecutar Compose completo con la definición DEV;
2. validar todos los servicios y healthchecks;
3. comprobar endpoints principales;
4. revisar logs en búsqueda de errores críticos;
5. validar reinicio/control de dependencias;
6. recopilar evidencias finales;
7. documentar hallazgos, limitaciones y criterios de cierre;
8. preparar el cierre de HU-06.
