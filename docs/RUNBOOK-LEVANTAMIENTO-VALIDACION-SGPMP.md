# RUNBOOK — Levantamiento y validación de ambientes SGPMP

**Repositorio:** `SGMP-Integracion`  
**Rama de validación:** `main`  
**Objetivo:** permitir al Líder de Implementación reproducir y validar el estado real de los ambientes integrados.  
**Sistema operativo de referencia:** Windows + Docker Desktop + Git Bash.

---

# 1. Estado actual de los ambientes

| Ambiente | Estado actual | ¿Se puede levantar completamente? | Observación |
|---|---|---:|---|
| DEV | COMPLETADO Y VALIDADO | Sí | Es el ambiente funcional disponible actualmente. |
| TEST | DEFINIDO, BLOQUEADO POR INSUMOS | No todavía | Faltan imágenes versionadas y credenciales externas. |
| PROD | DEFINIDO COMO FRONTERA IMPLEMENTACIÓN → DESPLIEGUE | No localmente | La operación corresponde a Despliegue/Dokploy. |

Este runbook permite ejecutar una validación completa de **DEV** y verificar el estado/bloqueos de **TEST** y **PROD**.

---

# 2. Arquitectura actual de DEV

DEV utiliza cuatro servicios gestionados por el Compose de Integración:

```text
Frontend
Backend
Gateway
Mosquitto
```

La base de datos DBIntegrador se levanta de forma separada mediante el procedimiento de HU-04 y es consumida por Backend y Gateway.

```text
                  EQUIPO LOCAL
┌──────────────────────────────────────────────┐
│                                              │
│  PostgreSQL / DBIntegrador                   │
│  SGP-RUNBOOK-DB                              │
│  host:5433 ─────────────────────┐             │
│                                 │             │
│                  host.docker.internal:5433    │
│                                 │             │
│        ┌────────────────────────┴──────┐      │
│        │                               │      │
│   Backend DEV                    Gateway DEV  │
│      :8000                         :8002      │
│                                      │       │
│                                      ▼       │
│                                Mosquitto DEV │
│                               :1883 / :9001  │
│                                              │
│   Frontend DEV :5173 ─────► Backend DEV     │
│                                              │
└──────────────────────────────────────────────┘
```

---

# 3. Precondiciones

Antes de comenzar debe estar instalado:

- Git.
- Git Bash.
- Docker Desktop.
- Docker Compose.
- `iconv` disponible en Git Bash.
- Repositorios requeridos clonados localmente.

Estructura esperada:

```text
SGMP/
├── implementacion/                 # SGMP-Integracion
├── sgpmp-backend/
├── SGPMP-FRONT-END-PWA/
├── DBIntegrador-master/
└── BROKER-MQTT-SGPMP/
```

La estructura es importante porque los Compose DEV usan rutas relativas hacia los repositorios hermanos.

---

# 4. Actualizar el repositorio de Integración

Entrar al repositorio:

```bash
cd ~/OneDrive/Escritorio/SGMP/implementacion
```

Cambiar a `main`:

```bash
git switch main
```

Actualizar:

```bash
git pull --ff-only origin main
```

Verificar:

```bash
git status
```

Resultado esperado:

```text
On branch main
nothing to commit, working tree clean
```

Revisar commits recientes:

```bash
git log --oneline -10
```

---

# 5. Comprobar dependencias externas

## 5.1 Backend

```bash
test -f ../sgpmp-backend/Dockerfile \
  && echo "OK: backend disponible" \
  || echo "ERROR: falta ../sgpmp-backend"
```

## 5.2 Frontend

```bash
test -f ../SGPMP-FRONT-END-PWA/Dockerfile \
  && echo "OK: frontend disponible" \
  || echo "ERROR: falta ../SGPMP-FRONT-END-PWA"
```

## 5.3 Gateway / Mosquitto

