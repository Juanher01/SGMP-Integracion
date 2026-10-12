# Base de Datos — Ecosistema de Implementación SGPMP

## 1. Objetivo y Motor de Base de Datos

Este documento define la forma en que el grupo de Implementación gestionará la base de datos PostgreSQL en los ambientes **DEV**, **TEST** y **PROD**.

* **Motor:** PostgreSQL (`postgres:16`)
* **Responsabilidad funcional:** El DBA del proyecto diseña el modelo de datos, tablas, schemas y restricciones.
* **Responsabilidad de infraestructura:** El grupo de Implementación prepara los ambientes en Docker Compose, mantiene el aislamiento, restaura la base de datos y conecta los componentes aprobados.

---

## 2. Fuente Oficial y Gestión del Dump del DBA

El DBA entrega la base de datos de referencia mediante un archivo de respaldo con extensión `.dump`.

### Ubicación y GitIgnore
* **Ruta local:** `database/dumps/sgpmp.dump`
* **Regla de versionamiento:** Los archivos `.dump` y `.sql` **nunca** deben subirse al repositorio Git. El `.gitignore` debe mantener:
  ```gitignore
  database/dumps/*.dump
  database/dumps/*.sql
  ```

### Verificaciones Previas a la Restauración
Antes de restaurar el dump en DEV o TEST, Implementación debe verificar:
1. Formato del archivo `.dump` (formato personalizado de PostgreSQL).
2. Versión de PostgreSQL y `pg_dump` utilizadas por el DBA.
3. Schemas e información incluida (solo estructura o estructura + datos iniciales).
4. Propietarios de objetos, roles requeridos y extensiones activas.
5. Nombre original de la base de datos y posibles dependencias externas.

### Herramienta de Restauración
Para restaurar el archivo en formato personalizado se utilizará:
```bash
pg_restore
```
Los comandos específicos de restauración se documentarán tras analizar la compatibilidad del archivo entregado.

---

## 3. Estrategia de Ambientes (DEV y TEST)

La base de datos se mantiene completamente aislada entre DEV y TEST. No comparten contenedor, base de datos, usuario, red ni volumen persistente.

```text
                       PostgreSQL
                           │
               ┌───────────┴───────────┐
               ▼                       ▼
       PostgreSQL DEV          PostgreSQL TEST
       (postgres-dev)          (postgres-test)
        [sgpmp_dev]             [sgpmp_test]
        Puerto: 5432            Puerto: 5433
     Volumen Persistente      Volumen Reiniciable
```

### Configuración por Ambiente

| Parámetro | DEV | TEST |
| :--- | :--- | :--- |
| **Servicio Compose** | `postgres-dev` | `postgres-test` |
| **Contenedor** | `sgpmp-postgres-dev` | `sgpmp-postgres-test` |
| **Base de Datos** | `sgpmp_dev` | `sgpmp_test` |
| **Usuario** | `sgpmp_dev` | `sgpmp_test` |
| **Puerto Host** | `5432` | `5433` |
| **Puerto Interno** | `5432` | `5432` |
| **Volumen** | `sgpmp-postgres-dev-data` | `sgpmp-postgres-test-data` |
| **Red Docker** | `sgpmp-dev-network` | `sgpmp-test-network` |
| **Propósito** | Integración y desarrollo local persistente | Pruebas automatizadas y reproducibles |

---

## 4. Matriz de Responsabilidades

| Rol | Responsabilidades Principales sobre la Base de Datos |
| :--- | :--- |
| **DBA** | Diseño del modelo de datos, schemas, tablas, relaciones, índices, restricciones y entrega del dump oficial. |
| **Desarrollo** | Mapeo SQLAlchemy/ORM, adaptadores de persistencia, lógica de acceso a datos y scripts de migración. |
| **Pruebas** | Ejecución de pruebas unitarias/E2E en el ambiente TEST y aprobación funcional previa a la integración. |
| **Implementación** | Orquestación Docker, aislamiento de ambientes, restauración de dumps, ejecución controlada de migraciones y verificación de conectividad. |

---

## 5. Volúmenes, Persistencia y Manejo de Datos

* **Consulta de volúmenes:**
  ```bash
  docker volume ls
  ```
* **Detención normal (Mantiene datos):**
  ```bash
  docker compose down
  ```
* **Eliminación intencional de datos (Solo para reconstruir ambientes):**
  ```bash
  docker compose down -v
  ```
  > [!WARNING]
  > El comando `docker compose down -v` elimina de forma irreversible los volúmenes persistentes y todos los datos contenidos.

---

## 6. Reglas de Control y Migraciones

### Restricciones para Implementación
* No modificar manualmente tablas, columnas, restricciones, índices ni esquemas.
* No crear estructuras de BD improvisadas en producción/integración.
* No utilizar la misma base de datos para DEV y TEST.

### Flujo de Migraciones
```text
Desarrollo (Script Migración) ──> Pruebas (Aprobación) ──> Implementación (Ejecución Controlada & Verificación)
```

---

## 7. Estado Actual y Próximos Pasos

### Estado Actual
* Contenedores `postgres-dev` y `postgres-test` configurados y verificados en estado `healthy`.
* Bases de datos, redes y volúmenes completamente independientes.
* Archivo `.dump` recibido del DBA y pendiente de análisis técnico antes de su restauración.

### Próximos Pasos
1. Analizar compatibilidad y formato del archivo `.dump` del DBA.
2. Ejecutar y documentar el procedimiento de restauración mediante `pg_restore` en DEV y TEST.
3. Conectar el Backend FastAPI una vez que sea liberado por el grupo de Pruebas.