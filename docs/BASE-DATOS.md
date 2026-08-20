# Base de Datos — Ecosistema de Implementación SGPMP

> [!WARNING]
> Esta versión reemplaza la anterior (10 de agosto de 2026), que documentaba `postgres:16` y no mencionaba el repositorio actual del DBA. El motor real es `postgres:18`, y la fuente oficial es el fork `DBIntegrador`.

## 1. Objetivo y motor de base de datos

* **Motor:** PostgreSQL **18** (confirmado en el Dockerfile del DBA; reemplaza a la 17.10 y a la 16 que circularon en versiones anteriores de este documento).
* **Responsabilidad funcional:** el DBA diseña el modelo de datos, esquemas, tablas y roles.
* **Responsabilidad de infraestructura:** Implementación prepara los ambientes en Docker Compose, mantiene el aislamiento entre DEV/TEST/PROD, restaura la base de datos y conecta los componentes aprobados.

## 2. Fuente oficial

* **Repositorio:** `DBIntegrador` (privado, propiedad del DBA). Implementación mantiene un **fork** propio (`DBIntegrador-master` en local) para trabajar sin depender de que el DBA otorgue colaboración individual a cada integrante.
* **Dump:** `backup7_1_0.dump` (formato *custom* de PostgreSQL, *archive version* 1.16 — generado con `pg_dump 18.4`; requiere un cliente `pg_restore` ≥ 17 para leerlo).
* **Roles:** `backup_roles.sql` (codificado en UTF-16; debe normalizarse a UTF-8 antes de aplicarlo).
* **Base y usuario administrador:** `dba` / `dba`.
* **Sincronización:** el fork no se actualiza solo. Antes de restaurar, debe traerse lo último del repositorio original (*upstream*) del DBA y dejar registrado el commit o tag usado.

> [!NOTE]
> El repositorio del DBA nunca se modifica desde Implementación. Todo el trabajo de adaptación (normalización de finales de línea, `.env` de prueba, ajustes de `pg_cron`) ocurre en una copia de trabajo fuera del repositorio del DBA.

## 3. Roles ya provistos por el DBA

El dump de roles ya diferencia un rol por equipo, con el patrón estándar de PostgreSQL (rol de grupo sin login + rol de acceso con login, miembro del grupo):

| Rol de acceso | Grupo | Límite de conexiones | Uso previsto |
| :--- | :--- | :--- | :--- |
| `dba` | — (superusuario) | — | Administración; solo uso puntual, nunca como rol de aplicación |
| `member_dev` | `grp_dev` | 20 | Desarrollo |
| `member_qa` | `grp_qa` | 10 | Pruebas |
| `member_impl` | `grp_impl` | 5 | Implementación |
| `member_iot` | `grp_iot` | 3 | Gateway AIoT |
| `member_deploy` | `grp_deploy` | 5 | Despliegue |

> [!WARNING]
> **Salvedad abierta:** el diseño de conexión del backend asume un rol `member_app`, que **no existe** en `backup_roles.sql` — los roles provistos son por equipo, no por servicio. Hoy DEV usa el rol administrador (`dba`) como sustituto temporal para el backend (`DB_APP_USER=dba`), mientras se confirma con el DBA si crearán `member_app` o si el backend debe conectarse con uno de los roles ya existentes.

## 4. Configuración por ambiente

| Parámetro | DEV | TEST | PROD |
| :--- | :--- | :--- | :--- |
| **Origen** | Contenedor externo del DBA (fuera de este compose) | Servicio `database` de este compose | Servicio `database` de este compose |
| **Imagen** | — (la levanta el fork del DBA por separado) | `${DATABASE_IMAGE}` | `${DATABASE_IMAGE}` |
| **Host** | `host.docker.internal` | `database` | `database` |
| **Puerto** | `5433` (publicado por el contenedor del DBA) | `5432` (interno, sin publicar) | `5432` (interno, sin publicar) |
| **Base / usuario admin** | `dba` / `dba` | `dba` / `dba` | `dba` / `dba` |
| **Rol de aplicación (backend)** | `dba` (sustituto temporal — ver §3) | Pendiente del DBA | Pendiente del DBA |
| **Rol AIoT (gateway)** | `member_iot` | Pendiente del DBA | Pendiente del DBA |
| **Persistencia** | Gestionada por el fork del DBA | Volumen `postgres-data`, reiniciable | Volumen `postgres-data`, nunca se reinicia |

La base de datos **no se duplica** dentro del compose de Implementación en DEV: se consume como capa externa, ya que el fork del DBA la levanta por su cuenta. En TEST y PROD sí es un servicio de este compose, porque ambos necesitan una imagen reproducible y versionada, no una instancia levantada a mano.

## 5. Matriz de responsabilidades