```bash
test -f ../BROKER-MQTT-SGPMP/Dockerfile \
  && echo "OK: Gateway disponible" \
  || echo "ERROR: falta ../BROKER-MQTT-SGPMP"
```

```bash
test -f ../BROKER-MQTT-SGPMP/docker/mosquitto.conf \
  && echo "OK: mosquitto.conf disponible" \
  || echo "ERROR: falta mosquitto.conf"
```

## 5.4 DBIntegrador

```bash
for f in \
  docker-compose.yml \
  backup7_1_0.dump \
  backup_roles.sql
do
  test -f "../DBIntegrador-master/$f" \
    && echo "OK: $f" \
    || echo "ERROR: falta $f"
done
```

Debe existir también `Dockerfile` o `dockerfile` dentro de `DBIntegrador-master`.

---

# 6. Preparar la base de datos DEV

## 6.1 Concepto

El Compose normal de DEV **no crea la base de datos**.

HU-04 entrega DBIntegrador como una capa externa reproducible. El script:

```text
scripts/restaurar-bd.sh
```

crea PostgreSQL, restaura el dump, aplica los roles y valida la base.

Para evitar afectar otras instancias locales durante la prueba del líder, este runbook utiliza:

```text
Contenedor: SGP-RUNBOOK-DB
Volumen:    sgpmp_runbook_pgdata
Puerto:     5433
Base:       dba
```

---

## 6.2 Definir contraseñas locales

El líder debe elegir dos contraseñas temporales/locales:

```bash
export DBA_PASSWORD='VALOR_LOCAL_NO_VERSIONADO'
export DB_IOT_PASSWORD='OTRO_VALOR_LOCAL_NO_VERSIONADO'
```

Estas contraseñas:

- son solo para la prueba local;
- no deben copiarse al repositorio;
- no deben enviarse por chat;
- no deben aparecer en capturas o evidencias.

---

## 6.3 Restaurar DBIntegrador

Ejecutar desde la raíz de `implementacion`:

```bash
CONTAINER=SGP-RUNBOOK-DB \
VOLUME=sgpmp_runbook_pgdata \
DB_PORT=5433 \
DBA_PASSWORD="$DBA_PASSWORD" \
bash scripts/restaurar-bd.sh --reset
```

`--reset` elimina y reconstruye **solo el volumen indicado para esta prueba**.

El script realiza:

```text
1. Comprueba Docker.
2. Comprueba DBIntegrador-master.
3. Copia temporalmente el dump y roles.
4. Normaliza backup_roles.sql si está en UTF-16.
5. Construye PostgreSQL 18.
6. Publica 5433 → 5432.
7. Aplica backup_roles.sql.
8. Habilita pg_cron.
9. Restaura backup7_1_0.dump.
10. Valida modulo1 ... modulo9.
11. Valida las tablas.
12. Valida los roles.
13. Valida pg_cron.
```

Resultado final esperado:

```text
OK: restauración HU-04 completada.
```

---

## 6.4 Comprobar estado de la BD

```bash
docker inspect SGP-RUNBOOK-DB \
  --format 'status={{.State.Status}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}sin-healthcheck{{end}}'
```

Esperado:

```text
status=running health=healthy
```

Comprobar puerto:

```bash
docker ps \
  --filter "name=SGP-RUNBOOK-DB" \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Debe aparecer:

```text
5433->5432/tcp
```

---

# 7. Ajustar credenciales locales después de la restauración

`backup_roles.sql` restaura la definición de los roles. Para asegurar que la instancia local utiliza las contraseñas elegidas por el líder, se reconcilian los usuarios necesarios.

Ejecutar:

```bash
docker exec -i SGP-RUNBOOK-DB \
  psql \
    -U dba \
    -d dba \
    -v dba_pass="$DBA_PASSWORD" \
    -v iot_pass="$DB_IOT_PASSWORD" <<'SQL'
