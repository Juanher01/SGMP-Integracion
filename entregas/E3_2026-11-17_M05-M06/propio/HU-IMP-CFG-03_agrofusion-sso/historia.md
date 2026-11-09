# HU-IMP-CFG-03 — El backend monta la clave pública del SSO de AgroFusion en DEV, TEST y PROD y la imagen no incluye claves

## Para copiar en Taiga — Descripción de la HU

**Rama:** `chore/agrofusion-sso-clave-publica` → PR a `dev` · rama desde `origin/test` → PR a `test` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo (ST-01 la ejecutó el líder) · **Revisa:** Sebastián Sandoval · **Entrega:** E3 · **Módulos:** M01 (identidad y acceso, SSO RF-02) · M07 (integración AgroFusion)

**Origen.** Solicitud del líder de Desarrollo: dejar configuradas las variables del SSO con AgroFusion en `Arekkazu/sgpmp-backend` · Fecha: 2026-11-07 · Tipo de flujo: cambio de configuración (Camino B, flujo 1).

**Situación actual.** Corte: `git fetch` del 2026-11-09. El código lee `AGROFUSION_SSO_PUBLIC_KEY_PATH`, `AGROFUSION_PROJECT_CODE` y `AGROFUSION_ISSUER` (`src/identity_access/infrastructure/adapters/agrofusion_sso_adapter.py:35-37`) y abre el archivo de la ruta con `open()`. Si no puede leerlo, responde 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE` (línea 53). `POST /sesiones/sso` responde 503 `SSO_NO_CONFIGURADO` si falta la ruta o el código (`sesiones_routers.py:170`). Las variables ya están en los compose y en las plantillas, pero **ningún compose monta el `.pem`**. Además, `.dockerignore` no excluye `*.pem` ni `*.key`, y el Dockerfile hace `COPY . .`.

| Rama | Estado | Evidencia |
|---|---|---|
| dev | ⚠️ Variables en `docker-compose.yml` y `docker-compose.prod.yml`. Sin montaje del `.pem` y sin exclusión de claves en `.dockerignore`. Corrección lista en `0dbe294` (rama `chore/agrofusion-sso-clave-publica`, PR #1051 abierto hacia `dev`) | `origin/dev` `3251d78d` |
| test | ❌ `docker-compose.test.yml` pasa las tres variables (líneas 62-64), pero el `backend` **no tiene bloque `volumes:`**. `.dockerignore` sin `*.pem`/`*.key` | `origin/test` `1e9b9451` |
| main | ❌ Sin montaje en `docker-compose.yml` ni en `docker-compose.prod.yml`. `.dockerignore` sin `*.pem`/`*.key` | `origin/main` `0abbeeef` |

**Descripción.** El backend de cada entorno debe encontrar la clave pública RS256 de AgroFusion en `/app/secrets/agrofusion_sso_public.pem`, montada como solo lectura desde el *File Mount* de Dokploy (`../files/agrofusion_sso_public.pem`). Se sigue el patrón que ya existe para `firebase.json`. La ruta sigue saliendo de la variable: sin valor, el SSO queda en 503 y el backend no se cae. Además, ninguna clave o certificado del contexto de construcción entra a la imagen.

**Alcance.** `docker-compose.yml`, `docker-compose.prod.yml`, `docker-compose.test.yml` (solo en `test`), `.env.example`, `.env.prod.example`, `.env.test.example` (solo en `test`; además se quitan `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET`, que el código de `test` ya no lee desde RF-101), `.dockerignore` (solo en `dev`; llega a `test` cuando Desarrollo fusiona `dev` en `test`). Catálogo de variables en `SGMP-Integracion`. · **Fuera de alcance:** código de aplicación (Desarrollo). Subir el `.pem` y cargar los valores en Dokploy (Despliegue). Emitir y registrar el código de proyecto en AgroFusion (Desarrollo). Alinear otras variables o volúmenes entre compose (PR aparte).

**Criterios de aceptación.**
1. CA-1 En `dev`, el servicio `backend` de `docker-compose.yml` y de `docker-compose.prod.yml` declara `../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro`, y los dos compose son válidos.
2. CA-2 En `dev`, `.dockerignore` excluye `**/*.pem` y `**/*.key`, y una imagen construida con un `.pem` de prueba en la raíz y un `.key` de prueba en una subcarpeta no contiene ninguno de los dos.
3. CA-3 `.env.example` y `.env.prod.example` explican que la variable es una ruta a un archivo montado, sin valores reales (`AGROFUSION_PROJECT_CODE` vacía).
4. CA-4 En `test`, el `backend` de `docker-compose.test.yml` declara el mismo montaje (crea el bloque `volumes:`), el compose es válido y `.env.test.example` explica las variables sin valores reales. `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` ya no aparecen en `docker-compose.test.yml` ni en `.env.test.example`, previa confirmación con `git grep` de que el código de `test` no las usa. El PR a `test` no toca `.dockerignore`.
5. CA-5 Cuando el cambio llega a `main` (con el release o por PR dirigido), `git merge-base --is-ancestor` o `git show origin/main:<archivo>` lo confirma.
6. CA-6 Despliegue recibió la ficha (`registros/variables/fichas/`) con el orden de pasos (archivo antes del despliegue, ruta, código por entorno, permisos `644`). En cada entorno desplegado, `docker exec <backend> sh -c 'test -r "$AGROFUSION_SSO_PUBLIC_KEY_PATH" && echo LEGIBLE'` responde `LEGIBLE`.
7. CA-7 `registros/variables/VARIABLES-ENTORNO.md` cataloga las tres variables (Backend; Autenticación / Seguridad; sensibilidad según el brief).
8. CA-8 Fecha de corte: el estado de `dev`, `test` y `main` citado en cada PR se reverifica con `git fetch` el día en que se abre.

**Verificación.**
| CA | Método (comando o prueba) | Resultado esperado | Evidencia a adjuntar |
|---|---|---|---|
| CA-1 | `docker compose -f <compose> config --no-interpolate --quiet` y `... config --no-interpolate \| grep -n agrofusion_sso_public` | `DEV-OK`/`PROD-OK`, código 0. El `target` aparece solo en `backend` | `evidencias/01-compose-config.txt`, `evidencias/02-montaje-declarado.txt` |
| CA-2 | `docker build` con `zz_prueba_dockerignore.pem` (raíz) y `zz_prueba_dir/zz_prueba.key` (subcarpeta) + `docker run ... ls` de cada uno | Los dos `ls` fallan (código ≠ 0) | `evidencias/03-dockerignore-build.txt` |
| CA-3 | `git diff origin/dev -- .env.example .env.prod.example` | Solo comentarios y la fila de la tabla de cambios | Diff en el PR |
| CA-4 | Los mismos comandos de CA-1 sobre `docker-compose.test.yml`; `git grep -n AGROFUSION_HUB -- src main.py`, `grep -n AGROFUSION_HUB docker-compose.test.yml .env.test.example` y `git diff --stat` | `TEST-OK`, código 0; montaje solo en `backend`; sin `AGROFUSION_HUB` en código ni en los dos archivos; dos archivos en el diff | `evidencias/test-*.txt` |
| CA-5 | `git merge-base --is-ancestor <commit> origin/main; echo $?` | `0` | Salida pegada |
| CA-6 | `docker exec ...` (lo ejecuta Despliegue) | `LEGIBLE` en cada entorno | Respuesta de Despliegue |
| CA-7 | `git diff -- registros/variables/VARIABLES-ENTORNO.md` | Tres filas nuevas | Diff |
| CA-8 | `git fetch origin && git rev-parse --short origin/{dev,test,main}` | Hashes del día | En la descripción del PR |

**Definición de terminado.**
- [ ] Todos los CA verificados con evidencia adjunta en la HU.
- [ ] PR abierto con descripción que enlaza esta HU y el origen.
- [ ] PR aprobado y fusionado por el líder que corresponde a la rama.
- [ ] Registro actualizado en `SGMP-Integracion/registros/variables/VARIABLES-ENTORNO.md`.

**Dependencias y aprobaciones.** PR a `dev`: Líder de Desarrollo. PR a `test`: Líder de Pruebas. `main`: Líder de Despliegue, con el release. Despliegue sube el `.pem` y carga `AGROFUSION_SSO_PUBLIC_KEY_PATH` y `AGROFUSION_PROJECT_CODE` en Dokploy. Desarrollo entrega el `.pem` y el código de proyecto de cada entorno.

**Riesgos.** (1) Si se despliega sin subir el archivo, Docker crea una **carpeta** `../files/agrofusion_sso_public.pem`, y el SSO da 500 cuando se cargue la ruta. Mitigación: subir el archivo antes y, si la carpeta ya existe, borrarla. (2) Un `.pem` sin permiso de lectura para UID 1000 da 500. Se detecta con el `test -r` de CA-6. (3) `docker-compose.test.yml` y `.env.test.example` solo existen en `test`, así que el PR dirigido no choca con el merge de `dev` en `test`. Si hubiera conflicto en alguna tabla de cambios, se conservan las filas de ambos lados.

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
**Estimación.** 2 h. Estado: commit `0dbe294` verificado (evidencias `01` a `04`). PR abierto el 2026-11-09: [Arekkazu/sgpmp-backend#1051](https://github.com/Arekkazu/sgpmp-backend/pull/1051) hacia `dev`, pendiente de aprobación del Líder de Desarrollo.

### ST-02 abrir PR del montaje hacia `test`
**Objetivo.** Llevar el mismo montaje a `docker-compose.test.yml` y documentar las variables en `.env.test.example`.
**Pasos.**
1. Rama desde `origin/test` (`brief-02-pr-test.md`).
2. Crear el bloque `volumes:` del `backend` en `docker-compose.test.yml` con el montaje. Actualizar `.env.test.example`. Quitar `AGROFUSION_HUB_*` de los dos archivos si `git grep` confirma que el código de `test` no las usa. No tocar `.dockerignore`: llega a `test` cuando Desarrollo fusiona `dev` en `test`.
3. Verificar como en ST-01, guardar `evidencias/test-*.txt` y abrir el PR.
**Entregable.** PR a `test`.
**Verificación.** CA-4.
**Estimación.** 3 h.

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
1. Enviar a Despliegue la ficha (orden: subir *File Mount* `agrofusion_sso_public.pem` antes del despliegue, `AGROFUSION_SSO_PUBLIC_KEY_PATH=/app/secrets/agrofusion_sso_public.pem`, `AGROFUSION_PROJECT_CODE` por entorno, permisos `644`).
2. Pedir la salida de `test -r` en cada entorno.
3. Probar `POST /sesiones/sso` y confirmar que ya no responde 503 ni 500 de configuración.
**Entregable.** Ficha en `registros/variables/fichas/` (subagente `entornos`), enviada a Despliegue, y su respuesta en `evidencias/`.
**Verificación.** CA-6.
**Estimación.** 2 h.

## Notas para el líder

- **Plazo sugerido:** ST-01 y ST-02 antes del 2026-11-12, para que el SSO llegue a TEST dentro del ciclo de pruebas de E3 (2026-11-17).
- **Número:** `CFG-01` y `CFG-02` ya están reservadas en planes de E2 (`BRK-PR35_compose-prod-broker/plan.md` y `HU-IMP-DOC-02/historia.md`), por eso esta es `CFG-03`. Confirmar que no choca con la numeración de Taiga.
- **Brief 2:** listo (`brief-02-pr-test.md`). El PR a `test` crea el bloque `volumes:` del `backend` **solo** con el montaje del `.pem`; Firebase (`firebase.json`) y `sgpmp_modelos` van en el PR de alineación de compose, por decisión del líder (2026-11-07). El brief 2 delega el cambio en el subagente `contenedores` y pasa por `/revisar` antes del push.
- **Pendiente sobre ST-01:** ejecutar `/revisar HU-IMP-CFG-03` sobre el PR #1051 (dictamen en `revisiones/`) y pedir al subagente `entornos` la ficha para Despliegue.
- **Patrón de `.dockerignore`:** el brief fijaba `*.pem`/`*.key`, que solo excluyen archivos en la **raíz** del contexto (`.dockerignore` no sigue la sintaxis de `.gitignore`). El líder aprobó `**/*.pem` y `**/*.key` (amend, commit `0dbe294`). Verificado con un `.pem` en la raíz y un `.key` en una subcarpeta (`evidencias/03-dockerignore-build.txt`). El PR a `test` **no** toca `.dockerignore`: el cambio llega a `test` cuando Desarrollo fusiona `dev` en `test`. El brief 2 solo modifica `docker-compose.test.yml` y `.env.test.example`.
- **Atribución del commit:** el brief pedía las líneas de atribución habituales, pero la regla 8 del `CLAUDE.md` de PI4 las prohíbe. El commit `0dbe294` va sin atribución.
- **Revisión:** comprobar que la tabla de cambios de cada archivo tenga una sola fila nueva y que `.env.*.example` no tenga valores.
- **Mensaje sugerido a Desarrollo:** "El compose ya monta `/app/secrets/agrofusion_sso_public.pem` (PR a `dev`). Necesitamos que entreguen a Despliegue el `.pem` y el `AGROFUSION_PROJECT_CODE` de TEST y PROD; DEV ya está identificado."

---
Redactada: 2026-11-09 · Fuentes: `Arekkazu/sgpmp-backend` `origin/dev` `3251d78d`, `origin/test` `1e9b9451`, `origin/main` `0abbeeef`, commit `0dbe294` · Brief: `brief-01-pr-dev.md`
