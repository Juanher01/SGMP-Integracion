# HU-IMP-CFG-04 — TEST recibe y documenta las variables de M04/M07 (`SGPMP_ENTORNO=TEST`) sin romper el respaldo de auditoría IoT

> **Estado:** en ejecución (2026-11-21, tarde): ST-01, ST-02, ST-03, ST-04a, ST-04b y ST-05 hechas (PR #1216 y #1217 fusionados el 2026-11-21; tabla de cabecera de la plantilla de TEST en el PR #1220, abierto); ST-04c y ST-06 esperan la fusión de #1204; ST-07 hecha: CA-10 cumple (release 1.4.0 en `main` por el PR #1219, 2026-11-21). Ver «Estado por subtarea». Creada en Taiga con ST-04a, ST-04b y ST-04c (2026-11-21; antes: lista para Taiga, fase 2, 2026-11-20, con las decisiones del líder). Renumeración del 2026-11-21: ver decisión 8. Carpeta: `entregas/E4_2026-11-24_M07-M08-final/issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/` (origen: issue, ADR-002).
> Fuente principal: [`analisis.md`](../../../prs/BACK-PR1204_compose-test-entorno-m04/analisis.md) (EXT-BACK-PR1204). Borradores de comentarios: [`entregables/borradores-comentarios.md`](entregables/borradores-comentarios.md). Brief de origen: [`brief-issue-1180.md`](brief-issue-1180.md) (copia del 2026-11-20; sus rutas `BE-PR1204_…` son anteriores al cambio de nombre a `BACK-PR1204_…`).
> Corte: `git fetch` del 2026-11-20 · BE `origin/dev 6cee5fc4` · `origin/test 12965211` · `origin/main 0abbeeef` · PR #1204 `b8968e68` · SGMP-Integracion `main f40300b`.
> Reverificado el 2026-11-21: BE `origin/dev 8d4981f6` · `origin/test 918806ec` · `origin/main 0abbeeef` · PR #1204 `b8968e68` (abierto) · SGMP-Integracion `main e11893c` (PR #21 fusionado). `test` y `dev` avanzaron sin tocar `docker-compose*.yml`, `.env*.example`, `Dockerfile` ni `.dockerignore`: las citas de líneas de esta HU siguen vigentes.
> Corte del 2026-11-21, 17:55 (America/Bogota): BE `origin/dev 8d4981f6` · **`origin/test cd5f36de`** (merges de M08 desde `dev`) · `origin/main 0abbeeef` · PR #1204 `097f6d80` (OPEN) · PR #941 OPEN · SGMP-Integracion `main a910760` (PR #22 y #23 fusionados). Entre `test@12965211` y `@cd5f36de` no cambia ningún `Dockerfile`, `.dockerignore`, `docker-compose*.yml` ni `.env*.example`, y el código no lee variables nuevas: las citas `@12965211` siguen vigentes. La ficha de ST-03 (corte `test@12965211`, reverificada en `@918806ec`) también sigue vigente.
> Corte del 2026-11-21, 22:15 (America/Bogota): BE `origin/dev 5115b83d` · `origin/test c698c656` · PR #1216 fusionado (`35f3ec3b`) · PR #1217 fusionado (`e372a059`) · PR #1220 abierto (m-04) · BE `origin/main 9655f389` (release 1.4.0, PR #1219; el #941 se cerró sin fusionar) · PR #1204 `097f6d80` (OPEN). Entre `test@35f3ec3b` y `@c698c656` solo entran archivos de Testing/Modulo7.

### Estado por subtarea (corte 2026-11-21, 17:55)

| ST | Estado | Evidencia |
|---|---|---|
| ST-01 Comentarios | Hecha | URLs en ST-01 |
| ST-02 Catálogo | Hecha (PR #23, fusionado 2026-11-21) | `registros/variables/VARIABLES-ENTORNO.md` |
| ST-03 Ficha | Hecha: entregada a Despliegue el 2026-11-21 a las 17:50 (America/Bogota). **Pendiente:** su respuesta sobre `IOT_INFERENCIA_M04_URL` y `OTA_URL_*` en TEST | Ver ST-03 |
| ST-04a Plantilla de TEST | Hecha: [PR #1216](https://github.com/Arekkazu/sgpmp-backend/pull/1216) a `test`, fusionado el 2026-11-21, 18:08 (America/Bogota; 23:08 UTC), `test 35f3ec3b`. Tabla de cabecera (REV-06 m-04): [PR #1220](https://github.com/Arekkazu/sgpmp-backend/pull/1220) a `test`, abierto (aprueba el Líder de Pruebas) | [`evidencias/CA-05_CA-06_plantillas.md`](evidencias/CA-05_CA-06_plantillas.md) |
| ST-04b Commit en el #1204 | Hecha (`097f6d80`) | [`evidencias/CA-04_st04b.txt`](evidencias/CA-04_st04b.txt) |
| ST-04c Retiro de `AGROFUSION_HUB_*` del compose | En espera de la fusión de #1204 | — |
| ST-05 `OTA_URL_*` en `.env.prod.example` | Hecha: [PR #1217](https://github.com/Arekkazu/sgpmp-backend/pull/1217) a `dev`, fusionado el 2026-11-21, 18:08 (America/Bogota; 23:08 UTC), `e372a059` | [`evidencias/CA-05_CA-06_plantillas.md`](evidencias/CA-05_CA-06_plantillas.md) |
| ST-06 TEST desplegado | En espera de la fusión de #1204 y del Deploy | — |
| ST-07 Registros y PROD | Hecha: INC-BE-09, INC-BE-04 (PR #1216) e INC-BE-02 (HU-IMP-AMB-10) actualizadas. CA-10 cumple: release 1.4.0 por el PR #1219 (#941 cerrado sin fusionar) | [`evidencias/CA-10_prod-seguimiento.md`](evidencias/CA-10_prod-seguimiento.md) |

---

## Para copiar en Taiga — Descripción de la HU

**Rama:** BE `cfg-04/test-plantilla-variables` → PR a `test` (ST-04a) · BE `fix/compose-test-entorno-m04-1180` → commit en la rama del PR #1204 (ST-04b) · BE `cfg-04/test-retiro-hub` → PR a `test` (ST-04c) · BE `cfg-04/dev-plantilla-prod-ota` → PR a `dev` · SGMP-Integracion `docs/hu-imp-cfg-04-variables-m04` (carpeta de la HU, INC-BE-09 y traslado desde CFG-03) y una rama propia para ST-02, ST-03 y ST-07 → PR a `main` · **Plazo:** por definir (líder); sugerido 2026-11-23 · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval · **Entrega:** E4 (2026-11-24) · **Módulos:** M07 (RF-97), M04 (RF-26, RF-53, RF-56/66, RF-69), OTA

**Origen.** Issue — [sgpmp-backend#1180](https://github.com/Arekkazu/sgpmp-backend/issues/1180) · Autor: TEX053 (Pruebas, TC-M07-378-G025) · Fecha: 2026-11-19 · Cerrado por Arekkazu el 2026-11-20 **sin la corrección desplegada**. Cambio relacionado de otro equipo: [PR #1204](https://github.com/Arekkazu/sgpmp-backend/pull/1204) (Arekkazu, `b8968e68`) e informe EXT-BACK-PR1204 (incluye el commit `d417c0c6`, SEG-M04-01 = issue #1161, directriz de Desarrollo, no de Análisis).

**Situación actual.** En TEST, `SourceSystem.Environment` vale `"DEV"`: `configuracion.py:18@12965211` lee `os.getenv("SGPMP_ENTORNO", "DEV")` y `docker-compose.test.yml@12965211` no pasa la variable al contenedor. El PR #1204 (abierto, 1 commit, 0 revisiones, sin conflicto con `test`) agrega 11 variables al `environment:` del backend de TEST con `${VAR:-…}`, igual que `dev`. Tiene un defecto: `docker-compose.test.yml:82@b8968e68` fija `IOT_AUDITORIA_RESPALDO_PATH` a la ruta relativa `var/auditoria_iot/fallas.sqlite3`, que sobrescribe el `ENV` de la imagen (`Dockerfile:61@12965211`, carpeta con dueño 1000 en l. 55-56) y resuelve a `/app/var`, de root y no escribible por `USER 1000` (l. 62; `.dockerignore:19` excluye `var/auditoria_iot/`). Además el PR no retira `AGROFUSION_HUB_*` (l. 67-68@b8968e68), que el código de `test` y `dev` ya no lee, ni toca `.env.test.example` ni el catálogo.

| Rama / artefacto | Estado | Evidencia |
|---|---|---|
| BE `test` | ❌ Sin `SGPMP_ENTORNO` ni las otras 10 en el compose; ⚠️ `AGROFUSION_HUB_*` en compose (l. 66-67) y `.env.test.example` (l. 54-55); ❌ `.env.test.example` sin ninguna de las 11 | `test@12965211` |
| PR #1204 → `test` | ⚠️ Corrige #1180; defecto en l. 82; conserva `AGROFUSION_HUB_*` | `b8968e68` (base `135bc318`) |
| BE `dev` | ✅ Las 11 en `docker-compose.yml`; `.env.prod.example` sin `OTA_URL_SECRET`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS` aunque `docker-compose.prod.yml` l. 167-169 las referencia | `dev@6cee5fc4` |
| BE `main` (PROD) | ⏳ Sin `SGPMP_ENTORNO` ni el código que la lee: sin efecto hoy. Llega con el release #941 (`dev`→`main`, abierto): `b2b9097b`, `d417c0c6`, `5e87d61e`, `098f635a` están en `dev` y `test` y AUSENTES en `main` | `main@0abbeeef`, `git merge-base --is-ancestor` |
| Catálogo `VARIABLES-ENTORNO.md` | ❌ Solo `SGPMP_ENTORNO` (l. 92, con líneas de compose desactualizadas); faltan 10 | SGMP-Integracion `main@f40300b` |

**Descripción.** Que el backend de TEST reciba y documente las variables de M04, OTA y M07 en toda la cadena (compose → plantilla → catálogo → ficha para Despliegue), sin la regresión de la l. 82, y verificar en TEST desplegado que `SGPMP_ENTORNO` llega al contenedor para que Pruebas re-pruebe #1180. La corrección del compose la hace Desarrollo en #1204; Implementación aporta la observación del defecto y su corrección con un commit en la rama de #1204 (ST-04b), la plantilla, el retiro de `AGROFUSION_HUB_*`, el catálogo, la ficha y el seguimiento hasta PROD. Sustituye la T2 / ST-02 de HU-IMP-CFG-03.

**Alcance.** Borradores de comentario para #1204 y #1180 · PR a `test`: `.env.test.example` con las variables de #1204, con las variables obligatorias (`${VAR:?}`) del compose de TEST que faltaban (ampliación del líder, 2026-11-21) y sin `AGROFUSION_HUB_*`; retiro de `AGROFUSION_HUB_*` de `docker-compose.test.yml` · Corrección de `IOT_AUDITORIA_RESPALDO_PATH` (l. 82) con un commit en la rama de #1204 o un PR hacia ella; si #1204 se fusiona sin la corrección, en el PR del compose · PR a `dev`: `OTA_URL_*` en `.env.prod.example` · Catálogo (10 filas nuevas y fila de `SGPMP_ENTORNO` corregida) · Ficha para Despliegue · Registro de incidencias · Verificación tras el despliegue en TEST · Seguimiento de PROD con el release #941.
**Fuera de alcance:** fusionar #1204 (Líder de Pruebas) · cargar valores en Dokploy y hacer Deploy (Despliegue) · definir el valor de `M04_FIRMA_MODELOS_KEY` (Despliegue lo carga; lo provee Desarrollo/Seguridad) · re-prueba de TC-M07-378-G025 (Pruebas, TEX053; exige sesión con permiso `exportacion_contable`) · mensaje de error engañoso `FIRMA_ARTEFACTO_INVALIDA` cuando falta la clave (Desarrollo) · disponibilidad del motor M04 de TEST (AIoT/Desarrollo) · volúmenes persistentes para logos, modelos y respaldo de auditoría (HU-IMP-AMB-10, en borrador: va después de esta HU y depende de la respuesta de Desarrollo sobre persistencia; dentro de ella, prioridad al respaldo de auditoría en PROD; INC-BE-02) · `${M04_FIRMA_MODELOS_KEY:?}` en PROD: no se hace (decisión del líder, 2026-11-20); queda como posible mejora, sin HU aparte.

**Criterios de aceptación.**
1. CA-1 **Corte.** La HU y cada PR registran la fecha del `git fetch` y los hashes de BE `origin/dev`, `origin/test`, `origin/main`, la cabeza de #1204 y `SGMP-Integracion origin/main`, reverificados el día de abrir cada PR (no se reutilizan los de este borrador).
2. CA-2 **Comunicación y desviación.** Hay en la HU enlaces a un comentario publicado en #1204 (defecto de la l. 82 con la corrección propuesta, `AGROFUSION_HUB_*` sin uso, Deploy y no Restart) y a una respuesta en #1180 (la re-prueba depende de la fusión de #1204 y del Deploy; el seguimiento va en INC-BE-09; no se pide reabrir el issue). El comentario en #1204 explica la desviación frente a lo que pidió Arekkazu en #1180: Implementación no «define» ni lee valores de secretos ni del `.env` de TEST; documenta nombre, sensibilidad y regla de carga, y Despliegue carga el valor.
3. CA-3 **Compose de TEST.** En `origin/test`: `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}` presente; cero apariciones de `AGROFUSION_HUB_`; `IOT_AUDITORIA_RESPALDO_PATH` ausente del compose o con la ruta absoluta `/app/storage/auditoria_iot/fallas.sqlite3`.
4. CA-4 **Respaldo de auditoría escribible.** La imagen construida desde la rama del PR #1204 con el commit de ST-04b (o desde la rama del PR de ST-04b hacia esa rama, si no hubo permiso de escritura; o desde la rama de ST-04c, si #1204 se fusionó sin esa corrección), con el valor que entrega el compose de TEST, resuelve `IOT_AUDITORIA_RESPALDO_PATH` a `/app/storage/auditoria_iot/fallas.sqlite3` y el proceso (uid 1000) puede escribir en esa carpeta.
5. CA-5 **Plantilla de TEST.** `.env.test.example` en `origin/test` contiene cada variable que el compose de TEST agrega en #1204 (`IOT_AUDITORIA_RESPALDO_PATH` como comentario «la fija la imagen»), sin `AGROFUSION_HUB_*`, con un comentario de sensibilidad en `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN` y `OTA_URL_SECRET`, y **sin valor** en esos tres. Contiene además las variables obligatorias (`${VAR:?}`) del compose de TEST, `MQTT_BROKER_URL` y `MQTT_BROKER_TOKEN`, esta con comentario de sensibilidad y sin valor (ampliación del líder, 2026-11-21). Todo lo de este CA llega con ST-04a (variables nuevas y retiro de `AGROFUSION_HUB_*` de la plantilla).
6. CA-6 **Plantilla de PROD en `dev`.** `.env.prod.example` en `origin/dev` contiene `OTA_URL_SECRET=` (vacío, marcado sensible), `OTA_URL_BASE` y `OTA_URL_TTL_SEGUNDOS`, por PR propio a `dev`.
7. CA-7 **Catálogo.** `registros/variables/VARIABLES-ENTORNO.md` (registro vivo; no un archivo paralelo) en `main` de SGMP-Integracion tiene exactamente una fila por cada una de las 11 variables, con sensibilidad (sensibles: `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN` y `OTA_URL_SECRET`) y estado por entorno; la fila de `SGPMP_ENTORNO` cita líneas y hashes vigentes y ya no dice «falta en TEST» si #1204 está fusionado; la nota de la l. 340 apunta a esta HU.
8. CA-8 **Ficha para Despliegue.** Existe `registros/variables/fichas/HU-IMP-CFG-04_<aaaa-mm-dd>.md` con: variable, entorno, obligatoria, sensibilidad, quién provee el valor, acción en Dokploy; `SGPMP_ENTORNO` opcional (`TEST` o el valor por defecto); regla de carga de `IOT_INFERENCIA_M04_URL` y `IOT_INFERENCIA_M04_TOKEN` solo con el motor de TEST con `modelos_cargados > 0`; «Deploy, no Restart»; el comando de verificación de presencia; ningún valor de secreto. **Entregada a Despliegue el 2026-11-21, 17:50 (America/Bogota; 22:50 UTC)** por chat de WhatsApp al Líder de Despliegue (detalle en ST-03).
9. CA-9 **TEST desplegado.** `b8968e68` (o su contenido) está en `origin/test`; Despliegue confirma por escrito un **Deploy** posterior a la fusión (fecha y hora); la salida del comando de presencia (`presente`/`ausente`, sin valores) se adjunta; y la HU enlaza el resultado de la re-prueba de Pruebas en #1180 (`SourceSystem.Environment = "TEST"`) o, si Pruebas no la hizo al cierre, el líder deja constancia de que sigue pendiente. Como #1180 está cerrado, este CA, ST-06 e INC-BE-09 son el seguimiento de la re-prueba.
10. CA-10 **PROD en seguimiento.** La HU registra, con fecha de corte, el estado en `origin/main` de `b2b9097b`, `d417c0c6`, `5e87d61e` y `098f635a` y el estado del PR #941. Cuando el release se fusione: `docker-compose.prod.yml` de `main` contiene `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-PROD}`.
11. CA-11 **Registros.** `registros/incidencias/registro.md` tiene la fila INC-BE-09 (#1180: `SGPMP_ENTORNO` no llega al contenedor de TEST; causa compose; corrige Desarrollo en #1204; estado; PROD con #941; es el seguimiento de la re-prueba, porque #1180 está cerrado), INC-BE-04 actualizada con el PR de ST-04a, e INC-BE-02 enlazada a HU-IMP-AMB-10 (borrador). La ST-02/T2 de HU-IMP-CFG-03 queda anotada como trasladada a esta HU.

**Verificación.** (`BE` = `sgpmp-backend`; en Git Bash anteponer `MSYS_NO_PATHCONV=1` a `git show origin/<rama>:<archivo>`.)

| CA | Método (comando o prueba) | Resultado esperado | Evidencia a adjuntar |
|---|---|---|---|
| CA-1 | `git -C sgpmp-backend fetch --prune origin; for b in dev test main; do git -C sgpmp-backend log -1 --format="$b %h %ad" --date=short origin/$b; done; gh pr view 1204 -R Arekkazu/sgpmp-backend --json state,headRefOid; git -C SGMP-Integracion fetch; git -C SGMP-Integracion log -1 --format=%h origin/main` | Hashes y fecha del día del PR, copiados en la descripción del PR y en `evidencias/` | Salida pegada en `evidencias/CA-01_corte.md` |
| CA-2 | `gh pr view 1204 -R Arekkazu/sgpmp-backend --comments \| grep -n 'IOT_AUDITORIA_RESPALDO_PATH'` y `gh issue view 1180 -R Arekkazu/sgpmp-backend --comments \| grep -niE 'Deploy\|1204'` | Ambos con coincidencias en un comentario del líder; ninguno contiene valores | URLs de los dos comentarios |
| CA-3 | `git -C sgpmp-backend show origin/test:docker-compose.test.yml \| grep -c AGROFUSION_HUB_` · `… \| grep -n 'SGPMP_ENTORNO:'` · `… \| grep -n 'IOT_AUDITORIA_RESPALDO_PATH'` | `0` · `${SGPMP_ENTORNO:-TEST}` · sin salida o solo `/app/storage/auditoria_iot/fallas.sqlite3` | Salida + hash de `origin/test` |
| CA-4 | En la rama que lleva la corrección (la de #1204 con el commit de ST-04b; o la del PR de ST-04b hacia ella; o la de ST-04c), tomar el valor que entrega el compose **tal cual** (sin sustituirlo): `V=$(sed -n 's/^ *IOT_AUDITORIA_RESPALDO_PATH: *\${IOT_AUDITORIA_RESPALDO_PATH:-\(.*\)}.*$/\1/p;t;s/^ *IOT_AUDITORIA_RESPALDO_PATH: *\([^$ ].*\)$/\1/p' docker-compose.test.yml); echo "compose: ${V:-sin línea, vale el ENV de la imagen}"`. Luego `docker build -t sgpmp-back:cfg04 .` y `docker run --rm ${V:+-e IOT_AUDITORIA_RESPALDO_PATH=$V} --entrypoint sh sgpmp-back:cfg04 -c 'id -u; echo "$IOT_AUDITORIA_RESPALDO_PATH"; d=$(dirname "$IOT_AUDITORIA_RESPALDO_PATH"); mkdir -p "$d" && touch "$d/.w" && echo ESCRIBIBLE'` (sin `--env-file` real). En Git Bash, anteponer `MSYS_NO_PATHCONV=1` al `docker run`: sin eso, `-e IOT_AUDITORIA_RESPALDO_PATH=/app/…` llega convertido en una ruta de Windows y la prueba falla aunque el compose esté bien (REV-02 n-01). El `sed` cubre `${…:-valor}` y el valor literal; se probó el 2026-11-20 contra `b8968e68` (devuelve la ruta relativa), `test@12965211` (vacío) y `dev@6cee5fc4` (literal). | `1000` · `/app/storage/auditoria_iot/fallas.sqlite3` · `ESCRIBIBLE`. Con la l. 82 relativa la prueba **falla** (muestra `var/...` y no imprime `ESCRIBIBLE`) | Salida pegada, con el valor de `V` |
| CA-5 | `diff <(git -C sgpmp-backend show origin/test:docker-compose.test.yml \| grep -oE '\$\{[A-Z0-9_]+' \| tr -d '${' \| sort -u) <(git -C sgpmp-backend show origin/test:.env.test.example \| grep -oE '^[A-Z0-9_]+=' \| tr -d '=' \| sort -u)` y `git -C sgpmp-backend show origin/test:.env.test.example \| grep -nE '^(M04_FIRMA_MODELOS_KEY\|IOT_INFERENCIA_M04_TOKEN\|OTA_URL_SECRET\|MQTT_BROKER_TOKEN)=.+'` | (a) Ausencia en la plantilla: `git -C sgpmp-backend show origin/test:.env.test.example \| grep -c AGROFUSION_HUB_` → `0`. (b) `diff`, evaluado **después de la fusión de #1204** (antes, las 10 variables de la plantilla salen como solo-plantilla `>`): ninguna variable de #1204 como solo-plantilla (`>`) ni como solo-compose (`<`), salvo `IOT_AUDITORIA_RESPALDO_PATH` mientras siga en el compose (en la plantilla es comentario); `AGROFUSION_HUB_*` puede aparecer como solo-compose hasta ST-04c; otras diferencias preexistentes se listan en la descripción del PR. (c) El segundo comando sin salida. (d) `git -C sgpmp-backend show <rama de ST-04a>:.env.test.example \| sed 's/=$/=x/' > <copia temporal>` y `docker compose -f docker-compose.test.yml --env-file <copia> config --quiet`, con el compose de `origin/test` (después de la fusión de #1204) o de la cabeza de #1204 (antes); se borra la copia → termina sin error (`PLANTILLA-OK`). Solo se aceptan avisos de variables opcionales listadas como diferencias previas. Control negativo: sin `MQTT_BROKER_URL` falla | Salidas + enlace al PR |
| CA-6 | `git -C sgpmp-backend show origin/dev:.env.prod.example \| grep -nE '^OTA_URL_(SECRET\|BASE\|TTL_SEGUNDOS)='` y `… \| grep -nE '^OTA_URL_SECRET=.+'`. (b) Lo mismo que CA-5 (d), con `.env.prod.example` y `docker-compose.prod.yml` de la rama de ST-05 | 3 líneas · sin salida · (b) `PLANTILLA-OK`. Si falla por una variable que no sea `OTA_URL_*`, se reporta como hallazgo y no entra en ST-05 | Salida + enlace al PR a `dev` |
| CA-7 | `for v in SGPMP_ENTORNO M04_FIRMA_MODELOS_KEY LOGOS_STORAGE_PATH IOT_INFERENCIA_M04_URL IOT_INFERENCIA_M04_TOKEN IOT_INFERENCIA_TLS_MIN IOT_INFERENCIA_CA_FILE IOT_AUDITORIA_RESPALDO_PATH OTA_URL_SECRET OTA_URL_BASE OTA_URL_TTL_SEGUNDOS; do echo "$v $(git -C SGMP-Integracion show origin/main:registros/variables/VARIABLES-ENTORNO.md \| grep -c "^| \`$v\`")"; done` | `1` en cada una; las tres sensibles dicen `Secreta` (vocabulario del catálogo, §1) | Salida + enlace al PR a SGMP-Integracion |
| CA-8 | `grep -nE 'Deploy\|modelos_cargados\|Secreta' registros/variables/fichas/HU-IMP-CFG-04_*.md` | Aparecen las tres cosas; revisión visual: ninguna celda con un valor de secreto | Ruta de la ficha + confirmación de entrega a Despliegue |
| CA-9 | `git -C sgpmp-backend merge-base --is-ancestor b8968e68 origin/test && echo INCLUIDO` (si hubo squash: `git show origin/test:docker-compose.test.yml \| grep -n 'SGPMP_ENTORNO:'`). Despliegue ejecuta: `docker exec <backend-test> sh -c 'for v in SGPMP_ENTORNO M04_FIRMA_MODELOS_KEY IOT_INFERENCIA_M04_URL OTA_URL_SECRET; do [ -n "$(printenv $v)" ] && echo "$v presente" \|\| echo "$v ausente"; done'` | `INCLUIDO`; `SGPMP_ENTORNO presente`; mensaje de Despliegue con «Deploy» y hora posterior a la fusión; comentario de Pruebas en #1180 con `"TEST"` | `evidencias/CA-09_test-desplegado.md` |
| CA-10 | `for c in b2b9097b d417c0c6 5e87d61e 098f635a; do git -C sgpmp-backend merge-base --is-ancestor $c origin/main && echo "$c INCLUIDO" \|\| echo "$c AUSENTE"; done; gh pr view 941 -R Arekkazu/sgpmp-backend --json state` y, tras el release, `git -C sgpmp-backend show origin/main:docker-compose.prod.yml \| grep -n 'SGPMP_ENTORNO:'` | Tabla con fecha; tras el release: 4 × `INCLUIDO` y `${SGPMP_ENTORNO:-PROD}` | `evidencias/CA-10_prod-seguimiento.md` |
| CA-11 | `grep -nE '^\| INC-BE-(02\|04\|09) ' registros/incidencias/registro.md` y `grep -n 'HU-IMP-CFG-04' entregas/E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-03_agrofusion-sso/historia.md` | Tres filas con estado actualizado y enlace a esta HU; CFG-03 cita CFG-04 en su ST-02 | Enlace al PR a SGMP-Integracion |

**Definición de terminado.**
- [ ] Todos los CA verificados con evidencia en `evidencias/` de la HU (CA-10 puede cerrar en estado «seguimiento» con la tabla al corte, si el release no ocurrió).
- [ ] PRs abiertos (a `test`, a `dev`, a `main` de SGMP-Integracion) con descripción que enlaza esta HU, #1180 y #1204.
- [ ] PRs aprobados y fusionados por quien corresponde a cada rama.
- [ ] Registros vivos actualizados: `registros/variables/VARIABLES-ENTORNO.md`, `registros/variables/fichas/`, `registros/incidencias/registro.md`.
- [ ] Ficha entregada a Despliegue y confirmación de Deploy registrada.
- [ ] Sin valores de secretos en ningún archivo, PR ni comentario.

**Dependencias y aprobaciones.**
- PRs a `test` (BE), los aprueba el Líder de Pruebas: ST-04a (`.env.test.example`, con el retiro de `AGROFUSION_HUB_*` de la plantilla) no depende de #1204; ST-04b es un commit en la rama de #1204 **antes** de su fusión (requiere permiso de escritura en el repositorio y aviso a Arekkazu en el PR; sin permiso, PR hacia la rama `fix/compose-test-entorno-m04-1180`, que acepta Arekkazu); ST-04c **depende de la fusión de #1204** (toca las mismas líneas del compose).
- PR a `dev` (BE): Líder de Desarrollo. Sin dependencias.
- PR a `main` (SGMP-Integracion): Líder de Implementación.
- Despliegue: cargar valores (`M04_FIRMA_MODELOS_KEY` y, cuando aplique, motor M04 y OTA) y hacer Deploy del backend de TEST.
- Pruebas (TEX053): re-prueba de TC-M07-378-G025.
- AIoT/Desarrollo: confirmar que el motor M04 de TEST tiene `modelos_cargados > 0` antes de cargar `IOT_INFERENCIA_M04_URL`.
- Release #941 (`dev`→`main`, Líder de Despliegue) para PROD.

**Riesgos.**
- #1204 se fusiona con la l. 82: el respaldo de auditoría IoT falla con `PermissionError` cuando la BD no responde (RF-53). Mitigación: comentario antes de la fusión (ST-01) y commit propio en la rama de #1204 (ST-04b, decisión del líder 2026-11-21; sin permiso de escritura, PR hacia su rama); si #1204 se fusiona sin esa corrección, lo corrige ST-04c. Detección: CA-4.
- Despliegue hace Restart y no Deploy: el contenedor sigue sin `SGPMP_ENTORNO`. Detección: comando de presencia (CA-9).
- Cargar `IOT_INFERENCIA_M04_URL` con el motor sin modelos: los paquetes pasan a FALLIDO al 5.º intento (0/5/15/30/60 s) sin vuelta atrás; el backend no consulta `healthz`. Mitigación: regla de carga en la ficha.
- Sin `M04_FIRMA_MODELOS_KEY` en TEST: registrar modelo da 503 `FIRMA_MODELOS_NO_CONFIGURADA` y activar da 422 `FIRMA_ARTEFACTO_INVALIDA` (mensaje engañoso). No impide desplegar.
- `LOGOS_STORAGE_PATH` y `MODELOS_STORAGE_PATH` en `/tmp` sin volumen: tras cada Deploy los logos dan 404 y activar versiones da 422 `ARTEFACTO_ALTERADO`. Fuera de esta HU (HU-IMP-AMB-10, borrador); se advierte a Pruebas en la ficha.
- #1204 sigue abierto al 2026-11-23: ST-04c y ST-06 quedan en curso para E4; ST-04a y ST-04b avanzan igual.
- ST-04a publica en la plantilla variables que el compose de TEST todavía no pasa (hasta que se fusione #1204). Mitigación: comentario en el bloque de la plantilla («las pasa el compose desde #1204») y la ficha de ST-03 lo repite.

**Referencias.** [#1180](https://github.com/Arekkazu/sgpmp-backend/issues/1180) · [#1204](https://github.com/Arekkazu/sgpmp-backend/pull/1204) · [#1161 SEG-M04-01](https://github.com/Arekkazu/sgpmp-backend/issues/1161) · [#941 release](https://github.com/Arekkazu/sgpmp-backend/pull/941) · commits `b8968e68`, `d417c0c6`, `b2b9097b`, `5e87d61e`, `098f635a` · `entregas/E4_2026-11-24_M07-M08-final/prs/BACK-PR1204_compose-test-entorno-m04/analisis.md` · `entregables/borradores-comentarios.md` · HU-IMP-CFG-03 ST-02 · INC-BE-09, INC-BE-02, INC-BE-04 · HU-IMP-AMB-10 (borrador).

---

## Para copiar en Taiga — Subtareas

### ST-01 Publicar (líder) y enlazar los comentarios en #1204 y #1180
**Objetivo.** Que Desarrollo corrija la l. 82 antes de fusionar y que Pruebas sepa cuándo re-probar.
**Pasos.**
1. Los textos están en `entregables/borradores-comentarios.md` (§1 y §2); reverificar hashes (CA-1) y que #1204 siga abierto (`gh pr view 1204 … --json state`). Si ya se fusionó, quitar del §1 la petición sobre la l. 82 y dejar el aviso de que la corrige ST-04c.
2. Confirmar que el §1 incluye la desviación de CA-2 (no definimos ni leemos valores) y que ambos dicen «Deploy, no Restart».
3. Entregar los textos al líder; cuando los publique, pegar las URLs en la HU y anotar la respuesta de Arekkazu (corrige la l. 82 sí/no).

**Hecho (2026-11-21).** Publicados por el líder: [comentario en #1204](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7066376147) (17:18 UTC) y [respuesta en #1180](https://github.com/Arekkazu/sgpmp-backend/issues/1180#issuecomment-7066432077) (17:22 UTC). Aviso de ST-04b en #1204: [comentario](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7066889566) (17:57 UTC). **Respuesta de Arekkazu:** [«Vosotros»](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7067098039) (18:13 UTC): no corrige la l. 82; la corrige Implementación (ST-04b).
**Entregable.** `entregables/borradores-comentarios.md` y las URLs de los comentarios publicados en la HU.
**Verificación.** Comandos de CA-2 (CA-1, CA-2).
**Estimación.** 2 h.

### ST-02 Actualizar el catálogo `VARIABLES-ENTORNO.md` con las 11 variables
**Objetivo.** Que el registro vivo documente nombre, sensibilidad, lector y valor por defecto de cada variable.
**Pasos.**
1. Rama propia desde `origin/main` de SGMP-Integracion (p. ej. `docs/cfg-04-catalogo-ficha`), después de fusionado el PR de la carpeta de la HU.
2. Agregar 10 filas con el formato de la tabla existente: `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN`, `OTA_URL_SECRET` como **Secreta** (vocabulario del catálogo); `LOGOS_STORAGE_PATH`, `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_TLS_MIN`, `IOT_INFERENCIA_CA_FILE`, `IOT_AUDITORIA_RESPALDO_PATH`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS` como no sensibles. Para cada una: archivo:línea@hash donde la lee el código (`git -C sgpmp-backend grep -n '<VAR>' origin/test -- '*.py'`), comportamiento si falta (tabla H1 de `analisis.md`) y estado DEV/TEST/PROD.
3. Corregir la fila de `SGPMP_ENTORNO` (l. 92): líneas de compose vigentes (`docker-compose.prod.yml:154@6cee5fc4` en `dev`), TEST resuelto por #1204 (o «pendiente de #1204» si no se ha fusionado), PROD con #941. Actualizar la nota de la l. 340 para que apunte a HU-IMP-CFG-04.
4. Commit sin atribuciones; PR a `main`.

**Hecho (2026-11-21).** [PR #23](https://github.com/Juanher01/SGMP-Integracion/pull/23), fusionado el 2026-11-21 (21:18 UTC), con las 11 filas y la ficha de ST-03. El 2026-11-21 (tarde) se actualizaron las notas del catálogo con los PR #1216 y #1217 y el corte `test@cd5f36de` (PR final de ST-07).
**Entregable.** PR a SGMP-Integracion con `registros/variables/VARIABLES-ENTORNO.md`.
**Verificación.** Comando de CA-7 → `1` por variable (CA-7).
**Estimación.** 4 h.

### ST-03 Redactar la ficha de variables para Despliegue
**Objetivo.** Que Despliegue sepa qué cargar en TEST, en qué orden y cómo redesplegar, sin recibir valores.
**Pasos.**
1. Crear `registros/variables/fichas/HU-IMP-CFG-04_<aaaa-mm-dd>.md` (en la rama de ST-02) a partir del borrador 2 de `analisis.md` y del formato de `HU-IMP-CFG-03_2026-11-17.md`.
2. Incluir: `SGPMP_ENTORNO` opcional (`TEST` o el valor por defecto del compose); `M04_FIRMA_MODELOS_KEY` sensible, la provee Desarrollo/Seguridad, crear en TEST; `IOT_INFERENCIA_M04_URL` + `IOT_INFERENCIA_M04_TOKEN` solo cuando AIoT/Desarrollo confirmen `modelos_cargados > 0` en el motor de TEST; `OTA_URL_SECRET` + `OTA_URL_BASE` solo si Pruebas prueba OTA; `OTA_URL_TTL_SEGUNDOS`, `LOGOS_STORAGE_PATH`, `IOT_AUDITORIA_RESPALDO_PATH`: no cargar.
3. Indicar «Deploy, no Restart» y el comando de presencia de CA-9. Advertir que logos y modelos de TEST se pierden en cada Deploy (INC-BE-02).
4. Entregar la ficha a Despliegue por el canal habitual y anotar fecha y destinatario en la HU.

**Hecho (2026-11-21).** Ficha [`registros/variables/fichas/HU-IMP-CFG-04_2026-11-20.md`](https://github.com/Juanher01/SGMP-Integracion/blob/main/registros/variables/fichas/HU-IMP-CFG-04_2026-11-20.md) en `main` (PR #23). **Entrega:** 2026-11-21, 17:50 (America/Bogota; 22:50 UTC), por chat de WhatsApp, al Líder de Despliegue. La envió el Líder de Implementación con el enlace a la ficha en `main`, un resumen (no cargar nada hasta la fusión de #1204; luego `M04_FIRMA_MODELOS_KEY` y Deploy, no Restart; motor M04 solo con `modelos_cargados > 0`; OTA solo si Pruebas la usa; `IOT_AUDITORIA_RESPALDO_PATH` no se crea; PROD sin cambios hasta #941; plantilla en el PR #1216) y este agregado: el valor de `M04_FIRMA_MODELOS_KEY` lo provee Desarrollo y debe ser la misma clave que usa el entrenamiento de modelos de TEST; si no coincide, las versiones registradas no validan. Se pidió fecha y hora del Deploy y la salida del comando de la §3.
**Pendiente:** respuesta de Despliegue a esta pregunta: ¿en el entorno de TEST de Dokploy ya existen `IOT_INFERENCIA_M04_URL` u `OTA_URL_*`? (solo si existen, sin valores). Motivo: al desplegar #1204, el compose empieza a entregarlas al contenedor; si `IOT_INFERENCIA_M04_URL` ya está definida y el motor de TEST no tiene modelos, los paquetes de inferencia pasan a FALLIDO desde ese Deploy. En ese caso hay que vaciarla o borrarla antes.
**Entregable.** Ficha en el PR de ST-02 + constancia de entrega.
**Verificación.** Comando de CA-8 (CA-8).
**Estimación.** 3 h.

### ST-04a Abrir PR a `test`: `.env.test.example` con las variables de #1204 y sin `AGROFUSION_HUB_*`
**Objetivo.** Documentar en la plantilla de TEST las variables que #1204 agrega al compose y quitar de ella `AGROFUSION_HUB_*`, que el código de `test` no lee (ajuste del líder, 2026-11-20). Puede ir ya: no depende de la fusión de #1204 (decisión del líder, 2026-11-20).
**Pasos.**
1. `git -C sgpmp-backend fetch` y `git switch -c cfg-04/test-plantilla-variables origin/test`.
2. `.env.test.example`: agregar un bloque por función (M07, M04 firma, motor M04, OTA, logos) con las variables de #1204, placeholders vacíos o el valor por defecto del compose, comentario «sensible: la carga Despliegue» en los tres secretos y una línea «las pasa el compose desde #1204». `IOT_AUDITORIA_RESPALDO_PATH` va como comentario («la fija la imagen»). Borrar `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` (l. 54-55 al corte). Solo nombres y marcadores; nunca valores reales.
3. Verificar local: segundo comando de CA-5 sin salida.
4. Commit sin atribuciones; push; entregar al líder la descripción del PR (plantilla de `promocion-entornos`), que enlace HU, #1180 y #1204 y pida aprobación al Líder de Pruebas.

**Hecho (2026-11-21).** [PR #1216](https://github.com/Arekkazu/sgpmp-backend/pull/1216) → `test`, abierto (aprueba el Líder de Pruebas). Commit `d873f740` sobre `test@cd5f36de`: la rama se rebasó antes del commit. El líder agregó al alcance las variables **obligatorias** (`${VAR:?}`) del compose de TEST que faltaban en la plantilla: `MQTT_BROKER_URL` y `MQTT_BROKER_TOKEN` (vacía, sensible), en un bloque propio. Las diferencias previas opcionales (`BROKER_SERVICE_TOKEN`, `COOKIE_SAMESITE`, `COOKIE_SECURE`, `DB_PORT`, `JWT_LEEWAY_SECONDS`) se listan en la descripción del PR. Resuelve la parte de INC-BE-04 que corresponde a la plantilla. CA-5 (a), (b), (c) y (d): [`evidencias/CA-05_CA-06_plantillas.md`](evidencias/CA-05_CA-06_plantillas.md). **Fusionado el 2026-11-21, 18:08 (America/Bogota; 23:08 UTC), `test 35f3ec3b`**, sin la tabla de cabecera de la plantilla, que va en el [PR #1220](https://github.com/Arekkazu/sgpmp-backend/pull/1220) (cherry-pick de `3dd1f9c8` sobre `test@c698c656`, abierto). CA-5 (a) y (c) repetidos sobre `origin/test@c698c656`: cumplen. CA-5 (b) sobre `origin/test` sigue esperando la fusión de #1204.
**Entregable.** PR a `test` en `Arekkazu/sgpmp-backend`.
**Verificación.** CA-5.
**Estimación.** 2 h.

### ST-04b Corregir la l. 82 del PR #1204 con un commit en su rama
**Objetivo.** Que #1204 llegue a `test` sin la ruta relativa del respaldo de auditoría IoT, sin esperar a que Desarrollo la corrija (decisión del líder, 2026-11-21). El compose es responsabilidad de Implementación; el PR sigue siendo de Arekkazu y lo fusiona el Líder de Pruebas.
**Pasos.**
1. Comprobar, con la cuenta que hará el push: que #1204 sigue abierto y que su cabeza es `b8968e68` (`gh pr view 1204 -R Arekkazu/sgpmp-backend --json state,headRefName,headRefOid`); el permiso de esa cuenta (`gh api repos/Arekkazu/sgpmp-backend/collaborators/$(gh api user --jq .login)/permission --jq .permission` → `write`, `maintain` o `admin`); y que la rama no está protegida (`gh api repos/Arekkazu/sgpmp-backend/branches/fix/compose-test-entorno-m04-1180 --jq .protected` → `false`). Si la cabeza ya no es `b8968e68` (Arekkazu subió otro commit), detenerse y avisar al líder: revisar si el commit nuevo ya corrige la l. 82 o cambia su número de línea antes de seguir. Si no hay permiso de escritura (o la rama está protegida), no se pasa a ST-04c: se abre un PR hacia la rama `fix/compose-test-entorno-m04-1180` con el mismo cambio, **desde un fork** (sin `write` no se puede subir una rama al repositorio de Arekkazu): `gh repo fork Arekkazu/sgpmp-backend --remote --remote-name fork`, pasos 3 y 4 iguales, en el paso 5 `git push fork HEAD:cfg-04/pr1204-ruta-respaldo` y `gh pr create -R Arekkazu/sgpmp-backend --base fix/compose-test-entorno-m04-1180 --head <cuenta>:cfg-04/pr1204-ruta-respaldo`. Si #1204 ya se fusionó, la corrección pasa a ST-04c.
2. Avisar a Arekkazu en el PR antes del push (texto para el líder): un único commit encima del suyo, sin reescribir nada. **Hecho (2026-11-21):** [aviso](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7066889566) y [respuesta «Vosotros»](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7067098039) de Arekkazu.
3. `git -C sgpmp-backend fetch origin fix/compose-test-entorno-m04-1180` y `git -C sgpmp-backend switch --track -c fix/compose-test-entorno-m04-1180 origin/fix/compose-test-entorno-m04-1180` (o `git worktree add --track -b … <ruta> origin/fix/compose-test-entorno-m04-1180` si la copia principal tiene cambios de otra subtarea). En `docker-compose.test.yml`, borrar la línea de `IOT_AUDITORIA_RESPALDO_PATH` (l. 82@b8968e68): TEST hereda el `ENV` del Dockerfile, como PROD. No tocar nada más.
4. Verificar local: `docker compose -f docker-compose.test.yml config --no-interpolate > /dev/null && echo OK` y el comando de CA-4 sobre la rama.
5. Commit sin atribuciones y `git push origin HEAD:fix/compose-test-entorno-m04-1180` (sube el commit aunque la rama local tenga otro nombre; **sin** `--force` ni `--force-with-lease`; si lo rechaza por no ser fast-forward, detenerse: alguien subió otro commit). Nunca reescribir el commit de Arekkazu.
6. Pegar en la HU el enlace al commit (o al PR hacia la rama de #1204) y la salida de CA-4.

**Hecho (2026-11-21).** Commit [`097f6d80`](https://github.com/Arekkazu/sgpmp-backend/commit/097f6d803a0a75f708989dc63cff4f9022ed6629) en `fix/compose-test-entorno-m04-1180` (push fast-forward `b8968e68..097f6d80`, sin force, cuenta `Chebaztian` con `write`; rama sin protección). Solo borra la l. 82. `docker compose … config --no-interpolate`: OK. CA-4: [`evidencias/CA-04_st04b.txt`](evidencias/CA-04_st04b.txt) — `1000` · `/app/storage/auditoria_iot/fallas.sqlite3` · `ESCRIBIBLE`; control negativo con la ruta relativa de `b8968e68`: `mkdir: cannot create directory 'var': Permission denied`. Pendiente: fusión de #1204 (Líder de Pruebas).
**Entregable.** Commit en la rama del PR #1204 (o PR hacia esa rama) y evidencia de CA-4.
**Verificación.** CA-4 (y la tercera condición de CA-3, tras la fusión).
**Estimación.** 1 h (excepción al mínimo de 2 h de `hu-taiga`, decidida por el líder el 2026-11-21: ya está así en Taiga).

### ST-04c Abrir PR a `test`: retiro de `AGROFUSION_HUB_*` del compose
**Objetivo.** Quitar del compose de TEST las variables sin uso (la plantilla ya las pierde en ST-04a; sustituye la ST-02/T2 de HU-IMP-CFG-03). Solo si #1204 se fusionó sin la corrección de ST-04b, corrige también la ruta relativa de la l. 82.
**Pasos.**
1. Esperar la fusión de #1204 (`gh pr view 1204 … --json state` → `MERGED`). Luego `git -C sgpmp-backend fetch` y `git switch -c cfg-04/test-retiro-hub origin/test`.
2. `docker-compose.test.yml`: borrar `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET`. Solo si #1204 se fusionó sin la corrección de ST-04b y sigue la línea `IOT_AUDITORIA_RESPALDO_PATH: ${…:-var/auditoria_iot/fallas.sqlite3}`, borrarla (TEST hereda el `ENV` del Dockerfile, como PROD). Si en lugar de borrarla se fija la ruta, escribir la ruta sin comillas y con valor por defecto, para que funcione el sed de CA-4 (REV-02 n-02). Añadir fila a la tabla de cambios de la cabecera.
3. Verificar local: `docker compose -f docker-compose.test.yml config --no-interpolate > /dev/null && echo OK`; comandos de CA-3 y CA-4 sobre la rama.
4. Commit sin atribuciones; push; descripción del PR al líder, que enlace HU, #1180 y #1204, liste las diferencias preexistentes compose ↔ plantilla y pida aprobación al Líder de Pruebas.
**Entregable.** PR a `test` en `Arekkazu/sgpmp-backend`.
**Verificación.** CA-3 (tras la fusión, sobre `origin/test`); CA-4 solo si esta subtarea corrigió la l. 82.
**Estimación.** 2 h.

### ST-05 Abrir PR a `dev`: `OTA_URL_*` en `.env.prod.example`
**Objetivo.** Que la plantilla de PROD documente las variables OTA que `docker-compose.prod.yml` ya referencia (l. 167-169@6cee5fc4), y viajen a `main` con el release.
**Pasos.**
1. `git switch -c cfg-04/dev-plantilla-prod-ota origin/dev`.
2. En `.env.prod.example`, junto al bloque de M04: `OTA_URL_SECRET=` (comentario: sensible, la carga Despliegue, obligatoria si se usa OTA), `OTA_URL_BASE=` (URL pública del backend de PROD; la confirma Despliegue), `OTA_URL_TTL_SEGUNDOS=86400`.
3. Verificar con el comando de CA-6 sobre la rama; commit sin atribuciones; push; descripción del PR al líder (aprueba Líder de Desarrollo).

**Hecho (2026-11-21).** [PR #1217](https://github.com/Arekkazu/sgpmp-backend/pull/1217) → `dev`, abierto (aprueba el Líder de Desarrollo). Commit `d96449dd` sobre `dev@8d4981f6`: bloque OTA junto al del motor de inferencia, en el orden de `docker-compose.prod.yml:167-169`, y fila en la tabla de cabecera del archivo. CA-6 (a) y (b): [`evidencias/CA-05_CA-06_plantillas.md`](evidencias/CA-05_CA-06_plantillas.md). **Fusionado el 2026-11-21, 18:08 (America/Bogota; 23:08 UTC), `e372a059`.** CA-6 (a) repetido sobre `origin/dev@5115b83d`: cumple.
**Entregable.** PR a `dev`.
**Verificación.** CA-6.
**Estimación.** 2 h.

### ST-06 Verificar TEST desplegado y coordinar la re-prueba de #1180
**Objetivo.** Evidenciar que `SGPMP_ENTORNO` llega al contenedor de TEST. Como #1180 está cerrado, ST-06 (con INC-BE-09) es el seguimiento de la re-prueba.
**Pasos.**
1. Tras la fusión de #1204: `merge-base --is-ancestor` de CA-9 (o grep si hubo squash).
2. Pedir a Despliegue el Deploy (no Restart) y la salida del comando de presencia; registrar fecha y hora.
3. Avisar en #1180 (texto para el líder) que TEST está listo para la re-prueba; enlazar el resultado de TEX053.
4. Pegar todo en `evidencias/CA-09_test-desplegado.md` (formato skill `verificacion` §9).
**Entregable.** Evidencia CA-9.
**Verificación.** CA-9.
**Estimación.** 2 h.

### ST-07 Registrar incidencias, seguimiento de PROD y traslado desde CFG-03
**Objetivo.** Dejar trazabilidad en los registros vivos y el pendiente de PROD.
**Pasos.**
1. En `registros/incidencias/registro.md` (rama de ST-02 o una nueva desde `origin/main`): **INC-BE-09** ya está registrada (2026-11-20, rama `docs/hu-imp-cfg-04-variables-m04`); actualizar su estado al avanzar; actualizar INC-BE-04 (PR de ST-04a) e INC-BE-02 (HU-IMP-AMB-10).
2. Ejecutar el comando de CA-10 y guardar la tabla en `evidencias/CA-10_prod-seguimiento.md`; repetirlo cuando se fusione #941.
3. HU-IMP-CFG-03: el traslado de su ST-02/T2 ya quedó anotado el 2026-11-20 (misma rama); solo comprobarlo con el comando de CA-11.
4. Commit sin atribuciones; PR a `main`.

**Cierre (2026-11-21, 22:15, America/Bogota).** CA-10 cumple: el #941 se cerró sin fusionar y el release 1.4.0 entró a `main` por el [PR #1219](https://github.com/Arekkazu/sgpmp-backend/pull/1219) (2026-11-21, 20:32 America/Bogota; `main 9655f389`); los 4 hashes están incluidos y `docker-compose.prod.yml:155` tiene `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-PROD}`. INC-BE-02: PROD resuelto por Desarrollo en `e2ec9ed5` (volumen `sgpmp_auditoria_iot_prod`, INC-M03-125-G12); falta TEST.

**Hecho al corte (2026-11-21, 17:55).** `registros/incidencias/registro.md`: INC-BE-04 → «en HU (HU-IMP-CFG-04)», con la parte de la plantilla en el PR #1216 y las diferencias opcionales que quedan; INC-BE-02 → enlazada a HU-IMP-AMB-10 (borrador; #1204 hace llegar `LOGOS_STORAGE_PATH`, pero sigue sin volumen); INC-BE-09 → estado del 2026-11-21. CA-10: [`evidencias/CA-10_prod-seguimiento.md`](evidencias/CA-10_prod-seguimiento.md): los 4 commits AUSENTES en `main@0abbeeef`, #941 OPEN, sin `SGPMP_ENTORNO` en `docker-compose.prod.yml` de `main`; queda en seguimiento. CA-11: CFG-03 cita a CFG-04 en su ST-02 (`historia.md:77` de CFG-03). Pendiente: actualizar INC-BE-09 e INC-BE-04 con las fusiones y repetir CA-10 cuando se fusione #941.
**Entregable.** PR a SGMP-Integracion + evidencia CA-10.
**Verificación.** CA-10, CA-11.
**Estimación.** 3 h.

**Total estimado:** 21 h (ST-04a 2 h + ST-04b 1 h + ST-04c 2 h).

---

## Notas para el líder (no se copian a Taiga)

**Plazo sugerido.** ST-01 hoy o mañana (antes de que Pruebas fusione #1204). ST-02, ST-03, ST-05 y ST-07 antes del 2026-11-23 (no dependen de nadie). ST-04a y ST-04b pueden ir ya (ST-04b, antes de que se fusione #1204). ST-04c y ST-06 dependen de #1204 y del Deploy; si no ocurren antes del 2026-11-24, la HU se presenta en E4 con esas dos en curso. CA-10 cierra en «seguimiento» hasta #941.

**Decisiones del líder (2026-11-20).**
1. El líder publica el comentario en #1204 y la respuesta en #1180; **no** se pide reabrir #1180.
2. `${M04_FIRMA_MODELOS_KEY:?}` en PROD: no. Queda como posible mejora, sin HU aparte.
3. HU-IMP-AMB-10 (persistencia de logos, modelos y respaldo de auditoría): queda en borrador, va después de esta HU y depende de la respuesta de Desarrollo sobre persistencia. Prioridad dentro de ella: respaldo de auditoría en PROD. **Nota (2026-11-21, noche):** PROD resuelto por Desarrollo en `e2ec9ed5` (volumen `sgpmp_auditoria_iot_prod`, INC-M03-125-G12); falta TEST. En `main@9655f389`, `docker-compose.prod.yml:169` fija `IOT_AUDITORIA_RESPALDO_PATH=/app/storage/auditoria_iot/fallas.sqlite3` (absoluta, igual al `ENV` del Dockerfile l. 61), dentro del volumen montado en l. 183. El compose de TEST de #1204 (`097f6d80`) no tiene ese volumen. `e2ec9ed5` es un cambio de otro equipo **pendiente de `/impacto`**.
4. ST-04 se parte: ST-04a (`.env.test.example`, puede ir ya) y ST-04b (retiro de `AGROFUSION_HUB_*` y la l. 82 si Desarrollo no la corrige; espera la fusión de #1204). Ajuste del 2026-11-20 (inicio de la ejecución): el retiro de `AGROFUSION_HUB_*` de la plantilla pasa a ST-04a; ST-04b queda solo con el compose. (Renumerada el 2026-11-21: esa subtarea del compose es ahora ST-04c; ver decisión 8.)
5. Carpeta: `issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/`; el informe pasa a `prs/BACK-PR1204_compose-test-entorno-m04/`.
6. #1180 se registra como **INC-BE-09**. Se aceptan las correcciones sobre INC-BE-08 (es el CORS de TEST, `registro.md:21`; las relacionadas son INC-BE-04 e INC-BE-02). Como #1180 está cerrado, INC-BE-09 y ST-06 son el seguimiento de la re-prueba.
7. La petición a Desarrollo de agregar a Implementación como revisora va en el comentario de #1204 (ST-01).
8. (2026-11-21) La l. 82 no espera a Desarrollo: Implementación la corrige con un commit propio en la rama de #1204, antes de la fusión (nueva ST-04b, 1 h). La ST-04b anterior pasa a ST-04c, solo con el retiro de `AGROFUSION_HUB_*` del compose (2 h); corrige la l. 82 solo si #1204 se fusionó sin esa corrección. Si no hay permiso de escritura en la rama de #1204, ST-04b abre un PR hacia esa rama en lugar de pasar a ST-04c. La HU se creó en Taiga con esta numeración.

**Puntos de atención para la revisión.**
- CA-4: comprobar que la prueba de escritura se hizo con la imagen de la rama, no con la de `dev`.
- CA-5: los tres secretos deben quedar con `=` y nada después; revisar también los comentarios.
- CA-7: no crear un catálogo paralelo; las líneas citadas deben ser del corte del día.
- Que la ficha (CA-8) no prometa valores de `OTA_URL_BASE` ni dominios sin curl del día.

---

## Metadatos

- Redactado: 2026-11-20 (America/Bogota), fase 1, borrador. Ajustado el mismo día en la fase 2 con las decisiones del líder.
- Ajustado el 2026-11-21: nueva ST-04b (commit en la rama de #1204) y renumeración de la anterior a ST-04c (decisión 8); M-01 y m-04 de REV-03, hallazgos de REV-04 y menores de REV-05; URLs de los comentarios publicados y respuesta de Arekkazu; HU creada en Taiga; corte reverificado (BE `dev 8d4981f6`, `test 918806ec`, `main 0abbeeef`, #1204 `b8968e68` → `097f6d80` tras ST-04b; SGMP-Integracion `main e11893c`). Ejecución de ST-04b: commit `097f6d80` y evidencia de CA-4.
- Ajustado el 2026-11-21 (tarde): estado por subtarea; ST-02, ST-03 (entrega a Despliegue), ST-04a (PR #1216), ST-05 (PR #1217) y ST-07 al corte; CA-5 (d) y CA-6 (b), con la prueba de `docker compose config` sobre la plantilla rellena, que propuso y aprobó el líder; respuesta de Despliegue pendiente; evidencias de CA-5/CA-6 y CA-10; corte `test@cd5f36de`.
- Ajustado el 2026-11-21 (noche): PR #1216 y #1217 fusionados (18:08 America/Bogota; 23:08 UTC); CA-5 (a) y (c) sobre `origin/test@c698c656` y CA-6 (a) sobre `origin/dev@5115b83d`; tabla de cabecera de la plantilla de TEST (REV-06 m-04) en el PR #1220; CA-10 y ST-07 cerrados (release 1.4.0, PR #1219, `main 9655f389`); nota de `e2ec9ed5` en HU-IMP-AMB-10 e INC-BE-02.
- Fuentes: `analisis.md` (EXT-BACK-PR1204) y `entregables/borradores-comentarios.md`; `PI4/brief-issue-1180.md`; `git fetch` del 2026-11-20: BE `origin/dev 6cee5fc4`, `origin/test 12965211`, `origin/main 0abbeeef`, PR #1204 `b8968e68` (OPEN, MERGEABLE, 0 revisiones), PR #941 OPEN `dev`→`main`; SGMP-Integracion `main f40300b`; `docker-compose.test.yml@b8968e68` l. 60-86; `Dockerfile@12965211` l. 55-62; `.env.test.example@12965211` l. 54-55; `registros/incidencias/registro.md` l. 15, 17, 21; `registros/variables/VARIABLES-ENTORNO.md` l. 92, 340; numeración: `entregas/README.md` (último AMB = AMB-09; CFG-04 indicado por el líder).
