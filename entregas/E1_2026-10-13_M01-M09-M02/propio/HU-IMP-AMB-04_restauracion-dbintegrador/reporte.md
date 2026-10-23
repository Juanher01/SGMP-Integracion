# HU-04 - Restauracion controlada de DBIntegrador

## Estado final

**Completada tecnicamente. PR pendiente de revision del lider.**

Fuente aprobada: `DBIntegrador-master/backup7_1_0.dump`.
Configuracion validada: PostgreSQL 18, base `dba`, usuario `dba`, puerto `5433`.

## Alcance

Se adapto `scripts/restaurar-bd.sh` para consumir `DBIntegrador-master` sin modificar el repositorio externo del DBA. No se modificaron dumps, schemas, tablas ni roles.

## Fuente y configuracion

| Elemento | Valor |
|---|---|
| Fuente DBA | `../DBIntegrador-master` |
| Dump | `backup7_1_0.dump` |
| Roles | `backup_roles.sql` |
| PostgreSQL | 18 |
| Base / usuario | `dba` / `dba` |
| Puerto oficial | `5433` |
| Contenedor de validacion | `SGP-HU04-OFICIAL` |
| Extension | `pg_cron` |
| Volumen | `sgmp_hu04_oficial` |

## Cambios realizados

- El script usa `DBIntegrador-master` y crea una copia temporal en `.sgpmp-local`.
- Se corrigieron rutas para Windows/Git Bash mediante `context: .` y `MSYS_NO_PATHCONV=1`.
- Se normaliza `backup_roles.sql` desde UTF-16 a UTF-8.
- PostgreSQL 18 monta el volumen en `/var/lib/postgresql`.
- Se habilita y valida `pg_cron`.
- `DBA_PASSWORD` se recibe por variable de entorno y no se documenta.
- El modo normal conserva el volumen; `--reset` requiere uso explicito.
- `database/*.dump` fue agregado a `.gitignore`.

## Procedimiento

Desde la raiz de `SGMP-Integracion`:

```bash
export DBA_PASSWORD='valor-local-no-versionado'
bash scripts/restaurar-bd.sh
```

Reconstruccion explicita del volumen:

```bash
bash scripts/restaurar-bd.sh --reset
```

El script verifica la fuente, copia dump y roles, levanta PostgreSQL 18, aplica roles, habilita `pg_cron`, ejecuta `pg_restore --no-owner --no-privileges --role=dba` y valida el resultado.

## Validacion oficial

La prueba final se ejecuto con el contenedor `SGP-HU04-OFICIAL`, el puerto `5433` y el volumen `sgmp_hu04_oficial`. El script termino con codigo 0.

Resultados:

- PostgreSQL 18 inicio correctamente.
- `backup7_1_0.dump` se restauro correctamente.
- Se validaron los schemas `modulo1` a `modulo9`.
- Se restauraron 187 tablas: auditoria 3, M01 15, M02 19, M03 17, M04 24, M05 25, M06 18, M07 15, M08 13 y M09 38.
- Se validaron los roles `dba`, `member_deploy`, `member_dev`, `member_impl`, `member_iot` y `member_qa`.
- `pg_cron` quedo habilitado.
- El mensaje `role dba already exists` es esperado porque PostgreSQL crea el usuario inicial antes de aplicar el archivo de roles.

## Hallazgos corregidos

1. Se cambio el contexto absoluto del Compose temporal por `context: .` para Windows/Git Bash.
2. PostgreSQL 18 rechazo `/var/lib/postgresql/data`; se uso `/var/lib/postgresql`.
3. Git Bash convertia `/scripts/roles.sql`; se agrego `MSYS_NO_PATHCONV=1`.
4. `backup_roles.sql` estaba en UTF-16; el script lo normaliza a UTF-8.
5. `pg_cron` no estaba creado; ahora se crea y se valida obligatoriamente.
6. `SGPMP` ocupaba `5433`; se detuvo durante la prueba y luego se intento reiniciar. La instancia HU-04 quedo detenida para liberar el puerto.

## Seguridad

- `DBIntegrador-master` no fue modificado.
- No se agregaron dumps, contrasenas, tokens ni certificados.
- `database/bd-8-08-26.dump` queda excluido por `.gitignore`.
- `.sgpmp-local` queda fuera del control de versiones.

## Criterio de cierre

- [x] Fuente y dump definidos.
- [x] Script adaptado.
- [x] PostgreSQL 18 validado.
- [x] Restauracion oficial en `5433`.
- [x] Schemas M01-M09 validados.
- [x] 187 tablas validadas.
- [x] Roles y `pg_cron` validados.
- [x] Evidencia consolidada en este archivo.
- [x] Dumps y secretos excluidos.
- [ ] Commit creado.
- [ ] PR abierto y revisado.

## Siguiente accion

Configurar la identidad Git y crear el commit:

```bash
git diff --cached --check
git commit -m "feat: adaptar restauracion a DBIntegrador"
```

## ST-04 - Cableado de BD por ambiente

Se alinearon `env/.env.dev.example`, `env/.env.test.example` y `env/.env.prod.example` con las variables consumidas por los overrides `docker-compose.dev.yml`, `docker-compose.test.yml` y `docker-compose.prod.yml`.

| Ambiente | Cableado | Estado |
|---|---|---|
| DEV | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_APP_USER`, `DB_APP_PASSWORD` hacia DBIntegrador externa | Definido; el ejemplo usa `host.docker.internal:5433` |
| TEST | Mismas variables hacia una instancia DBIntegrador aislada y reiniciable | Definido; host, base y credenciales dependen de DBA/Pruebas |
| PROD | Mismas variables hacia la BD operada por Despliegue | Definido; valores llegan como secretos de Dokploy |

La BD no se duplica dentro del Compose de integración: se consume como capa externa recibida del DBA. TEST y PROD quedan pendientes de accesos y secretos reales; no se inventaron valores de infraestructura.
