# REV-01 — HU-IMP-CFG-03 (fase 2: documentación del SSO de AgroFusion)

- **Fecha:** 2026-11-17 (13:00–13:20 -05) · **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Qué se revisó:** árbol de trabajo **sin commit** de `Juanher01/SGMP-Integracion`, rama `docs/hu-imp-cfg-03-agrofusion-sso` (HEAD `95b16b9`), PR #18 abierto hacia `main`. `git diff` y archivos sin seguimiento.
- **Alcance aprobado por el líder para hoy:** solo documentación en SGMP-Integracion. T1 (ST-05, `.env.prod.example`) y T2 (ST-02, PR a `test`) quedan pendientes "no se aplica hoy" y **no** se cuentan como defecto.
- **Corte reverificado** (`git fetch --prune` hoy): BE `dev@2b9ee221` · `test@5697ebbe` · `main@0abbeeef`; FE `dev@601d5a84` · `test@247b1183` · `main@fe88f82d`. Coinciden con los hashes citados en los documentos.

## 1. Dictamen global

**APROBAR CON OBSERVACIONES.**

Las afirmaciones técnicas se contrastaron contra el código de cada rama y contra los entornos. Todas las que revisé son correctas: hashes, inclusión de commits por rama, números de línea, uso de `AGROFUSION_HUB_*` y `SGPMP_ENTORNO`, cadena de `VITE_BASE_PATH`, `VITE_AGROFUSION_LOGIN_URL` sin uso y los curl 401/503/503 y de CORS. No hay secretos ni texto de la clave pública en los `.md`. No se tocaron `registro-SEG.md`, la v1.5 de E1, `CLAUDE.md` ni `PI4/.claude/`. Ninguna observación bloquea. Las de severidad **Media** conviene corregirlas antes del commit porque contradicen un CA o el texto nuevo.

## 2. Criterios de aceptación

