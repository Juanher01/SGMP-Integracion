# REV-03 — HU-IMP-CFG-04 (primera entrega de ejecución: ST-02, ST-03, ST-04a y ajuste de `historia.md`)

- **Fecha:** 2026-11-20 (America/Bogota)
- **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Objeto:** tres cambios **preparados** (`git diff --cached`), sin commit ni PR:
  1. SGMP-Integracion, rama `docs/hu-imp-cfg-04-variables-m04` (PR #21): `historia.md` (ajuste del líder del 2026-11-20 y «Sensible» → «Secreta»).
  2. SGMP-Integracion, worktree rama `docs/cfg-04-catalogo-ficha` desde `origin/main f40300b`: `registros/variables/VARIABLES-ENTORNO.md` (M) y `registros/variables/fichas/HU-IMP-CFG-04_2026-11-20.md` (A). ST-02 y ST-03.
  3. sgpmp-backend, rama `cfg-04/test-plantilla-variables` desde `origin/test 12965211`: `.env.test.example` (+40 −4). ST-04a. Índice en LF (`git ls-files --eol`: `i/lf w/crlf`).
- **Corte reverificado** (`git fetch origin` sin `--prune`): sgpmp-backend `origin/dev 6cee5fc4` · `origin/test 12965211` · `origin/main 0abbeeef` · `origin/pr-1204 b8968e68`. `gh pr view 1204`: `OPEN`, `MERGEABLE`, 0 revisiones, **0 comentarios**.
- **Criterios evaluados:** CA-5 (ST-04a), CA-7 (ST-02), CA-8 (ST-03) y los pasos de cada subtarea. CA-7 y CA-8 se corrieron sobre el archivo preparado del worktree (no sobre `origin/main`). CA-5 se corrió sobre el `.env.test.example` preparado y el compose de `origin/pr-1204`, y también contra `origin/test`.

## Dictamen global

**APROBAR CON OBSERVACIONES**, condicionado a corregir M-01 en `historia.md` antes de copiar la HU a Taiga y a resolver M-02 antes de abrir el PR del catálogo y la ficha.

| Cambio | Dictamen |
|---|---|
| 1. `historia.md` | **SOLICITAR CAMBIOS** (M-01: el resultado esperado de CA-5 no se actualizó con el traslado; corrección de una línea). El resto del ajuste es coherente. |
| 2. Catálogo y ficha (ST-02, ST-03) | **APROBAR CON OBSERVACIONES** (M-02 condicionado; m-01, m-02, m-03). Las 23 citas que se muestrearon coinciden con el código. |
| 3. `.env.test.example` (ST-04a) | **APROBAR**. Cumple los pasos de ST-04a. No tiene valores de secretos. |

## Criterios

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-5 (ST-04a) | **NO VERIFICABLE AÚN** (lo preparado cumple) | El CA exige el estado en `origin/test`, que depende de la fusión del PR de ST-04a y, para el `diff`, de #1204. Sobre lo preparado: segundo comando (`grep -nE '^(M04_FIRMA_MODELOS_KEY\|IOT_INFERENCIA_M04_TOKEN\|OTA_URL_SECRET)=.+'`): sin salida, rc=1. `grep -c AGROFUSION_HUB` = 0. Las 11 variables de #1204 (l. 71-86@b8968e68) están: 10 como `VAR=` e `IOT_AUDITORIA_RESPALDO_PATH` como comentario «la fija la imagen». Cada uno de los tres secretos tiene encima el comentario «Sensible: la carga Despliegue». Los valores por defecto coinciden con el compose de #1204 (`TEST`, `1.3`, `86400`, `/tmp/sgpmp_logos`). La línea «las pasa el compose desde el PR #1204» está. El `diff` contra `pr-1204` da como solo-compose `AGROFUSION_HUB_CLIENT_ID/SECRET` e `IOT_AUDITORIA_RESPALDO_PATH`, además de las 7 preexistentes (`BROKER_SERVICE_TOKEN`, `COOKIE_SAMESITE`, `COOKIE_SECURE`, `DB_PORT`, `JWT_LEEWAY_SECONDS`, `MQTT_BROKER_TOKEN`, `MQTT_BROKER_URL`, iguales a la línea base `test`↔`test`). No hay ninguna solo-plantilla. Ver M-01. |
| CA-7 (ST-02) | **CUMPLE** sobre lo preparado (falta la fusión en `main`) | Comando de CA-7 contra el archivo preparado: `1` en las 11. Sensibilidad: `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN` y `OTA_URL_SECRET` = `**Secreta**`; el resto `Interna` o `No sensible` (vocabulario §1). Cada fila trae el estado DEV/TEST/PROD en la descripción, porque el catálogo no tiene columnas de entorno. La fila de `SGPMP_ENTORNO` cita `configuracion.py:18@12965211`, `docker-compose.yml:80` y `docker-compose.prod.yml:154@6cee5fc4` y `b2b9097b` (verificado: el commit agrega la l. de PROD). Sigue diciendo «falta en TEST», que es correcto porque #1204 no está fusionado. La nota del antiguo l. 340 (ahora l. 350) dice «Trasladado a HU-IMP-CFG-04». Se agregó la actualización 2026-11-20 en §8. |
| CA-8 (ST-03) | **CUMPLE** sobre lo preparado (falta la constancia de entrega a Despliegue) | Existe `fichas/HU-IMP-CFG-04_2026-11-20.md`. `grep -nE 'Deploy\|modelos_cargados\|Secreta'`: 13 líneas, con las tres cadenas. Tiene variable, obligatoria, sensibilidad, provee, acción en Dokploy (TEST) y rebuild. `SGPMP_ENTORNO` es opcional con `TEST` por defecto. Trae la regla `modelos_cargados > 0` para URL y token (§2.5), «Deploy, no Restart» (§2.3) y el comando de presencia (§3). Ningún valor de secreto. No promete dominios: `OTA_URL_BASE` = «URL pública del backend de TEST, sin `/` final» y lo confirma Despliegue. Ver m-02 y M-02. |

### Muestra de citas verificadas (todas coinciden)

- Código en `test@12965211`: `configuracion.py:18`; `firma_artefacto.py:24,28`; `registrar_version_modelo_use_case.py:405` (`FIRMA_MODELOS_NO_CONFIGURADA`); `version_modelo.py:207` (`FIRMA_ARTEFACTO_INVALIDA`); `motor_inferencia_http_adapter.py:110,114,115,117` y `TLS_MINIMO_POR_DEFECTO = "1.3"` (l. 47); `broker_auth.py:70` (`TOKEN_SERVICIO_NO_CONFIGURADO` l. 37); `respaldo_auditoria_iot_sqlite_adapter.py:18` (default relativo); `ota_edge_adapters.py:94,96`; `crear_distribucion_ota_use_case.py:79` (`OTA_NO_CONFIGURADA`); `_aviso_fase.py:32` (default `24*3600`); `almacen_logos.py:45` y `main.py:1166-1168` (crea el directorio y, si falla, solo registra en el log); `Dockerfile:55-56,61`; `docker-compose.test.yml:62` (`MODELOS_STORAGE_PATH`), l. 66-67 (`AGROFUSION_HUB_*`); `.env.test.example:54-55`.
- Compose en `dev@6cee5fc4`: `docker-compose.yml:76,80,82,88-92,94-96` (l. 92 literal); `docker-compose.prod.yml:150,154,156,162-165,167-169` (sin `IOT_AUDITORIA_RESPALDO_PATH`). En `main@0abbeeef`: `LOGOS_STORAGE_PATH` l. 69 y 145; ninguna de las nuevas en compose ni en `src/`.
- PR #1204 `b8968e68`: l. 67-68 (`AGROFUSION_HUB_*`), 71, 73, 75, 78-82, 84-86.

## Hallazgos

### Bloqueantes / Mayores

| ID | Cambio | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|---|
| M-01 | 1 `historia.md` | Tabla de verificación, fila CA-5, columna «Resultado esperado» (l. 51) | Se cambió el texto de CA-5 (l. 35, «Todo lo de este CA llega con ST-04a»), pero no el resultado esperado: «Ninguna de las variables de #1204 ni `AGROFUSION_HUB_*` en el `diff`». Si ST-04a se fusiona antes que ST-04b, el compose de TEST conserva `AGROFUSION_HUB_*` y el `diff` lo lista como solo-compose (`<`). Ejecutado sobre lo preparado contra `pr-1204` y contra `test`: aparece. Lo mismo pasa con `IOT_AUDITORIA_RESPALDO_PATH` mientras la l. 82 siga en el compose. Con el criterio escrito así, la verificación de CA-5 falla aunque la plantilla esté bien. Es el inverso del error ya registrado de comandos que se cumplen solos. | Separar las dos comprobaciones. (a) Ausencia en la plantilla: `git show origin/test:.env.test.example \| grep -c AGROFUSION_HUB_` → `0`. (b) `diff`: «ninguna variable de #1204 como solo-plantilla (`>`) ni como solo-compose, salvo `IOT_AUDITORIA_RESPALDO_PATH` (comentario en la plantilla); `AGROFUSION_HUB_*` puede aparecer como solo-compose hasta ST-04b». Antes de la fusión de #1204, las 10 de la plantilla salen como `>`: anotar que el `diff` completo se evalúa después de #1204. |
| M-02 (condicionado) | 2 Ficha y catálogo | Ficha §4, 2.º punto: «Implementación pidió a Desarrollo quitar la línea o usar la ruta absoluta». Catálogo §8: «se pidió a Desarrollo corregirla» | `gh pr view 1204 --json comments` → `0` comentarios al corte. ST-01 todavía no está publicado, así que la afirmación hoy no es cierta. Además la ficha se entrega a otro equipo. | Publicar ST-01 antes de abrir el PR de ST-02/ST-03 (y entonces es cierto), o redactar en futuro: «Implementación lo pide a Desarrollo en #1204 (ST-01)». |

### No bloqueantes

| ID | Cambio | Dónde | Evidencia | Corrección sugerida |
|---|---|---|---|---|
| m-01 | 2 Catálogo | Filas `AGROFUSION_HUB_CLIENT_ID` y `_SECRET` (l. 90-91) | Siguen diciendo «se retira en ST-02 de HU-IMP-CFG-03» y citan `docker-compose.test.yml:66-67@5697ebbe`. La nota de §8 ya dice que se trasladó a CFG-04, y la HU (Alcance, ST-04a/b) también. Las líneas 66-67 siguen vigentes en `12965211`. | Apuntar a «ST-04a (plantilla) y ST-04b (compose) de HU-IMP-CFG-04» y actualizar el hash a `@12965211`. |
| m-02 | 2 Ficha | §1, encabezado de la tabla | No tiene las columnas `Servicio` ni `Entorno(s)` del formato de la skill `variables-entorno`. El entorno está implícito en el título de §1 y en «Acción en Dokploy (TEST)», así que CA-8 se cumple. | Opcional: agregar la columna `Entorno(s)` (TEST) para que se pueda cotejar con la ficha de PROD posterior. |
| m-03 | 2 Ficha / 1 HU | Ficha §3 frente a CA-9 (l. 55) | La ficha agrega `printenv SGPMP_ENTORNO` (valor no secreto, lo declara). CA-9 no lo espera. Es coherente pero distinto. | Opcional: agregar a CA-9 «y `TEST` en la última línea» para que la evidencia de Despliegue y el CA coincidan. |
| m-04 | 1 `historia.md` | CA-5 (l. 35) frente a ST-04a paso 2 (l. 127) | CA-5 pone `IOT_AUDITORIA_RESPALDO_PATH` como comentario solo «si sale del compose»; ST-04a lo pone siempre como comentario, y así quedó la plantilla. La decisión del paso es la correcta: no invita a cargar la ruta relativa. | Quitar el condicional de CA-5: «`IOT_AUDITORIA_RESPALDO_PATH` como comentario "la fija la imagen"». |
| m-05 | 2 Proceso | ST-02 paso 1 | La rama sale de `main f40300b` antes de fusionar el PR #21, cuando el paso dice «después de fusionado el PR de la carpeta de la HU». La ficha cita la carpeta de la HU como texto (sin enlace roto). | Abrir el PR de ST-02/ST-03 después de fusionar #21 o rebasar sobre `main` antes de abrirlo; reverificar el corte (CA-1). |

### Comprobaciones sin hallazgo

- Sin secretos ni valores reales en los tres cambios. Los `grep` de URL y contraseñas en el catálogo solo encuentran filas preexistentes.
- Sin atribución a herramientas.
- No se tocó lógica de aplicación.
- El registro vivo es el oficial: no se creó ningún catálogo paralelo.
- Vocabulario «Secreta»: catálogo, ficha e historia alineados. En `historia.md` no queda ningún «Sensible» como valor de sensibilidad. La plantilla usa «Sensible:» en comentarios, como pide ST-04a paso 2.
- Coherencia del traslado: Alcance, Dependencias, ST-04a, ST-04b, Decisión 4, catálogo §8 y ficha §1 (fila `AGROFUSION_HUB_*`: «Retirar de TEST cuando… ST-04b») coinciden.
- La ficha no dice nada de PROD que contradiga `main`: «No hacer nada todavía» y no tocar `AGROFUSION_HUB_*` (verificado: `main.py:671` y `agrofusion_auth.py:19-20@0abbeeef` las leen; `git grep` vacío en `*.py@12965211`).

## Borrador de comentario (para el PR de ST-02/ST-03 y de ST-04a, cuando se abran)

> Hola, Juan Hernando. Revisé lo preparado de ST-02, ST-03 y ST-04a contra CA-5, CA-7 y CA-8, con el corte del 2026-11-20 (BE `dev@6cee5fc4`, `test@12965211`, `main@0abbeeef`, #1204 `b8968e68`).
>
> **Lo que está bien.** La plantilla de TEST trae las 11 variables de #1204 en bloques por función. Los tres secretos quedan con `=` vacío y comentario de sensibilidad, sin `AGROFUSION_HUB_*`. Los valores por defecto son los del compose. En el catálogo verifiqué 23 citas archivo:línea@hash y todas coinciden. La ficha explica bien el orden de carga, la regla `modelos_cargados > 0` y «Deploy, no Restart», y no promete dominios ni valores.
>
> **Antes de abrir el PR de catálogo y ficha:**
> 1. Ficha §4 y catálogo §8 dicen que ya se pidió a Desarrollo corregir la l. 82, pero #1204 no tiene comentarios todavía. Si ST-01 no está publicado al abrir el PR, pásalo a futuro («se pide en #1204, ST-01»).
> 2. Las filas `AGROFUSION_HUB_*` del catálogo siguen apuntando a «ST-02 de HU-IMP-CFG-03» con `@5697ebbe`. Cámbialas a ST-04a/ST-04b de HU-IMP-CFG-04 con `@12965211`.
> 3. Rebasa sobre `main` cuando se fusione #21 y vuelve a verificar el corte (CA-1).
>
> **Cómo verificar:** comando de CA-7 sobre el archivo (debe dar `1` en las 11), `grep -nE 'Deploy|modelos_cargados|Secreta'` en la ficha y, para la plantilla, `grep -c AGROFUSION_HUB_ .env.test.example` → `0` y el segundo comando de CA-5 sin salida.

## Nota posterior (2026-11-21): renumeración ST-04b → ST-04c

Esta nota no cambia el dictamen. El 2026-11-21 el líder agregó una nueva **ST-04b** («Corregir la l. 82 del PR #1204 con un commit en su rama»; sin permiso de escritura, PR hacia esa rama). La ST-04b que se cita en esta revisión (retiro de `AGROFUSION_HUB_*` del compose de TEST) es ahora **ST-04c**, y corrige la l. 82 solo si #1204 se fusionó sin esa corrección. Donde arriba dice «ST-04b», léase «ST-04c». M-01 y m-04 se aplicaron en `historia.md` con la numeración nueva (ver REV-04).
