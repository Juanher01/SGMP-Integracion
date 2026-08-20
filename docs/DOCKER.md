# Docker — Guía Operativa de Docker Compose (SGPMP)

## 1. Objetivo

Este documento es el manual operativo para desplegar y administrar los ambientes **DEV** y **TEST** del sistema SGPMP mediante Docker Compose.

> [!NOTE]
> En esta etapa, el ecosistema orquesta únicamente las instancias de PostgreSQL. Los servicios Backend y Frontend se incorporarán progresivamente al ser aprobados por el grupo de Pruebas.

---

## 2. Comandos Operativos por Ambiente

Todos los comandos se ejecutan desde la raíz del repositorio (`SGMP-Integracion`).

### 2.1 Ambiente DEV

* **Validar configuración:**
  ```bash
  docker compose --profile dev --env-file env/.env.dev.example config
  ```
* **Levantar servicio (`postgres-dev`):**
  ```bash
  docker compose --profile dev --env-file .env.dev up -d
  ```
* **Verificar estado (`healthy`):**
  ```bash
  docker compose --profile dev --env-file .env.dev ps
  ```
* **Ver logs:**
  ```bash
  docker compose --profile dev --env-file .env.dev logs -f postgres-dev
  ```
* **Acceso interactivo SQL:**
  ```bash
  docker exec -it sgpmp-postgres-dev psql -U sgpmp_dev -d sgpmp_dev
  ```
* **Detener ambiente:**
  ```bash
  docker compose --profile dev --env-file .env.dev down
  ```

---

### 2.2 Ambiente TEST

* **Validar configuración:**
  ```bash
  docker compose --profile test --env-file env/.env.test.example config
  ```
* **Levantar servicio (`postgres-test`):**
  ```bash
  docker compose --profile test --env-file .env.test up -d
  ```
* **Verificar estado (`healthy`):**
  ```bash
  docker compose --profile test --env-file .env.test ps
  ```
* **Ver logs:**
  ```bash
  docker compose --profile test --env-file .env.test logs -f postgres-test
  ```
* **Acceso interactivo SQL:**
  ```bash
  docker exec -it sgpmp-postgres-test psql -U sgpmp_test -d sgpmp_test
  ```
* **Detener ambiente:**
  ```bash
  docker compose --profile test --env-file .env.test down
  ```

---

## 3. Gestión de Volúmenes y Persistencia

* **Listar volúmenes activos:**
  ```bash
  docker volume ls
  ```
* **Eliminar volúmenes (Solo para reseteo completo de ambiente):**
  ```bash
  docker compose down -v
  ```
  > [!WARNING]
  > La opción `-v` elimina irreversiblemente los datos persistentes de los volúmenes `sgpmp-postgres-dev-data` y `sgpmp-postgres-test-data`.

---

## 4. Reglas Operativas de Docker

1. **Aislamiento de Perfiles:** Operar siempre con la bandera `--profile dev` o `--profile test` indicando el archivo `.env` correspondiente.
2. **Archivos de variables:** Los archivos reales `.env.dev` y `.env.test` **no se versionan**. Usar las plantillas `env/.env.*.example`.
3. **Flujo de Integración:** No agregar manualmente servicios backend/frontend al Compose hasta contar con el tag/commit aprobado por Pruebas.