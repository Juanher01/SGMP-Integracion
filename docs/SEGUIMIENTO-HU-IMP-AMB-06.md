# Seguimiento técnico — HU-IMP-AMB-06
## Montaje del ambiente DEV

**Rama:** `feat/ambiente-dev`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-06 — Montaje del ambiente DEV
**Estado:** ⏳ En progreso

---

# 1. Objetivo

Montar y validar el ambiente DEV utilizando las definiciones heredadas de HU-01 y HU-02, integrando la capa de base de datos entregada por HU-04 y, posteriormente, la capa AIoT entregada por HU-05.

---

# 2. Estado de subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Build local de backend/frontend con `.env.dev` | ✅ Completada |
| ST-02 | Integrar capa BD de HU-04 y capa AIoT de HU-05 | ⏳ En progreso |
| ST-03 | Verificación integral, healthchecks y evidencias | ⏳ Pendiente |

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

El archivo local de ejecución es:

```text
./.env.dev
```

y el contrato versionado se mantiene en:

```text
env/.env.dev.example
```

Los archivos reales `.env.*` permanecen ignorados por Git.

---

# 4. ST-02 — Integración de HU-04

HU-04 fue probada en un worktree aislado para no mezclar su rama completa con HU-06.

```text
implementacion       → feat/ambiente-dev
implementacion-hu04  → detached HEAD de origin/feat/db-restauracion-dbintegrador
```

Commit probado:

```text
ce7fd5d feat: adaptar restauración a DBIntegrador
```

## 4.1 Fuente recibida

Se verificaron los artefactos de DBIntegrador:

```text
backup7_1_0.dump
backup_roles.sql
docker-compose.yml
dockerfile
scripts/restaurar-bd.sh
```

## 4.2 Instancia aislada para HU-06

Se creó exclusivamente para la prueba:

```text
Contenedor: SGP-HU06-DB
Volumen: sgmp_hu06_hu04_pgdata
Puerto host: 5433
Puerto interno: 5432
Base: dba
Usuario inicial: dba
PostgreSQL: 18
```

## 4.3 Restauración validada

Resultado:

```text
✅ PostgreSQL 18 iniciado
✅ backup_roles.sql aplicado
✅ pg_cron habilitado
✅ backup7_1_0.dump restaurado
✅ schemas modulo1 a modulo9 encontrados
✅ roles esperados encontrados
✅ script finalizó correctamente
```

Tablas restauradas:

```text
auditoria      3
modulo1       15
modulo2       19
modulo3       17
modulo4       24
modulo5       25
modulo6       18
modulo7       15
modulo8       13
modulo9       38
```

Total:

```text
187 tablas
```

Roles validados:

```text
dba
member_deploy
member_dev
member_impl
member_iot
member_qa
```

Extensión:

```text
pg_cron
```

---

# 5. Hallazgo de autenticación durante la integración

La restauración aplicó `backup_roles.sql`, el cual contiene un `ALTER ROLE dba ... PASSWORD ...`.

El `pg_hba.conf` de la instancia restaurada quedó con:

```text
local / localhost → trust
conexiones remotas → scram-sha-256
```

Por esta razón, una conexión local podía funcionar sin validar realmente la contraseña mientras una conexión desde otro contenedor fallaba.

Para la instancia aislada HU-06 se realizó una reconciliación local de la contraseña del rol `dba` después de la restauración.

Este ajuste:

- se realizó únicamente sobre `SGP-HU06-DB`;
- no modificó `backup_roles.sql`;
- no modificó el dump;
- no modificó la rama HU-04;
- no versionó ningún secreto.

Después del ajuste se validó autenticación remota correctamente.

---

# 6. Pruebas de conectividad backend → HU-04

## 6.1 TCP

Desde `sgpmp-dev-backend:latest`:

```text
TCP OK -> host.docker.internal:5433
```

Resultado:

```text
✅ red / puerto accesibles
```

## 6.2 PostgreSQL