| Rol | Responsabilidades sobre la base de datos |
| :--- | :--- |
| **DBA** | Diseño del modelo de datos, esquemas, tablas, roles, extensiones y entrega del dump oficial. |
| **Desarrollo** | Mapeo SQLAlchemy/ORM, adaptadores de persistencia, migraciones. |
| **Pruebas** | Validación funcional en TEST con el rol `member_qa`. |
| **Implementación** | Orquestación Docker, aislamiento entre ambientes, restauración del dump, verificación de conectividad. |

## 6. Estado de la restauración — validado, pendiente de integrar a `main`

La restauración contra `DBIntegrador` **ya se ejecutó y se validó por completo**, pero ese trabajo vive en la rama `feat/db-restauracion-dbintegrador` (commit `ce7fd5d`), que divergió de `main` antes de que se completara el resto del backlog (compose base, contratos de TEST/PROD, evidencias). Fusionar esa rama tal cual borraría ese trabajo posterior, así que **no se ha integrado todavía**.

**Resultado ya validado** (ver `docs/REPORTE-HU04-DBIntegrador.md` en esa rama):

| Esquema | Tablas | Esquema | Tablas |
| :--- | ---: | :--- | ---: |
| `auditoria` | 3 | `modulo6` | 18 |
| `modulo1` | 15 | `modulo7` | 15 |
| `modulo2` | 19 | `modulo8` | 13 |
| `modulo3` | 17 | `modulo9` | 38 |
| `modulo4` | 24 | **Total** | **187** |
| `modulo5` | 25 | | |

PostgreSQL 18 confirmado, `pg_cron` habilitado, y los seis roles del DBA verificados contra el resultado restaurado.

**Consecuencia práctica hoy:** `scripts/restaurar-bd.sh` en `main` todavía apunta al repositorio anterior del DBA (`docuemntacionDB`, dump `backup7_0_0.dump`, contenedor `SGPMP`). El script y el reporte validados en la rama divergente deben reaplicarse manualmente sobre el `main` actual — sin arrastrar el resto de los cambios de esa rama — para que la restauración oficial documentada aquí sea también la que corre en la práctica.

## 7. Hallazgos técnicos del dump (spike de validación)

Estos hallazgos son válidos independientemente del estado de integración de la rama, porque describen el contenido del dump en sí:

1. **CRLF en `DOCKER/sql/00-init-roles.sh` del repositorio del DBA.** Clonado en Windows, el shebang queda con final `\r` y el contenedor no arranca (`Exited (127)`). *Mitigación de nuestro lado:* normalizar a LF en una copia de trabajo fuera del repositorio del DBA, sin tocarlo.
2. **`pg_cron` queda en bucle de reinicio tras restaurar**, porque el dump trae una fila de `cron.job` con `database=sgpmp` y `username=postgres`, que no existen en el contenedor del DBA. *Mitigación:* `UPDATE cron.job SET username='dba', database='dba';` y limpiar `cron.job_run_details` inmediatamente después del `pg_restore`.
3. **El esquema `public` del dump trae 18 tablas ajenas** (de otro proyecto, no del SGPMP). *Mitigación:* restaurar con `--no-owner --no-privileges` y, si se requiere un ambiente limpio, eliminar esas tablas de `public` tras la restauración.
4. **El owner original del dump es `postgres`, que no existe** en el contenedor del DBA (`POSTGRES_USER=dba`). *Mitigación:* restaurar siempre con `--no-owner --no-privileges`; las 187 tablas quedan con owner `dba` sin pérdida de datos.
5. **El cliente `pg_restore` debe ser ≥ 17.** El dump es *archive version* 1.16 (generado con `pg_dump 18.4`); un cliente PostgreSQL 16 o anterior lo rechaza con "versión no soportada". Restaurar siempre dentro del contenedor del DBA, nunca con un cliente del host salvo que sea ≥ 17.

## 8. Reglas de control

* No modificar manualmente tablas, columnas, restricciones, índices ni esquemas.
* No crear estructuras de base de datos improvisadas en TEST o PROD.
* No usar la misma base de datos entre DEV, TEST y PROD.
* Los archivos `.dump` y `.sql` nunca se suben al repositorio (`.gitignore`: `database/dumps/*.dump`, `database/dumps/*.sql`, `database/*.dump`).

## 9. Flujo de migraciones

```text
Desarrollo (script de migración) → Pruebas (aprobación) → Implementación (ejecución controlada y verificación)
```

## 10. Próximos pasos

1. Reaplicar manualmente sobre `main` el script y el reporte validados de la rama `feat/db-restauracion-dbintegrador`, sin arrastrar el resto de sus cambios.
2. Confirmar con el DBA si crearán el rol `member_app`, o cuál rol existente debe usar el backend.
3. Obtener del DBA las credenciales reales de `member_iot` y del rol de aplicación para TEST y PROD (hoy vacías en `env/.env.test.example` y `env/.env.prod.example`, a propósito — no se inventaron valores).
