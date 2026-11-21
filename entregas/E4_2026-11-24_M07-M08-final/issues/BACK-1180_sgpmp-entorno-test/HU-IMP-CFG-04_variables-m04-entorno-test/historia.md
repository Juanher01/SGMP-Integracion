# HU-IMP-CFG-04 — TEST recibe y documenta las variables de M04/M07 (`SGPMP_ENTORNO=TEST`) sin romper el respaldo de auditoría IoT

> **Estado:** lista para Taiga (fase 2, 2026-11-20, con las decisiones del líder). Carpeta: `entregas/E4_2026-11-24_M07-M08-final/issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/` (origen: issue, ADR-002).
> Fuente principal: [`analisis.md`](../../../prs/BACK-PR1204_compose-test-entorno-m04/analisis.md) (EXT-BACK-PR1204). Borradores de comentarios: [`entregables/borradores-comentarios.md`](entregables/borradores-comentarios.md). Brief de origen: [`brief-issue-1180.md`](brief-issue-1180.md) (copia del 2026-11-20; sus rutas `BE-PR1204_…` son anteriores al cambio de nombre a `BACK-PR1204_…`).
> Corte: `git fetch` del 2026-11-20 · BE `origin/dev 6cee5fc4` · `origin/test 12965211` · `origin/main 0abbeeef` · PR #1204 `b8968e68` · SGMP-Integracion `main f40300b`.

---

## Para copiar en Taiga — Descripción de la HU

**Rama:** BE `cfg-04/test-plantilla-variables` → PR a `test` (ST-04a) · BE `cfg-04/test-retiro-hub` → PR a `test` (ST-04b) · BE `cfg-04/dev-plantilla-prod-ota` → PR a `dev` · SGMP-Integracion `docs/hu-imp-cfg-04-variables-m04` (carpeta de la HU, INC-BE-09 y traslado desde CFG-03) y una rama propia para ST-02, ST-03 y ST-07 → PR a `main` · **Plazo:** por definir (líder); sugerido 2026-11-23 · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval · **Entrega:** E4 (2026-11-24) · **Módulos:** M07 (RF-97), M04 (RF-26, RF-53, RF-56/66, RF-69), OTA

