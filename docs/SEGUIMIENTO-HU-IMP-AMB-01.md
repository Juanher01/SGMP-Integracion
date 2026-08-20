# Seguimiento HU-IMP-AMB-01 — Compose base y convención de orquestación

**Responsable:** Juan Esteban Hernández Lozano  
**Rama de trabajo:** `feat/compose-base`  
**Historia de Usuario:** HU-IMP-AMB-01 — Compose base y convención de orquestación  

---

## ST-01 — Reorganizar `compose/` y `dockerfiles/`

**Estado:** ✅ Completada

### Objetivo

Reorganizar la estructura del repositorio de infraestructura para cumplir con la convención definida en el backlog.

### Cambios realizados

```text
compose/
├── docker-compose.yml
├── compose.dev.yml
├── compose.test.yml
└── compose.prod.yml

dockerfiles/
├── backend/
│   ├── .dockerignore
│   └── Dockerfile
└── frontend/
    ├── .dockerignore
    ├── Dockerfile
    └── nginx.conf
```

### Validación

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --services
```

Resultado inicial:

```text
backend
frontend
```

### Commit

```text
47a8e75 refactor(compose): reorganiza estructura de orquestacion
```

---

## ST-02 — Compose base con las cuatro capas

**Estado:** ✅ Completada

### Objetivo

Representar las cuatro capas requeridas mediante cinco servicios técnicos:

```text
database
backend
frontend
gateway
mosquitto
```

### Cambios principales

- Se eliminó la dependencia de `docker_default`.
- Se creó la red propia `sgpmp-network`.
- Se agregó `database`.
- Se agregó volumen `postgres-data`.
- Se agregó healthcheck de PostgreSQL con `pg_isready`.
- Se agregó `mosquitto` con `eclipse-mosquitto:2`.
- Se agregó healthcheck de Mosquitto sobre `1883`.
- Se agregó `gateway`.
- Se configuró `gateway → database`.
- Se configuró `gateway → mosquitto`.
- Se configuró `backend → database`.
- Se mantuvo `frontend → backend`.
- Se verificaron healthchecks existentes de backend y frontend.

### Grafo de dependencias

```text
database ──────► backend ──────► frontend
    │
    └──────────► gateway ◄────── mosquitto
```

### Validaciones

Servicios:

```text
database
backend
frontend
mosquitto
gateway
```

Red:

```text
sgpmp-network
```

Volumen:

```text
postgres-data
```

Validación sintáctica:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --quiet
```

Resultado: sin errores.

También se confirmó:

```text
nc: /usr/bin/nc
mosquitto_pub: /usr/bin/mosquitto_pub
```

dentro de `eclipse-mosquitto:2`.

### Commit

```text
3f38177 feat(compose): incorpora las cuatro capas al compose base
```

---

## ST-03 — Tres overrides por ambiente

**Estado:** ✅ Completada

### Objetivo

Separar correctamente las variaciones de DEV, TEST y PROD manteniendo una definición base común.

---

### DEV

**Origen de backend/frontend:** build local.

Cambios principales:

- El `build` de backend y frontend se retiró del Compose base.
- Backend DEV construye desde `../../sgpmp-backend`.
- Frontend DEV construye desde `../../SGPMP-FRONT-END-PWA`.
- Frontend utiliza `target: dev`.
- Gateway se construye localmente desde `BROKER-MQTT-SGPMP-develop`.
- Base de datos se construye localmente desde `DBIntegrador-master`.
- Mosquitto usa `eclipse-mosquitto:2`.
- Se agregó `ENVIRONMENT=dev` en backend y gateway.

