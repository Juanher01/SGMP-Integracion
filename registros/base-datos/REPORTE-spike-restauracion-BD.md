# Reporte — Spike de validación de restauración de BD (SGPMP)

**Fecha:** 2026-08-11 · **Alcance:** spike desechable, sin infraestructura persistente
**Dump:** `docuemntacionDB/backup7_0_0.dump` · **Contenedor:** `docuemntacionDB/DOCKER` (postgres:17.10 + pg_cron)

**Veredicto corto:** el dump **restaura limpio** (`EXIT=0`, 0 errores, 0 warnings) sobre el
contenedor del DBA usando `--no-owner --no-privileges`. Hay **tres problemas reales** que hay
que resolver con el equipo de BD antes de automatizar: un bug de CRLF que impide levantar su
contenedor en Windows, un bucle de reinicio de `pg_cron` provocado por los datos restaurados,
y 18 tablas de otro proyecto contaminando el esquema `public` del dump.

---

## Pregunta 1 — ¿Restauran limpio los esquemas y sus tablas?

**Sí, con `--no-owner --no-privileges`: `pg_restore` EXIT=0, 0 errores, 0 warnings.**

### Conteo de tablas por esquema (tras el restore sobre `dba`)

| Esquema | Tablas base | Vistas |
|---|---:|---:|
| auditoria | 3 | 0 |
| modulo1 | 15 | 9 |
| modulo2 | 19 | 26 |
| modulo3 | 17 | 16 |
| modulo4 | 24 | 8 |
| modulo5 | 25 | 12 |
| modulo6 | 18 | 27 |
| modulo7 | 15 | 9 |
| modulo8 | 13 | 20 |
| modulo9 | 38 | 55 |
| **Subtotal objetivo** | **187** | **182** |
| public (ajeno, ver abajo) | 18 | 0 |
| cron (de la extensión) | 2 | 0 |
| **Total no-sistema** | **207** | **182** |

Los 10 esquemas (`auditoria` + `modulo1..modulo9`) se crearon completos. También se
restauraron **292 funciones/procedimientos** en esos esquemas y **328 triggers** de usuario,
con datos (p. ej. `auditoria` 9.423 filas, `modulo1` 1.716, `modulo4` 1.402, `modulo9` 908).

La cifra de "~206 tablas" del brief se explica: **187** son de los esquemas objetivo; el resto
hasta 205–207 son las 18 de `public` (ajenas) y las 2 de `cron`.

### Errores agrupados por tipo

Se hicieron dos intentos sobre volumen limpio:

| Intento | Invocación | Exit | Errores |
|---|---|---:|---:|
| **A** | `--no-owner --no-privileges` sobre `dba` | **0** | **0** |
| **B** | conservando owners/privilegios sobre `dba` | 1 | 1013 |

- **Ownership: 1013 errores (intento B), todos idénticos** — `role "postgres" does not exist`.
  Desglose por comando: 239 `ALTER FUNCTION`, 205 `ALTER TABLE`, 183 `ALTER SEQUENCE`,
  182 `ALTER VIEW`, 140 `ALTER TYPE`, 54 `ALTER PROCEDURE`, 10 `ALTER SCHEMA`.
  Causa: el dump fue tomado en una instancia cuyo superusuario es `postgres`, mientras que el
  contenedor del DBA usa `POSTGRES_USER=dba` y **no crea ningún rol `postgres`**.
  **Severidad: baja-media.** No pierde datos: las 187 tablas se crearon igual y quedaron con
  owner `dba`. Sólo fallan las reasignaciones de propietario.
- **Roles: 0 errores** relativos a la matriz del DBA (`grp_*`, `backend_dev`, `qa`, `iot`,
  `devops_*`). El dump no referencia ninguno de esos roles.
- **Privilegios: 0 errores.**
- **Otros: 0** en el intento A.

**Veredicto pregunta 1: restaura limpio** con `--no-owner --no-privileges`. Es la vía correcta,
porque los owners del dump (`postgres`) no existen ni deben existir en el contenedor del DBA.

---

## Pregunta 2 — Comportamiento de `pg_cron`

