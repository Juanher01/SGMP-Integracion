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

Resultado obtenido:

```text
backend
frontend
```

Esto confirma que, después de la reorganización, Docker Compose sigue resolviendo correctamente los servicios actualmente definidos.

### Control de versiones

Commit asociado:

```text
47a8e75 refactor(compose): reorganiza estructura de orquestacion
```

Estado posterior al commit:

```text
On branch feat/compose-base
nothing to commit, working tree clean
```

### Resultado

La subtarea ST-01 queda completada. La estructura de `compose/` y `dockerfiles/` ya cumple la convención definida para HU-IMP-AMB-01 y queda preparada para continuar con ST-02: incorporación de las cuatro capas al Compose base.

---

## Estado general HU-IMP-AMB-01

| Subtarea | Estado |
|---|---|
| ST-01 — Reorganizar `compose/` y `dockerfiles/` | ✅ Completada |
| ST-02 — Compose base con las cuatro capas | ⏳ Pendiente |
| ST-03 — Tres overrides por ambiente | ⏳ Pendiente |
| ST-04 — Reasignación de puertos | ⏳ Pendiente |