Validación:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --quiet
```

Resultado: sin errores.

Se verificó que DEV conserva `build:` para backend y frontend.

---

### TEST

**Origen de backend/frontend:** imágenes versionadas.

Cambios principales:

- Se eliminaron builds locales.
- `database` usa `${DATABASE_IMAGE}`.
- `backend` usa `${BACKEND_IMAGE}`.
- `frontend` usa `${FRONTEND_IMAGE}`.
- `gateway` usa `${GATEWAY_IMAGE}`.
- Mosquitto mantiene `eclipse-mosquitto:2`.
- Se agregó `ENVIRONMENT=test` en backend y gateway.
- Mosquitto publica:
  - `1884:1883`
  - `9002:9001`
- Gateway publica:
  - `8003:8000`
- Backend publica:
  - `8001:8000`
- Frontend publica:
  - `8081:80`
- Se reutiliza el `mosquitto.conf` entregado por AIoT para TEST.

Validaciones:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.test.yml   --env-file .env.test   config --quiet
```

Resultado: sin errores.

Servicios:

```text
database
backend
frontend
mosquitto
gateway
```

Búsqueda de builds:

```text
Sin resultados.
```

Imágenes resueltas durante validación:

```text
ghcr.io/placeholder/sgpmp-backend:test
ghcr.io/placeholder/sgpmp-frontend:test
postgres:18
eclipse-mosquitto:2
ghcr.io/placeholder/sgpmp-gateway:test
```

Variables verificadas:

```text
ENVIRONMENT: test
ENVIRONMENT: test
```

Los nombres `ghcr.io/placeholder/...` son únicamente valores temporales para validar sintaxis; deberán sustituirse por las imágenes reales.

---

### PROD

**Origen de backend/frontend:** imágenes versionadas.

Cambios principales:

- PROD no realiza builds locales.
- `database` usa `${DATABASE_IMAGE}`.
- `backend` usa `${BACKEND_IMAGE}`.
- `frontend` usa `${FRONTEND_IMAGE}`.
- `gateway` usa `${GATEWAY_IMAGE}`.
- Mosquitto mantiene `eclipse-mosquitto:2`.
- Se agregó `ENVIRONMENT=prod` en backend y gateway.
- Se establece `MQTT_TLS=true` para el gateway.
- No se publican puertos del host desde este override.
- La exposición externa queda a cargo de Despliegue.
- No se reutiliza el `mosquitto.conf` de DEV/TEST porque contiene acceso anónimo; la configuración TLS/autenticada de PROD queda como dependencia de HU-IMP-AMB-05.

Validaciones:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.prod.yml   --env-file .env.prod   config --quiet
```

Resultado: sin errores.

Servicios:

```text
database
mosquitto
gateway
backend
frontend
```

Búsqueda de builds:

```text
Sin resultados.
```

Imágenes resueltas durante validación:

```text
eclipse-mosquitto:2
ghcr.io/placeholder/sgpmp-gateway:prod
ghcr.io/placeholder/sgpmp-backend:prod
ghcr.io/placeholder/sgpmp-frontend:prod
postgres:18
```

Variables verificadas:

```text
ENVIRONMENT: prod
ENVIRONMENT: prod
```

Puertos publicados:

```text
Sin resultados.
```

### Resultado de ST-03

La separación por ambiente queda así:

| Ambiente | Backend | Frontend | Gateway | Base de datos | Mosquitto |
|---|---|---|---|---|---|
| DEV | Build local | Build local | Build local | Build local desde DBIntegrador | Imagen pública |
| TEST | Imagen por variable | Imagen por variable | Imagen por variable | Imagen por variable | Imagen pública |
| PROD | Imagen por variable | Imagen por variable | Imagen por variable | Imagen por variable | Imagen pública |

DEV, TEST y PROD ya se derivan del mismo Compose base y difieren mediante sus respectivos overrides.

---

## Estado general HU-IMP-AMB-01

| Subtarea | Estado |
|---|---|
| ST-01 — Reorganizar `compose/` y `dockerfiles/` | ✅ Completada |
| ST-02 — Compose base con las cuatro capas | ✅ Completada |
| ST-03 — Tres overrides por ambiente | ✅ Completada |
| ST-04 — Reasignación de puertos | ⏳ Pendiente |
