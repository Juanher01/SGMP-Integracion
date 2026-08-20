# Subtarea ST-04 — Datos semilla y usuarios/roles

**HU:** HU-IMP-AMB-07 — Montaje del ambiente TEST  
**Subtarea:** ST-04 — Datos semilla y usuarios/roles  
**Responsable:** Juan Sebastián Gutiérrez Tobar  
**Rama:** `feat/ambiente-test`  
**Fecha:** 20 de agosto de 2026  

---

## 1. Definición de la estrategia de datos semilla (Seed Data)

### 1.1 Estado actual en el repositorio
En el repositorio de infraestructura `SGMP-Integracion` **no existen archivos ni scripts de siembra de datos de negocio (`seeds.sql` o fixtures)**.

La fuente de verdad para la inicialización del ambiente TEST se obtiene directamente del contenedor e insumos del DBA (`DBIntegrador`), mediante la ejecución automatizada del script [`scripts/restaurar-bd.sh`](SGMP-Integracion/scripts/restaurar-bd.sh) sobre el archivo `backup7_1_0.dump`.

### 1.2 Estructura de tablas provista por Implementación
Al ejecutar la restauración oficial, el ambiente TEST queda aprovisionado automáticamente con la estructura limpia de 187 tablas organizadas en los siguientes esquemas:

| Esquema | Propósito / Módulo | Tablas Base | Vistas |
|---|---|:---:|:---:|
| `auditoria` | Registro de trazabilidad y eventos | 3 | 0 |
| `modulo1` | Gestión de usuarios, roles y autenticación | 15 | 0 |
| `modulo2` | Parámetros del sistema y configuración | 19 | 0 |
| `modulo3` | Ingestión de telemetría y sensores (AIoT) | 17 | 0 |
| `modulo4` | Control de dispositivos y actuadores (AIoT) | 24 | 0 |
| `modulo5` | Gestión agrícola y cultivos | 25 | 0 |
| `modulo6` | Inventarios y suministros | 18 | 0 |
| `modulo7` | Procesamiento analítico y predicción | 15 | 0 |
| `modulo8` | Reportes y paneles de control | 13 | 0 |
| `modulo9` | Registro central de dispositivos IoT | 38 | 0 |
| **Total** | **Estructura integral SGPMP** | **187** | **0** |

### 1.3 Delimitación de responsabilidad para la siembra de datos
En alineación con los acuerdos formalizados en [`docs/REQUISITOS-PRUEBAS-TEST.md`](SGMP-Integracion/docs/REQUISITOS-PRUEBAS-TEST.md) (ST-01) y [`docs/CONTRATO-TEST.md`](SGMP-Integracion/docs/CONTRATO-TEST.md) (ST-02):

*   **Implementación:** Garantiza la disponibilidad del contenedor de base de datos (`sgpmp-database-test`), la red compartida `sgpmp-network`, las 187 tablas estructurales limpias y el mecanismo de reinicio determinista.
*   **Pruebas (Cypress / Pytest / Newman):** Es responsable de la siembra (*seeding*) de sus propios datos de prueba y fixtures necesarios durante el ciclo de ejecución de las pruebas automatizadas (E2E, API REST y flujos IoT).

---

## 2. Matriz de Usuarios y Roles (RBAC)

### 2.1 Roles de infraestructura a nivel de Base de Datos (PostgreSQL)
A nivel de base de datos, el archivo `backup_roles.sql` del DBA define la matriz de roles y permisos con acceso restringido por ambiente:

| Rol PostgreSQL | Grupo | Propósito | Estado en TEST |
|---|---|---|---|
| `dba` | Administrador | Propietario de esquemas y administración global | Configurado en `compose.test.yml` |
| `member_qa` | `grp_qa` | Rol de conexión dedicado para el equipo de Pruebas | Pre-creado por el DBA (Límite: 10 conexiones) |
| `member_app` | `grp_app` | Rol de aplicación consumido por el Backend | Definido en catálogo (`DB_APP_USER`) |
| `member_iot` | `grp_iot` | Rol consumido por la capa AIoT / Gateway | Definido en catálogo (`DB_IOT_USER`) |
| `member_dev` | `grp_dev` | Rol de desarrollo | Inactivo en TEST |
| `member_deploy`| `grp_deploy`| Rol de despliegue | Inactivo en TEST |

