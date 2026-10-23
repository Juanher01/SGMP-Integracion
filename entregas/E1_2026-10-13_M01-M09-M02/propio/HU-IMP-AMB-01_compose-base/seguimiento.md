# Seguimiento técnico — HU-IMP-AMB-01
## Compose base y convención de orquestación

**Responsable:** Juan Esteban Hernández Lozano  
**Rama de trabajo:** `feat/compose-base`  
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-01 — Compose base y convención de orquestación  
**Estado:** ✅ Completada

---

# 1. Objetivo de la Historia de Usuario

El objetivo de HU-IMP-AMB-01 fue establecer una definición común de Docker Compose para los ambientes DEV, TEST y PROD, de forma que los tres ambientes compartieran la misma arquitectura base y se diferenciaran únicamente mediante sus archivos de override y variables de entorno.

La solución debía representar las cuatro capas del ambiente:

1. Base de datos.
2. Aplicación, compuesta por backend y frontend.
3. Gateway AIoT.
4. Broker MQTT Mosquitto.

A nivel de Docker Compose estas cuatro capas se representan mediante cinco servicios:

```text
database
backend
frontend
gateway
mosquitto
```

La HU también exigía reorganizar la estructura del repositorio, evitar colisiones de puertos, definir red y volúmenes, incorporar healthchecks y documentar la convención de ramas del repositorio de infraestructura.

---

# 2. Estado inicial encontrado

Antes de iniciar la HU, el repositorio ya contenía una primera aproximación de Docker Compose, pero correspondía a una arquitectura anterior.

El estado inicial presentaba principalmente estas características:

- Los archivos Compose estaban ubicados en la raíz del repositorio.
- Existían:
  - `docker-compose.yml`
  - `docker-compose.dev.yml`
  - `docker-compose.test.yml`
  - `docker-compose.prod.yml`
- El Compose base únicamente contenía backend y frontend.
- La base de datos se asumía levantada externamente.
- El stack dependía de una red externa llamada `docker_default`.
- No estaban integrados:
  - `database`
  - `gateway`
  - `mosquitto`
- Backend y frontend tenían su estrategia de build definida en el Compose base.
- TEST y PROD todavía heredaban builds locales.
- Los Dockerfiles de referencia estaban ubicados bajo `docs/dockerFiles/`.
- No existía aislamiento explícito entre los proyectos Compose de DEV, TEST y PROD.

A partir de este estado se realizó una refactorización progresiva.

---

# 3. ST-01 — Reorganización de `compose/` y `dockerfiles/`

**Estado:** ✅ Completada

## 3.1 Objetivo

Ajustar la estructura física del repositorio a la convención definida para la infraestructura.

## 3.2 Estructura resultante

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

## 3.3 Cambios realizados

Se movieron y renombraron los archivos Compose:

```text
docker-compose.yml
→ compose/docker-compose.yml

docker-compose.dev.yml
→ compose/compose.dev.yml

docker-compose.test.yml
→ compose/compose.test.yml

docker-compose.prod.yml
→ compose/compose.prod.yml
```

También se trasladaron los Dockerfiles de referencia:

```text
docs/dockerFiles/back/*
→ dockerfiles/backend/*

docs/dockerFiles/front/*
→ dockerfiles/frontend/*
```

Debido al cambio de ubicación de `docker-compose.yml`, fue necesario ajustar los contextos relativos de build para que siguieran apuntando a los repositorios hermanos de backend y frontend.

## 3.4 Validación

Se ejecutó:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --services
```

Resultado inicial después de la reorganización:

```text
backend
frontend
```

Esto confirmó que el cambio de estructura no rompió la resolución de Docker Compose.

## 3.5 Commit asociado

```text
47a8e75 refactor(compose): reorganiza estructura de orquestacion
```

Posteriormente se registró documentalmente el cierre de ST-01 mediante:

```text
a0e5c11 docs(hu-01): registra cierre de ST-01
```

---

# 4. ST-02 — Compose base con las cuatro capas

**Estado:** ✅ Completada

## 4.1 Objetivo

Transformar el Compose de dos servicios en una orquestación común capaz de representar todo el ambiente.

## 4.2 Red propia

Se eliminó la dependencia de:

```text
docker_default
```

y se creó una red propia:

```yaml
networks:
  sgpmp-network:
    driver: bridge
```

Todos los servicios del stack fueron conectados a esta red.

Esto permite que los contenedores se comuniquen internamente por nombre de servicio, por ejemplo:

```text
backend → database
gateway → database
gateway → mosquitto
frontend → backend
```

## 4.3 Servicio `database`

Se incorporó el servicio `database` al Compose base.

La definición común incluye:

- conexión a `sgpmp-network`;
- volumen persistente;
- configuración requerida para `pg_cron`;
- healthcheck mediante `pg_isready`.

Volumen definido:

```yaml
volumes:
  postgres-data:
