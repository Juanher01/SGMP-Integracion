# REV-06 — HU-IMP-CFG-04 (ST-04a, ST-05 y PR final de ST-07, 2026-11-21 tarde)

- **Fecha:** 2026-11-21, 18:05 (America/Bogota)
- **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Objeto:**
  1. [Arekkazu/sgpmp-backend#1216](https://github.com/Arekkazu/sgpmp-backend/pull/1216) (ST-04a): `cfg-04/test-plantilla-variables` → `test`, 1 commit `d873f740` (padre `cd5f36de` = `origin/test`), solo `.env.test.example` (+47 −4). OPEN, MERGEABLE.
  2. [Arekkazu/sgpmp-backend#1217](https://github.com/Arekkazu/sgpmp-backend/pull/1217) (ST-05): `cfg-04/dev-plantilla-prod-ota` → `dev`, 1 commit `d96449dd` (padre `8d4981f6` = `origin/dev`), solo `.env.prod.example` (+11). OPEN, MERGEABLE, `REVIEW_REQUIRED`.
  3. Árbol de trabajo **sin commit** de SGMP-Integracion, rama `docs/cfg-04-st07-y-estado` sobre `main a910760`: `historia.md`, `registros/incidencias/registro.md`, `registros/variables/VARIABLES-ENTORNO.md`, `entregas/README.md`, `entregas/E4_…/README.md` y los nuevos `evidencias/CA-05_CA-06_plantillas.md` y `evidencias/CA-10_prod-seguimiento.md`.
- **Estado real reverificado hoy** (`git fetch --prune` en sgpmp-backend y SGMP-Integracion; `refs/pull/{1204,1216,1217}/head`; `gh pr view`):
  - BE `dev 8d4981f6` · `test cd5f36de` · `main 0abbeeef` (2026-10-13). #1204 OPEN, 2 commits, cabeza `097f6d80`. #941 OPEN, cabeza `8d4981f6`, `REVIEW_REQUIRED`. SGMP-Integracion `origin/main a910760` (PR #22 fusionado 21:17Z y #23 21:18Z).
  - `git diff --name-only 12965211 cd5f36de` y `918806ec cd5f36de` sobre `Dockerfile*`, `.dockerignore`, `docker-compose*.yml`, `.env*.example`: vacío. Líneas `+` de `*.py` en ese rango: ningún `getenv`/`environ` nuevo. `12965211` es ancestro de `cd5f36de`.

## Dictamen global

**APROBAR CON OBSERVACIONES** (con menores). No hay hallazgos Mayores ni Bloqueantes.

Las dos plantillas cumplen lo que piden CA-5 (a)(b)(c)(d) y CA-6 (a)(b) en la rama de cada PR. Repetí cada prueba y obtuve las mismas salidas que la evidencia, incluida la de `docker compose config` con la plantilla rellena y sus controles negativos. CA-10 coincide con mi ejecución. Las filas INC-BE-02/04/09 son coherentes con los PR. No hay secretos, ni atribución a herramientas, ni mojibake, ni enlaces relativos rotos. Quedan cinco menores de trazabilidad: el corte en las descripciones de los PR, una afirmación de `historia.md` sobre el catálogo que no se aplicó, números de línea de #1204 desfasados, la tabla de cabecera de `.env.test.example` y que el texto de CA-5 no recoge la ampliación del alcance. Ninguno impide fusionar los PR. Conviene corregir m-02, m-03 y m-05 antes del commit del PR final a SGMP-Integracion.

## Criterios

| CA | Veredicto | Evidencia (propia) |
|---|---|---|
| CA-1 Corte | **CUMPLE en la HU; parcial en los PR** (m-01) | `historia.md:7` coincide hash por hash con mi `fetch`. #1216 solo cita `test@cd5f36de` y `097f6d80`; #1217 solo `dev@8d4981f6`. Ninguno da la fecha del `fetch` ni los demás hashes que pide el CA. `evidencias/CA-01_corte.md` (l. 63) no existe. |
| CA-5 (a) | **CUMPLE** (rama del #1216) | `git show pr/1216:.env.test.example \| grep -c AGROFUSION_HUB_` → `0`. |
| CA-5 (b) | **CUMPLE** (con el compose de `097f6d80`) | `diff` compose↔plantilla: `< AGROFUSION_HUB_CLIENT_ID/SECRET`, `< BROKER_SERVICE_TOKEN`, `< COOKIE_SAMESITE`, `< COOKIE_SECURE`, `< DB_PORT`, `< JWT_LEEWAY_SECONDS`. Ninguna de #1204 sale de un solo lado. Contra `origin/test` salen como `>` las 10 de #1204, como se esperaba. Es idéntico a la evidencia y a la descripción del PR. Las 5 opcionales están en la tabla «Diferencias previas» del PR, y sus valores (`${COOKIE_SAMESITE}`, `${DB_PORT:-5448}`, `${BROKER_SERVICE_TOKEN:-}`…) coinciden con `docker-compose.test.yml:31,49,51,52,92@097f6d80`. Las 9 `${VAR:?}` son iguales en `origin/test` y en `097f6d80`. En la plantilla de `origin/test` faltan `MQTT_BROKER_URL` y `MQTT_BROKER_TOKEN`; en la del #1216, ninguna. |
| CA-5 (c) | **CUMPLE** | `grep -nE '^(M04_FIRMA_MODELOS_KEY\|IOT_INFERENCIA_M04_TOKEN\|OTA_URL_SECRET\|MQTT_BROKER_TOKEN)=.+'`: sin salida. Las cuatro están vacías (l. 61, 76, 84, 94) y cada una lleva «Sensible: la carga Despliegue» en el comentario de arriba (l. 60, 74, 83, 93). |
| CA-5 (d) | **CUMPLE** | Copia en el scratchpad (`sed 's/=$/=x/'`), compose de `097f6d80`, Docker Compose v5.7.0, `MSYS_NO_PATHCONV=1`. Las obligatorias no estaban definidas en el shell (comprobado por nombre). Resultado: 3 avisos (`COOKIE_SAMESITE`, `COOKIE_SECURE`, `JWT_LEEWAY_SECONDS`, todas diferencias previas) y `PLANTILLA-OK`. Control negativo sin `MQTT_BROKER_URL`: `required variable MQTT_BROKER_URL is missing a value: MQTT_BROKER_URL requerido para TEST`. Las copias se borraron. |
| Descripción del #1216 | **CUMPLE** (salvo m-01) | Tiene las «Diferencias previas» (tabla de 5), la nota sobre INC-BE-04 (resuelve solo la parte de la plantilla) y la sección «Prueba: la plantilla levanta el compose», con la misma salida que reproduje. Relaciona #1180 y #1204. No tiene valores ni mojibake. |
| CA-6 (a) | **CUMPLE** (rama del #1217) | `220:OTA_URL_SECRET=` · `222:OTA_URL_BASE=` · `224:OTA_URL_TTL_SEGUNDOS=86400`. `^OTA_URL_SECRET=.+`: sin salida. Comentario «Sensible: la carga Despliegue. Firma (HMAC-SHA256)…», coherente con `ota_edge_adapters.py:103@dev` (`hmac.new(…, hashlib.sha256)`). |
| CA-6 (b) | **CUMPLE** | `docker-compose.prod.yml` del #1217 (igual al de `dev`; OTA en l. 167-169): `PLANTILLA-OK` sin avisos. Control negativo sin `FRONTEND_URL`: `…FRONTEND_URL es obligatoria en PROD (la provee Despliegue)`. Ver n-03 (la prueba no distingue OTA). |
| Tabla de cabecera del #1217 | **CUMPLE** | Fila `\| 2026-11-21 \| chebaztian \| HU-IMP-CFG-04 ST-05 DEV-15: OTA_URL_SECRET, OTA_URL_BASE y OTA_URL_TTL_SEGUNDOS \|`, al final de la tabla. El nombre coincide con el autor git del commit (`chebaztian`). Fecha, ID y frase corta, como pide `sgpmp-backend/CLAUDE.md` §«Tabla de seguimiento en cabecera». |
| CA-8 Ficha y entrega | **CUMPLE** (la constancia la declara el líder; no se puede verificar con git) | `fichas/HU-IMP-CFG-04_2026-11-20.md` está en `origin/main` (PR #23, 21:18Z). El grep de CA-8 encuentra `Deploy`, `modelos_cargados` y `Secreta`. La entrega (2026-11-21 17:50 America/Bogota = 22:50 UTC, WhatsApp, Líder de Despliegue) aparece igual en `historia.md:15, 54, 140` y es posterior a la fusión de la ficha y a la apertura del #1216 (22:20Z), que el mensaje cita. La pregunta pendiente sobre `IOT_INFERENCIA_M04_URL`/`OTA_URL_*` en TEST está en l. 15, l. 141 y `entregas/README.md:62`. |
| CA-10 PROD | **CUMPLE (seguimiento)** | Repetí el comando: `b2b9097b`, `d417c0c6`, `5e87d61e` y `098f635a` están INCLUIDOS en `dev` y `test` y AUSENTES en `main`. #941: `OPEN`, `main`, `8d4981f6`, `REVIEW_REQUIRED`. `grep 'SGPMP_ENTORNO:'` sobre el `docker-compose.prod.yml` de `main` no devuelve nada (rc=1). Coincide con la evidencia en todo. |
| CA-11 Registros | **CUMPLE** | `registro.md:15` (INC-BE-02): estado `diagnosticado` con nota del 2026-11-21, enlace a CFG-04 y a AMB-10 (borrador; la carpeta no existe, como corresponde). `:17` (INC-BE-04): `en HU (HU-IMP-CFG-04)` (vocabulario de la l. 5), PR #1216 enlazado, 5 opcionales y ST-04c. `:22` (INC-BE-09): estado del 2026-11-21 con `097f6d80`. `HU-IMP-CFG-03/historia.md:77` cita CFG-04. |
| Coherencia de `historia.md` | **CUMPLE con observaciones** (m-02, m-05, n-02) | La tabla «Estado por subtarea» (l. 11-21) coincide con l. 3, con las notas «Hecho» (l. 114, 127, 140, 154, 169, 192, 216) y con `entregas/README.md:62`. CA-5 (d) y CA-6 (b) están en la tabla de verificación (l. 67-68). El corte `test@cd5f36de` es correcto y su afirmación de que no cambian archivos ni variables se confirma. Los hashes `d873f740`, `d96449dd`, `097f6d80` y `cd5f36de`, la hora de fusión del PR #23 (21:18Z) y la l. 77 de CFG-03 son correctos. |
| Secretos, atribución, codificación, enlaces | **CUMPLE** | El grep de `(SECRET\|KEY\|TOKEN\|PASSWORD)…=[^ <\`]` sobre las líneas `+` y las evidencias solo encuentra los patrones `'^OTA_URL_SECRET=.+'` (falsos positivos). `co-authored\|generated with\|claude\|anthropic`: nada. Secuencias de doble codificación UTF-8 (mojibake): nada en el diff, en las evidencias ni en el cuerpo de los PR. UTF-8 sin CR. Comprobé todos los enlaces relativos de `historia.md`, de las dos evidencias y de los dos README: ninguno está roto. |

## Hallazgos

### Mayores

Ninguno.

### Menores

| ID | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|
| m-01 | Descripción de los PR #1216 y #1217; `historia.md:63` (CA-1) | CA-1 pide que **cada PR** registre la fecha del `fetch` y los hashes de BE `dev`, `test`, `main`, la cabeza de #1204 y SGMP-Integracion `main`. #1216 da solo `test@cd5f36de` y `097f6d80`; #1217 solo `dev@8d4981f6`. Además, la fila de CA-1 promete `evidencias/CA-01_corte.md`, que no existe. Ninguno de los dos PR enlaza la HU (solo dice «HU-IMP-CFG-04, ST-0x») y #1217 no relaciona #1180 ni #1204 (DoD l. 77). | Añadir a las dos descripciones una línea «Corte (2026-11-21 17:55, `git fetch`): BE `dev 8d4981f6` · `test cd5f36de` · `main 0abbeeef` · #1204 `097f6d80` · SGMP-Integracion `main a910760`» y el enlace a `historia.md` en `main` de SGMP-Integracion (cuando se fusione). En #1217, «Relacionado: #1180, #1204». En la HU, crear `evidencias/CA-01_corte.md` con la salida de los comandos de CA-1, o cambiar la columna de evidencia de CA-1 a «`historia.md` l. 7 y cabecera de cada evidencia». |
| m-02 | `historia.md:127` (ST-02 «Hecho») frente a `VARIABLES-ENTORNO.md:363` | La HU dice: «se actualizaron las notas del catálogo con los PR #1216 y #1217 **y el corte `test@cd5f36de`**». `grep cd5f36de VARIABLES-ENTORNO.md` no devuelve nada. El catálogo sigue con «Corte reverificado el 2026-11-21: … `test@918806ec`». | Una de dos: añadir en `VARIABLES-ENTORNO.md`, después de la l. 363, «Corte del 2026-11-21, 17:55: BE `test@cd5f36de` (merge de `dev`); sin cambios en compose, plantillas ni `Dockerfile` desde `@918806ec`: las citas siguen vigentes», o quitar «y el corte `test@cd5f36de`» de la l. 127. |
| m-03 | `VARIABLES-ENTORNO.md:102-104` (filas OTA, editadas en este diff) | Las filas citan «TEST: lo agrega el PR #1204 (l. 84/85/86)» sin hash. Esas líneas son de `b8968e68`. En la cabeza vigente `097f6d80`, después de borrar la l. 82, son **l. 83-85**. Las de l. 78-81 (motor M04) no cambian. | Escribir «(l. 84@b8968e68; l. 83@097f6d80)», o directamente «l. 83-85@097f6d80», en las tres filas OTA. |
| m-04 | #1216, `.env.test.example` (sin tabla de cabecera) | `sgpmp-backend/CLAUDE.md` §«Tabla de seguimiento en cabecera»: un archivo que admite comentarios «recibe la tabla la primera vez que se toca». `.env.prod.example` y `docker-compose.test.yml` ya la tienen, y #1217 la respeta. #1216 edita `.env.test.example` sin agregarla. | Agregar en un segundo commit del #1216 (sin force push): `# \| Fecha \| Nombre \| Que se hizo \|` + separador + `# \| 2026-11-21 \| chebaztian \| HU-IMP-CFG-04 ST-04a #1180: variables del compose de #1204, MQTT_BROKER_URL/TOKEN; retiro de AGROFUSION_HUB_* \|`. Repetir CA-5 (a)-(d): las líneas se desplazan, así que hay que actualizar los números de línea de la evidencia y de la descripción del PR. |
| m-05 | `historia.md:43` (Alcance), `:51` (CA-5) y `:67` (CA-5 (c)) | El líder amplió el alcance de ST-04a a las obligatorias `${VAR:?}` del compose (`MQTT_BROKER_URL`, `MQTT_BROKER_TOKEN`, sensible). Eso solo está en la nota «Hecho» de ST-04a (l. 154). El texto de CA-5 y el comando (c) siguen con tres sensibles, mientras que la evidencia y el PR comprueban cuatro. (d) lo cubre de forma implícita (sin `MQTT_*` no da `PLANTILLA-OK`). | En CA-5 (l. 51): «… y las variables obligatorias (`${VAR:?}`) del compose de TEST (ampliación del líder, 2026-11-21); comentario de sensibilidad y sin valor también en `MQTT_BROKER_TOKEN`». En la l. 67, añadir `MQTT_BROKER_TOKEN` al regex de (c). En Alcance (l. 43), una frase igual. Si la HU de Taiga lleva el mismo texto, ajustarla también. |

### Notas (no bloquean)

| ID | Dónde | Evidencia | Sugerencia |
|---|---|---|---|
| n-01 | `entregas/README.md:41-42` (fuera del diff) | La tabla de entregas dice «por iniciar» para E3 y E4, pero `E4…/README.md:2` dice «en curso» y E4 tiene una HU en ejecución. | Pasar E4 a «en curso» (y E3 a su estado real) en el mismo PR, si el líder lo aprueba. |
| n-02 | `historia.md:7` | «La ficha de ST-03 cita `test@918806ec` como corte». El corte de la ficha es `test@12965211` (l. 5), y `@918806ec` es su reverificación (l. 6). | «La ficha de ST-03 tiene corte `test@12965211`, reverificado en `@918806ec`; sigue vigente». |
| n-03 | CA-6 (b), `historia.md:68` y la evidencia | La prueba de compose con la plantilla de PROD pasa también con la plantilla de `origin/dev`, que **no** tiene `OTA_URL_*` (rc=0, comprobado): el compose usa `${OTA_URL_*:-}`. (b) prueba que la plantilla completa levanta el compose de PROD, pero no la presencia de OTA. Eso lo prueba (a). | Ninguna acción. Si se quiere, aclararlo en la evidencia: «(b) no depende de OTA; la presencia de OTA la prueba (a)». |
| n-04 | #1216 `MQTT_BROKER_URL=` y `OTA_URL_BASE=` vacías | La regla 2 de `variables-entorno` pide para las no sensibles «un valor de ejemplo útil». Las dos son dominios que decide Despliegue y se verifican con curl, así que dejarlas vacías con «La confirma Despliegue» es razonable. | Ninguna acción. |

## Comandos usados (resumen)

```bash
git -C sgpmp-backend fetch --prune origin
git -C sgpmp-backend fetch origin refs/pull/1216/head:refs/remotes/pr/1216 refs/pull/1217/head:refs/remotes/pr/1217 refs/pull/1204/head:refs/remotes/pr/1204
gh pr view <1204|1216|1217|941> -R Arekkazu/sgpmp-backend --json state,baseRefName,headRefOid,mergeable,reviewDecision,commits
export MSYS_NO_PATHCONV=1
diff <(git show pr/1204:docker-compose.test.yml | grep -oE '\$\{[A-Z0-9_]+' | tr -d '${' | sort -u) <(git show pr/1216:.env.test.example | grep -oE '^[A-Z0-9_]+=' | tr -d '=' | sort -u)
git show pr/1216:.env.test.example | sed 's/=$/=x/' > <scratchpad>/copia-test   # borrada después
docker compose -f <scratchpad>/docker-compose.test.yml --env-file <scratchpad>/copia-test config --quiet && echo PLANTILLA-OK
for c in b2b9097b d417c0c6 5e87d61e 098f635a; do for b in dev test main; do git -C sgpmp-backend merge-base --is-ancestor $c origin/$b && echo "$c $b INCLUIDO" || echo "$c $b AUSENTE"; done; done
git -C sgpmp-backend diff --name-only 12965211 cd5f36de -- 'Dockerfile*' .dockerignore 'docker-compose*.yml' '.env*.example'
```

## Borrador de retroalimentación

**Para el #1216 (comentario en el PR, si el líder lo publica):**

> Revisé el PR contra la HU-IMP-CFG-04 (CA-5) y repetí las pruebas. La plantilla queda sin `AGROFUSION_HUB_*` y las cuatro variables sensibles están vacías y marcadas. Con el compose de `097f6d80`, solo quedan de un lado las cinco diferencias opcionales que listas y `AGROFUSION_HUB_*` (hasta el PR de retiro). Con los vacíos rellenos, la plantilla levanta `docker compose config` con los tres avisos que documentas, y sin `MQTT_BROKER_URL` falla con su mensaje. Obtuve exactamente tu salida.
>
> Dos ajustes, ninguno cambia el contenido de las variables:
> 1. `sgpmp-backend/CLAUDE.md` pide la tabla de seguimiento en la cabecera de todo archivo que se edita por primera vez. `.env.test.example` todavía no la tiene. Basta un segundo commit (sin force push) con la tabla y una fila `2026-11-21 | chebaztian | HU-IMP-CFG-04 ST-04a #1180: …`.
> 2. Agrega a la descripción el corte completo del día (`dev 8d4981f6` · `test cd5f36de` · `main 0abbeeef` · #1204 `097f6d80` · SGMP-Integracion `a910760`) y el enlace a la HU.

**Para el #1217:**

> La plantilla de PROD queda con `OTA_URL_SECRET=` vacía y marcada como sensible, `OTA_URL_BASE` y `OTA_URL_TTL_SEGUNDOS=86400`, en el orden de `docker-compose.prod.yml:167-169`. La fila de la tabla de cabecera sigue la convención del repo, y la plantilla rellena levanta el compose de PROD sin avisos. Solo falta en la descripción el corte completo del día, el enlace a la HU y «Relacionado: #1180, #1204».

**Para el PR final a SGMP-Integracion (autor del ajuste):**

> Las evidencias de CA-5/CA-6 y CA-10 son reproducibles: las rehíce y coinciden línea por línea. La tabla «Estado por subtarea», las notas «Hecho», las filas INC-BE-02/04/09 y los dos README están alineados entre sí y con GitHub. La constancia de entrega de la ficha y la pregunta pendiente a Despliegue están en los tres lugares que corresponden. Antes del commit:
> 1. **(m-02)** `historia.md:127` dice que el catálogo ya tiene el corte `test@cd5f36de`, y no lo tiene. Agrégalo al catálogo después de la l. 363 o quita la frase.
> 2. **(m-03)** En las filas OTA del catálogo (l. 102-104), las líneas de #1204 son de `b8968e68`. En `097f6d80` son l. 83-85: pon el hash.
> 3. **(m-05)** Lleva la ampliación de `MQTT_BROKER_URL`/`MQTT_BROKER_TOKEN` al texto de CA-5, a su comando (c) y al Alcance.
> 4. **(m-01)** Resuelve la evidencia de CA-1 (archivo o columna) y, de paso, n-02 (l. 7) y n-01 (estado de E4 en `entregas/README.md`).
