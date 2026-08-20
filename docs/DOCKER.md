# Docker — Guía Operativa de Docker Compose (SGPMP)

> [!WARNING]
> Esta versión reemplaza la anterior (10 de agosto de 2026), que solo cubría PostgreSQL vía *profiles* y describía backend/frontend como pendientes de incorporar. Hoy el compose orquesta las cuatro capas (base de datos, backend, frontend, gateway AIoT + Mosquitto) en los tres ambientes.

## 1. Objetivo

Manual operativo para levantar y administrar los ambientes **DEV**, **TEST** y **PROD** del sistema SGPMP mediante Docker Compose, usando el modelo de **compose base + un override por entorno**.

## 2. Prerrequisito — repositorios hermanos (solo DEV)

En DEV, backend, frontend y gateway se construyen localmente a partir del código fuente de sus propios repositorios. Deben estar clonados como carpetas **hermanas** de `SGMP-Integracion`, en el mismo directorio padre:

```
padre/
├── SGMP-Integracion/
├── sgpmp-backend/
├── SGPMP-FRONT-END-PWA/
├── BROKER-MQTT-SGPMP/
└── DBIntegrador-master/
```

TEST y PROD no tienen este prerrequisito: consumen imágenes ya publicadas (`${BACKEND_IMAGE}`, `${FRONTEND_IMAGE}`, `${GATEWAY_IMAGE}`, `${DATABASE_IMAGE}`), no construyen nada localmente.

## 3. Comandos por ambiente

Todos los comandos se ejecutan desde la raíz del repositorio (`SGMP-Integracion`). El patrón general es siempre: compose base + override del ambiente + su archivo de variables.

### 3.1 Ambiente DEV

* **Copiar la plantilla de variables (una sola vez):**
  ```bash
  cp env/.env.dev.example .env.dev
  ```
* **Validar configuración:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.dev.yml --env-file .env.dev config
  ```
* **Levantar (construye las imágenes locales):**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.dev.yml --env-file .env.dev up --build
  ```
* **Verificar estado:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.dev.yml --env-file .env.dev ps
  ```
* **Ver logs de un servicio:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.dev.yml --env-file .env.dev logs -f backend
  ```
* **Detener:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.dev.yml --env-file .env.dev down
  ```

> La base de datos en DEV es externa (fork `DBIntegrador` del DBA, ver `BASE-DATOS.md`); no la levanta este compose salvo que se habilite explícitamente el perfil `internal-db`.

### 3.2 Ambiente TEST

* **Copiar la plantilla de variables:**
  ```bash
  cp env/.env.test.example .env.test
  ```
* **Validar configuración:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test config
  ```
* **Levantar (consume imágenes, no construye):**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test up -d
  ```
* **Ver logs:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test logs -f
  ```
* **Detener:**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test down
  ```

> Requiere que `${DATABASE_IMAGE}`, `${BACKEND_IMAGE}`, `${FRONTEND_IMAGE}` y `${GATEWAY_IMAGE}` tengan un valor real en `.env.test`. Hoy están vacías: no existe todavía un pipeline de CI/CD que publique estas imágenes en GHCR (ver `docs/CONTRATO-TEST.md`, §7).

### 3.3 Ambiente PROD

* **Validar únicamente la sintaxis** (la operación real corresponde a Despliegue, vía Dokploy):
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.prod.yml --env-file .env.prod config
  ```

> PROD no publica ningún puerto al host: la exposición hacia el exterior (HTTPS/dominio) la administra el proxy inverso de Dokploy, no este compose. Ver `docs/CONTRATO-PROD.md` para la frontera completa con Despliegue.

## 4. Gestión de volúmenes y persistencia

* **Listar volúmenes activos:**
  ```bash
  docker volume ls
  ```
* **Detención normal (conserva datos):**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.<env>.yml down
  ```
* **Eliminación intencional de datos (reconstruir el ambiente desde cero):**
  ```bash
  docker compose -f compose/docker-compose.yml -f compose/compose.<env>.yml down -v
  ```
  > [!WARNING]
  > `-v` elimina de forma irreversible el volumen `postgres-data` del ambiente correspondiente.

## 5. Reglas operativas

1. **Nunca se levanta un override solo.** Siempre `-f compose/docker-compose.yml -f compose/compose.<env>.yml`.
2. **Los archivos `.env.dev`, `.env.test` y `.env.prod` no se versionan.** Se generan localmente a partir de las plantillas `env/.env.*.example`.
3. **DEV construye; TEST y PROD consumen.** No se agregan `build:` a los overrides de TEST o PROD — rompe el principio de "una sola imagen validada en los tres ambientes".
4. **La red (`sgpmp-network`) y el volumen (`postgres-data`) son comunes** a los cuatro servicios; se definen una sola vez en el compose base.