```

La capa de base de datos toma como referencia técnica el repositorio `DBIntegrador-master`.

En DEV, el origen se configuró mediante build local desde:

```text
../../DBIntegrador-master
```

La restauración real del dump, roles, esquemas y credenciales definitivas no se resolvió dentro de HU-01, ya que pertenece a HU-IMP-AMB-04.

## 4.4 Dependencia backend → database

El backend fue configurado para esperar a que la base de datos se encuentre saludable:

```yaml
depends_on:
  database:
    condition: service_healthy
```

De esta forma, el backend no debe iniciar antes de que PostgreSQL responda satisfactoriamente al healthcheck.

## 4.5 Servicio `mosquitto`

Se incorporó Mosquitto utilizando:

```text
eclipse-mosquitto:2
```

El archivo de configuración utilizado en DEV y TEST proviene del repositorio AIoT:

```text
BROKER-MQTT-SGPMP-develop/docker/mosquitto.conf
```

La configuración analizada establece:

```text
listener 1883
allow_anonymous true

listener 9001
protocol websockets
```

Por tanto:

- `1883` corresponde a MQTT.
- `9001` corresponde a MQTT sobre WebSockets.

Se definió un healthcheck sobre el puerto interno `1883`.

Antes de mantenerlo, se comprobó directamente que la imagen `eclipse-mosquitto:2` contiene:

```text
/usr/bin/nc
/usr/bin/mosquitto_pub
```

por lo que el healthcheck basado en `nc` es ejecutable dentro de la imagen.

## 4.6 Servicio `gateway`

Se incorporó el gateway AIoT a partir del repositorio:

```text
BROKER-MQTT-SGPMP-develop
```

De su configuración se identificaron, entre otras, las siguientes variables:

```text
DATABASE_URL
DB_SCHEMA_INGEST
DB_SCHEMA_REGISTRY
MQTT_HOST
MQTT_PORT
MQTT_USERNAME
MQTT_PASSWORD
MQTT_TLS
MQTT_CLIENT_ID
MQTT_RECONNECT_DELAY
MQTT_TOPIC_PREFIX
MQTT_TOPIC_TELEMETRY
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_COMMAND
MQTT_TOPIC_STATUS
API_TOKEN
API_HOST
API_PORT
```

La configuración común establecida para el gateway incluye:

```text
MQTT_HOST=mosquitto
MQTT_PORT=1883
DB_SCHEMA_INGEST=modulo3
DB_SCHEMA_REGISTRY=modulo9
API_HOST=0.0.0.0
API_PORT=8000
```

El gateway depende de:

```text
database
mosquitto
```

ambos con condición `service_healthy`.

También se definió un healthcheck contra:

```text
GET /v1/healthz
```

## 4.7 Backend y frontend

El backend y frontend quedaron dentro del Compose base únicamente con las propiedades compartidas por los tres ambientes.

Backend:

- red común;
- dependencia de base de datos.

Frontend:

- red común;
- dependencia de backend.

Los healthchecks de backend y frontend no se duplicaron en Compose porque se verificó que ya existen en sus Dockerfiles de referencia.

## 4.8 Grafo resultante

```text
database ──────► backend ──────► frontend
    │
    └──────────► gateway ◄────── mosquitto
```

## 4.9 Validaciones

Servicios:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --services
```

Resultado:

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

Resultado:

```text
Sin errores
```

También se verificó que ya no quedaran referencias a:

```text
docker_default
BD del DBA debe estar corriendo
No se define aquí ningún servicio de base de datos
```

## 4.10 Commit asociado

```text
3f38177 feat(compose): incorpora las cuatro capas al compose base
```

---

# 5. ST-03 — Overrides DEV, TEST y PROD

**Estado:** ✅ Completada

## 5.1 Objetivo

Separar las decisiones específicas de cada ambiente de la definición base.

La regla establecida fue:

```text
Compose base
      +
override de ambiente
      +
.env correspondiente
```

---

## 5.2 DEV

DEV debe construir localmente backend y frontend.

Por esta razón, los bloques `build:` de ambos servicios fueron retirados del Compose base y movidos a:

```text
compose/compose.dev.yml
```

Backend DEV:

```text
build local desde ../../sgpmp-backend
puerto host 8000
ENVIRONMENT=dev
uvicorn con --reload
```

Frontend DEV:

```text
build local desde ../../SGPMP-FRONT-END-PWA
target=dev
puerto host 5173
```

Gateway DEV:

