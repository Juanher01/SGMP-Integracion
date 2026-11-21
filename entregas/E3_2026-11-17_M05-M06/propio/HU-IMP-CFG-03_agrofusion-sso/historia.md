# HU-IMP-CFG-03 — El backend monta la clave pública del SSO de AgroFusion en DEV, TEST y PROD y la imagen no incluye claves

## Para copiar en Taiga — Descripción de la HU

**Rama:** `chore/agrofusion-sso-clave-publica` → PR a `dev` · rama desde `origin/test` → PR a `test` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo (ST-01 la ejecutó el líder) · **Revisa:** Sebastián Sandoval · **Entrega:** E3 · **Módulos:** M01 (identidad y acceso, SSO RF-02) · M07 (integración AgroFusion)

**Origen.** Solicitud del líder de Desarrollo: dejar configuradas las variables del SSO con AgroFusion en `Arekkazu/sgpmp-backend` · Fecha: 2026-11-07 · Tipo de flujo: cambio de configuración (Camino B, flujo 1).

**Situación actual.** Corte original: `git fetch` del 2026-11-09. El código lee `AGROFUSION_SSO_PUBLIC_KEY_PATH`, `AGROFUSION_PROJECT_CODE` y `AGROFUSION_ISSUER` (`src/identity_access/infrastructure/adapters/agrofusion_sso_adapter.py:35-37`) y abre el archivo de la ruta con `open()`. Si no puede leerlo (o la ruta es una carpeta), responde 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE` (línea 53). `POST /sesiones/sso` responde 503 `SSO_NO_CONFIGURADO` si falta la ruta o el código (`sesiones_routers.py:172@2b9ee221`; l.166 en `main@0abbeeef`). Al 2026-11-09 las variables ya estaban en los compose y en las plantillas, pero **ningún compose montaba el `.pem`**, `.dockerignore` no excluía `*.pem` ni `*.key`, y el Dockerfile hace `COPY . .`.

**Actualización — corte 2026-11-17** (`git fetch`; BE `dev@2b9ee221`, `test@5697ebbe`, `main@0abbeeef`; FE `dev@601d5a84`, `test@247b1183`, `main@fe88f82d`; detalle en `revisiones/VERIF-DOC-agrofusion.md`):

| Commit | dev | test | main |
|---|---|---|---|
| `0dbe294` (Implementación, PR #1051: montaje en DEV/PROD y `.dockerignore`) | sí | sí | no |
| `9ff4d38` (Desarrollo, PR #1129: `${AGROFUSION_ISSUER:-agrofusion-auth}` y códigos SIGAB en `.env.example`) | sí | sí | no |
| `9a52ad5c` (Desarrollo, PR #1130, merge `64c69123`: montaje en `docker-compose.test.yml`) | no | sí | no |
| FE `d688fd9d` (ruta `/sso`) | sí | sí | no |

| Rama / entorno | Estado | Evidencia |
|---|---|---|
| dev / DEV | ✅ Montaje en `docker-compose.yml:109` y `docker-compose.prod.yml:189`; `.dockerignore` con `**/*.pem` y `**/*.key`; `SGPMP_ENTORNO` `${…:-DEV}` (l.79). Pendiente: `.env.prod.example:235` sigue diciendo `SGPMP-DEV` (ST-05). Desplegado con la **desviación temporal** de Dokploy (`…/agrofusion_sso_public.pem/clave.pem`, doc. 05 §4.3) | `origin/dev` `2b9ee221`; curl `POST api-sgpmp-dev/sesiones/sso` → **401 `SSO_TOKEN_INVALIDO`** |
| test / TEST | ⚠️ Montaje en `docker-compose.test.yml:86` (PR #1130). Faltan `SGPMP_ENTORNO` (TEST se identifica como `DEV`) y el retiro de `AGROFUSION_HUB_*` (l.66-67 y `.env.test.example`), que el código de `test` no lee (ST-02). Sin variables SSO en el contenedor (503); File Mount por confirmar con Despliegue. CORS rechaza `https://inmero.co` | `origin/test` `5697ebbe`; curl → **503 `SSO_NO_CONFIGURADO`** |
| main / PROD | ❌ Sin montaje; `AGROFUSION_HUB_*` **en uso** (`main.py:671`, `src/shared/agrofusion_auth.py:19-20`); el FE no tiene la ruta `/sso`. Llega con el release (BE PR #941) y el del FE (INC-IMP-06) | `origin/main` `0abbeeef`; curl `POST sigab/sesiones/sso` → **503** |

**Descripción.** El backend de cada entorno debe encontrar la clave pública RS256 de AgroFusion en `/app/secrets/agrofusion_sso_public.pem`, montada como solo lectura desde el *File Mount* de Dokploy (`../files/agrofusion_sso_public.pem`). Se sigue el patrón que ya existe para `firebase.json`. La ruta sigue saliendo de la variable: sin valor, el SSO queda en 503 y el backend no se cae. Además, ninguna clave o certificado del contexto de construcción entra a la imagen.

**Alcance.** `docker-compose.yml`, `docker-compose.prod.yml`, `docker-compose.test.yml` (solo en `test`), `.env.example`, `.env.prod.example`, `.env.test.example` (solo en `test`; además se quitan `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET`, que el código de `test` ya no lee desde RF-101), `.dockerignore` (solo en `dev`; llega a `test` cuando Desarrollo fusiona `dev` en `test`). Catálogo de variables en `SGMP-Integracion`. · **Fuera de alcance:** código de aplicación (Desarrollo). Subir el `.pem` y cargar los valores en Dokploy (Despliegue). Emitir y registrar el código de proyecto en AgroFusion (Desarrollo). Alinear otras variables o volúmenes entre compose (PR aparte).

**Criterios de aceptación.**
1. CA-1 En `dev`, el servicio `backend` de `docker-compose.yml` y de `docker-compose.prod.yml` declara `../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro`, y los dos compose son válidos.
2. CA-2 En `dev`, `.dockerignore` excluye `**/*.pem` y `**/*.key`, y una imagen construida con un `.pem` de prueba en la raíz y un `.key` de prueba en una subcarpeta no contiene ninguno de los dos.
3. CA-3 `.env.example` y `.env.prod.example` explican que la variable es una ruta a un archivo montado, sin valores reales (`AGROFUSION_PROJECT_CODE` vacía).
4. CA-4 En `test`, el `backend` de `docker-compose.test.yml` conserva el montaje que ya agregó Desarrollo (PR #1130; el PR de Implementación **no** lo vuelve a crear), pasa `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}` (misma forma que en DEV y PROD), y el compose es válido. `.env.test.example` explica las variables sin valores reales e incluye `SGPMP_ENTORNO=TEST`. `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` ya no aparecen en `docker-compose.test.yml` ni en `.env.test.example`, previa confirmación con `git grep` de que el código de `test` no las usa. El PR a `test` no toca `.dockerignore`. *(Redacción revisada 2026-11-17.)*
5. CA-5 Cuando el cambio llega a `main` (con el release o por PR dirigido), `git merge-base --is-ancestor` o `git show origin/main:<archivo>` lo confirma.
6. CA-6 Despliegue recibió la ficha (`registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md`) con el orden de pasos (File Mount antes del primer Deploy, ruta, código por entorno, Deploy y no Restart, permisos `644`). En cada entorno desplegado, la **prueba principal** (doc. 05 §8) `curl -X POST {API}/sesiones/sso -H "Content-Type: application/json" -d '{"sso_token":"x"}'` responde **401 `SSO_TOKEN_INVALIDO`** (503 = faltan variables; 500 = clave no montada o ruta que es carpeta). El código viaja en el campo `error_code` del cuerpo (`src/shared/error_handlers.py:65@6cee5fc4`; l.54 en `main@0abbeeef`). Complementaria (la misma orden de la ficha §2): `docker exec <backend> sh -c 'test -f "$AGROFUSION_SSO_PUBLIC_KEY_PATH" && test -r "$AGROFUSION_SSO_PUBLIC_KEY_PATH" && echo ARCHIVO-LEGIBLE'` responde `ARCHIVO-LEGIBLE` (`test -r` solo no basta: da verdadero sobre una carpeta).
7. CA-7 `registros/variables/VARIABLES-ENTORNO.md` cataloga las tres variables (Backend; Autenticación / Seguridad; sensibilidad según el brief).
8. CA-8 Fecha de corte: el estado de `dev`, `test` y `main` citado en cada PR se reverifica con `git fetch` el día en que se abre.

**Verificación.**
| CA | Método (comando o prueba) | Resultado esperado | Evidencia a adjuntar |
|---|---|---|---|
| CA-1 | `docker compose -f <compose> config --no-interpolate --quiet` y `... config --no-interpolate \| grep -n agrofusion_sso_public` | `DEV-OK`/`PROD-OK`, código 0. El `target` aparece solo en `backend` | `evidencias/01-compose-config.txt`, `evidencias/02-montaje-declarado.txt` |
| CA-2 | `docker build` con `zz_prueba_dockerignore.pem` (raíz) y `zz_prueba_dir/zz_prueba.key` (subcarpeta) + `docker run ... ls` de cada uno | Los dos `ls` fallan (código ≠ 0) | `evidencias/03-dockerignore-build.txt` |
| CA-3 | `git diff origin/dev -- .env.example .env.prod.example` | Solo comentarios y la fila de la tabla de cambios | Diff en el PR |
| CA-4 | Los mismos comandos de CA-1 sobre `docker-compose.test.yml`; `... config --no-interpolate \| grep -n SGPMP_ENTORNO`; `git grep -n AGROFUSION_HUB -- src main.py`, `grep -n AGROFUSION_HUB docker-compose.test.yml .env.test.example` y `git diff --stat` | `TEST-OK`, código 0; montaje (ya existente) solo en `backend`; `SGPMP_ENTORNO` en `backend`; sin `AGROFUSION_HUB` en código ni en los dos archivos; dos archivos en el diff | `evidencias/test-*.txt` |
| CA-5 | `git merge-base --is-ancestor <commit> origin/main; echo $?` | `0` | Salida pegada |
| CA-6 | Principal: `curl -X POST {API}/sesiones/sso -H "Content-Type: application/json" -d '{"sso_token":"x"}'` (Implementación o Despliegue). Complementaria: `docker exec ... test -f && test -r` (Despliegue) | 401 `SSO_TOKEN_INVALIDO` en cada entorno; `ARCHIVO-LEGIBLE` | Salida del curl (código HTTP y `error_code`) y respuesta de Despliegue. Al 2026-11-17: DEV 401, TEST 503, PROD 503 |
| CA-7 | `git diff -- registros/variables/VARIABLES-ENTORNO.md` | Tres filas nuevas | Diff |
| CA-8 | `git fetch origin && git rev-parse --short origin/{dev,test,main}` | Hashes del día | En la descripción del PR |

**Definición de terminado.**
- [ ] Todos los CA verificados con evidencia adjunta en la HU.
- [ ] PR abierto con descripción que enlaza esta HU y el origen.
- [ ] PR aprobado y fusionado por el líder que corresponde a la rama.
- [ ] Registro actualizado en `SGMP-Integracion/registros/variables/VARIABLES-ENTORNO.md`.

**Dependencias y aprobaciones.** PR a `dev`: Líder de Desarrollo. PR a `test`: Líder de Pruebas. `main`: Líder de Despliegue, con el release. Despliegue sube el `.pem` y carga `AGROFUSION_SSO_PUBLIC_KEY_PATH` y `AGROFUSION_PROJECT_CODE` en Dokploy. Desarrollo entrega el `.pem` y el código de proyecto de cada entorno.

**Riesgos.** (1) Si se despliega sin subir el archivo, Docker crea una **carpeta** `../files/agrofusion_sso_public.pem`, y el SSO da 500 cuando se cargue la ruta. Mitigación: subir el archivo antes y, si la carpeta ya existe, borrarla. Variante observada en DEV (doc. 05 §4.3): Dokploy v0.30.7 no reemplaza la carpeta vacía, falla sin avisar y da el despliegue por exitoso; sin acceso SSH se aplicó la desviación temporal (File Path `agrofusion_sso_public.pem/clave.pem`, ruta `/app/secrets/agrofusion_sso_public.pem/clave.pem`), que se revierte cuando se borre la carpeta o Dokploy pase a v0.31.0 o posterior. (2) Un `.pem` sin permiso de lectura para UID 1000 da 500. Se detecta con el curl de CA-6 (500) y se confirma con `test -f && test -r` (ficha §2). (3) `docker-compose.test.yml` y `.env.test.example` solo existen en `test`, así que el PR dirigido no choca con el merge de `dev` en `test`. Si hubiera conflicto en alguna tabla de cambios, se conservan las filas de ambos lados.

**Referencias.** `Arekkazu/sgpmp-backend` commit `0dbe294` (rama `chore/agrofusion-sso-clave-publica`). `agrofusion_sso_adapter.py:35-53`. `sesiones_routers.py:146-174`. `brief-01-pr-dev.md`, `brief-02-pr-test.md` (en esta carpeta).

## Para copiar en Taiga — Subtareas

### ST-01 abrir PR `chore/agrofusion-sso-clave-publica` hacia `dev`
**Objetivo.** Montar la clave pública en los compose de DEV y PROD y excluir claves de la imagen.
**Pasos.**
1. Rama desde `origin/dev`. Cambios en los cinco archivos (`brief-01-pr-dev.md`).
2. Verificar (paso 6 del brief) y guardar las salidas en `evidencias/`.
3. Commit, push y PR con `entregables/PR-dev.md`.
**Entregable.** PR a `dev`. Evidencias `01` a `04`.
**Verificación.** `docker compose ... config` OK, montaje solo en `backend`, `.pem` de prueba ausente en la imagen (CA-1, CA-2, CA-3).
**Estimación.** 2 h. Estado: commit `0dbe294` verificado (evidencias `01` a `04`). PR abierto el 2026-11-09: [Arekkazu/sgpmp-backend#1051](https://github.com/Arekkazu/sgpmp-backend/pull/1051) hacia `dev`, pendiente de aprobación del Líder de Desarrollo. Corte 2026-11-17: `0dbe294` está en `dev` y en `test` (no en `main`).

### ST-02 abrir PR hacia `test`: `SGPMP_ENTORNO`, retiro de `AGROFUSION_HUB_*` y plantilla
> **Trasladada a HU-IMP-CFG-04 (2026-11-20).** `SGPMP_ENTORNO` lo corrige Desarrollo en Arekkazu/sgpmp-backend#1204; el retiro de `AGROFUSION_HUB_*` y la plantilla pasan a ST-04a (plantilla) y ST-04c (compose; renumerada el 2026-11-21) de [HU-IMP-CFG-04](../../../E4_2026-11-24_M07-M08-final/issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/historia.md). Esta subtarea no se ejecuta en CFG-03.

> **Reescrita el 2026-11-17 (T2 de `revisiones/VERIF-DOC-agrofusion.md`). NO se aplica hoy:** queda lista para ejecutar después de la presentación del 2026-11-17, con aprobación del líder. El paso 3.1 de `brief-02-pr-test.md` quedó obsoleto.

**Objetivo.** Completar la configuración de TEST que el PR #1130 de Desarrollo no cubrió: identificar el entorno como `TEST`, retirar variables que el código de `test` ya no lee y documentar la plantilla.
**Pasos.**
1. Rama desde `origin/test` actualizado (`chore/agrofusion-sso-compose-test`). Reverificar con `git fetch` (CA-8).
2. **No volver a montar la clave:** el montaje ya está en `docker-compose.test.yml:86@5697ebbe` (PR #1130, idéntico a `0dbe294`). No tocar el bloque `volumes:` ni `.dockerignore`.
3. `docker-compose.test.yml`, servicio `backend`, `environment:`: agregar `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}` justo después de `AGROFUSION_ISSUER`, con la misma forma que DEV (`docker-compose.yml:79` `${SGPMP_ENTORNO:-DEV}`) y PROD (`docker-compose.prod.yml:153` `${SGPMP_ENTORNO:-PROD}`)@2b9ee221. Quitar `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` (l.66-67), previa confirmación con `git grep -n AGROFUSION_HUB -- '*.py'` (vacío al 2026-11-17). Una fila en la tabla de cambios.
4. `.env.test.example`: quitar el bloque `# AgroFusion - integración M2M` (`AGROFUSION_HUB_*`); sobre las tres variables del SSO, el comentario de `.env.example:156-162@2b9ee221` (ruta montada; códigos `SIGAB-DEV`/`SIGAB-TEST`/`SIGAB` y ruta `https://inmero.co/{código en minúscula}/sso`; `agrofusion-auth` por defecto); agregar `SGPMP_ENTORNO=TEST` con el comentario de `.env.example:169`. Sin valores reales.
5. Verificar (CA-4), guardar `evidencias/test-*.txt`, `/revisar` y abrir el PR (aprueba el Líder de Pruebas). Avisar a Despliegue para que cargue `SGPMP_ENTORNO=TEST` y retire `AGROFUSION_HUB_*` de TEST (ficha §4).
**Entregable.** PR a `test`.
**Verificación.** CA-4.
**Estimación.** 2 h.

### ST-03 verificar la llegada del cambio a `main`
**Objetivo.** Confirmar que el release (o un PR dirigido) llevó el cambio a `main`.
**Pasos.**
1. `git fetch origin` y `git merge-base --is-ancestor <commit> origin/main` (o `git show origin/main:docker-compose.prod.yml | grep agrofusion_sso_public` si hubo cherry-pick).
2. Registrar el resultado en la HU.
**Entregable.** Salida pegada en `evidencias/main-llegada.txt`.
**Verificación.** CA-5.
**Estimación.** 2 h.

### ST-04 coordinar con Despliegue la carga del archivo y de las variables
**Objetivo.** Que cada entorno tenga el `.pem` montado y legible y las dos variables cargadas.
**Pasos.**
1. Enviar a Despliegue la ficha `registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md` (redactada el 2026-11-17): File Mount antes del primer Deploy, ruta, código por entorno (`SIGAB-DEV`/`SIGAB-TEST`/`SIGAB`), `SGPMP_ENTORNO`, Deploy y no Restart, desviación temporal de DEV, advertencia de no retirar `AGROFUSION_HUB_*` de PROD antes del lanzamiento, y los pendientes de TEST (frontend, regla `/sigab`, CORS) marcados como no urgentes antes de la presentación.
2. Probar `POST /sesiones/sso` con el curl de CA-6 en cada entorno: esperado 401 `SSO_TOKEN_INVALIDO`. Pedir a Despliegue, como complementaria, la salida de `test -f && test -r` (ficha §2).
**Entregable.** Ficha (creada), envío a Despliegue y su respuesta en `evidencias/`.
**Verificación.** CA-6. Estado 2026-11-17: DEV 401 (cumple, con desviación temporal); TEST 503 y PROD 503 (pendientes de Despliegue; PROD además del lanzamiento).
**Estimación.** 2 h.

### ST-05 corregir `.env.prod.example:235` (PR a `dev`) — pendiente
> **NO se aplica hoy** (T1 de `revisiones/VERIF-DOC-agrofusion.md`): queda lista para ejecutar con aprobación del líder.

**Objetivo.** T1 de `revisiones/VERIF-DOC-agrofusion.md`: la línea 235 de `.env.prod.example` (texto de Implementación, `0dbe294`) dice "DEV usa SGPMP-DEV; TEST y PROD usan el código con que se registre cada entorno" en `dev@2b9ee221` y `test@5697ebbe`.
**Pasos.**
1. Rama desde `origin/dev`. Reemplazar el comentario que dice «DEV usa SGPMP-DEV; TEST y PROD usan el código con que se registre cada entorno» (l.236@6cee5fc4 en `dev` y `test@135bc318`; era la l.235@2b9ee221) por el texto de `.env.example:159-161@2b9ee221` (códigos `SIGAB-DEV`, `SIGAB-TEST`, `SIGAB`; retorno a `https://inmero.co/{código en minúscula}/sso`). Una fila en la tabla de cambios. Sin valores.
2. `git diff` (solo comentarios), `/revisar` y PR a `dev` (aprueba el Líder de Desarrollo). `test` y `main` lo reciben por promoción o con el release (en `main` la línea aún no existe).
**Entregable.** PR a `dev`.
**Verificación.** CA-3: `git show origin/dev:.env.prod.example | grep -n SGPMP-DEV` sin coincidencias tras la fusión.
**Estimación.** 1 h.

## Notas para el líder

- **Plazo sugerido:** ST-01 y ST-02 antes del 2026-11-12, para que el SSO llegue a TEST dentro del ciclo de pruebas de E3 (2026-11-17). *(Histórico, 2026-11-09: plazo vencido. El estado vigente está en la Situación actual y en ST-02.)*
- **Número:** `CFG-01` y `CFG-02` ya están reservadas en planes de E2 (`BRK-PR35_compose-prod-broker/plan.md` y `HU-IMP-DOC-02/historia.md`), por eso esta es `CFG-03`. Confirmar que no choca con la numeración de Taiga.
- **Brief 2:** listo (`brief-02-pr-test.md`). El PR a `test` crea el bloque `volumes:` del `backend` **solo** con el montaje del `.pem`; Firebase (`firebase.json`) y `sgpmp_modelos` van en el PR de alineación de compose, por decisión del líder (2026-11-07). El brief 2 delega el cambio en el subagente `contenedores` y pasa por `/revisar` antes del push. *(Histórico, 2026-11-09. Desde el 2026-11-17 el PR a `test` no crea `volumes:`: el montaje lo agregó Desarrollo en el PR #1130. Ver ST-02.)*
- **Pendiente sobre ST-01:** ejecutar `/revisar HU-IMP-CFG-03` sobre el PR #1051 (dictamen en `revisiones/`) y pedir al subagente `entornos` la ficha para Despliegue. *(Histórico, 2026-11-09. El PR #1051 ya se fusionó y la ficha existe: `registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md`.)*
- **Patrón de `.dockerignore`:** el brief fijaba `*.pem`/`*.key`, que solo excluyen archivos en la **raíz** del contexto (`.dockerignore` no sigue la sintaxis de `.gitignore`). El líder aprobó `**/*.pem` y `**/*.key` (amend, commit `0dbe294`). Verificado con un `.pem` en la raíz y un `.key` en una subcarpeta (`evidencias/03-dockerignore-build.txt`). El PR a `test` **no** toca `.dockerignore`: el cambio llega a `test` cuando Desarrollo fusiona `dev` en `test`. El brief 2 solo modifica `docker-compose.test.yml` y `.env.test.example`.
- **Atribución del commit:** el brief pedía las líneas de atribución habituales, pero la regla 8 del `CLAUDE.md` de PI4 las prohíbe. El commit `0dbe294` va sin atribución.
- **Revisión:** comprobar que la tabla de cambios de cada archivo tenga una sola fila nueva y que `.env.*.example` no tenga valores.
- **Mensaje sugerido a Desarrollo:** "El compose ya monta `/app/secrets/agrofusion_sso_public.pem` (PR a `dev`). Necesitamos que entreguen a Despliegue el `.pem` y el `AGROFUSION_PROJECT_CODE` de TEST y PROD; DEV ya está identificado." *(Histórico, 2026-11-09. Al 2026-11-17 el origen de la clave y los códigos `SIGAB-*` están en el doc. 05 de Desarrollo; falta que Desarrollo registre `SIGAB-TEST` y `SIGAB` en AgroFusion.)*
- **Actualización 2026-11-17:** ficha para Despliegue creada; ST-02 reescrita (sin montaje) y ST-05 agregada (T1). INC-BE-06 en HU (HU-IMP-CFG-03) y derivada a Despliegue; INC-FE-01 derivada a Desarrollo, sin impacto; nuevas INC-FE-05, INC-BE-08 e INC-IMP-06 (`registros/incidencias/registro.md`).
- **`SGPMP_ENTORNO` en TEST (P4 de `revisiones/VERIF-DOC-agrofusion.md` §7):** CA-4 fija `${SGPMP_ENTORNO:-TEST}`, la misma forma que DEV y PROD. Con ese default la variable no es obligatoria en Dokploy (ficha §1). Decisión del líder, 2026-11-20: `:-TEST`, por paridad con `dev` (`:-DEV` y `:-PROD`) y con el PR Arekkazu/sgpmp-backend#1204.
- **Reverificado 2026-11-20:** BE `dev@6cee5fc4`, `test@135bc318`, `main@0abbeeef`. El contenido sigue vigente. `d417c0c6` (Desarrollo, 2026-11-19) desplaza una línea las citas de `dev`: el montaje está hoy en `docker-compose.yml:111` y `docker-compose.prod.yml:191`, y el comentario de ST-05 en `.env.prod.example:236`.

---
Actualizada: 2026-11-17 (corte BE `2b9ee221`/`5697ebbe`/`0abbeeef`, FE `601d5a84`/`247b1183`/`fe88f82d`; `revisiones/VERIF-DOC-agrofusion.md`) · Redactada: 2026-11-09 · Fuentes: `Arekkazu/sgpmp-backend` `origin/dev` `3251d78d`, `origin/test` `1e9b9451`, `origin/main` `0abbeeef`, commit `0dbe294` · Brief: `brief-01-pr-dev.md`