### 2.2 Roles de aplicación y negocio (Backend / Frontend JWT)
El modelo RBAC de la aplicación reside en el esquema `modulo1` (tablas de usuarios, roles, permisos y sesiones).

Para la ejecución de pruebas de frontend (Cypress) y pruebas de API (Pytest/Newman), se requiere la existencia de usuarios de prueba con tokens JWT válidos.

#### Matriz de usuarios de prueba requeridos (Pendiente de confirmación por Pruebas):

| Rol de Aplicación | Modulo Principal | Uso en Pruebas | Estado |
|---|---|---|---|
| `ADMIN_SISTEMA` | M01 / M02 | Pruebas de administración global y configuración | Pendiente credenciales de Pruebas |
| `OPERADOR_AGRICOLA` | M05 / M06 | Pruebas de registro de insumos y actividades | Pendiente credenciales de Pruebas |
| `ANALISTA_AIOT` | M03 / M04 / M09 | Pruebas de monitoreo de telemetría y actuadores | Pendiente credenciales de Pruebas |
| `AUDITOR` | Auditoría | Pruebas de acceso a logs y reportes | Pendiente credenciales de Pruebas |

---

## 3. Procedimiento de inicialización y reseteo de datos en TEST

Para asegurar corridas de prueba repetibles y deterministas, el ambiente TEST debe reiniciarse al estado limpio base de 187 tablas antes de ejecutar las suites de pruebas.

### Flujo operativo de reseteo:

```bash
# 1. Eliminar contenedores y volumen de datos persistentes de TEST
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test down -v

# 2. Iniciar únicamente el servicio de base de datos PostgreSQL limpia
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test up -d database

# 3. Restaurar las 187 tablas y esquemas limpios desde el dump oficial
CONTAINER="sgpmp-database-test" DBUSER="dba" DBNAME="dba" bash scripts/restaurar-bd.sh --keep
```

---

## 4. Dependencias y pendientes de terceros para ST-04

| Item | Dependencia / Proveedor | Estado | Acción requerida |
|---|---|:---:|---|
| **Respuesta a encuesta de datos** | Pruebas (Sara Sofía González) | 🟡 Pendiente | Confirmar si Pruebas siembra fixtures dinámicos en Cypress/Pytest o solicita precarga estática. |
| **Credenciales del rol `member_qa`** | DBA (Samuel) | 🟡 Pendiente | Entrega formal de la contraseña del rol `member_qa` para Pruebas. |
| **Credenciales `DB_APP_*` y `DB_IOT_*`** | DBA (Samuel) | 🟡 Pendiente | Entrega formal de usuarios/contraseñas de aplicación para conexión de Backend y Gateway. |
| **Usuarios de prueba de negocio (RBAC)** | Pruebas / Desarrollo | 🟡 Pendiente | Definir usuarios y contraseñas de prueba para autenticación JWT en frontend/backend. |

---

## 5. Estado de cierre de ST-04

- [x] Estrategia y delimitación de responsabilidad de datos semilla documentada.
- [x] Inventario de 187 tablas y esquemas `modulo1` a `modulo9` verificado sobre `backup7_1_0.dump`.
- [x] Matriz de roles PostgreSQL (`member_qa`, `member_app`, `member_iot`) documentada.
- [x] Procedimiento determinista de reseteo de BD para TEST documentado.
- [ ] Entrega de credenciales del rol `member_qa` por el DBA.
- [ ] Respuesta de Pruebas a la encuesta de usuarios RBAC y política de fixtures.

**ST-04 queda documentado y formalizado en el repositorio local.**
