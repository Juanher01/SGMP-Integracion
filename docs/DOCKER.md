# Docker — Ecosistema de Implementación SGPMP

## 1. Objetivo

Docker Compose será utilizado por el grupo de Implementación para construir y operar ambientes reproducibles del sistema SGPMP.

En la etapa actual se encuentran preparados los ambientes base DEV y TEST con instancias PostgreSQL independientes.

Los servicios de aplicación Backend y Frontend serán incorporados posteriormente, cuando el grupo de Pruebas libere una versión aprobada para Implementación.

---

## 2. Ambientes actuales

### 2.1 DEV

El ambiente DEV está destinado al desarrollo e integración local.

Configuración actual:

- Servicio Docker Compose: `postgres-dev`
- Contenedor: `sgpmp-postgres-dev`
- Base de datos: `sgpmp_dev`
- Usuario: `sgpmp_dev`
- Puerto del host: `5432`
- Puerto interno del contenedor: `5432`
- Volumen persistente: `sgpmp-postgres-dev-data`
- Red Docker: `sgpmp-dev-network`
- Archivo de variables: `.env.dev`

### 2.2 TEST

El ambiente TEST está destinado a pruebas reproducibles y validaciones técnicas.

Puede ser utilizado por el grupo de Pruebas y posteriormente por el grupo de Implementación.

Configuración actual:

- Servicio Docker Compose: `postgres-test`
- Contenedor: `sgpmp-postgres-test`
- Base de datos: `sgpmp_test`
- Usuario: `sgpmp_test`
- Puerto del host: `5433`
- Puerto interno del contenedor: `5432`
- Volumen persistente: `sgpmp-postgres-test-data`
- Red Docker: `sgpmp-test-network`
- Archivo de variables: `.env.test`

---

## 3. Validar la configuración Docker Compose

Antes de levantar un ambiente se debe verificar la configuración.

### DEV

```bash
docker compose --profile dev --env-file .env.dev config
```

### TEST

```bash
docker compose --profile test --env-file .env.test config
```

Si el comando termina sin errores, la configuración puede ser utilizada.

---

## 4. Levantar el ambiente DEV

Ejecutar desde la carpeta `implementation/`:

```bash
docker compose --profile dev --env-file .env.dev up -d
```

Consultar el estado:

```bash
docker compose --profile dev --env-file .env.dev ps
```

El contenedor esperado es:

```text
sgpmp-postgres-dev
```

Su estado debe llegar a:

```text
healthy
```

---

## 5. Levantar el ambiente TEST

Ejecutar desde la carpeta `implementation/`:

```bash
docker compose --profile test --env-file .env.test up -d
```

Consultar el estado:

```bash
docker compose --profile test --env-file .env.test ps
```

El contenedor esperado es:

```text
sgpmp-postgres-test
```

Su estado debe llegar a:

```text
healthy
```

---

## 6. Levantar DEV y TEST simultáneamente

Primero DEV:

```bash
docker compose --profile dev --env-file .env.dev up -d
```

Después TEST:

```bash
docker compose --profile test --env-file .env.test up -d
```

Consultar todos los contenedores:

```bash
docker ps
```

Se esperan:

```text
sgpmp-postgres-dev
sgpmp-postgres-test
```

Distribución de puertos:

```text
DEV:
localhost:5432 -> contenedor:5432

TEST:
localhost:5433 -> contenedor:5432
```

---

## 7. Consultar logs

### PostgreSQL DEV

```bash
docker compose --profile dev --env-file .env.dev logs postgres-dev
```

### PostgreSQL TEST

```bash
docker compose --profile test --env-file .env.test logs postgres-test
```

Logs en tiempo real:

```bash
docker compose --profile dev --env-file .env.dev logs -f postgres-dev
```

---

## 8. Acceder a PostgreSQL DEV

```bash
docker exec -it sgpmp-postgres-dev psql -U sgpmp_dev -d sgpmp_dev
```

Dentro de PostgreSQL:

```sql
SELECT current_database();
SELECT current_user;
SELECT version();
```

Listar bases:

```text
\l
```

Salir:

```text
\q
```

---

## 9. Acceder a PostgreSQL TEST

```bash
docker exec -it sgpmp-postgres-test psql -U sgpmp_test -d sgpmp_test
```

Dentro de PostgreSQL:

```sql
SELECT current_database();
SELECT current_user;
```

Salir:

```text
\q
```

---

## 10. Volúmenes persistentes

DEV utiliza:

```text
sgpmp-postgres-dev-data
```

TEST utiliza:

```text
sgpmp-postgres-test-data
```

Consultar volúmenes:

```bash
docker volume ls
```

---

## 11. Detener DEV

```bash
docker compose --profile dev --env-file .env.dev down
```

---

## 12. Detener TEST

```bash
docker compose --profile test --env-file .env.test down
```

---

## 13. Eliminar volúmenes

El siguiente comando no debe utilizarse durante la operación normal:

```bash
docker compose down -v
```

La opción `-v` elimina los volúmenes y los datos almacenados.

---

## 14. Estado de Backend y Frontend

Actualmente no se incorporan los servicios Backend ni Frontend al `docker-compose.yml`.

Aunque existe código desarrollado, Implementación únicamente debe recibir versiones previamente aprobadas por el grupo de Pruebas.

Flujo:

```text
Desarrollo
    ↓
dev
    ↓
Pruebas
    ↓
Versión aprobada
    ↓
Implementación
    ↓
integration
```

Después de recibir una versión aprobada se podrán incorporar servicios como:

```text
backend-dev
frontend-dev
backend-test
frontend-test
```

---

## 15. Arquitectura Docker actual

```text
Docker Compose
│
├── DEV
│   └── postgres-dev
│       ├── sgpmp_dev
│       ├── volumen persistente
│       └── red DEV
│
└── TEST
    └── postgres-test
        ├── sgpmp_test
        ├── volumen persistente
        └── red TEST
```

Arquitectura futura:

```text
Docker Compose
│
├── DEV
│   ├── frontend-dev
│   ├── backend-dev
│   └── postgres-dev
│
├── TEST
│   ├── frontend-test
│   ├── backend-test
│   └── postgres-test
│
└── PROD
    ├── frontend-prod
    ├── backend-prod
    └── PostgreSQL de producción
```

---

## 16. Reglas

1. No incorporar código de `dev` que no haya sido aprobado por Pruebas.
2. DEV y TEST deben mantener bases de datos independientes.
3. Los archivos `.env.dev` y `.env.test` no se versionan.
4. Los archivos `.env.*.example` sí se versionan.
5. No utilizar `docker compose down -v` salvo que se quiera eliminar deliberadamente la información.
6. Los cambios del esquema de base de datos no deben realizarse manualmente por Implementación.
7. Backend y Frontend se agregarán únicamente después de una entrega formal.