**Origen.** Issue — [sgpmp-backend#1180](https://github.com/Arekkazu/sgpmp-backend/issues/1180) · Autor: TEX053 (Pruebas, TC-M07-378-G025) · Fecha: 2026-11-19 · Cerrado por Arekkazu el 2026-11-20 **sin la corrección desplegada**. Cambio relacionado de otro equipo: [PR #1204](https://github.com/Arekkazu/sgpmp-backend/pull/1204) (Arekkazu, `b8968e68`) e informe EXT-BACK-PR1204 (incluye el commit `d417c0c6`, SEG-M04-01 = issue #1161, directriz de Desarrollo, no de Análisis).

**Situación actual.** En TEST, `SourceSystem.Environment` vale `"DEV"`: `configuracion.py:18@12965211` lee `os.getenv("SGPMP_ENTORNO", "DEV")` y `docker-compose.test.yml@12965211` no pasa la variable al contenedor. El PR #1204 (abierto, 1 commit, 0 revisiones, sin conflicto con `test`) agrega 11 variables al `environment:` del backend de TEST con `${VAR:-…}`, igual que `dev`. Tiene un defecto: `docker-compose.test.yml:82@b8968e68` fija `IOT_AUDITORIA_RESPALDO_PATH` a la ruta relativa `var/auditoria_iot/fallas.sqlite3`, que sobrescribe el `ENV` de la imagen (`Dockerfile:61@12965211`, carpeta con dueño 1000 en l. 55-56) y resuelve a `/app/var`, de root y no escribible por `USER 1000` (l. 62; `.dockerignore:19` excluye `var/auditoria_iot/`). Además el PR no retira `AGROFUSION_HUB_*` (l. 67-68@b8968e68), que el código de `test` y `dev` ya no lee, ni toca `.env.test.example` ni el catálogo.

| Rama / artefacto | Estado | Evidencia |
|---|---|---|
| BE `test` | ❌ Sin `SGPMP_ENTORNO` ni las otras 10 en el compose; ⚠️ `AGROFUSION_HUB_*` en compose (l. 66-67) y `.env.test.example` (l. 54-55); ❌ `.env.test.example` sin ninguna de las 11 | `test@12965211` |
| PR #1204 → `test` | ⚠️ Corrige #1180; defecto en l. 82; conserva `AGROFUSION_HUB_*` | `b8968e68` (base `135bc318`) |
| BE `dev` | ✅ Las 11 en `docker-compose.yml`; `.env.prod.example` sin `OTA_URL_SECRET`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS` aunque `docker-compose.prod.yml` l. 167-169 las referencia | `dev@6cee5fc4` |
| BE `main` (PROD) | ⏳ Sin `SGPMP_ENTORNO` ni el código que la lee: sin efecto hoy. Llega con el release #941 (`dev`→`main`, abierto): `b2b9097b`, `d417c0c6`, `5e87d61e`, `098f635a` están en `dev` y `test` y AUSENTES en `main` | `main@0abbeeef`, `git merge-base --is-ancestor` |
| Catálogo `VARIABLES-ENTORNO.md` | ❌ Solo `SGPMP_ENTORNO` (l. 92, con líneas de compose desactualizadas); faltan 10 | SGMP-Integracion `main@f40300b` |

**Descripción.** Que el backend de TEST reciba y documente las variables de M04, OTA y M07 en toda la cadena (compose → plantilla → catálogo → ficha para Despliegue), sin la regresión de la l. 82, y verificar en TEST desplegado que `SGPMP_ENTORNO` llega al contenedor para que Pruebas re-pruebe #1180. La corrección del compose la hace Desarrollo en #1204; Implementación aporta la observación del defecto, la plantilla, el retiro de `AGROFUSION_HUB_*`, el catálogo, la ficha y el seguimiento hasta PROD. Sustituye la T2 / ST-02 de HU-IMP-CFG-03.

**Alcance.** Borradores de comentario para #1204 y #1180 · PR a `test`: `.env.test.example` con las variables de #1204 y sin `AGROFUSION_HUB_*`; retiro de `AGROFUSION_HUB_*` de `docker-compose.test.yml`; corrección de `IOT_AUDITORIA_RESPALDO_PATH` si #1204 se fusiona con la l. 82 · PR a `dev`: `OTA_URL_*` en `.env.prod.example` · Catálogo (10 filas nuevas y fila de `SGPMP_ENTORNO` corregida) · Ficha para Despliegue · Registro de incidencias · Verificación tras el despliegue en TEST · Seguimiento de PROD con el release #941.
**Fuera de alcance:** fusionar #1204 (Líder de Pruebas) · cargar valores en Dokploy y hacer Deploy (Despliegue) · definir el valor de `M04_FIRMA_MODELOS_KEY` (Despliegue lo carga; lo provee Desarrollo/Seguridad) · re-prueba de TC-M07-378-G025 (Pruebas, TEX053; exige sesión con permiso `exportacion_contable`) · mensaje de error engañoso `FIRMA_ARTEFACTO_INVALIDA` cuando falta la clave (Desarrollo) · disponibilidad del motor M04 de TEST (AIoT/Desarrollo) · volúmenes persistentes para logos, modelos y respaldo de auditoría (HU-IMP-AMB-10, en borrador: va después de esta HU y depende de la respuesta de Desarrollo sobre persistencia; dentro de ella, prioridad al respaldo de auditoría en PROD; INC-BE-02) · `${M04_FIRMA_MODELOS_KEY:?}` en PROD: no se hace (decisión del líder, 2026-11-20); queda como posible mejora, sin HU aparte.

**Criterios de aceptación.**
1. CA-1 **Corte.** La HU y cada PR registran la fecha del `git fetch` y los hashes de BE `origin/dev`, `origin/test`, `origin/main`, la cabeza de #1204 y `SGMP-Integracion origin/main`, reverificados el día de abrir cada PR (no se reutilizan los de este borrador).
2. CA-2 **Comunicación y desviación.** Hay en la HU enlaces a un comentario publicado en #1204 (defecto de la l. 82 con la corrección propuesta, `AGROFUSION_HUB_*` sin uso, Deploy y no Restart) y a una respuesta en #1180 (la re-prueba depende de la fusión de #1204 y del Deploy; el seguimiento va en INC-BE-09; no se pide reabrir el issue). El comentario en #1204 explica la desviación frente a lo que pidió Arekkazu en #1180: Implementación no «define» ni lee valores de secretos ni del `.env` de TEST; documenta nombre, sensibilidad y regla de carga, y Despliegue carga el valor.
3. CA-3 **Compose de TEST.** En `origin/test`: `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}` presente; cero apariciones de `AGROFUSION_HUB_`; `IOT_AUDITORIA_RESPALDO_PATH` ausente del compose o con la ruta absoluta `/app/storage/auditoria_iot/fallas.sqlite3`.
4. CA-4 **Respaldo de auditoría escribible.** La imagen construida desde la rama del PR a `test`, con el valor que entrega el compose de TEST, resuelve `IOT_AUDITORIA_RESPALDO_PATH` a `/app/storage/auditoria_iot/fallas.sqlite3` y el proceso (uid 1000) puede escribir en esa carpeta.
5. CA-5 **Plantilla de TEST.** `.env.test.example` en `origin/test` contiene cada variable que el compose de TEST agrega en #1204 (si `IOT_AUDITORIA_RESPALDO_PATH` sale del compose, queda como comentario «la fija la imagen»), sin `AGROFUSION_HUB_*`, con un comentario de sensibilidad en `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN` y `OTA_URL_SECRET`, y **sin valor** en esos tres. Las variables nuevas llegan con ST-04a; la ausencia de `AGROFUSION_HUB_*` se verifica después de ST-04b.
6. CA-6 **Plantilla de PROD en `dev`.** `.env.prod.example` en `origin/dev` contiene `OTA_URL_SECRET=` (vacío, marcado sensible), `OTA_URL_BASE` y `OTA_URL_TTL_SEGUNDOS`, por PR propio a `dev`.
7. CA-7 **Catálogo.** `registros/variables/VARIABLES-ENTORNO.md` (registro vivo; no un archivo paralelo) en `main` de SGMP-Integracion tiene exactamente una fila por cada una de las 11 variables, con sensibilidad (sensibles: las tres de CA-5) y estado por entorno; la fila de `SGPMP_ENTORNO` cita líneas y hashes vigentes y ya no dice «falta en TEST» si #1204 está fusionado; la nota de la l. 340 apunta a esta HU.
8. CA-8 **Ficha para Despliegue.** Existe `registros/variables/fichas/HU-IMP-CFG-04_<aaaa-mm-dd>.md` con: variable, entorno, obligatoria, sensibilidad, quién provee el valor, acción en Dokploy; `SGPMP_ENTORNO` opcional (`TEST` o el valor por defecto); regla de carga de `IOT_INFERENCIA_M04_URL` y `IOT_INFERENCIA_M04_TOKEN` solo con el motor de TEST con `modelos_cargados > 0`; «Deploy, no Restart»; el comando de verificación de presencia; ningún valor de secreto.
9. CA-9 **TEST desplegado.** `b8968e68` (o su contenido) está en `origin/test`; Despliegue confirma por escrito un **Deploy** posterior a la fusión (fecha y hora); la salida del comando de presencia (`presente`/`ausente`, sin valores) se adjunta; y la HU enlaza el resultado de la re-prueba de Pruebas en #1180 (`SourceSystem.Environment = "TEST"`) o, si Pruebas no la hizo al cierre, el líder deja constancia de que sigue pendiente. Como #1180 está cerrado, este CA, ST-06 e INC-BE-09 son el seguimiento de la re-prueba.
10. CA-10 **PROD en seguimiento.** La HU registra, con fecha de corte, el estado en `origin/main` de `b2b9097b`, `d417c0c6`, `5e87d61e` y `098f635a` y el estado del PR #941. Cuando el release se fusione: `docker-compose.prod.yml` de `main` contiene `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-PROD}`.
11. CA-11 **Registros.** `registros/incidencias/registro.md` tiene la fila INC-BE-09 (#1180: `SGPMP_ENTORNO` no llega al contenedor de TEST; causa compose; corrige Desarrollo en #1204; estado; PROD con #941; es el seguimiento de la re-prueba, porque #1180 está cerrado), INC-BE-04 actualizada con el PR de ST-04a, e INC-BE-02 enlazada a HU-IMP-AMB-10 (borrador). La ST-02/T2 de HU-IMP-CFG-03 queda anotada como trasladada a esta HU.

**Verificación.** (`BE` = `sgpmp-backend`; en Git Bash anteponer `MSYS_NO_PATHCONV=1` a `git show origin/<rama>:<archivo>`.)

| CA | Método (comando o prueba) | Resultado esperado | Evidencia a adjuntar |
|---|---|---|---|
| CA-1 | `git -C sgpmp-backend fetch --prune origin; for b in dev test main; do git -C sgpmp-backend log -1 --format="$b %h %ad" --date=short origin/$b; done; gh pr view 1204 -R Arekkazu/sgpmp-backend --json state,headRefOid; git -C SGMP-Integracion fetch; git -C SGMP-Integracion log -1 --format=%h origin/main` | Hashes y fecha del día del PR, copiados en la descripción del PR y en `evidencias/` | Salida pegada en `evidencias/CA-01_corte.md` |
| CA-2 | `gh pr view 1204 -R Arekkazu/sgpmp-backend --comments \| grep -n 'IOT_AUDITORIA_RESPALDO_PATH'` y `gh issue view 1180 -R Arekkazu/sgpmp-backend --comments \| grep -niE 'Deploy\|1204'` | Ambos con coincidencias en un comentario del líder; ninguno contiene valores | URLs de los dos comentarios |
| CA-3 | `git -C sgpmp-backend show origin/test:docker-compose.test.yml \| grep -c AGROFUSION_HUB_` · `… \| grep -n 'SGPMP_ENTORNO:'` · `… \| grep -n 'IOT_AUDITORIA_RESPALDO_PATH'` | `0` · `${SGPMP_ENTORNO:-TEST}` · sin salida o solo `/app/storage/auditoria_iot/fallas.sqlite3` | Salida + hash de `origin/test` |
| CA-4 | En la rama del PR, tomar el valor que entrega el compose **tal cual** (sin sustituirlo): `V=$(sed -n 's/^ *IOT_AUDITORIA_RESPALDO_PATH: *\${IOT_AUDITORIA_RESPALDO_PATH:-\(.*\)}.*$/\1/p;t;s/^ *IOT_AUDITORIA_RESPALDO_PATH: *\([^$ ].*\)$/\1/p' docker-compose.test.yml); echo "compose: ${V:-sin línea, vale el ENV de la imagen}"`. Luego `docker build -t sgpmp-back:cfg04 .` y `docker run --rm ${V:+-e IOT_AUDITORIA_RESPALDO_PATH=$V} --entrypoint sh sgpmp-back:cfg04 -c 'id -u; echo "$IOT_AUDITORIA_RESPALDO_PATH"; d=$(dirname "$IOT_AUDITORIA_RESPALDO_PATH"); mkdir -p "$d" && touch "$d/.w" && echo ESCRIBIBLE'` (sin `--env-file` real). En Git Bash, anteponer `MSYS_NO_PATHCONV=1` al `docker run`: sin eso, `-e IOT_AUDITORIA_RESPALDO_PATH=/app/…` llega convertido en una ruta de Windows y la prueba falla aunque el compose esté bien (REV-02 n-01). El `sed` cubre `${…:-valor}` y el valor literal; se probó el 2026-11-20 contra `b8968e68` (devuelve la ruta relativa), `test@12965211` (vacío) y `dev@6cee5fc4` (literal). | `1000` · `/app/storage/auditoria_iot/fallas.sqlite3` · `ESCRIBIBLE`. Con la l. 82 relativa la prueba **falla** (muestra `var/...` y no imprime `ESCRIBIBLE`) | Salida pegada, con el valor de `V` |
| CA-5 | `diff <(git -C sgpmp-backend show origin/test:docker-compose.test.yml \| grep -oE '\$\{[A-Z0-9_]+' \| tr -d '${' \| sort -u) <(git -C sgpmp-backend show origin/test:.env.test.example \| grep -oE '^[A-Z0-9_]+=' \| tr -d '=' \| sort -u)` y `git -C sgpmp-backend show origin/test:.env.test.example \| grep -nE '^(M04_FIRMA_MODELOS_KEY\|IOT_INFERENCIA_M04_TOKEN\|OTA_URL_SECRET)=.+'` | Ninguna de las variables de #1204 ni `AGROFUSION_HUB_*` en el `diff` (otras diferencias preexistentes se listan en la descripción del PR); el segundo comando sin salida | Salidas + enlace al PR |
| CA-6 | `git -C sgpmp-backend show origin/dev:.env.prod.example \| grep -nE '^OTA_URL_(SECRET\|BASE\|TTL_SEGUNDOS)='` y `… \| grep -nE '^OTA_URL_SECRET=.+'` | 3 líneas · sin salida | Salida + enlace al PR a `dev` |
| CA-7 | `for v in SGPMP_ENTORNO M04_FIRMA_MODELOS_KEY LOGOS_STORAGE_PATH IOT_INFERENCIA_M04_URL IOT_INFERENCIA_M04_TOKEN IOT_INFERENCIA_TLS_MIN IOT_INFERENCIA_CA_FILE IOT_AUDITORIA_RESPALDO_PATH OTA_URL_SECRET OTA_URL_BASE OTA_URL_TTL_SEGUNDOS; do echo "$v $(git -C SGMP-Integracion show origin/main:registros/variables/VARIABLES-ENTORNO.md \| grep -c "^| \`$v\`")"; done` | `1` en cada una; las tres sensibles dicen `Sensible` | Salida + enlace al PR a SGMP-Integracion |
| CA-8 | `grep -nE 'Deploy\|modelos_cargados\|Sensible' registros/variables/fichas/HU-IMP-CFG-04_*.md` | Aparecen las tres cosas; revisión visual: ninguna celda con un valor de secreto | Ruta de la ficha + confirmación de entrega a Despliegue |
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
- PRs a `test` (BE), los aprueba el Líder de Pruebas: ST-04a (`.env.test.example`) no depende de #1204; ST-04b **depende de la fusión de #1204** (toca las mismas líneas del compose).
- PR a `dev` (BE): Líder de Desarrollo. Sin dependencias.
- PR a `main` (SGMP-Integracion): Líder de Implementación.
- Despliegue: cargar valores (`M04_FIRMA_MODELOS_KEY` y, cuando aplique, motor M04 y OTA) y hacer Deploy del backend de TEST.
- Pruebas (TEX053): re-prueba de TC-M07-378-G025.
- AIoT/Desarrollo: confirmar que el motor M04 de TEST tiene `modelos_cargados > 0` antes de cargar `IOT_INFERENCIA_M04_URL`.
- Release #941 (`dev`→`main`, Líder de Despliegue) para PROD.