ALTER ROLE dba WITH PASSWORD :'dba_pass';
ALTER ROLE member_iot WITH PASSWORD :'iot_pass';
SQL
```

Esperado:

```text
ALTER ROLE
ALTER ROLE
```

Verificar existencia de los roles AIoT:

```bash
docker exec -i SGP-RUNBOOK-DB \
  psql -U dba -d dba -c \
  "SELECT rolname FROM pg_roles WHERE rolname IN ('grp_iot','member_iot') ORDER BY rolname;"
```

Deben aparecer:

```text
grp_iot
member_iot
```

---

# 8. Aplicar permisos AIoT requeridos para DEV

Durante la validación de HU-06 se identificó que los roles existían, pero la instancia restaurada no entregaba todos los privilegios efectivos requeridos para que el Gateway accediera a `modulo3` y `modulo9`.

Aplicar en **esta instancia local**:

```bash
docker exec -i SGP-RUNBOOK-DB \
  psql -U dba -d dba <<'SQL'
GRANT USAGE ON SCHEMA modulo3 TO grp_iot;
GRANT USAGE ON SCHEMA modulo9 TO grp_iot;

GRANT SELECT ON TABLE
    modulo9.dispositivos_iot,
    modulo9.variables_ambientales,
    modulo9.sensores,
    modulo3.estados_dispositivos_iot
TO grp_iot;

GRANT INSERT, SELECT
ON TABLE modulo3.heartbeats
TO grp_iot;

GRANT INSERT
ON TABLE modulo3.transmisiones_mqtt
TO grp_iot;

DO $$
DECLARE
    f regprocedure;
BEGIN
    SELECT p.oid::regprocedure
      INTO f
      FROM pg_proc p
      JOIN pg_namespace n
        ON n.oid = p.pronamespace
     WHERE n.nspname = 'modulo3'
       AND p.proname = 'fn_ingesta_telemetria'
     LIMIT 1;

    IF f IS NOT NULL THEN
        EXECUTE format(
            'GRANT EXECUTE ON FUNCTION %s TO grp_iot',
            f
        );
    END IF;
END
$$;
SQL
```

Este procedimiento modifica únicamente la instancia local de prueba. No modifica `DBIntegrador-master`.

Verificar privilegios:

```bash
docker exec -i SGP-RUNBOOK-DB \
  psql -U dba -d dba <<'SQL'
SELECT
  has_schema_privilege('member_iot', 'modulo3', 'USAGE')
    AS modulo3_usage,
  has_schema_privilege('member_iot', 'modulo9', 'USAGE')
    AS modulo9_usage,
  has_table_privilege(
    'member_iot',
    'modulo9.dispositivos_iot',
    'SELECT'
  ) AS dispositivos_select,
  has_table_privilege(
    'member_iot',
    'modulo3.heartbeats',
    'INSERT'
  ) AS heartbeats_insert,
  has_table_privilege(
    'member_iot',
    'modulo3.transmisiones_mqtt',
    'INSERT'
  ) AS transmisiones_insert;
SQL
```

Los valores deben ser `t` / `true`.

---

# 9. Preparar `.env.dev`

## 9.1 Crear el archivo

```bash
cp env/.env.dev.example .env.dev
```

## 9.2 Completar valores requeridos

Abrir:

```bash
notepad .env.dev
```

Mantener:

```dotenv
ENVIRONMENT=dev

DB_HOST=host.docker.internal
DB_PORT=5433
DB_NAME=dba

DB_ADMIN_USER=dba
DB_APP_USER=dba
DB_IOT_USER=member_iot

DB_SCHEMA_INGEST=modulo3
DB_SCHEMA_REGISTRY=modulo9

FRONTEND_URL=http://localhost:5173
VITE_API_BASE_URL=http://localhost:8000

MQTT_HOST=mosquitto
MQTT_PORT=1883
MQTT_TLS=false
```

Completar manualmente:

```dotenv
DB_APP_PASSWORD=<mismo valor elegido para DBA_PASSWORD>
DB_IOT_PASSWORD=<mismo valor elegido para DB_IOT_PASSWORD>

