# REV-02 — HU-IMP-CFG-03 (fase 2: documentación del SSO de AgroFusion, contenido preparado)

- **Fecha:** 2026-11-20 13:57 -05 · **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Qué se revisó:** `git diff --cached` (17 archivos) en `Juanher01/SGMP-Integracion`, rama `docs/hu-imp-cfg-03-agrofusion-sso` (HEAD `95b16b9` = `origin`, PR #18 OPEN hacia `main`). `origin/main` (`0fa672e5`) es ancestro de HEAD. El árbol de trabajo no tiene cambios sin preparar en estos archivos. Quedan fuera: `.claude/`, `entregas/E2_*/motor_ia/`, `entregas/E2_*/prs/` y el stash `e2-readmes`.
- **Corte de hoy (`git fetch --prune`):**
  - Backend: `dev@6cee5fc4` · `test@135bc318` · `main@0abbeeef`.
  - Frontend: `dev@c8aa45b8` · `test@3358b032` · `main@fe88f82d`.
  - Los documentos citan el corte del 2026-11-17: BE `2b9ee221`/`5697ebbe`, FE `601d5a84`/`247b1183`.
- **Inclusión de commits por rama (re-ejecutada):**

| Commit | dev | test | main |
|---|---|---|---|
| `0dbe294` | sí | sí | no |
| `9ff4d38` | sí | sí | no |
| `9a52ad5c` | no | sí | no |

  El PR #941 sigue OPEN.
- **Curl de hoy (13:57 -05):**

| Entorno | Respuesta |
|---|---|
| DEV | 401 `SSO_TOKEN_INVALIDO` |
| TEST | 503 `SSO_NO_CONFIGURADO` |
| PROD | 503 `SSO_NO_CONFIGURADO` |

  El campo del cuerpo de la respuesta se llama `error_code`.

## 1. Criterios de aceptación

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-1 | CUMPLE (sin cambios desde REV-01) | Montaje en `origin/dev:docker-compose.yml:111` y `docker-compose.prod.yml:191`. Hoy están una línea más abajo que lo citado (l.109 y l.189 @2b9ee221), por `d417c0c6`. |
| CA-2 | CUMPLE | `origin/dev:.dockerignore:23-24` contiene `**/*.pem` y `**/*.key`. |
| CA-3 | CUMPLE con observación (ST-05 pendiente) | `origin/dev:.env.prod.example:236` sigue diciendo `SGPMP-DEV` (era la l.235 en el corte). `AGROFUSION_PROJECT_CODE=` está vacía (l.242). |
| CA-4 | NO VERIFICABLE AÚN (el líder lo difirió) | `origin/test:docker-compose.test.yml` no cambió desde `5697ebbe`: montaje en l.86, `HUB_*` en l.66-67, sin `SGPMP_ENTORNO`. `git grep AGROFUSION_HUB origin/test -- '*.py'` sale vacío. |
| CA-5 | NO VERIFICABLE AÚN | Los tres commits no están en `main`; el #941 está OPEN. |
| **CA-6** | **NO CUMPLE (parte documental)** · DEV CUMPLE · TEST/PROD NO VERIFICABLE AÚN | La ficha no menciona los permisos `644` que el CA exige (`grep -c 644` = 0). No hay constancia de que Despliegue haya recibido la ficha. CA-6 y ficha usan cadenas distintas (`LEGIBLE` / `ARCHIVO-LEGIBLE`) y piden "`code`" cuando el campo real es `error_code` (curl de hoy). |
| CA-7 | CUMPLE | `VARIABLES-ENTORNO.md` (index) l.87-100: las tres variables SSO corregidas, más `HUB_*`, `SGPMP_ENTORNO`, `M07_*`, `FORWARDED_ALLOW_IPS` y `VITE_BASE_PATH`. Las citas coinciden con el código @hash. |
| CA-8 | CUMPLE con observación | El corte del 2026-11-17 es correcto y está fechado, pero el commit se hace el 2026-11-20. Desde entonces BE `dev` avanzó 61 commits y `test` 92. `d417c0c6` (Desarrollo, 2026-11-19, `M04_FIRMA_MODELOS_KEY`) tocó `docker-compose.yml`, `docker-compose.prod.yml`, `.env.example` y `.env.prod.example` de `dev` (en `test` llegó por `1b61087c`), y desplaza las líneas citadas una posición. El contenido afirmado sigue siendo cierto. |
| DoD "registro actualizado" | CUMPLE con observaciones | Se actualizaron `registro.md`, el catálogo y la ficha. Los estados del registro están fuera de su vocabulario (O-8). |

## 2. Estado de las observaciones de REV-01

Todas se re-verificaron con `git grep --cached`. **Ninguna se aplicó.**

| ID | Dónde sigue (index) |
|---|---|
| O-1 | Ficha sin `644` (CA-6). |
| O-2 | `historia.md:119` (plazo 2026-11-12 vencido), `:121` ("El PR a `test` crea el bloque `volumes:`") y `:122` ("pedir… la ficha", que ya existe). |
| O-3 | `historia.md:36,48` (`LEGIBLE`, "`code`") frente a la ficha l.48 (`ARCHIVO-LEGIBLE`) y l.84 ("`code`"). |
| O-4 | Ficha l.15: `SGPMP_ENTORNO` "Sí en TEST", frente a CA-4 `${SGPMP_ENTORNO:-TEST}`. La decisión sobre P4 no está registrada. |
| O-5 | `historia.md:23` ("Sin File Mount ni variables en Dokploy") y `VARIABLES-ENTORNO.md:338`. Un 503 no prueba nada sobre el File Mount. |
| O-6 | `historia.md:108-115` (ST-05) no tiene el aviso "no se aplica hoy" ni cita un CA. |
| O-7 | `VARIABLES-ENTORNO.md:99`: "T5 de HU-IMP-CFG-03", que no existe como subtarea. |
| O-8 | `registro.md`: INC-FE-01 "cerrada sin impacto", INC-BE-06 "resuelto del lado de Implementación" (columna Entorno = DEV), INC-BE-08 colocada antes de INC-BE-07. |
| O-9 | `commits/BACK-9ff4d38…/analisis.md:79` ("Ningún frontend vive en `inmero.co/<prefijo>`") y `prs/BACK-PR1130…/analisis.md:84` (`test -r`) y `:94` ("falta la fila en README"). |
| O-10 | `brief-01-pr-dev.md:13`: "El código ya usa `agrofusion-auth` si viene vacía". |
| O-11 | `entregas/E3…/README.md:10`: "ficha ST-04 entregada". |
| O-12 | Ver N-1. |
| O-13 | Resuelto: el `git add` fue selectivo. |

## 3. Comprobaciones adicionales

**Secretos en los `.md`: ninguno.** El grep sobre las líneas añadidas (`BEGIN`, `MIIB`, `-----`, `password=`, `secret=`, cadenas base64 de 40 o más caracteres) solo encuentra SHA de commits y la huella truncada `9d99cf66b629bbf7…`. Los códigos `SIGAB-*` no son secretos.

**PDF de fuentes:**
- Los SHA-256 coinciden con VERIF §1 (`2f388e2a…`, `b69d1ab6…`, `6fa2c4d1…`, `0d105238…`).
- En la capa de texto (`pdftotext`) no hay valores de secretos: el doc. 05 §5 dice "El valor del secreto no se transcribe".
- **El doc. 05 trae la clave pública completa** (§4.1, `-----BEGIN PUBLIC KEY-----`). No es un secreto, pero contradice la restricción del brief-03 (l.85: "no copies la clave a ningún archivo de SGMP-Integracion") y la frase de la ficha l.6.
- Hay objetos de imagen (doc. 01: 8, doc. 02: 2, doc. 05: 4, doc. M05-M06: 20). No pude revisarlos: no hay `pdftoppm` ni `pdfimages`.

**PDF frente a ADR-002:**
- ADR-002 l.15 manda versionar la *fuente editable* y llevar las exportaciones `.pdf` a Drive. No contempla PDF de terceros como evidencia.
- No son exportaciones de un documento nuestro, así que no lo incumplen literalmente. Pero son unos 3,5 MB de binarios, y el `SGPMP_M05_M06_Suministros_Finanzas.pdf` (2,2 MB) no tiene datos de infraestructura (brief-03 l.23: "solo se archiva").
- La trazabilidad ya está cubierta por las huellas SHA-256 de VERIF §1.

**Enlaces relativos:**
- Solo `entregas/E3…/README.md` usa enlaces Markdown, y sus 4 destinos existen.
- Hay una referencia rota en texto: `brief-02-pr-test.md:3` cita `BRIEF-ClaudeCode-agrofusion-sso-PR-dev.md`, que no existe (es `brief-01-pr-dev.md`). La línea es antigua, pero el archivo entra en este commit.

**Coherencia entre documentos:**
- Los puntos O-3, O-4, O-5, O-8 y O-11 siguen abiertos.
- **`entregas/README.md:60`** (tablero general, en el index sin cambios) dice "por crear… PR #1051 abierto hacia `dev`; falta el PR a `test`". Contradice el README de E3. Puede que la corrección esté en el stash excluido.
- La descripción del PR #18 sigue listando ST-01 a ST-04. No menciona ST-05, la fase 2, la ficha ni los PDF.

**Atribución a herramientas:**
- No hay `Co-Authored-By`, "Generated with", enlaces de sesión ni emojis.
- Hay dos menciones a revisar:
  - REV-01 l.3 dice "**Revisor:** agente `revisor`", cuando la convención de E1 (`HU-IMP-DOC-01/revisiones/REV-02.md:3`) es "Revisa: Líder de Implementación (con el agente `revisor`)".
  - `brief-03` l.1 se titula "Brief para Claude Code", igual que los brief 1 y 2 que ya están en el PR #18.

**Alcance:**
- No se tocaron los repos de aplicación, `registro-SEG.md` ni la v1.5 de E1.
- `SGPMP-DEV` solo aparece en notas históricas o pendientes (hipótesis A resuelta).

## 4. Hallazgos

### Que motivan SOLICITAR CAMBIOS (aplicar antes del commit)

| ID | Sev. | Dónde | Corrección |
|---|---|---|---|
| C-1 | Mayor (CA-6) | Ficha §2 paso 3 (l.25) | Añadir "archivo con permisos `644` (legible por UID 1000)". |
| C-2 | Media | `historia.md:36,48` y ficha l.48, l.84 | Unificar la cadena esperada (`ARCHIVO-LEGIBLE` en los dos lados) y escribir `error_code` en vez de `code`. Opcional: añadir `-w ' HTTP%{http_code}\n'` al curl de la ficha l.36. |
| C-3 | Media | `historia.md:119,121,122` | Marcarlas como "(Histórico, 2026-11-09)" o remitir a la ST-02 reescrita y a la ficha. |
| C-4 | Media | Doc. 05 en el commit | Decidir antes de comitear. **Recomiendo** sacar del index los 4 PDF (`git restore --staged …/fuentes-desarrollo-2026-11-14/`), subirlos a Drive (`G-Implementacion/entrega_3`) y dejar en VERIF §1 el enlace junto a las huellas. Si se quedan en el repositorio: registrar la decisión (nota en VERIF §1 o en el README de E3), revisar a ojo las figuras del doc. 05 y corregir la frase del brief-03/ficha. |

### No bloqueantes (pueden ir en el mismo commit o en el siguiente)

| ID | Sev. | Dónde | Corrección |
|---|---|---|---|
| N-1 | Menor | REV-01 O-4 a O-11 | Aplicar las correcciones que REV-01 ya propuso: ficha l.15, `historia.md:23`, `VARIABLES-ENTORNO.md:338` y `:99`, ST-05, estados de `registro.md` y orden de filas, una línea "Actualización 2026-11-17" en los dos `analisis.md`, `brief-01:13`, y "ficha redactada; envío pendiente" en el README de E3. |
| N-2 | Menor | `historia.md` (pie) o descripción del PR #18 | Añadir "Reverificado 2026-11-20: BE `dev@6cee5fc4`, `test@135bc318`, `main@0abbeeef`; el contenido sigue vigente; `d417c0c6` desplaza una línea las citas de `dev`". En ST-05, citar el texto a reemplazar por contenido y no por "líneas 234-235" (hoy son 235-236). |
| N-3 | Menor | `brief-02-pr-test.md:3` | Cambiar `BRIEF-ClaudeCode-agrofusion-sso-PR-dev.md` por `brief-01-pr-dev.md`. |
| N-4 | Menor | REV-01 l.3 | Usar la convención de E1: "Revisa: Líder de Implementación (con el agente `revisor`)". |
| N-5 | Menor | `entregas/README.md:60` y descripción del PR #18 | Actualizar el estado de CFG-03 (estado de Taiga, PR #1051 fusionado, ST-05) y el contenido del PR. |
| N-6 | Info (trabajo derivado) | BE `d417c0c6` (2026-11-19, SEG-M04-01) | Desarrollo agregó `M04_FIRMA_MODELOS_KEY` a los compose y plantillas de `dev` (llegó a `test`) sin pasar por Implementación. Falta en el catálogo. Fuera del alcance de CFG-03: `/impacto` aparte. Es el tercer cambio ajeno a archivos de Implementación en una semana (#1129, #1130, `d417c0c6`), lo que refuerza la pregunta P5 de VERIF §7. |

## 5. Borrador de comentario para el PR #18

> Gracias por la fase 2. Volví a comprobar el contenido preparado contra el código (corte de hoy: BE `dev@6cee5fc4`, `test@135bc318`, `main@0abbeeef`) y contra los entornos (curl 2026-11-20 13:57: DEV 401 `SSO_TOKEN_INVALIDO`, TEST 503, PROD 503). Las afirmaciones técnicas siguen siendo correctas: catálogo, ficha, nuevas incidencias, análisis de #1129 y #1130. No hay secretos en los `.md`.
>
> Antes del commit, pido estos ajustes (son los de REV-01, que aún no están aplicados):
> 1. **Ficha §2, paso 3:** añadir "permisos `644`". El CA-6 lo exige (`grep 644` sobre la ficha hoy da 0).
> 2. **CA-6 y ficha:** una sola cadena esperada (`ARCHIVO-LEGIBLE`) y `error_code` en vez de `code`. Es el nombre real del campo, según el curl de hoy.
> 3. **`historia.md:119-122`:** marcar como históricas las notas del plazo del 2026-11-12, de "el PR a `test` crea `volumes:`" y de "pedir la ficha".
> 4. **PDF de Desarrollo:** el doc. 05 trae la clave pública completa, y el brief pide no copiarla al repositorio. Propongo sacarlos del commit, subirlos a Drive y conservar las huellas SHA-256 de VERIF §1. Si se quedan, que quede escrita la decisión.
> 5. Menores: los puntos O-4 a O-11 de REV-01, la referencia `BRIEF-ClaudeCode-…` del brief-02, la línea de reverificación del 2026-11-20 (`d417c0c6` desplaza una línea las citas de `dev`), la fila de CFG-03 en `entregas/README.md` y la descripción de este PR.
>
> Para comprobarlo: `grep -n 644 registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md` y `grep -rn 'LEGIBLE\|`code`' <HU>/historia.md registros/variables/fichas/`.
