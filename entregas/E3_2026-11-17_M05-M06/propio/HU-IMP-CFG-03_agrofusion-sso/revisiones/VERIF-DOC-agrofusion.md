# VERIF-DOC-agrofusion — Verificación de documentación tras el SSO de AgroFusion (fase 1)

- **HU:** HU-IMP-CFG-03 · **Brief:** `../brief-03-documentacion.md` (v2) · **Fecha:** 2026-11-17
- **Modo:** solo lectura. No se modificó ningún documento ni repositorio de aplicación.
- **Agentes:** `analista-cambios` (/impacto), `entornos` (A, B, D, F, G, H), `contenedores` (E, INC-FE-01). El líder consolidó y comprobó la discrepancia sobre INC-FE-01.

## 1. Corte (git fetch 2026-11-17)

| Repo | origin/dev | origin/test | origin/main |
|---|---|---|---|
| sgpmp-backend | `2b9ee221` | `5697ebbe` | `0abbeeef` |
| SGPMP-FRONT-END-PWA | `601d5a84` | `247b1183` | `fe88f82d` |
| SGMP-Integracion | — | — | `0fa672e5` · rama del PR #18 `docs/hu-imp-cfg-03-agrofusion-sso` = `95b16b96` (abierto) |

Estado de los commits relevantes:

