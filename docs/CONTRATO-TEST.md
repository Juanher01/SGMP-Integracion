# Contrato de entrega del ambiente TEST

**HU:** HU-IMP-AMB-07 — Montaje del ambiente TEST
**Subtarea:** ST-02 — Redactar el contrato de entrega
**Responsable:** Juan Sebastián Gutiérrez Tobar
**Rama:** `feat/ambiente-test` 
**Estado:** Verificado sobre archivos reales — con variables pendientes de terceros (ver §6)
**Fecha:** 20 de agosto de 2026


---

## 1. Principio de responsabilidad

**Implementación monta y orquesta el ambiente TEST. Pruebas lo opera.**
Implementación es responsable de que las cuatro capas estén disponibles, sean estables y expongan una URL fija. Pruebas ejecuta su stack de validación (Cypress, Vitest, Pytest, Playwright, cypress-axe, Newman, k6, OWASP ZAP) contra esa URL, sin instalar, configurar ni mantener infraestructura.

Ver `docs/REQUISITOS-PRUEBAS-TEST.md` (ST-01) para el detalle completo de la conciliación con Pruebas.

---

## 2. Levantamiento del ambiente

```bash
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test up -d
```

- Proyecto Compose: `sgpmp-test`
- Red compartida: `sgpmp-network` (bridge)
- Volumen persistente de base de datos: `postgres-data`

---

## 3. Servicios, puertos y healthchecks

| Capa | Contenedor | Puerto host → contenedor | Imagen | Healthcheck |
|---|---|---|---|---|
| Base de datos | `sgpmp-database-test` | No expuesto al host (interno en `sgpmp-network`, 5432) | `${DATABASE_IMAGE}` | `pg_isready` (definido en base) |
| Backend | `sgpmp-backend-test` | `8001` → `8000` | `${BACKEND_IMAGE}` | Depende de `database` en estado `healthy` |
| Frontend | `sgpmp-frontend-test` | `8081` → `80` | `${FRONTEND_IMAGE}` | Depende de `backend` en estado `healthy` |
| Gateway AIoT | `sgpmp-gateway-test` | `8003` → `8000` | `${GATEWAY_IMAGE}` | `http://127.0.0.1:8000/v1/healthz` (definido en base); depende de `database` y `mosquitto` en estado `healthy` |
| Broker Mosquitto | `sgpmp-mosquitto-test` | `1884`→`1883` (MQTT) · `9002`→`9001` (WebSockets) | `eclipse-mosquitto:2` | Verificado en puerto 1883 (definido en base) |

**URLs de acceso para Pruebas:**
- Backend: `http://localhost:8001`
- Frontend: `http://localhost:8081`
- Gateway AIoT: `http://localhost:8003`
- Mosquitto (MQTT): `localhost:1884`
- Mosquitto (WebSockets): `localhost:9002`

**Configuración de Mosquitto:** se monta desde el repositorio hermano `../../BROKER-MQTT-SGPMP-develop/docker/mosquitto.conf` (solo lectura). Requiere que ese repositorio esté clonado como hermano de `SGMP-Integracion`.

**TLS del gateway en TEST:** `MQTT_TLS=false` — coherente con la matriz del backlog (TLS obligatorio solo en PROD).

---

## 4. Variables de entorno

El catálogo completo vive en `env/.env.test.example` (48 variables, documentadas en `docs/VARIABLES-ENTORNO.md` y `docs/FR-IMP-CE-04.md`). DEV, TEST y PROD comparten exactamente el mismo catálogo de nombres; solo cambian los valores.

### 4.1 Variables ya resueltas (con valor de ejemplo funcional)

| Variable | Valor | Ámbito |
|---|---|---|
| `ENVIRONMENT` | `test` | General |
| `DB_HOST` | `database` | Base de datos |
| `DB_PORT` | `5432` | Base de datos |
| `DB_NAME` | `dba` | Base de datos |
| `DB_ADMIN_USER` | `dba` | Base de datos |
| `DB_SCHEMA_INGEST` | `modulo3` | Gateway / BD |
| `DB_SCHEMA_REGISTRY` | `modulo9` | Gateway / BD |
| `FRONTEND_URL` | `http://localhost:8081` | Backend / CORS |
| `JWT_EXPIRE_HOURS` | `24` | Backend |
| `SMTP_HOST` / `SMTP_PORT` | `smtp.gmail.com` / `587` | Backend / Mail |
| `MODELOS_STORAGE_PATH` | `/tmp/sgpmp_modelos` | Backend |
| `VITE_API_BASE_URL` | `http://localhost:8001` | Frontend (solo build DEV) |
| `MQTT_HOST` / `MQTT_PORT` | `mosquitto` / `1883` | Gateway / MQTT |
| `MQTT_TLS` | `false` | Gateway / MQTT |
| `MQTT_CLIENT_ID` | `sgpmp` | Gateway / MQTT |
| `MQTT_TOPIC_*` (prefix, telemetry, heartbeat, command, status) | Definidos | Gateway / MQTT |

### 4.2 Variables sin valor — deben resolverse antes de levantar TEST