Desde la imagen backend:

```text
DB OK: database=dba user=dba
```

Resultado:

```text
✅ autenticación PostgreSQL
✅ base dba accesible
✅ usuario dba válido
```

## 6.3 Contrato real de Compose

Se ejecutó el backend mediante `docker compose run --no-deps` utilizando la `DATABASE_URL` generada por `compose.dev.yml`.

Resultado:

```text
COMPOSE DB OK: database=dba user=dba
```

Esto confirmó:

```text
.env.dev
   ↓
compose.dev.yml
   ↓
DATABASE_URL
   ↓
backend
   ↓
host.docker.internal:5433
   ↓
HU-04
```

---

# 7. Adaptación realizada en DEV

La entrega HU-04 establece que la BD se consume externamente en DEV.

Se actualizaron:

```text
compose/compose.dev.yml
env/.env.dev.example
```

Contrato DEV:

```text
DB_HOST=host.docker.internal
DB_PORT=5433
DB_NAME=dba
DB_APP_USER=dba
DB_APP_PASSWORD=<secreto local>
```

## 7.1 Servicio database interno

El servicio `database` heredado se conserva para no modificar la arquitectura base de HU-01, pero en DEV queda bajo el perfil:

```text
internal-db
```

En la ejecución DEV normal no se activa.

Validación:

```text
docker compose ... config --profiles
→ internal-db
```

Servicios DEV activos sin perfil:

```text
backend
frontend
mosquitto
gateway
```

Por tanto:

```text
database interno → no participa en DEV normal
```

## 7.2 Dependencias

Backend:

```text
depends_on database → eliminado en override DEV
```

Gateway:

```text
depends_on database → eliminado en override DEV
depends_on mosquitto → conservado
```

Validación de Compose:

```text
docker compose ... config --quiet
→ OK
```

---

# 8. Separación de contenedores legacy

Se detectaron contenedores antiguos pertenecientes al proyecto Compose:

```text
project=implementacion
```

No se eliminaron.

Se detuvieron y renombraron:

```text
sgpmp-backend-dev-legacy
sgpmp-frontend-dev-legacy
```

Esto liberó:

```text
8000
5173
```

para la ejecución HU-06.

---

# 9. Backend DEV real contra HU-04

Se levantó únicamente el backend nuevo:

```text
docker compose ... up -d --build --no-deps backend
```

Validación:

```text
project=sgpmp-dev
service=backend
status=running
```

Estado Docker:

```text
Up (...) (healthy)
0.0.0.0:8000->8000/tcp
```

Logs:

```text
Application startup complete.
GET /health → 200 OK
```

Prueba HTTP:

```text
GET /docs → HTTP 200
```

Resultado consolidado:

```text
✅ backend DEV construido
✅ backend DEV iniciado
✅ healthcheck correcto
✅ HTTP correcto
✅ backend consume HU-04 externa
✅ no se levanta una segunda BD interna
```

---

# 10. Estado actual de ST-02

Parte HU-04:

```text
Restauración                    ✅
Schemas / tablas / roles        ✅
pg_cron                         ✅
TCP backend → BD                ✅
Autenticación backend → BD      ✅
DATABASE_URL Compose → BD       ✅
Adaptación Compose DEV          ✅
Backend real → HU-04            ✅
Health backend                  ✅
HTTP backend                    ✅
```

**Integración de la capa de base de datos HU-04: COMPLETADA para DEV.**

Parte HU-05:

```text
Integración AIoT / MQTT / Gateway → PENDIENTE
```

ST-02 permanece abierta hasta disponer y validar la entrega HU-05.

---

# 11. Próximos pasos

1. Versionar el checkpoint de integración HU-04.
2. Levantar y validar frontend DEV contra el backend actual.
3. Verificar disponibilidad de HU-05.
4. Integrar Mosquitto/Gateway cuando HU-05 esté disponible.
5. Ejecutar ST-03 únicamente después de contar con todas las capas.