| CA | Veredicto | Justificación y evidencia (re-ejecutada hoy) |
|---|---|---|
| CA-1 montaje en `dev` (DEV/PROD) | CUMPLE | `git show origin/dev:docker-compose.yml` l.109 y `docker-compose.prod.yml` l.189: `../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro`. `0dbe294` está en `dev` y `test`, no en `main` (`merge-base --is-ancestor`). |
| CA-2 `.dockerignore` | CUMPLE | `origin/dev:.dockerignore` l.23-24 `**/*.pem`, `**/*.key`. No reconstruí la imagen; me apoyo en `evidencias/03-dockerignore-build.txt`, ya revisada en la fase 1. |
| CA-3 plantillas | CUMPLE, con observación | Sin valores reales (`AGROFUSION_PROJECT_CODE=` vacía, l.241). El comentario `.env.prod.example:235` dice `SGPMP-DEV` en `dev` y `test` (confirmado) y en `main` no existe (confirmado). Queda cubierto por ST-05/T1, que hoy no se aplica. |
| CA-4 `test` | NO VERIFICABLE AÚN (diferido por el líder) | La redacción nueva es correcta: el montaje ya está en `docker-compose.test.yml:86@5697ebbe` (PR #1130, `9a52ad5c`/`64c69123` solo en `test`). `HUB_*` están en l.66-67 y en `.env.test.example:54-55`. `git grep AGROFUSION_HUB origin/test -- '*.py'` sale vacío. `SGPMP_ENTORNO` no aparece en el compose de TEST y el código toma `"DEV"` (`configuracion.py:18`). |
| CA-5 llegada a `main` | NO VERIFICABLE AÚN | El release BE #941 sigue `OPEN`. `0dbe294`, `9ff4d38` y `9a52ad5c` no están en `main`. |
| CA-6 ficha y prueba por entorno | Parcial: DEV CUMPLE; TEST/PROD NO VERIFICABLE AÚN (Despliegue y release) | Curl de hoy a las 13:09 -05: `api-sgpmp-dev` → 401 `SSO_TOKEN_INVALIDO`; `api-sgpmp-test` → 503 `SSO_NO_CONFIGURADO`; `sigab` → 503. La ficha existe, pero **no menciona los permisos `644`** que exige el CA-6 (obs. O-1). No hay constancia de que se haya enviado. |
| CA-7 catálogo | CUMPLE | Tres filas SSO corregidas (SIGAB-*, la nota de `ISSUER` vacía, desviación DEV, `sesiones_routers.py:172@2b9ee221`/`166@main`, ambas verificadas) y filas nuevas. Todas las citas de código coinciden: `configuracion.py:18,20-22`, `Dockerfile:72`/`:66`, `middlewares.py:33`, FE `vite.config.ts:14`, `Dockerfile:13,45`, `docker-compose.yml:9`, `docker-compose.test.yml:11`, `.env.example:36`, `9c278e32`. |
| CA-8 fecha de corte | CUMPLE (para esta documentación) | Hashes reverificados hoy, idénticos a los citados. |

## 3. Verificación de afirmaciones (muestra contrastada)

| Afirmación | Dónde | Resultado |
|---|---|---|
| Tabla commit × rama (`0dbe294`, `9ff4d38`, `9a52ad5c`, FE `d688fd9d`) | `historia.md:14-19`, VERIF §1 | Vigente |
| `AGROFUSION_HUB_*` en uso solo en `main` (`main.py:671`, `agrofusion_auth.py:19-20`) | catálogo, ficha §5, INC-IMP-06 | Vigente |
| `ISSUER` vacía no cubierta por `os.getenv`; la resuelve `:-` del compose (dev l.78, prod l.152; test l.65; main prod l.148, main dev-compose l.72 sin default) | catálogo, informe `9ff4d38` | Vigente |
| `ssoConfigurado`/`agrofusionLoginUrl` no importados en ninguna rama | INC-FE-01, catálogo | Vigente (`git grep` sobre `config/sso` sin resultados en las tres ramas) |
| FE `main` sin ruta `/sso` (`App.tsx:361`); `dev` en l.367 | INC-IMP-06 | Vigente |
| `SsoCallbackPage.tsx:21` lee `token` | INC-FE-01 | Vigente (`src/auth/pages/SsoCallbackPage.tsx`) |
| CORS TEST 400 sin ACAO; DEV y PROD 200 con `https://inmero.co` | INC-BE-08 | Vigente (curl hoy) |
| `inmero.co/sigab-test/` = PROD (mismo ETag) | INC-FE-05 | Vigente (`ETag "6af520df-f63"` en los dos) |
| `back-sigab-dev/test` → 404 | INC-BE-03 | Vigente |
| PR #1129/#1130 fusionados el 2026-11-14 sin reviews; #1051 fusionado | informes /impacto | Vigente (`gh pr view`) |
| SHA-256 de los cuatro PDF | VERIF §1 | Vigente |
| "TEST sin File Mount ni variables en Dokploy" | `historia.md:23`, catálogo l.338 | **Sin fuente** para el File Mount: un 503 solo prueba que faltan variables (obs. O-5) |

## 4. Hallazgos

### Bloqueantes
Ninguno.

### No bloqueantes

| ID | Sev. | Dónde | Hallazgo | Corrección sugerida |
|---|---|---|---|---|
| O-1 | Media | `registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md` (§2, l.25 o l.43) vs `historia.md:36` (CA-6) | El CA-6 exige que la ficha incluya "permisos `644`", y la ficha no los menciona (`grep 644` sin resultados). | Agregar al paso 3: "archivo con permisos `644` (legible por UID 1000)". |
| O-2 | Media | `historia.md:121` (Notas, "Brief 2: listo… El PR a `test` crea el bloque `volumes:`") | Contradice la ST-02 reescrita y la nota del brief-02. | Marcar como histórico o remitir a ST-02 (2026-11-17). Revisar también `historia.md:119` ("Plazo sugerido… antes del 2026-11-12"), que ya venció. |
| O-3 | Media | `historia.md:36` y `:48` (CA-6, `echo LEGIBLE`) vs ficha l.48 (`echo ARCHIVO-LEGIBLE`) | Hay dos cadenas esperadas para la misma prueba. Además, CA-6 y ficha l.84 piden "`code`", pero la respuesta real trae el campo `error_code`. | Unificar la cadena (p. ej. `ARCHIVO-LEGIBLE` en los dos lados) y escribir `error_code`. Sugerencia: añadir `-w ' HTTP%{http_code}\n'` al curl de la ficha (l.36) para que la evidencia muestre el código HTTP. |
| O-4 | Menor | Ficha l.15 (`SGPMP_ENTORNO` "Sí en TEST") vs CA-4 (`${SGPMP_ENTORNO:-TEST}`) vs informe PR1130 l.84 ("opcional por el default") | Con el default de CA-4, la variable deja de ser obligatoria en TEST. También queda abierta la pregunta P4 de VERIF §7 (`:-TEST` o `:?`), sin decisión registrada aunque CA-4 ya fija `:-TEST`. | Registrar la decisión del líder (fecha) en las Notas y alinear la ficha. Alinear también `SGPMP_ENTORNO=TEST` "activa" (CA-4) frente a "comentada" (informe PR1130 l.81). |
| O-5 | Menor | `historia.md:23` ("Sin File Mount ni variables en Dokploy"), `VARIABLES-ENTORNO.md:338` | Implementación no puede ver el File Mount de TEST/PROD. El 503 solo prueba que faltan variables. La ficha l.64 sí lo dice bien ("sin variables"). | "Sin variables SSO en el contenedor (503); File Mount por confirmar con Despliegue". |
| O-6 | Menor | `historia.md:108` (ST-05) | ST-05 no tiene el aviso "NO se aplica hoy" que sí tiene ST-02, y su Verificación no cita ningún CA (`hu-taiga` §3). | Copiar el aviso de ST-02 y referenciar CA-3. |
| O-7 | Menor | `VARIABLES-ENTORNO.md:99` (`VITE_BASE_PATH`, "T5 de HU-IMP-CFG-03") | T5 no es una subtarea de CFG-03 (la historia solo incorpora T1 y T2). La referencia no lleva a ningún sitio. | Cambiar por "T5 de `VERIF-DOC-agrofusion.md` (sin HU)" o abrir la HU correspondiente. |
| O-8 | Menor | `registros/incidencias/registro.md:9` (INC-FE-01 "cerrada sin impacto") y `:19` (INC-BE-06 "resuelto del lado de Implementación") | Son estados fuera del vocabulario del propio registro (`detectado → diagnosticado → derivado/en HU → resuelto → verificado`). La columna Entorno de INC-BE-06 sigue diciendo "DEV" aunque ahora cubre TEST/PROD. INC-BE-08 quedó antes de INC-BE-07. | INC-FE-01 → `verificado` (sin impacto) o `derivado (Desarrollo)`. INC-BE-06 → `en HU (HU-IMP-CFG-03)` / `derivado (Despliegue)`, con el detalle en la nota. Reordenar. |
| O-9 | Menor | `commits/BACK-9ff4d38_…/analisis.md:79,104,106` y `prs/BACK-PR1130_…/analisis.md:84,94` | Quedaron frases desactualizadas al pasar a la fase 2: "Ningún frontend vive en `inmero.co/<prefijo>`" (falso según el curl de VERIF §2), "falta la fila en README" (ya está) y "`test -r` posterior" (la ficha lo reemplaza por `test -f`). VERIF-DOC l.112 dice lo mismo sobre el README. | Añadir a cada informe una línea "Actualización 2026-11-17" que remita a VERIF §8, a la ficha y a la fila del README. El análisis original no se reescribe. |
| O-10 | Menor | `brief-01-pr-dev.md:13` | Sigue diciendo "El código ya usa `agrofusion-auth` si viene vacía", lo que el catálogo corrigió (hallazgo 10 de VERIF). Además, el bloque de código l.86 se editó, así que ya no refleja lo que se commiteó en `0dbe294`. | Extender la nota de corrección a la frase de `ISSUER`. Valorar dejar el bloque l.86 como estaba, con la nota encima: es texto histórico. |
| O-11 | Menor | `entregas/E3_…/README.md:10` ("ficha ST-04 entregada") | No hay constancia del envío a Despliegue. La historia (ST-04 paso 1) lo deja como pendiente. | "ficha ST-04 redactada; envío a Despliegue pendiente" (o la fecha de envío, si ya se hizo). |
| O-12 | Info (decisión del líder) | `evidencias/fuentes-desarrollo-2026-11-14/05_Documento_despliegue.pdf` (§4.1) | El PDF archivado trae la clave pública completa. No es un secreto (el propio doc. 05 §9.3 lo dice), pero choca con el criterio de "solo origen y huella" si el PDF se commitea. No pude revisar las figuras (capturas) del PDF en busca de valores: no hay renderizador. | Decidir si los PDF entran al repo. Antes del commit, revisar visualmente la Figura 2 del doc. 05 (registro del canal) y las del doc. 01/02. |
| O-13 | Info (proceso) | Árbol de trabajo | Hay archivos sin seguimiento ajenos a la HU: `.claude/` (memoria de agentes), `entregas/E2_*/motor_ia/` y `entregas/E2_*/prs/`, además de los README de E2 y de `entregas/`. | Hacer `git add` selectivo por ruta; no usar `git add -A`. |

## 5. Comprobaciones de seguridad y alcance

- `grep -rnE 'MIIB|BEGIN (PUBLIC|PRIVATE)'` sobre los `.md` de E3 y de `registros/`: sin resultados. La huella aparece truncada (`9d99cf66b629bbf7…`) en VERIF l.35 y en la ficha l.6, junto con su origen `a50cc0b`. Bien.
- `git diff HEAD -- registros/seguridad/registro-SEG.md entregas/E1_2026-10-13_M01-M09-M02`: sin cambios. `PI4/CLAUDE.md`: mtime 2026-10-23. `PI4/.claude/`: ningún archivo modificado hoy.
- Ningún cambio en `sgpmp-backend` ni en el frontend (solo lectura).
- VERIF §9 (nota para Análisis): nombra los archivos donde AgroFusion guarda sus secretos, no sus valores. Deja la decisión a Análisis. Correcto.

## 6. Borrador de comentario para el PR #18

> Gracias por la actualización. Comprobé las afirmaciones contra el código (corte BE `2b9ee221`/`5697ebbe`/`0abbeeef`, FE `601d5a84`/`247b1183`/`fe88f82d`) y contra los entornos (curl 2026-11-17 13:09: DEV 401, TEST 503, PROD 503; CORS TEST 400). Todo coincide: la tabla de commits por rama, las líneas citadas, el uso de `AGROFUSION_HUB_*` solo en `main`, `VITE_AGROFUSION_LOGIN_URL` sin uso y `VITE_BASE_PATH`. No hay secretos ni texto de la clave.
>
> Antes del commit, propongo estos ajustes:
> 1. **Ficha, §2 paso 3:** añadir "permisos `644`". El CA-6 lo exige y hoy no aparece.
> 2. **`historia.md:121`:** la nota "Brief 2: listo… crea el bloque `volumes:`" contradice la ST-02 nueva. Marcarla como histórica. La de l.119 (plazo 2026-11-12) también.
> 3. **CA-6 / ficha:** unificar `LEGIBLE` / `ARCHIVO-LEGIBLE` y escribir `error_code` (es el campo real de la respuesta). Conviene añadir `-w ' HTTP%{http_code}\n'` al curl.
> 4. Menores: ST-05 con el aviso "no se aplica hoy" y su CA. "Sin File Mount" en TEST → "sin variables (503); File Mount por confirmar". "T5 de CFG-03" en el catálogo. Estados de INC-FE-01/INC-BE-06 según el vocabulario del registro. Una línea de actualización en los dos informes /impacto. "Ficha entregada" → "redactada" si aún no se envió.
>
> Para comprobarlo: `grep -n 644 registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md` y `grep -n LEGIBLE` sobre la ficha y la historia.
