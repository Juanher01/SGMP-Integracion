# Seguimiento HU-IMP-AMB-01 — Compose base y convención de orquestación

**Responsable:** Juan Esteban Hernández Lozano  
**Rama de trabajo:** `feat/compose-base`  
**Historia de Usuario:** HU-IMP-AMB-01 — Compose base y convención de orquestación  

---

## ST-01 — Reorganizar `compose/` y `dockerfiles/`

**Estado:** ✅ Completada

### Objetivo

Reorganizar la estructura del repositorio de infraestructura para cumplir con la convención definida en el backlog, separando los archivos de orquestación Docker Compose y las copias de referencia de los Dockerfiles.

### Cambios realizados

Se creó la estructura:

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

Se realizaron los siguientes movimientos:

- `docker-compose.yml` → `compose/docker-compose.yml`
- `docker-compose.dev.yml` → `compose/compose.dev.yml`
- `docker-compose.test.yml` → `compose/compose.test.yml`
- `docker-compose.prod.yml` → `compose/compose.prod.yml`
- `docs/dockerFiles/back/.dockerignore` → `dockerfiles/backend/.dockerignore`
- `docs/dockerFiles/back/Dockerfile` → `dockerfiles/backend/Dockerfile`
- `docs/dockerFiles/front/.dockerignore` → `dockerfiles/frontend/.dockerignore`
- `docs/dockerFiles/front/Dockerfile` → `dockerfiles/frontend/Dockerfile`
- `docs/dockerFiles/front/nginx.conf` → `dockerfiles/frontend/nginx.conf`

También se ajustaron las rutas y comentarios necesarios en los archivos Compose para que continuaran funcionando desde su nueva ubicación.

### Validación realizada

Se validó la resolución del ambiente DEV con:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --services
```

Resultado:

```text
backend
frontend
```

### Control de versiones

Commit asociado:

```text
47a8e75 refactor(compose): reorganiza estructura de orquestacion
```

### Resultado

ST-01 queda completada.

---

## ST-02 — Compose base con las cuatro capas

**Estado:** ✅ Completada

### Objetivo

Ampliar el Compose base para representar las cuatro capas requeridas:

1. Base de datos.
2. Aplicación (backend + frontend).
3. Gateway AIoT.
4. Broker Mosquitto.

Técnicamente, el stack queda compuesto por cinco servicios:

```text
database
backend
frontend
gateway
mosquitto
```

### Cambios realizados

#### Red propia

Se eliminó la dependencia de la red externa `docker_default` y se creó:

```yaml
networks:
  sgpmp-network:
    driver: bridge
```

Todos los servicios del stack usan esta red.

#### Servicio `database`

Se incorporó la capa de base de datos con:

- red `sgpmp-network`;
- volumen persistente `postgres-data`;
- configuración para `pg_cron`;
- healthcheck mediante `pg_isready`;
- dependencia del backend respecto a `database`.

En DEV, la definición toma como contexto local `DBIntegrador-master`.

La restauración de roles, dump, esquemas y configuración definitiva de usuarios queda asociada a HU-IMP-AMB-04.

#### Volumen PostgreSQL

```yaml
volumes:
  postgres-data:
```

#### Servicio `mosquitto`

Se incorporó Mosquitto usando:

```text
eclipse-mosquitto:2
```

En DEV:

- MQTT: `1883`;
- WebSockets: `9001`;
- configuración tomada desde el repositorio AIoT;
- healthcheck sobre el puerto interno `1883`.

Se confirmó que la imagen contiene:

```text
/usr/bin/nc
/usr/bin/mosquitto_pub
```

#### Servicio `gateway`

Se incorporó el gateway AIoT con:

- dependencia de `database`;
- dependencia de `mosquitto`;
- `MQTT_HOST=mosquitto`;
- `MQTT_PORT=1883`;
- `DB_SCHEMA_INGEST=modulo3`;
- `DB_SCHEMA_REGISTRY=modulo9`;
- API interna en `8000`;
- healthcheck en `/v1/healthz`.

En DEV se construye desde `BROKER-MQTT-SGPMP-develop` y se publica:

```text
host 8002 → contenedor 8000
```

Esto evita la colisión con el backend, que usa `8000` en el host.

#### Backend

El backend:

- mantiene build desde el repositorio local;
- usa `sgpmp-network`;
- depende de `database` con `service_healthy`;
- conserva el `HEALTHCHECK` de su Dockerfile.

#### Frontend

El frontend:

- mantiene build desde el repositorio local;
- usa `sgpmp-network`;
- depende de backend con `service_healthy`;
- conserva el `HEALTHCHECK` de su Dockerfile.

### Grafo de dependencias

```text
database ──────► backend ──────► frontend
    │
    └──────────► gateway ◄────── mosquitto
```

### Validaciones realizadas

#### Servicios

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --services
```

Resultado:

```text
database
backend
frontend
mosquitto
gateway
```

#### Red

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --networks
```

Resultado:

```text
sgpmp-network
```

#### Volumen

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --volumes
```

Resultado:

```text
postgres-data
```

#### Validación sintáctica

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/compose.dev.yml \
  --env-file .env.dev \
  config --quiet
```

Resultado: sin errores.

#### Healthchecks backend/frontend

Se confirmó que ambos Dockerfiles contienen instrucciones `HEALTHCHECK`.

#### Healthcheck Mosquitto

La imagen `eclipse-mosquitto:2` dispone de:

```text
nc: /usr/bin/nc
mosquitto_pub: /usr/bin/mosquitto_pub
```

#### Referencias obsoletas

Se verificó que `compose/` ya no contiene referencias a:

```text
docker_default
BD del DBA debe estar corriendo
No se define aquí ningún servicio de base de datos
```

### Consideraciones pendientes

Se resolverán en las HU/subtareas correspondientes:

- unificación definitiva de variables;
- roles definitivos de PostgreSQL;
- credenciales reales de backend/gateway;
- restauración de roles y dump;
- ejecución integral de los cinco servicios;
- validación extremo a extremo.

### Resultado

ST-02 queda completada a nivel de definición de orquestación. El Compose base ya contiene las cuatro capas requeridas y los cinco servicios técnicos, con red, volumen, dependencias y healthchecks definidos.

---

## Estado general HU-IMP-AMB-01

| Subtarea | Estado |
|---|---|
| ST-01 — Reorganizar `compose/` y `dockerfiles/` | ✅ Completada |
| ST-02 — Compose base con las cuatro capas | ✅ Completada |
| ST-03 — Tres overrides por ambiente | ⏳ Pendiente |
| ST-04 — Reasignación de puertos | ⏳ Pendiente |