SECRET_KEY=<valor local seguro>
RF71_INTERNAL_KEY=<valor local seguro>
GATEWAY_API_TOKEN=<valor local seguro>
```

Para DEV, las variables SMTP/Firebase pueden permanecer sin valor si esas integraciones no forman parte de esta prueba.

Mosquitto DEV opera con la configuración local recibida y permite conexión anónima, por lo que:

```dotenv
MQTT_USERNAME=
MQTT_PASSWORD=
```

pueden permanecer vacías en esta validación local.

---

## 9.3 Verificar que `.env.dev` no se versiona

```bash
git check-ignore -v .env.dev
```

Debe aparecer una regla de `.gitignore`.

También:

```bash
git status --short --untracked-files=all |
grep '\.env\.dev$' ||
echo "OK: .env.dev no será versionado"
```

Esperado:

```text
OK: .env.dev no será versionado
```

---

# 10. Validar la configuración de DEV

Ejecutar:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --quiet
```

Si no imprime errores:

```text
COMPOSE DEV CONFIG: OK
```

Comprobar servicios del perfil normal:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --services
```

Esperado:

```text
mosquitto
gateway
backend
frontend
```

No debe aparecer `database`.

---

# 11. Levantar DEV

Ejecutar:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  up -d --build
```

Esperar:

```bash
sleep 15
```

Consultar:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  ps
```

Esperado:

```text
sgpmp-backend-dev      Up (...) healthy
sgpmp-frontend-dev     Up
sgpmp-gateway-dev      Up (...) healthy
sgpmp-mosquitto-dev    Up (...) healthy
```

Puertos:

| Servicio | Puerto host |
|---|---:|
| Backend | 8000 |
| Frontend | 5173 |
| Gateway | 8002 |
| MQTT | 1883 |
| MQTT WebSocket | 9001 |
| PostgreSQL externo | 5433 |

---

# 12. Smoke tests HTTP

Backend:

```bash
curl -s -o /dev/null \
  -w "BACKEND HEALTH: HTTP %{http_code}\n" \
  http://localhost:8000/health
```

Frontend:

```bash
curl -s -o /dev/null \
  -w "FRONTEND: HTTP %{http_code}\n" \
  http://localhost:5173/
```

Gateway:

```bash
curl -s -o /dev/null \
  -w "GATEWAY HEALTH: HTTP %{http_code}\n" \
  http://localhost:8002/v1/healthz
```

Esperado:

```text
BACKEND HEALTH: HTTP 200
FRONTEND: HTTP 200
GATEWAY HEALTH: HTTP 200
```

Mosquitto:

```bash
docker inspect sgpmp-mosquitto-dev \
  --format 'MOSQUITTO: status={{.State.Status}} health={{.State.Health.Status}}'
```

Esperado:

```text
MOSQUITTO: status=running health=healthy
```

---

# 13. Validar Backend → PostgreSQL

```bash
docker exec -i sgpmp-backend-dev \
  python - <<'PY'
import os
import psycopg2

conn = psycopg2.connect(os.environ["DATABASE_URL"])

try:
    with conn.cursor() as cur:
        cur.execute(
            "SELECT current_database(), current_user"
        )
        db, user = cur.fetchone()
        print(
            f"BACKEND DB OK: database={db} user={user}"
        )
finally:
    conn.close()
PY
```

Esperado:

```text
BACKEND DB OK: database=dba user=dba
```

---

# 14. Validar Gateway → PostgreSQL

```bash
docker exec -i sgpmp-gateway-dev \
  python - <<'PY'
import asyncio
import os

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