| Commit | dev | test | main |
|---|---|---|---|
| `0dbe294` (nuestro, PR #1051) | sí | sí | no |
| `9ff4d38` (Desarrollo, PR #1129) | sí | sí | no |
| `9a52ad5c` (Desarrollo, PR #1130, merge `64c69123`) | no | sí | no |
| FE `d688fd9d` (ruta `/sso`) | sí | sí | **no** |

Release pendiente: PR #941 `dev → main` (1.4.0), abierto.

**Fuentes de Desarrollo** — Drive: [PENDIENTE: enlace] (SHA-256, primeros 16 caracteres). No se versionan en el repositorio: el doc. 05 §4.1 trae la clave pública completa (`brief-03-documentacion.md` l. 85: no copiarla a ningún archivo de SGMP-Integracion) y ADR-002 no prevé binarios de terceros (decisión del líder, 2026-11-20; REV-02 C-4).

| Archivo | SHA-256 |
|---|---|
| `01_Integracion_SIGAB_AgroFusion_SIGCON.pdf` | `2f388e2aff196f16…` |
| `02_Ajustes_requerimientos_Analisis.pdf` | `b69d1ab610b898b8…` |
| `05_Documento_despliegue.pdf` | `6fa2c4d15eb4296b…` |
| `SGPMP_M05_M06_Suministros_Finanzas.pdf` | `0d105238914fcd0f…` |

La clave pública que trae el doc. 05 §4.1 **no** se copió a ningún archivo. Origen: `Server-IA/agrofusion-backendauth`, `app/keys/sso_public.pem`, rama `main`, commit `a50cc0b`. Huella SHA-256 según Desarrollo: `9d99cf66b629bbf7…`.

## 2. Pruebas en vivo (curl, 2026-11-17 ~12:02–12:10 -05)

| URL | Resultado | Lectura |
|---|---|---|
| `api.inmero.co/api-sgpmp-dev/health` | 200 | Backend DEV vigente |
| `api.inmero.co/api-sgpmp-test/health` | 200 | Backend TEST vigente |
| `api.inmero.co/sigab/health` | 200 | Backend PROD vigente (sin M07: `/integracion/aaef` → 404) |
| `api.inmero.co/back-sigab-dev/health`, `…/back-sigab-test/health` | 404 | Rutas antiguas retiradas |
| `inmero.co/sigab-dev/` (y sus assets) | 200 | Frontend DEV con base `/sigab-dev/` |
| `inmero.co/sigab-test/` | 200, pero es **PROD** | Mismo `index.html` y ETag que `/sigab/`; el asset de `/sigab-test/` da 404. **No hay frontend TEST desplegado.** El router `/sigab` lo captura |
| `inmero.co/sigab/` | 200 | Frontend PROD, base `/sigab/` |
| `dev.inmero.co/` | 200 | **Otra aplicación** (`TaskFlow`) |
| `api.inmero.co/` | 404 | Ya no hay frontend TEST en la raíz |
| `api.inmero.co/broker-sigab-dev/v1/healthz` | 404 | Gateway DEV no localizado |
| `api.inmero.co/broker-sigab-test/v1/healthz` | 200 | Gateway TEST vigente |
| `api.inmero.co/broker-sigab/v1/healthz` | 200 | Gateway sin sufijo (¿PROD?) |
| `POST api-sgpmp-dev/sesiones/sso {"sso_token":"x"}` | **401 `SSO_TOKEN_INVALIDO`** | DEV lee la clave (la desviación §4.3 funciona) |
| `POST api-sgpmp-test/sesiones/sso` | **503 `SSO_NO_CONFIGURADO`** | TEST sin variables SSO |
| `POST sigab/sesiones/sso` | **503 `SSO_NO_CONFIGURADO`** | PROD sin variables (y main no monta el .pem) |
| `OPTIONS api-sgpmp-test` con `Origin: https://inmero.co` | **400**, sin ACAO | CORS de TEST no admite el origen nuevo del frontend |
| `OPTIONS api-sgpmp-dev` / `sigab` con el mismo origen | 200, ACAO `https://inmero.co` | Correcto |

## 3. Tabla de hallazgos

| # | Documento | Sección/línea | Dice hoy | Estado real (evidencia) | Fuente de Desarrollo | Cambio propuesto | Responsable |
|---|---|---|---|---|---|---|---|
| 1 | BE `.env.prod.example` (dev, test) | l.235 | "DEV usa `SGPMP-DEV`" | `.env.example:160-161@2b9ee221` y `@5697ebbe` ya dicen SIGAB-DEV/SIGAB-TEST/SIGAB (por `9ff4d38`). La línea 235 la escribimos nosotros en `0dbe294`. En main no existe (`.env.prod.example:211-213@0abbeeef`) | 05 §3 | Copiar el texto de `.env.example:159-161`. PR a dev; test y main lo reciben por promoción o release | Implementación |
| 2 | BE `docker-compose.test.yml` | l.63-67, 81-86@5697ebbe | Pasa `AGROFUSION_HUB_*`; no pasa `SGPMP_ENTORNO`. El montaje del .pem ya está (l.86, PR #1130) | `HUB_*` no se leen en test (`git grep` vacío en `*.py@5697ebbe`). `SGPMP_ENTORNO` toma `"DEV"` por defecto (`configuracion.py:18@5697ebbe`): TEST se identifica como DEV | 05 §3 | `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}` (o guarda `:?`), quitar `HUB_*`. PR desde `origin/test` | Implementación (aprueba Pruebas) |
| 3 | BE `.env.test.example` (solo test) | l.48-55@5697ebbe | Solo nombres; incluye `HUB_*`; sin `SGPMP_ENTORNO` | Ídem fila 2 | 05 §3 | Quitar `HUB_*`, agregar `SGPMP_ENTORNO=TEST` y comentar ruta y código SIGAB-TEST | Implementación |
| 4 | BE compose de main (`docker-compose.yml`, `docker-compose.prod.yml`) | prod l.146-150, 166-169@0abbeeef | Pasan `HUB_*`; no montan el .pem; no pasan `SGPMP_ENTORNO` | **En main `HUB_*` siguen en uso**: `main.py:671`, `src/shared/agrofusion_auth.py:19-20@0abbeeef`. El PDF dice "obsoletas" y es prematuro para main | 05 §3 (contradicción) | Ningún PR dirigido a main: llega con el release #941. Avisar a Despliegue de que **no retire `HUB_*` de PROD antes del release** | Implementación (aviso) / Despliegue |
| 5 | BE `docker-compose.yml` (dev) | l.76-79, 104-109@2b9ee221 | Comentario: ruta `/app/secrets/agrofusion_sso_public.pem` | El montaje no cambia. La desviación de DEV es de valores en Dokploy (File Path `…pem/clave.pem`). 401 en vivo | 05 §4.3 | No tocar el compose. Registrar la desviación temporal en el catálogo y la paridad, con su condición de reversión (carpeta borrada o Dokploy ≥ v0.31.0) | Implementación |
| 6 | `<HU>/historia.md` (PR #18) | l.9, 27, 51, 89-91, 105@95b16b96 | Verificación con `test -r`; cita `sesiones_routers.py:170`; "DEV ya está identificado" | El router está en l.172@2b9ee221 (l.166@main). No menciona la desviación, el curl del §8 ni "Deploy, no Restart". `test -r` sobre la **carpeta** de DEV da verdadero: no detecta el caso del 500 | 05 §4.3, §7, §8 | Actualizar la situación (corte 11-17; 401/503/503). CA-6: curl del §8 como prueba principal y `test -f -a -r` como complementaria. Agregar al riesgo la variante de Dokploy v0.30.7. Línea 170 → 172 | Implementación |
| 7 | `<HU>/entregables/PR-dev.md` (PR #18) | l.19, 32-42@95b16b96 | Instrucciones a Despliegue con `test -r` | PR ya fusionado; texto histórico | 05 §7-8 | Dejarlo como registro histórico y añadir una nota que remita a la ficha | Implementación |
| 8 | `<HU>/brief-01-pr-dev.md` (PR #18) | l.12, 32, 84@95b16b96 | "En DEV es `SGPMP-DEV`" | Contradice `.env.example:160@2b9ee221` (SIGAB-DEV) | 05 §3 | Nota de corrección (brief histórico) | Implementación |
| 9 | `<HU>/brief-02-pr-test.md` (PR #18) | paso 3.1 | Crear `volumes:` con el montaje en `docker-compose.test.yml` | Ya lo hizo Desarrollo en PR #1130 (`docker-compose.test.yml:86@5697ebbe`), idéntico a `0dbe294` | — | Reescribir ST-02: sin montaje; con `SGPMP_ENTORNO`, retiro de `HUB_*` y la plantilla | Implementación |
| 10 | `registros/variables/VARIABLES-ENTORNO.md` (PR #18) | l.87-89@95b16b96 | `PROJECT_CODE` DEV = `SGPMP-DEV`; `ISSUER` "si viene vacía usa agrofusion-auth"; `KEY_PATH` única; `sesiones_routers.py:170` | DEV SIGAB-DEV. El default del código (`os.getenv`, `agrofusion_sso_adapter.py:37`) **no** se aplica a una variable vacía: lo resuelve el `:-` del compose. Ruta DEV temporal `…pem/clave.pem`. Línea 172 | 05 §3, §4.3 | Corregir los códigos (relación con la ruta del frontend), la frase de `ISSUER`, la desviación de DEV y la línea | Implementación |
| 11 | `VARIABLES-ENTORNO.md` (main y PR #18) | tabla principal | Faltan `SGPMP_ENTORNO`, `M07_LIMITE_BYTES`, `M07_TIMEOUT_SEGUNDOS`, `M07_COMPROBANTE_NIC41_HABILITADO`, `FORWARDED_ALLOW_IPS`, `AGROFUSION_HUB_*` y `VITE_BASE_PATH` | `configuracion.py:18,20-22@2b9ee221`; `Dockerfile:72@2b9ee221` (l.66@main) `ENV FORWARDED_ALLOW_IPS`. `M07_*` solo comentadas en `.env.example:172-175`, sin compose. `VITE_BASE_PATH` en FE `Dockerfile:13,45`, `docker-compose.yml:9`, `vite.config.ts:14@601d5a84` | 05 §3 | Agregar las filas. `M07_*` opcionales y sin compose (diferencia justificada); NIC41 "no activar". `FORWARDED_ALLOW_IPS` como ENV de imagen. `HUB_*` "solo main; se retira con el release" | Implementación |
| 12 | `registros/variables/fichas/` | main y PR #18 | Solo `.gitkeep` | **No existe la ficha de CFG-03**, que el CA-6 exige | 05 §7-8 | Crear `fichas/HU-IMP-CFG-03_<fecha>.md`: ruta y código por entorno (DEV temporal), `SGPMP_ENTORNO` TEST, File Mount **antes** del primer Deploy, **Deploy, no Restart**, curl del §8, no retirar `HUB_*` de PROD antes del release | Implementación |
| 13 | Doc. ambiente v1.5 §3.4 Grupo C | l.301-303@0fa672e5 | DEV `KEY_PATH` "no montada (INC-BE-06)"; `PROJECT_CODE` DEV = `SGPMP`; `HUB_*` "valor propio" en los tres entornos | DEV montada y leída (401). Código SIGAB-DEV. `HUB_*` no se leen en dev ni en test | 05 §3 | Actualizar las tres filas y agregar `SGPMP_ENTORNO` y `M07_*` | Implementación |
| 14 | Doc. ambiente v1.5, "AgroFusion y M2M" | l.311 | "Variables vacías → SSO 503 y el M2M no se monta" | Válido solo para main (`main.py:671`). En dev y test el M2M usa credenciales en BD (RF-101). Falta el caso 500 | 05 §3, §4.3, §8 | Reescribir: 503 sin variables, 500 sin archivo o con carpeta, 401 correcto; M2M con credenciales en BD desde RF-101 | Implementación |
| 15 | Doc. ambiente v1.5 §3.3 | l.181-199 | Hashes de octubre; sin el montaje del .pem | Montaje en dev l.109, test l.86, prod-compose de dev l.189; main no | — | Corte nuevo en la v1.6 | Implementación |
| 16 | Doc. ambiente v1.5 §3.8 | l.395-397 | Frontend `dev.inmero.co`/`api.inmero.co`; backend `back-sigab-dev`/`-test` | Ver §2: `back-sigab-*` 404; `dev.inmero.co` es otra app; los vigentes son `api-sgpmp-*`, `/sigab`, `inmero.co/sigab-*` | 01, 05 | Dominios nuevos, **confirmados por Despliegue** | Implementación (dato: Despliegue) |
| 17 | Doc. ambiente v1.5 §11.4 y `registros/incidencias/registro.md` | v1.5 l.666, 675; registro l.9, 18, 38, 45@0fa672e5 | INC-BE-06 "por confirmar"; INC-FE-01 "pendiente de triage" | INC-BE-06: **resuelta en DEV** con la desviación (401); abierta en TEST y PROD (503). INC-FE-01: ver fila 19 | 05 §4.3 | Actualizar el registro vivo; la v1.6 remite a él | Implementación |
| 18 | `registros/incidencias/registro.md` | l.15 INC-BE-03 | `ROOT_PATH` ≠ prefijo público `back-sigab-*` | El prefijo público es ahora `/api-sgpmp-*` | curl | Revalidar o cerrar INC-BE-03; revisar `tag-rootpath` del mapa | Implementación |
| 19 | FE `.env.example` / `Dockerfile` / compose (3 ramas) | `.env.example:32-36`; `Dockerfile:12-32`; `docker-compose.yml:7-17` | Documenta `VITE_AGROFUSION_LOGIN_URL` y retorno "/sso/callback?sso_token=" | No llega al build (sin `ARG` ni `build.args`), **pero no importa**: `ssoConfigurado` y `agrofusionLoginUrl` no se importan en ningún archivo (`git grep` en las 3 ramas solo encuentra `src/auth/config/sso.ts`). El botón se quitó en `9c278e32`. `/sso` no depende de la variable. El retorno real es `/sso?token=` (`App.tsx:367`, `SsoCallbackPage.tsx:21@601d5a84`) | 05 (retorno `/{código}/sso`) | INC-FE-01 se **reclasifica**: variable muerta y comentario desfasado, no una falla. Decidir con Desarrollo si se elimina o se reintroduce el botón. Corregir el comentario y documentar `VITE_BASE_PATH` | Desarrollo (decide) / Implementación (plantilla) |
| 20 | FE main (PROD) | `App.tsx:361@fe88f82d` | Solo `/sso/callback` | AgroFusion devuelve a `inmero.co/sigab/sso?token=`: **en PROD no hay ruta**. El bundle de `/sigab` no contiene `path:"/sso"`. `d688fd9d` no está en main | 01 §3 paso 3 | Llega con el release del FE. Ficha: el SSO de PROD no funciona hasta entonces | Desarrollo (release) |
| 21 | Mapa `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio` (E1/documentos) | `env-dev-front` l.187, `env-dev-back` l.190, `env-dev-gw` l.193, `env-test-front` l.209, `env-test-back` l.212, `env-prod-*` l.237-243 | Dominios `dev.inmero.co`, `back-sigab-*`, `api.inmero.co/` (front TEST); PROD "por definir" | Ver §2 | 01, 05 | v1.6 (ver §4) | Implementación (dato: Despliegue) |
| 22 | Mapa v1.5 | `ext-agrofusion` l.120, `edge-af-be` l.418 | Una sola flecha M2M "HTTPS 443 entrante" | Tres flujos: SSO por navegador (`/{código}/sso` → `POST /sesiones/sso`), `POST /integraciones/agrofusion/token`, `GET /integracion/aaef/productores/{NIT}` (`m07_router.py:68@2b9ee221`). AgroFusion → SIGCON | 01 §3-4 | v1.6 (ver §4) | Implementación |
| 23 | `PI4/CLAUDE.md`, skills `verificacion` y `triage` | tabla Infraestructura; "Frontend en la raíz / (no admite prefijo)" | `dev.inmero.co`, `back-sigab-*`, `broker-sigab-dev`; sin prefijo | Falso en las 3 ramas: `vite.config.ts:14` `base: VITE_BASE_PATH`, `Dockerfile:13,45,52-54`, `App.tsx:398` `basename`. curl lo confirma | curl y código | Reescribir la tabla y retirar "no admite prefijo" (fuera del alcance de SGMP-Integracion) | Líder |
| 24 | `registros/seguridad/registro-SEG.md` | todo@0fa672e5 | Nada sobre AgroFusion; tampoco registra SEG-M01-02 | Riesgo aceptado (secreto del canal y clave privada SSO en el código de AgroFusion) sin directriz. SEG-M01-02 (BE #438, cerrado el 2026-10-03) no está en el registro | 02 §3.4; 05 §9 | Citar el riesgo en la v1.6 del documento de ambiente; preguntar a Análisis si lo quiere como SEG. Valorar agregar SEG-M01-02 al registro | Implementación (consulta a Análisis) |
| 25 | BE `docker-compose.test.yml` | l.54@5697ebbe | `ALLOWED_ORIGINS: ${…:-}` | CORS de TEST rechaza `https://inmero.co` (400) | CLAUDE.md (debe coincidir con el origen del frontend) | Cargar el valor (Despliegue). Valorar la guarda `:?` | Despliegue / Implementación |

## 4. Veredicto del mapa y del documento de ambiente

**Mapa de puertos: hace falta la v1.6.**
1. **DEV:** frontend `inmero.co/sigab-dev/` (`VITE_BASE_PATH=/sigab-dev`); backend `api.inmero.co/api-sgpmp-dev`; gateway "por confirmar".
2. **TEST:** frontend `inmero.co/sigab-test/`, marcado "no desplegado al 2026-11-17"; backend `api-sgpmp-test`; gateway sin cambio.
3. **PROD:** `inmero.co/sigab/`, `api.inmero.co/sigab`, `/broker-sigab` (este último por confirmar).
4. **Protocolos:** reemplazar `edge-af-be` por tres flechas (redirección del navegador a `/{código}/sso?token=`, `POST /integraciones/agrofusion/token`, `GET /integracion/aaef/productores/{NIT}`, esta con la nota "DEV: origen 172.17.0.1, según Desarrollo, sin verificar"). Agregar la flecha PWA → `POST /sesiones/sso`, el nodo SIGCON con la flecha AgroFusion → SIGCON ("según Desarrollo") y la anotación Traefik → frontend "subruta `/sigab-*`; nginx recorta `VITE_BASE_PATH`".
5. **Hallazgos:** TEST sin frontend, SSO de TEST 503, CORS de TEST, PROD sin `/sso`. Revisar `tag-rootpath`.
6. **Control:** `ctl-version` → v1.6 · 2026-11-17; `ctl-fuente` → corte de §1.

Ojo: en `D:\USER\Downloads\` ya existe un `IMP_Diag_Despliegue_Puertos_Protocolos_v1.6.drawio` del 2026-11-02, y hay una rama remota `docs/mapa-puertos-v1.5`. Ver la pregunta P1.

**Documento de ambiente: hace falta la v1.6** (la v1.5 entregada en E1 no se toca). Secciones: §3.3 (corte y montaje), §3.4 Grupo C (filas 13), párrafo "AgroFusion y M2M" (fila 14), §3.8 (dominios, fila 16), §11.4 (remitir al registro vivo, fila 17), y una nota de seguridad (fila 24). Control de cambios y `.docx` con `md2docx.ps1`.

## 5. Informes de /impacto

| Cambio | Informe | Resumen |
|---|---|---|
| `9ff4d38` (PR #1129, dev y test) | `entregas/E3_2026-11-17_M05-M06/commits/BACK-9ff4d38_sso-issuer-codigos-proyecto/analisis.md` | Correcto. `${AGROFUSION_ISSUER:-agrofusion-auth}` (`docker-compose.yml:78@2b9ee221`) arregla el caso de la variable vacía. No choca con CFG-03. Test ya tiene el default (`docker-compose.yml:78`, `docker-compose.test.yml:65`). En main, `docker-compose.prod.yml:148` ya lo tiene y `docker-compose.yml:72` llega con el release. Deja fuera `.env.prod.example:235` (desviación nuestra) |
| PR #1130 (`9a52ad5c`, solo test) | `entregas/E3_2026-11-17_M05-M06/prs/BACK-PR1130_montaje-clave-sso-test/analisis.md` | Correcto e idéntico a `0dbe294`. No choca en contenido, pero **deja obsoleto el paso 3.1 del brief-02**. Queda pendiente en test: `SGPMP_ENTORNO`, retirar `HUB_*` y la plantilla. Fusionado sin revisión |

Sin otros commits ajenos: `git log --since=2026-11-07` sobre `Dockerfile`, `.dockerignore`, `docker-compose*.yml`, `.env*.example` (y `nginx.conf` en el FE) solo muestra `0dbe294`, `9ff4d38`, `9a52ad5c` y merges en el backend, y nada en el frontend.

Pendiente fuera de esta fase: las filas de estos dos cambios en `entregas/E3_2026-11-17_M05-M06/README.md` no se tocaron.

## 6. Trabajos derivados (no documentación)

| # | Trabajo | Rama | Propuesta |
|---|---|---|---|
| T1 | `.env.prod.example:235` → códigos SIGAB | BE dev (test y main por promoción o release) | PR de Implementación, dentro de CFG-03 |
| T2 | `SGPMP_ENTORNO` en TEST, retiro de `HUB_*` y plantilla `.env.test.example` | BE test | Reescribir ST-02 (brief-02) sin el montaje; PR desde `origin/test` |
| T3 | `HUB_*` y montaje del .pem en main | BE main | Sin PR: viaja con el release #941. Aviso a Despliegue |
| T4 | Catálogo: `SGPMP_ENTORNO`, `M07_*`, `FORWARDED_ALLOW_IPS`, `HUB_*`, `VITE_BASE_PATH` | SGMP-Integracion | Fase 2 (`entornos`) |
| T5 | INC-FE-01 reclasificada: variable muerta | FE | Pregunta a Desarrollo; si se elimina, Desarrollo; si se reintroduce el botón, PR de Implementación (`ARG`, `build.args`, plantilla). Corregir el comentario `/sso?token=` y añadir `VITE_BASE_PATH` a `.env.example` (PR de Implementación) |
| T6 | Frontend TEST no desplegado; regla `/sigab` que captura `/sigab-*`; CORS y SSO de TEST | Despliegue | Ficha a Despliegue |
| T7 | Ruta `/sso` ausente en PROD | FE main | Release del FE (Desarrollo) |
| T8 | CLAUDE.md y skills con dominios viejos y "no admite prefijo" | `PI4/.claude`, `CLAUDE.md` | Decisión del líder |

## 7. Preguntas para el líder

1. **Dónde viven las versiones nuevas (ADR-002).** Propuesta: en la entrega vigente, `entregas/E3_2026-11-17_M05-M06/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION_v1.6.md` (+ `.docx`) e `IMP_Diag_Despliegue_Puertos_Protocolos_v1.6.drawio`; la v1.5 sigue intacta en E1. ¿El `v1.6.drawio` de `Downloads` (2026-11-02) es un borrador tuyo? Si lo es, se partiría de él o se usaría v1.7 para no chocar.
2. **¿CFG-03 o HU nueva?** Recomendación: CFG-03 se queda con T1, T2 y la ficha (son sus CA-4 y CA-6); la v1.6 del documento y del mapa va en una HU `DOC` nueva (abarca más que el SSO: dominios, TEST sin frontend). Si apruebas, `planificador` la numera.
3. **¿Los archivos de la fase 2 van en la rama del PR #18 o en una rama nueva?** Recomendación: las correcciones de `<HU>` y del catálogo, en el PR #18 (ya los contiene); la v1.6, en la rama de la HU DOC.
4. **`SGPMP_ENTORNO` en TEST:** ¿default `:-TEST` o guarda `:?`?
5. **¿Acordar con Desarrollo que avise antes de tocar compose o plantillas?** #1129 y #1130 se fusionaron sin revisión.

**Para Despliegue:**
1. Confirmar los dominios por entorno (backend, frontend y gateway). ¿Cuál es la URL del gateway DEV? ¿`/broker-sigab` es PROD? ¿Qué pasa con `dev.inmero.co`?
2. ¿Cuándo se despliega el frontend de TEST en `inmero.co/sigab-test`? La regla de PROD (`PathPrefix(/sigab)`) captura `/sigab-*`: conviene `Path(/sigab) || PathPrefix(/sigab/)`. Lo mismo aplica a `api.inmero.co/sigab` y a `/broker-sigab`.
3. TEST y PROD responden 503: ¿cuándo se cargan el File Mount (antes del primer Deploy) y las variables? ¿TEST tiene ya `ALLOWED_ORIGINS=https://inmero.co`?
4. ¿Qué versión de Dokploy hay y cuándo pasa a ≥ v0.31.0? Es la condición para revertir la desviación de DEV.
5. No retirar `AGROFUSION_HUB_*` de PROD antes del release; en TEST, retirarlas cuando se fusione T2.
6. ¿El `VITE_API_BASE_URL` de DEV con `www.api.inmero.co` (lo incrusta el bundle) es intencional?

**Para Desarrollo:**
1. ¿Cuándo se fusiona el release #941 y el del FE (con `d688fd9d`)? Hasta entonces el SSO de PROD no puede funcionar.
2. `VITE_AGROFUSION_LOGIN_URL` / `ssoConfigurado`: ¿se eliminan o vuelve el botón?
3. ¿`M07_LIMITE_BYTES` y `M07_TIMEOUT_SEGUNDOS` se ajustan por entorno? Si es así, deben entrar al `environment:`.
4. El GET AAEF valida los parámetros antes que el token (observación).
5. ¿Cómo se verifica el origen `172.17.0.1` y el flujo AgroFusion → SIGCON?
6. ¿Análisis ya registró el riesgo del §9 / 02 §3.4? (H)

## 8. Datos del brief que no se confirmaron

| Dato del brief | Resultado | Evidencia |
|---|---|---|
| A: "`.env.prod.example:235` sigue diciendo SGPMP-DEV"; revisar `historia.md` y `PR-dev.md` | Confirmado en dev y test. **No existe en main.** `historia.md` y `PR-dev.md` no traen `SGPMP-DEV` literal; sí lo traen `brief-01` (l.12, 32, 84) y el catálogo (l.88) | `.env.prod.example:211-213@0abbeeef` |
| C: "PR #1130 … `9a52ad5c`" | Confirmado; el merge es `64c69123` | `gh pr view 1130` |
| D: "`AGROFUSION_HUB_*` obsoletas" (doc. 05 §3) | **Solo en dev y test.** En main siguen en uso | `main.py:671`, `src/shared/agrofusion_auth.py:19-20@0abbeeef` |
| D: "`FORWARDED_ALLOW_IPS` en `Dockerfile:72` de dev" | Confirmado (l.66 en main) | `Dockerfile:72@2b9ee221` |
| F: "INC-FE-01 … el impacto puede ser menor" | **Más que menor: nulo.** `ssoConfigurado` no se usa en ninguna rama; el botón se quitó en `9c278e32`. (`entornos` informó "botón deshabilitado"; se verificó y es incorrecto) | `git grep ssoConfigurado` en `origin/{dev,test,main}` solo encuentra `sso.ts` |
| E: frontend de TEST en `inmero.co/sigab-test` (doc. 01 y 05) | **No desplegado**: esa ruta la sirve PROD | ETag idéntico a `/sigab/`; el asset de `/sigab-test/` da 404 |
| E: gateway DEV `broker-sigab-dev` (CLAUDE.md) | No responde | 404 en `/` y `/v1/healthz` |
| E: "AgroFusion llama desde 172.17.0.1" y "AgroFusion → SIGCON" | No verificable desde Implementación | Pregunta a Desarrollo |
| PDF 01 §3: dirección de retorno `https://inmero.co/{código}/sso` | Coherente en DEV (`/sigab-dev/` sirve la PWA con la ruta `/sso`). En PROD la ruta no existe (fila 20). El informe de /impacto de `9ff4d38` deja esto como pregunta abierta; el curl la responde | curl §2; `App.tsx:367@601d5a84` vs `:361@fe88f82d` |
| H: "riesgo aceptado" | No consta en `registro-SEG.md` ni en issues | `registro-SEG.md@0fa672e5` |
| CLAUDE.md: "Frontend en la raíz `/` (no admite prefijo)" | Falso | `vite.config.ts:14`, `Dockerfile:13,45` (3 ramas), curl |

## 9. Nota para Análisis (Miguel Ortiz, `miguelortiz13`) — hipótesis H

Desarrollo documenta como **riesgo aceptado** (doc. 02 §3.4 y doc. 05 §9.1-9.2; fuentes en Drive, §1) que:

- el `client_secret` con el que AgroFusion pide el token de canal a SIGAB está escrito en el código de AgroFusion (`agrofusion-backendint/app/services/checks_service.py`);
- la clave privada con la que AgroFusion firma los tokens del SSO está en su repositorio (`agrofusion-backendauth/app/keys/`).

Con la regla del 13-11-2026 (toda cuenta nueva que entra por SSO nace Administrador), quien tenga ese repositorio puede pedir tokens de canal a nombre de cualquier usuario o firmar un token con cualquier correo. Las mitigaciones del lado de SIGAB (dirección permitida, vencimiento corto, auditoría) están en el doc. 05 §9.1.

Al 2026-11-17 este riesgo **no consta** en `registros/seguridad/registro-SEG.md` (`@0fa672e5`) ni en ningún issue SEG. Implementación no lo registra: **Análisis decide** si lo incorpora como directriz SEG, como riesgo aceptado en su propio registro o como ninguna de las dos. Tampoco consta en el registro SEG-M01-02 (BE #438, cerrado el 2026-10-03), sobre validación de `aud`/`exp`/`iss`; queda a criterio de Análisis si se agrega.