| Variable | Quién la provee | Uso |
|---|---|---|
| `DATABASE_IMAGE`, `BACKEND_IMAGE`, `FRONTEND_IMAGE`, `GATEWAY_IMAGE` | CI/CD / equipos de Desarrollo (tags publicados en GHCR) | Imagen de cada contenedor |
| `DB_APP_USER`, `DB_APP_PASSWORD` | DBA | Conexión del backend a la BD |
| `DB_IOT_USER`, `DB_IOT_PASSWORD` | DBA | Conexión del gateway a la BD |
| `SECRET_KEY` | Implementación / DevOps | Firma JWT del backend |
| `RF71_INTERNAL_KEY` | Implementación / DevOps | Seguridad interna del backend |
| `GATEWAY_API_TOKEN` | AIoT | Autenticación backend → gateway |
| `MQTT_USERNAME`, `MQTT_PASSWORD` | AIoT | Autenticación del gateway al broker |
| `FIREBASE_CREDENTIALS_PATH`, `SMTP_USER`, `SMTP_PASSWORD` | Implementación / Desarrollo | Notificaciones (no crítico para levantar el ambiente) |
| `VITE_FIREBASE_*`, `VITE_VAPID_KEY`, `VITE_AGROFUSION_LOGIN_URL` | Desarrollo Frontend | Solo aplican a build de DEV; no bloquean TEST (frontend se consume como imagen ya construida) |

> **Clasificación de sensibilidad** (según `docs/FR-IMP-CE-04.md`): `DB_APP_PASSWORD`, `DB_IOT_PASSWORD`, `SECRET_KEY`, `RF71_INTERNAL_KEY`, `SMTP_PASSWORD`, `GATEWAY_API_TOKEN` y `MQTT_PASSWORD` son **Secretas** — nunca se versionan con valores reales, solo se documentan como placeholders en `.env.test.example`.

### 4.3 Verificación de coherencia

No hay variables que el compose necesite y no estén declaradas en `.env.test.example`, ni variables sobrantes sin uso — el catálogo está sincronizado con `compose/docker-compose.yml` + `compose/compose.test.yml`.

---

## 5. Base de datos: acceso y credenciales

- **Rol dedicado para Pruebas:** `member_qa` (grupo `grp_qa`, límite de 10 conexiones, contraseña propia) — ya provisto por el DBA en `DBIntegrador`.
- **Versión de PostgreSQL:** `postgres:18`.
- **Nomenclatura unificada (confirmado):** se eliminaron `POSTGRES_*` y `JWT_*` obsoletas; todo el proyecto usa la familia `DB_*`.
- **Construcción de conexión:**
  - Backend: `postgresql://${DB_APP_USER}:${DB_APP_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`
  - Gateway: `postgresql+asyncpg://${DB_IOT_USER}:${DB_IOT_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`
- **Acción pendiente:** coordinar con el DBA (Samuel) la entrega formal de credenciales reales para `DB_APP_*` y `DB_IOT_*`.

---

## 6. Datos y RBAC — pendiente de confirmación de Pruebas

Sigue abierto hasta recibir respuesta al catálogo enviado a Sara Sofía González (ver `docs/REQUISITOS-PRUEBAS-TEST.md`, §4):
- Política de datos semilla (¿la siembra Implementación o Pruebas?).
- Si la base de datos debe reiniciarse a un estado determinista antes de cada corrida.
- Usuarios/roles adicionales más allá de `member_qa`.
- Colección Postman y URL base para Newman.
- Endpoints objetivo para k6.
- Alcance/URL autorizada para el escaneo de OWASP ZAP.

---

## 7. Puntos pendientes de cierre

| # | Punto | Impacto | Responsable / dependencia |
|---|---|---|---|
| 1 | Tags de imágenes vacíos (`DATABASE_IMAGE`, `BACKEND_IMAGE`, `FRONTEND_IMAGE`, `GATEWAY_IMAGE`) | Sin esto, Docker Compose falla por referencia de imagen inválida | CI/CD / equipos de Desarrollo — no existe pipeline (`.github/workflows/`) todavía |
| 2 | Credenciales de BD vacías (`DB_APP_USER`, `DB_APP_PASSWORD`, `DB_IOT_USER`, `DB_IOT_PASSWORD`) | Backend y gateway no pueden conectar a la BD | DBA (Samuel) |
| 3 | Secretos de aplicación vacíos (`SECRET_KEY`, `RF71_INTERNAL_KEY`) | Backend no puede firmar JWT ni operar con seguridad interna | Implementación / DevOps — puede resolverse internamente sin depender de terceros |
| 4 | `GATEWAY_API_TOKEN`, `MQTT_USERNAME`, `MQTT_PASSWORD` vacíos | Backend no puede autenticarse con el gateway; gateway no puede autenticarse con Mosquitto | AIoT |
| 5 | Datos semilla / RBAC de Pruebas sin confirmar | ST-04 no puede cerrarse | Pruebas (Sara Sofía González) |

**Veredicto de ejecución:** el ambiente está **completamente definido y sincronizado** (compose + catálogo de variables), pero **no puede levantarse hoy** por las variables vacías del punto 1, 2 y 4. El punto 3 sí es accionable de forma inmediata por Implementación.

---

## 8. Estado de la subtarea

- [x] Servicios, URLs, puertos y healthchecks documentados con datos reales verificados sobre los archivos actuales de la rama.
- [x] Catálogo completo de variables auditado, sin mismatches entre compose y `.env.test.example`.
- [x] Responsables de cada variable pendiente identificados explícitamente.
- [x] Acceso a base de datos y rol de Pruebas confirmados.
- [ ] `SECRET_KEY` y `RF71_INTERNAL_KEY` — accionable ya por Implementación (no bloqueado por terceros).
- [ ] Tags de imágenes en GHCR — pendiente de pipeline CI/CD.
- [ ] Credenciales de BD — pendiente del DBA.
- [ ] `GATEWAY_API_TOKEN` / credenciales MQTT — pendiente de AIoT.
- [ ] Datos semilla / RBAC — pendiente de respuesta de Pruebas.

**ST-02 se entrega completo y verificado.** La arquitectura de TEST está totalmente definida; lo que resta es la entrega de valores reales por parte de terceros (DBA, AIoT, CI/CD) y la respuesta de Pruebas sobre política de datos — ninguno de estos puntos requiere redefinir el contrato, solo completarlo.