### Sobre la base `dba` (configuración actual del DBA)

- Estado base: `shared_preload_libraries=pg_cron`, `cron.database_name=dba`, y el init del DBA
  **no** crea la extensión (sólo `plpgsql`). Quien la crea es el dump.
- `CREATE EXTENSION pg_cron WITH SCHEMA pg_catalog` del dump **funcionó sin conflicto**:
  queda `pg_cron 1.6` en `pg_catalog` (y `pgcrypto 1.3` en `public`). Sin errores.

### ⚠️ Pero el restore deja `pg_cron` en bucle de reinicio

El dump **trae los datos de `cron.job`** (es tabla de configuración de la extensión, así que
`pg_dump` la incluye). La fila restaurada es:

```
jobid=1  jobname=desbloquear_cuentas  schedule=*/5 * * * *
database=sgpmp   username=postgres   active=t
```

Ni la base `sgpmp` ni el rol `postgres` existen en el contenedor del DBA, así que el
`pg_cron launcher` falla y reinicia **cada segundo, indefinidamente**:

```
ERROR:  role "postgres" does not exist
LOG:  background worker "pg_cron launcher" (PID …) exited with exit code 1
```

También llegaron **2.607 filas de `cron.job_run_details`** (historial de ejecuciones del
2026-07-13 al 2026-08-08 de la máquina del DBA), basura para nuestro entorno.

**Remediación validada** (0 crashes en los 8s siguientes):

```sql
UPDATE cron.job SET username = 'dba', database = 'dba';
TRUNCATE cron.job_run_details;   -- opcional, limpia el historial ajeno
```

Esto **hay que incluirlo en el script de restauración**, en cualquiera de los dos escenarios.

### ¿Base dedicada para los `modulo1..9`?

Se probaron los dos escenarios de verdad:

| Escenario | `cron.database_name` | Exit | Errores |
|---|---|---:|---:|
| Restore sobre `dba` | `dba` (actual) | **0** | 0 |
| Restore sobre base dedicada `sgpmp` | `dba` (sin ajustar) | 1 | **6** |
| Restore sobre base dedicada `sgpmp` | `sgpmp` (ajustado) | **0** | 0 |

Con base dedicada y **sin** ajustar el GUC, los 6 errores son todos cascada de `pg_cron`:

```
ERROR:  can only create extension in database dba
DETAIL: Jobs must be scheduled from the database configured in cron.database_name, since the
        pg_cron background worker reads job descriptions from this database.
HINT:   Add cron.database_name = 'sgpmp' in postgresql.conf to use the current database.
→ y en cascada: extension "pg_cron" does not exist, schema "cron" does not exist (x2),
  relation "cron.jobid_seq" does not exist, relation "cron.runid_seq" does not exist
```

**Respuesta: sí, una base dedicada obliga a ajustar `cron.database_name`.** No es opcional:
`pg_cron` sólo permite crear la extensión en la base que nombra ese parámetro, y es un GUC de
arranque (`shared_preload_libraries`), o sea que cambiarlo **exige reiniciar el servidor** y
modificar el `command:` del `docker-compose.yml` del DBA.

**Recomendación:** para el spike y el corto plazo, **dejar los `modulo1..9` en la base `dba`**
(configuración actual del DBA, restaura con 0 errores, sin negociar nada). Pero es una decisión
que conviene revisar con el equipo de BD, porque hoy `dba` es a la vez nombre de usuario
bootstrap, nombre de la base y destino de los datos de negocio, lo cual es confuso. Si se
prefiere una base `sgpmp` dedicada (lo cual **coincide con el nombre real de la base origen del
dump**), el cambio es de una línea en su compose:

```yaml
environment:
  POSTGRES_DB: sgpmp
command: >
  -c shared_preload_libraries=pg_cron
  -c cron.database_name=sgpmp
```

y quedó verificado que con ese ajuste el restore vuelve a dar **EXIT=0, 0 errores**.

---

## Invocación exacta de `pg_restore` que funcionó

```bash
docker exec -i SGPMP pg_restore -U dba -d dba --no-owner --no-privileges -v \
  < backup7_0_0.dump
```