**Riesgos.**
- #1204 se fusiona con la l. 82: el respaldo de auditoría IoT falla con `PermissionError` cuando la BD no responde (RF-53). Mitigación: comentario antes de la fusión; si no alcanza, ST-04b lo corrige. Detección: CA-4.
- Despliegue hace Restart y no Deploy: el contenedor sigue sin `SGPMP_ENTORNO`. Detección: comando de presencia (CA-9).
- Cargar `IOT_INFERENCIA_M04_URL` con el motor sin modelos: los paquetes pasan a FALLIDO al 5.º intento (0/5/15/30/60 s) sin vuelta atrás; el backend no consulta `healthz`. Mitigación: regla de carga en la ficha.
- Sin `M04_FIRMA_MODELOS_KEY` en TEST: registrar modelo da 503 `FIRMA_MODELOS_NO_CONFIGURADA` y activar da 422 `FIRMA_ARTEFACTO_INVALIDA` (mensaje engañoso). No impide desplegar.
- `LOGOS_STORAGE_PATH` y `MODELOS_STORAGE_PATH` en `/tmp` sin volumen: tras cada Deploy los logos dan 404 y activar versiones da 422 `ARTEFACTO_ALTERADO`. Fuera de esta HU (HU-IMP-AMB-10, borrador); se advierte a Pruebas en la ficha.
- #1204 sigue abierto al 2026-11-23: ST-04b y ST-06 quedan en curso para E4; ST-04a avanza igual.
- ST-04a publica en la plantilla variables que el compose de TEST todavía no pasa (hasta que se fusione #1204). Mitigación: comentario en el bloque de la plantilla («las pasa el compose desde #1204») y la ficha de ST-03 lo repite.

**Referencias.** [#1180](https://github.com/Arekkazu/sgpmp-backend/issues/1180) · [#1204](https://github.com/Arekkazu/sgpmp-backend/pull/1204) · [#1161 SEG-M04-01](https://github.com/Arekkazu/sgpmp-backend/issues/1161) · [#941 release](https://github.com/Arekkazu/sgpmp-backend/pull/941) · commits `b8968e68`, `d417c0c6`, `b2b9097b`, `5e87d61e`, `098f635a` · `entregas/E4_2026-11-24_M07-M08-final/prs/BACK-PR1204_compose-test-entorno-m04/analisis.md` · `entregables/borradores-comentarios.md` · HU-IMP-CFG-03 ST-02 · INC-BE-09, INC-BE-02, INC-BE-04 · HU-IMP-AMB-10 (borrador).

---

## Para copiar en Taiga — Subtareas

### ST-01 Publicar (líder) y enlazar los comentarios en #1204 y #1180
**Objetivo.** Que Desarrollo corrija la l. 82 antes de fusionar y que Pruebas sepa cuándo re-probar.
**Pasos.**
1. Los textos están en `entregables/borradores-comentarios.md` (§1 y §2); reverificar hashes (CA-1) y que #1204 siga abierto (`gh pr view 1204 … --json state`). Si ya se fusionó, quitar del §1 la petición sobre la l. 82 y dejar el aviso de que la corrige ST-04b.
2. Confirmar que el §1 incluye la desviación de CA-2 (no definimos ni leemos valores) y que ambos dicen «Deploy, no Restart».
3. Entregar los textos al líder; cuando los publique, pegar las URLs en la HU y anotar la respuesta de Arekkazu (corrige la l. 82 sí/no).
**Entregable.** `entregables/borradores-comentarios.md` y las URLs de los comentarios publicados en la HU.
**Verificación.** Comandos de CA-2 (CA-1, CA-2).
**Estimación.** 2 h.

### ST-02 Actualizar el catálogo `VARIABLES-ENTORNO.md` con las 11 variables
**Objetivo.** Que el registro vivo documente nombre, sensibilidad, lector y valor por defecto de cada variable.
**Pasos.**
1. Rama propia desde `origin/main` de SGMP-Integracion (p. ej. `docs/cfg-04-catalogo-ficha`), después de fusionado el PR de la carpeta de la HU.
2. Agregar 10 filas con el formato de la tabla existente: `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN`, `OTA_URL_SECRET` como **Sensible**; `LOGOS_STORAGE_PATH`, `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_TLS_MIN`, `IOT_INFERENCIA_CA_FILE`, `IOT_AUDITORIA_RESPALDO_PATH`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS` como no sensibles. Para cada una: archivo:línea@hash donde la lee el código (`git -C sgpmp-backend grep -n '<VAR>' origin/test -- '*.py'`), comportamiento si falta (tabla H1 de `analisis.md`) y estado DEV/TEST/PROD.
3. Corregir la fila de `SGPMP_ENTORNO` (l. 92): líneas de compose vigentes (`docker-compose.prod.yml:154@6cee5fc4` en `dev`), TEST resuelto por #1204 (o «pendiente de #1204» si no se ha fusionado), PROD con #941. Actualizar la nota de la l. 340 para que apunte a HU-IMP-CFG-04.
4. Commit sin atribuciones; PR a `main`.
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
**Entregable.** Ficha en el PR de ST-02 + constancia de entrega.
**Verificación.** Comando de CA-8 (CA-8).
**Estimación.** 3 h.

### ST-04a Abrir PR a `test`: `.env.test.example` con las variables de #1204
**Objetivo.** Documentar en la plantilla de TEST las variables que #1204 agrega al compose. Puede ir ya: no depende de la fusión de #1204 (decisión del líder, 2026-11-20).
**Pasos.**
1. `git -C sgpmp-backend fetch` y `git switch -c cfg-04/test-plantilla-variables origin/test`.
2. `.env.test.example`: agregar un bloque por función (M07, M04 firma, motor M04, OTA, logos) con las variables de #1204, placeholders vacíos o el valor por defecto del compose, comentario «sensible: la carga Despliegue» en los tres secretos y una línea «las pasa el compose desde #1204». `IOT_AUDITORIA_RESPALDO_PATH` va como comentario («la fija la imagen»). No tocar `AGROFUSION_HUB_*` (ST-04b). Nunca valores reales.
3. Verificar local: segundo comando de CA-5 sin salida.
4. Commit sin atribuciones; push; entregar al líder la descripción del PR (plantilla de `promocion-entornos`), que enlace HU, #1180 y #1204 y pida aprobación al Líder de Pruebas.
**Entregable.** PR a `test` en `Arekkazu/sgpmp-backend`.
**Verificación.** CA-5 (parte de las variables nuevas).
**Estimación.** 2 h.

### ST-04b Abrir PR a `test`: retiro de `AGROFUSION_HUB_*` y ruta del respaldo
**Objetivo.** Quitar de TEST las variables sin uso (sustituye la ST-02/T2 de HU-IMP-CFG-03) y, si Desarrollo no la corrige en #1204, la ruta relativa de la l. 82.
**Pasos.**
1. Esperar la fusión de #1204 (`gh pr view 1204 … --json state` → `MERGED`). Luego `git -C sgpmp-backend fetch` y `git switch -c cfg-04/test-retiro-hub origin/test`.
2. `docker-compose.test.yml`: borrar `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET`. Si sigue la línea `IOT_AUDITORIA_RESPALDO_PATH: ${…:-var/auditoria_iot/fallas.sqlite3}`, borrarla (TEST hereda el `ENV` del Dockerfile, como PROD). Si en lugar de borrarla se fija la ruta, escribir la ruta sin comillas y con valor por defecto, para que funcione el sed de CA-4 (REV-02 n-02). Añadir fila a la tabla de cambios de la cabecera.
3. `.env.test.example`: borrar `AGROFUSION_HUB_*` (l. 54-55 al corte).
4. Verificar local: `docker compose -f docker-compose.test.yml config --no-interpolate > /dev/null && echo OK`; comandos de CA-3 y CA-4 sobre la rama.
5. Commit sin atribuciones; push; descripción del PR al líder, que enlace HU, #1180 y #1204, liste las diferencias preexistentes compose ↔ plantilla y pida aprobación al Líder de Pruebas.
**Entregable.** PR a `test` en `Arekkazu/sgpmp-backend`.
**Verificación.** CA-3, CA-4 y CA-5 completo (tras la fusión, sobre `origin/test`).
**Estimación.** 3 h.

### ST-05 Abrir PR a `dev`: `OTA_URL_*` en `.env.prod.example`
**Objetivo.** Que la plantilla de PROD documente las variables OTA que `docker-compose.prod.yml` ya referencia (l. 167-169@6cee5fc4), y viajen a `main` con el release.
**Pasos.**
1. `git switch -c cfg-04/dev-plantilla-prod-ota origin/dev`.
2. En `.env.prod.example`, junto al bloque de M04: `OTA_URL_SECRET=` (comentario: sensible, la carga Despliegue, obligatoria si se usa OTA), `OTA_URL_BASE=` (URL pública del backend de PROD; la confirma Despliegue), `OTA_URL_TTL_SEGUNDOS=86400`.
3. Verificar con el comando de CA-6 sobre la rama; commit sin atribuciones; push; descripción del PR al líder (aprueba Líder de Desarrollo).
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
**Entregable.** PR a SGMP-Integracion + evidencia CA-10.
**Verificación.** CA-10, CA-11.
**Estimación.** 3 h.

**Total estimado:** 21 h (ST-04a 2 h + ST-04b 3 h).

---

## Notas para el líder (no se copian a Taiga)

**Plazo sugerido.** ST-01 hoy o mañana (antes de que Pruebas fusione #1204). ST-02, ST-03, ST-05 y ST-07 antes del 2026-11-23 (no dependen de nadie). ST-04a puede ir ya. ST-04b y ST-06 dependen de #1204 y del Deploy; si no ocurren antes del 2026-11-24, la HU se presenta en E4 con esas dos en curso. CA-10 cierra en «seguimiento» hasta #941.

**Decisiones del líder (2026-11-20).**
1. El líder publica el comentario en #1204 y la respuesta en #1180; **no** se pide reabrir #1180.
2. `${M04_FIRMA_MODELOS_KEY:?}` en PROD: no. Queda como posible mejora, sin HU aparte.
3. HU-IMP-AMB-10 (persistencia de logos, modelos y respaldo de auditoría): queda en borrador, va después de esta HU y depende de la respuesta de Desarrollo sobre persistencia. Prioridad dentro de ella: respaldo de auditoría en PROD.
4. ST-04 se parte: ST-04a (`.env.test.example`, puede ir ya) y ST-04b (retiro de `AGROFUSION_HUB_*` y la l. 82 si Desarrollo no la corrige; espera la fusión de #1204).
5. Carpeta: `issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/`; el informe pasa a `prs/BACK-PR1204_compose-test-entorno-m04/`.
6. #1180 se registra como **INC-BE-09**. Se aceptan las correcciones sobre INC-BE-08 (es el CORS de TEST, `registro.md:21`; las relacionadas son INC-BE-04 e INC-BE-02). Como #1180 está cerrado, INC-BE-09 y ST-06 son el seguimiento de la re-prueba.
7. La petición a Desarrollo de agregar a Implementación como revisora va en el comentario de #1204 (ST-01).

**Puntos de atención para la revisión.**
- CA-4: comprobar que la prueba de escritura se hizo con la imagen de la rama, no con la de `dev`.
- CA-5: los tres secretos deben quedar con `=` y nada después; revisar también los comentarios.
- CA-7: no crear un catálogo paralelo; las líneas citadas deben ser del corte del día.
- Que la ficha (CA-8) no prometa valores de `OTA_URL_BASE` ni dominios sin curl del día.

---

## Metadatos

- Redactado: 2026-11-20 (America/Bogota), fase 1, borrador. Ajustado el mismo día en la fase 2 con las decisiones del líder.
- Fuentes: `analisis.md` (EXT-BACK-PR1204) y `entregables/borradores-comentarios.md`; `PI4/brief-issue-1180.md`; `git fetch` del 2026-11-20: BE `origin/dev 6cee5fc4`, `origin/test 12965211`, `origin/main 0abbeeef`, PR #1204 `b8968e68` (OPEN, MERGEABLE, 0 revisiones), PR #941 OPEN `dev`→`main`; SGMP-Integracion `main f40300b`; `docker-compose.test.yml@b8968e68` l. 60-86; `Dockerfile@12965211` l. 55-62; `.env.test.example@12965211` l. 54-55; `registros/incidencias/registro.md` l. 15, 17, 21; `registros/variables/VARIABLES-ENTORNO.md` l. 92, 340; numeración: `entregas/README.md` (último AMB = AMB-09; CFG-04 indicado por el líder).