async def main():
    engine = create_async_engine(
        os.environ["DATABASE_URL"],
        pool_pre_ping=True
    )

    async with engine.connect() as conn:
        row = (
            await conn.execute(
                text(
                    "SELECT current_database(), current_user"
                )
            )
        ).one()

        print(
            f"GATEWAY DB OK: "
            f"database={row[0]} user={row[1]}"
        )

    await engine.dispose()

asyncio.run(main())
PY
```

Esperado:

```text
GATEWAY DB OK: database=dba user=member_iot
```

---

# 15. Validar Gateway → Mosquitto

```bash
docker exec -i sgpmp-gateway-dev \
  python - <<'PY'
import os
import socket

host = os.environ["MQTT_HOST"]
port = int(os.environ["MQTT_PORT"])

with socket.create_connection((host, port), 5):
    print(
        f"GATEWAY MQTT TCP OK: {host}:{port}"
    )
PY
```

Esperado:

```text
GATEWAY MQTT TCP OK: mosquitto:1883
```

---

# 16. Validar MQTT publish / subscribe

```bash
rm -f /tmp/sgpmp-runbook-mqtt.txt

docker exec sgpmp-mosquitto-dev \
  mosquitto_sub \
    -h 127.0.0.1 \
    -p 1883 \
    -t 'sgpmp/runbook/test' \
    -C 1 \
    -W 10 \
  > /tmp/sgpmp-runbook-mqtt.txt &

SUB_PID=$!

sleep 2

docker exec sgpmp-mosquitto-dev \
  mosquitto_pub \
    -h 127.0.0.1 \
    -p 1883 \
    -t 'sgpmp/runbook/test' \
    -m 'SGPMP_RUNBOOK_MQTT_OK'

wait "$SUB_PID"

cat /tmp/sgpmp-runbook-mqtt.txt
rm -f /tmp/sgpmp-runbook-mqtt.txt
```

Esperado:

```text
SGPMP_RUNBOOK_MQTT_OK
```

---

# 17. Revisión de logs

```bash
for container in \
  sgpmp-backend-dev \
  sgpmp-gateway-dev \
  sgpmp-mosquitto-dev
do
  echo
  echo "===== $container ====="

  docker logs --since 15m "$container" 2>&1 |
    grep -Ei \
      'traceback|exception|critical|(^|[^a-z])error([^a-z]|$)' \
    || echo "OK: sin errores críticos detectados"
done
```

Esperado:

```text
OK: sin errores críticos detectados
```

para los servicios revisados.

---

# 18. Criterio de aprobación de DEV

DEV queda aprobado cuando se cumplen todos:

```text
[OK] DBIntegrador restaurada
[OK] PostgreSQL healthy
[OK] Compose DEV válido
[OK] Backend healthy
[OK] Frontend accesible
[OK] Gateway healthy
[OK] Mosquitto healthy
[OK] Backend → PostgreSQL
[OK] Gateway → PostgreSQL
[OK] Gateway → Mosquitto
[OK] MQTT publish / subscribe
[OK] Sin errores críticos de inicialización
```

---

# 19. Detener DEV

Detener Backend, Frontend, Gateway y Mosquitto:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  down
```

No usar:

```text
-v
```

salvo que se quiera eliminar intencionalmente volúmenes asociados al proyecto Compose.

El contenedor externo de DBIntegrador no se elimina con el `down` de DEV.

---

# 20. Detener la BD del runbook conservando datos

El script HU-04 crea su Compose temporal en:

```text
.sgpmp-local/dbintegrador/
```

Para detener la instancia conservando su volumen:

```bash
docker compose \
  -f .sgpmp-local/dbintegrador/docker-compose.hu04.yml \
  --env-file .sgpmp-local/dbintegrador/.env \
  down
```

Para volver a utilizarla después, ejecutar nuevamente el script sin `--reset`:

```bash
CONTAINER=SGP-RUNBOOK-DB \
VOLUME=sgpmp_runbook_pgdata \
DB_PORT=5433 \
DBA_PASSWORD="$DBA_PASSWORD" \
bash scripts/restaurar-bd.sh --keep
```