**Nota:** el cliente `pg_restore` 17.10 **del propio contenedor sí lee el dump**. El archivo es
formato custom *archive version 1.16* (creado por `pg_dump 18.4` desde un servidor 17.10), que
PG17 soporta; el que **no** puede leerlo es un cliente PG16 o anterior — se verificó que
`pg_restore` 16 del host falla con `versión no soportada (1.16) en el encabezado del archivo`.
Consecuencia práctica: **restaurar siempre dentro del contenedor**, nunca con un cliente local
del host, salvo que sea ≥17.

Forma equivalente para el script definitivo (con el archivo copiado adentro):

```bash
docker cp backup7_0_0.dump SGPMP:/tmp/backup.dump
docker exec SGPMP pg_restore -U dba -d dba --no-owner --no-privileges -v /tmp/backup.dump
docker exec SGPMP psql -U dba -d dba -c "UPDATE cron.job SET username='dba', database='dba';"
```

---

## Ajustes que hay que proponerle al equipo de BD

1. **🔴 Bloqueante — CRLF en `DOCKER/sql/00-init-roles.sh`.** Clonado en Windows, el script
   queda con finales CRLF y el shebang `#!/bin/bash\r` hace que el entrypoint muera:
   `cannot execute: required file not found` → **contenedor `Exited (127)`, roles nunca creados.**
   *Cómo se resolvió en el spike:* se montó una copia con finales LF vía un override de compose
   externo (en el scratchpad), sin tocar su repo.
   *Fix que deben aplicar ellos:* agregar un `.gitattributes` con `*.sh text eol=lf`.
2. **🟠 `pg_cron` queda en bucle tras el restore** (rol `postgres` / base `sgpmp` inexistentes).
   O el script de restauración corre el `UPDATE cron.job` de arriba, o el DBA excluye los datos
   de `cron.job`/`cron.job_run_details` al generar el dump.
3. **🟠 El esquema `public` del dump trae 18 tablas de otro proyecto**: `clientes`,
   `dispositivos`, `ordenes_servicio`, `tecnicos`, `cotizaciones`, `ventas`, `productos`,
   `marcas`, `items_*`, `estados_orden`, `historial_estados`, `empresa_config`,
   `tipos_dispositivo`, `tipos_servicio`, más `_sqlx_migrations` y `alembic_version`.
   No es del SGPMP: son restos de otra aplicación en la misma base. Conviene pedir un dump
   limpio (`pg_dump -n auditoria -n 'modulo*'`) o excluir `public` al restaurar.
4. **🟡 Owner `postgres` inexistente.** Mientras el dump se genere desde una instancia con
   superusuario `postgres`, hay que restaurar con `--no-owner --no-privileges` (documentarlo)
   o que ellos generen el dump ya con owner `dba`.
5. **🟡 `.env` versionado.** `DOCKER/.env` está *commiteado* con contraseñas reales de todos los
   roles. Debería ir a `.gitignore` (su propio `.env.example` lo advierte, pero no se cumplió).
   *En el spike no se tocó:* se usó `docker compose --env-file` apuntando a un `.env` de prueba
   fuera del repo.
6. **🟢 Absorber el restore en su `initdb.d`.** Es viable y automatiza todo, pero implica meter
   un dump de 6,6 MB en su repo y que el restore corra sólo en la primera inicialización del
   volumen. Alternativa preferible: dejarlo como script externo del equipo de Integración,
   que es lo que este spike deja listo.

---

## Reproducibilidad

El spike no dejó infraestructura montada (`docker compose down -v` final; sin contenedores ni
volúmenes) y **el repo `docuemntacionDB` quedó intacto** (`git status --porcelain` vacío).

Archivos auxiliares usados, todos fuera del repo del DBA (en el scratchpad de la sesión):
`dba-test.env` (contraseñas `dev123`), `compose.override.yml` (montaje LF), `compose.dedicada.yml`
(experimento de base dedicada), y los logs `restore-pg17.log`, `restore-owners.log`,
`restore-sgpmp.log`, `restore-dedicada.log`.