```text
build local desde ../../BROKER-MQTT-SGPMP-develop
ENVIRONMENT=dev
host 8002 → container 8000
```

Database DEV:

```text
build local desde ../../DBIntegrador-master
```

Mosquitto DEV:

```text
eclipse-mosquitto:2
```

Validación:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.dev.yml   --env-file .env.dev   config --quiet
```

Resultado: sin errores.

También se verificó que backend y frontend conservan `build:` en la configuración final de DEV.

---

## 5.3 TEST

TEST no realiza builds locales de backend ni frontend.

Se configuró:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE
```

como variables de imagen.

Durante la validación estructural se utilizaron valores placeholder para comprobar el comportamiento de Compose sin asumir todavía los nombres definitivos de GHCR.

Se verificó:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.test.yml   --env-file .env.test   config | grep -n "build:"
```

Resultado:

```text
Sin resultados
```

Imágenes resueltas durante la validación:

```text
ghcr.io/placeholder/sgpmp-backend:test
ghcr.io/placeholder/sgpmp-frontend:test
postgres:18
eclipse-mosquitto:2
ghcr.io/placeholder/sgpmp-gateway:test
```

TEST quedó configurado con:

```text
ENVIRONMENT=test
```

para backend y gateway.

---

## 5.4 PROD

PROD tampoco realiza builds locales.

Se configuró de la misma forma mediante variables de imagen:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE
```

Se estableció:

```text
ENVIRONMENT=prod
MQTT_TLS=true
```

en la configuración correspondiente.

No se publicaron puertos host en PROD, ya que la exposición externa será responsabilidad de Despliegue mediante Dokploy.

Se verificó:

```bash
docker compose   -f compose/docker-compose.yml   -f compose/compose.prod.yml   --env-file .env.prod   config | grep -n "build:"
```

Resultado:

```text
Sin resultados
```

También:

```bash
... config | grep -n "published:"
```

Resultado:

```text
Sin resultados
```

No se reutilizó en PROD el `mosquitto.conf` de DEV/TEST porque contiene:

```text
allow_anonymous true
```

La configuración TLS/autenticada de producción queda como dependencia de la capa AIoT.

## 5.5 Commit asociado

```text
376a7aa feat(compose): define overrides dev test y prod
```

---

# 6. ST-04 — Puertos y aislamiento de ambientes

**Estado:** ✅ Completada

## 6.1 Objetivo

Evitar colisiones entre servicios y permitir que DEV y TEST puedan coexistir localmente.

## 6.2 Aislamiento por proyecto Compose

Se configuraron nombres independientes:

```text
DEV  → sgpmp-dev
TEST → sgpmp-test
PROD → sgpmp-prod
```

Esto evita que los ambientes compartan involuntariamente el mismo proyecto Compose.

La validación produjo:

```text
name: sgpmp-dev
name: sgpmp-test
name: sgpmp-prod
```

## 6.3 Matriz definitiva de puertos

| Servicio | Puerto interno | DEV host | TEST host | PROD host |
|---|---:|---:|---:|---|
| Backend | 8000 | 8000 | 8001 | No publicado |
| Gateway | 8000 | 8002 | 8003 | No publicado |
| Frontend | 5173 DEV / 80 imagen prod | 5173 | 8081 | No publicado |
| Mosquitto MQTT | 1883 | 1883 | 1884 | No publicado |
| Mosquitto WebSocket | 9001 | 9001 | 9002 | No publicado |
| PostgreSQL | 5432 | No publicado | No publicado | No publicado |

Es importante distinguir entre puerto interno y puerto publicado.

Backend y gateway utilizan ambos el puerto interno:

```text
8000
```

sin conflicto porque se encuentran en contenedores distintos.

La colisión se evita a nivel del host:

```text
DEV:
backend → 8000
gateway → 8002

TEST:
backend → 8001
gateway → 8003
```

## 6.4 Validación DEV

```text
backend: host 8000 -> container 8000
frontend: host 5173 -> container 5173
gateway: host 8002 -> container 8000
mosquitto: host 1883 -> container 1883
mosquitto: host 9001 -> container 9001
```

## 6.5 Validación TEST

```text
backend: host 8001 -> container 8000
frontend: host 8081 -> container 80
gateway: host 8003 -> container 8000
mosquitto: host 1884 -> container 1883
mosquitto: host 9002 -> container 9001
```

## 6.6 Validación de duplicados

Dentro de DEV:

```text
Sin resultados
```

Dentro de TEST:

```text
Sin resultados
```

Comparando DEV + TEST:

```text
Sin resultados
```

Esto confirma que no existen puertos host duplicados entre los dos ambientes.

## 6.7 Validación PROD

La búsqueda de puertos publicados produjo:

```text
Sin resultados
```

por lo que PROD no fuerza publicaciones directas de puertos.

## 6.8 Validación sintáctica final

Se ejecutó `config --quiet` para los tres ambientes:

```text
DEV  → sin errores
TEST → sin errores
PROD → sin errores
```

---

# 7. Convención de ramas de infraestructura

**Estado:** ✅ Documentada

Se actualizó:

```text
docs/FLUJO-GIT.md
```

para diferenciar la convención de los repositorios de código de la convención propia de infraestructura.

Para `SGMP-Integracion` quedó documentado:

```text
feat/<area>-<descripcion>
fix/<area>-<descripcion>
docs/<descripcion>
chore/<descripcion>
```

Ejemplos:

```text
feat/compose-base
feat/env-unificado
feat/ambiente-dev
fix/compose-healthcheck
docs/variables-entorno
chore/estructura-repo
```

Flujo documentado:

```text
main actualizado
      ↓
crear rama de trabajo
      ↓
realizar cambios
      ↓
validar
      ↓
commit
      ↓
push
      ↓
Pull Request hacia main
      ↓
revisión y aprobación
      ↓
merge a main
```

---

# 8. Archivos principales modificados

```text
compose/docker-compose.yml
compose/compose.dev.yml
compose/compose.test.yml
compose/compose.prod.yml

dockerfiles/backend/.dockerignore
dockerfiles/backend/Dockerfile

dockerfiles/frontend/.dockerignore
dockerfiles/frontend/Dockerfile
dockerfiles/frontend/nginx.conf

docs/FLUJO-GIT.md
docs/SEGUIMIENTO-HU-IMP-AMB-01.md
```

---

# 9. Validaciones principales realizadas

Durante la HU se utilizaron principalmente:

```bash
docker compose ... config --quiet
docker compose ... config --services
docker compose ... config --networks
docker compose ... config --volumes
docker compose ... config --images
```

También se realizaron búsquedas y verificaciones específicas para:

```text
healthchecks
builds por ambiente
puertos publicados
puertos duplicados
nombres de proyecto
referencias obsoletas
convención de ramas
```

No se ejecutó todavía una validación integral del sistema con los cinco servicios reales y las credenciales definitivas.

Esa ejecución corresponde posteriormente al montaje de DEV en HU-IMP-AMB-06, una vez estén disponibles las entregas definitivas de BD y AIoT y se complete el catálogo de variables.

---

# 10. Criterios de aceptación de HU-IMP-AMB-01

| Criterio | Evidencia | Estado |
|---|---|---|
| Compose base con cuatro capas, red, volúmenes y healthchecks | `compose/docker-compose.yml` + validaciones | ✅ Cumplido |
| Overrides DEV, TEST y PROD | `compose/compose.*.yml` | ✅ Cumplido |
| Puertos sin colisiones | Matriz y pruebas de duplicados | ✅ Cumplido |
| Estructura y convención de ramas documentadas | `compose/`, `dockerfiles/`, `docs/FLUJO-GIT.md` | ✅ Cumplido |

---

# 11. Historial principal de commits

```text
47a8e75 refactor(compose): reorganiza estructura de orquestacion
a0e5c11 docs(hu-01): registra cierre de ST-01
3f38177 feat(compose): incorpora las cuatro capas al compose base
376a7aa feat(compose): define overrides dev test y prod
```

El commit correspondiente al cierre de ST-04, aislamiento de ambientes y documentación final se registra en el historial Git de la rama al finalizar la HU.

---

# 12. Pendientes que no pertenecen a HU-01

HU-01 deja preparada la arquitectura de orquestación, pero no resuelve todavía:

- nombres definitivos de imágenes GHCR;
- variables unificadas;
- roles definitivos de PostgreSQL;
- restauración real del dump;
- credenciales de aplicación;
- usuario IoT de base de datos;
- configuración TLS definitiva de Mosquitto en PROD;
- ejecución integral de los cinco servicios;
- pruebas extremo a extremo.

Estos puntos corresponden principalmente a:

```text
HU-IMP-AMB-02
HU-IMP-AMB-04
HU-IMP-AMB-05
HU-IMP-AMB-06
```

---

# 13. Conclusión

**HU-IMP-AMB-01 queda completada a nivel de definición, organización y validación estructural.**

El repositorio dispone ahora de una base común de Docker Compose para DEV, TEST y PROD, con las cuatro capas requeridas, separación por ambiente, aislamiento de proyectos, red propia, volumen, healthchecks, matriz de puertos sin colisiones y convención Git de infraestructura documentada.

La solución queda preparada para continuar con la unificación de variables de entorno y posteriormente con el montaje integral de DEV.