---

# 21. Estado de TEST

TEST tiene actualmente:

```text
compose/compose.test.yml
env/.env.test.example
docs/CONTRATO-TEST.md
```

La arquitectura está definida, pero el ambiente no está operativo porque faltan insumos obligatorios.

Principales pendientes:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE

DB_APP_USER
DB_APP_PASSWORD

DB_IOT_USER
DB_IOT_PASSWORD

GATEWAY_API_TOKEN
```

También existen valores de seguridad/AIoT que deben ser suministrados por sus responsables.

Mientras las imágenes estén vacías, Docker Compose no puede crear los servicios TEST.

Por tanto:

```text
TEST = DEFINIDO, PERO NO LEVANTABLE ACTUALMENTE
```

Cuando existan todos los artefactos:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.test.yml \
  --env-file .env.test \
  config --quiet
```

y luego:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.test.yml \
  --env-file .env.test \
  up -d
```

Puertos previstos:

| Servicio TEST | Puerto |
|---|---:|
| Backend | 8001 |
| Frontend | 8081 |
| Gateway | 8003 |
| MQTT | 1884 |
| MQTT WebSocket | 9002 |

---

# 22. Estado de PROD

PROD tiene:

```text
compose/compose.prod.yml
env/.env.prod.example
docs/CONTRATO-PROD.md
```

Implementación entrega la definición técnica. La operación real corresponde a Despliegue mediante Dokploy.

PROD depende de:

```text
imágenes versionadas
credenciales de BD
SECRET_KEY / RF71_INTERNAL_KEY
GATEWAY_API_TOKEN
configuración MQTT
certificados TLS
dominios
proxy inverso
secretos de Despliegue
```

No se deben reutilizar secretos de DEV o TEST para intentar simular producción.

Una vez Despliegue tenga las variables autorizadas, la configuración puede comprobarse con:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.prod.yml \
  --env-file .env.prod \
  config --quiet
```

La ejecución productiva se realiza en la infraestructura administrada por Despliegue.

---

# 23. Resumen para el líder

| Validación | DEV | TEST | PROD |
|---|---|---|---|
| Compose definido | Sí | Sí | Sí |
| Catálogo de variables | Sí | Sí | Sí |
| Artefactos suficientes | Sí | No | No |
| Credenciales suficientes | Sí, locales | No | No |
| Puede ejecutarse actualmente | Sí | No | No localmente |
| Healthchecks funcionales | Sí | Pendiente | Despliegue |
| Backend → BD | Validado | Pendiente | Pendiente |
| Gateway → BD | Validado | Pendiente | Pendiente |
| MQTT | Validado | Pendiente | Pendiente |
| Estado | OPERATIVO | DEFINIDO / BLOQUEADO | DEFINIDO / ENTREGA |

---

# 24. Resultado esperado de la revisión

La revisión puede considerarse satisfactoria si:

1. La rama `main` está actualizada.
2. DBIntegrador se restaura correctamente.
3. DEV levanta mediante Docker Compose.
4. Backend, Frontend, Gateway y Mosquitto están disponibles.
5. Backend se conecta a PostgreSQL.
6. Gateway se conecta a PostgreSQL.
7. Gateway alcanza Mosquitto.
8. La prueba MQTT publish/subscribe funciona.
9. No existen errores críticos de inicialización.
10. TEST y PROD se reportan con sus bloqueos reales sin inventar imágenes, credenciales o secretos.

---

# 25. Nota de seguridad

Nunca incluir en commits, capturas o documentación:

```text
DBA_PASSWORD
DB_APP_PASSWORD
DB_IOT_PASSWORD
SECRET_KEY
RF71_INTERNAL_KEY
GATEWAY_API_TOKEN
SMTP_PASSWORD
tokens
certificados privados
```

Los archivos reales:

```text
.env.dev
.env.test
.env.prod
```

deben permanecer fuera de Git.
