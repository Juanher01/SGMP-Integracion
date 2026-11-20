# Brief para Claude Code: actualizar la documentación tras el SSO de AgroFusion (verificar y ajustar) — v2

> Abre la sesión en `PI4`. Este brief trabaja **solo en `SGMP-Integracion`**. Los repositorios de aplicación (`sgpmp-backend`, `SGPMP-FRONT-END-PWA`) se leen y no se modifican.
> HU de origen: `HU-IMP-CFG-03` (`SGMP-Integracion/entregas/E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-03_agrofusion-sso/`, en adelante `<HU>`).
> v2: incorpora los cuatro documentos que entregó Desarrollo el 2026-11-14/15.

## Contexto

En HU-IMP-CFG-03, el backend empezó a montar la clave pública del SSO de AgroFusion. Hay que verificar qué documentación quedó desactualizada y corregirla. Esto se hace en dos fases:

- **Fase 1:** los agentes verifican. Es solo lectura.
- **Fase 2:** los agentes ajustan. **Solo empieza cuando yo apruebe el informe de la fase 1.**

### Fuentes de Desarrollo (te las adjunto)

Guárdalas en `<HU>/evidencias/fuentes-desarrollo-2026-11-14/`:

| Archivo | Uso en este brief |
|---|---|
| `05_Documento_despliegue.pdf` (v1.0, 2026-11-14) | **Principal.** Ambientes, variables, clave pública, montaje e incidente de DEV, procedimiento y verificación por ambiente |
| `01_Integracion_SIGAB_AgroFusion_SIGCON.pdf` (v1.0, 2026-11-14) | Flujos SSO y contable, dominios, endpoints que AgroFusion llama |
| `02_Ajustes_requerimientos_Analisis.pdf` (v1.0, 2026-11-14) | Va dirigido a Análisis. Solo interesan el §3.4 (riesgo de seguridad) y el §3.7 (dirección de retorno y código de proyecto) |
| `SGPMP_M05_M06_Suministros_Finanzas.pdf` (2026-11-15) | Funcional. No tiene datos de infraestructura: solo se archiva |

Si un documento contradice el código de la rama, **manda el código** y la contradicción se registra como hallazgo.

### Hipótesis que verificar

Lo que sigue es lo que se sabía al 2026-11-17. **Son hipótesis: verifica cada una con git el día de la ejecución.**

**A. El código de proyecto no es el que pusimos.**
- Según los documentos 01, 02 y 05, `AGROFUSION_PROJECT_CODE` es `SIGAB-DEV`, `SIGAB-TEST` y `SIGAB`, en mayúsculas.
- El valor tiene que coincidir con la ruta del frontend, porque AgroFusion arma la dirección de retorno como `https://inmero.co/{código en minúscula}/sso`.
- En CFG-03 escribimos `SGPMP-DEV`. Desarrollo ya lo corrigió en el comentario de `.env.example` de dev, pero `.env.prod.example:235` sigue diciendo `SGPMP-DEV`.
- Revisa también `<HU>/historia.md`, `entregables/PR-dev.md`, las filas del catálogo en la rama del PR #18 y el documento de ambiente v1.5, que dice `SGPMP`.

**B. DEV no usa la ruta estándar de la clave.**
- En DEV hubo despliegues antes de crear el *File Mount*, y Docker creó una carpeta. Dokploy v0.30.7 no la reemplaza.
- La solución que aplicó Desarrollo (doc. 05 §4.3) fue usar el *File Path* `agrofusion_sso_public.pem/clave.pem` y la ruta `AGROFUSION_SSO_PUBLIC_KEY_PATH=/app/secrets/agrofusion_sso_public.pem/clave.pem`.
- TEST y PROD usan la ruta estándar. Esto se documenta como desviación temporal, con la condición para revertirla: borrar la carpeta o actualizar Dokploy a v0.31 o posterior.

**C. Cambios de Desarrollo sobre archivos de Implementación.**
- `9ff4d38` (dev, 2026-11-13): `AGROFUSION_ISSUER: ${AGROFUSION_ISSUER:-agrofusion-auth}`. Antes, una variable vacía hacía rechazar todo token.
- PR **#1130** (`9a52ad5c`, test, 2026-11-14): monta la clave en `docker-compose.test.yml`. **Lo hizo Desarrollo, no nuestro brief 2.**
- Busca si hay más: `git log --since=2026-11-07` sobre `Dockerfile`, `.dockerignore`, `docker-compose*.yml` y `.env*.example` en las tres ramas.

**D. Variables obsoletas o que faltan.**
- `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` son obsoletas (doc. 05 §3) y siguen en los compose de test y main.
- `SGPMP_ENTORNO` no se pasa en el compose de TEST, así que queda en `DEV` (doc. 05 §3).
- El catálogo no tiene `M07_LIMITE_BYTES`, `M07_TIMEOUT_SEGUNDOS` ni `M07_COMPROBANTE_NIC41_HABILITADO`, y hay que revisar si tiene `FORWARDED_ALLOW_IPS`, que está como `ENV` en el `Dockerfile:72` de dev.

**E. El mapa de puertos tiene dominios desactualizados.** Esto corrige lo que se dijo antes: "el mapa no cambia".
- El `.drawio` v1.5 muestra `api.inmero.co/back-sigab-dev`, `back-sigab-test`, `https://dev.inmero.co/` y `https://api.inmero.co/` como frontend.
- Según los documentos 01 y 05:
  - backend: `https://api.inmero.co/api-sgpmp-dev`, `-test` y `/sigab`;
  - frontend: `https://inmero.co/sigab-dev`, `/sigab-test` y `/sigab`.
- El SSO tampoco agrega puertos, pero sí flujos:
  - el navegador va de AgroFusion a `inmero.co/{código}/sso`;
  - AgroFusion llama a `POST /integraciones/agrofusion/token` y a `GET /integracion/aaef/productores/{NIT}`, en DEV desde `172.17.0.1`, porque corre en el mismo servidor.
- Los dominios son de Despliegue: se confirman con `curl` o con Despliegue y no se toman de un solo documento.

**F. Documento de ambiente v1.5 desactualizado** (`entregas/E1_2026-10-13_M01-M09-M02/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`):
- §3.4 Grupo C, líneas ~301-303, y el párrafo "AgroFusion y M2M" (~l. 311);
- las incidencias INC-BE-06 (probablemente resuelta, con la desviación de B) e INC-FE-01 (`VITE_AGROFUSION_LOGIN_URL` no llega al build). Verifica qué controla `ssoConfigurado` en `src/auth/config/sso.ts:10` del frontend. Como el SSO empieza en AgroFusion, el impacto puede ser menor;
- §3.8, dominios.

**G. Mejor verificación para Despliegue** (doc. 05 §5 y §8): `curl -X POST {API}/sesiones/sso -d '{"sso_token":"x"}'`.
- `401 SSO_TOKEN_INVALIDO`: la clave se lee.
- `503`: faltan variables.
- `500`: la clave no está montada.

Además, se despliega con **Deploy, no Restart**, porque el montaje se toma al recrear el contenedor. Esto reemplaza o complementa el `test -r` de nuestra ficha.

**H. Seguridad (doc. 02 §3.4 y doc. 05 §9).** El `client_secret` del canal y la clave privada del SSO están en el código de AgroFusion; el riesgo quedó aceptado.
- No es una tarea de Implementación. Se cita en el documento de ambiente.
- Pregunta si Análisis ya lo registró.

### Además
- `0dbe294` (PR #1051) está en `origin/dev` y en `origin/test`, pero no en `origin/main` (`0abbeeef`). Doc. 05: PROD lo recibe con el próximo lanzamiento.
- El PR #18 de `SGMP-Integracion` sigue abierto. Si en la fase 2 cambian archivos que están en él, decide si se agregan a esa rama o a una nueva.

## Restricciones

- No modifiques `sgpmp-backend` ni el frontend. Si un hallazgo exige cambiarlos, por ejemplo `.env.prod.example`, regístralo como trabajo derivado.
- Nunca leas, escribas ni pidas valores de secretos. Los códigos de proyecto y la clave pública no son secretos, pero **no copies la clave a ningún archivo de `SGMP-Integracion`**: basta con citar su origen y su huella. Lo que está cargado en Dokploy no se consulta: se le pregunta a Despliegue.
- No edites el `.docx` a mano: se genera con `herramientas/md2docx.ps1`. El `.drawio` se edita con `source` y `target` en cada flecha.
- No reescribas la v1.5 entregada en E1. Los cambios van en una versión nueva.
- Antes de la fase 2, no hagas commits ni pushes. **Al terminar la fase 1, detente y espera mi respuesta.**

## Fase 1: verificación (solo lectura)

0. **Corte.** `git fetch` en los tres repositorios. Anota los hashes de `origin/dev`, `origin/test` y `origin/main` (CA-8 de la HU). Guarda los cuatro PDF en la carpeta indicada.

1. **Cambios de otro equipo.** Ejecuta `/impacto` sobre:
   - `https://github.com/Arekkazu/sgpmp-backend/commit/9ff4d38`
   - `https://github.com/Arekkazu/sgpmp-backend/pull/1130`
   - cualquier otro commit que aparezca en C.

   El informe debe decir:
   - si el cambio es correcto;
   - si choca con CFG-03;
   - qué trabajo genera para nosotros: llevar `:-agrofusion-auth` a TEST y PROD, quitar `AGROFUSION_HUB_*`, pasar `SGPMP_ENTORNO` en TEST y corregir `.env.prod.example`.

   Los informes van a la carpeta de la entrega vigente.

2. **Variables y documento de ambiente.** Usa el subagente `entornos` para contrastar las hipótesis A, B, D, F, G y H con el código de cada rama, el doc. 05 y estos archivos:
   - el documento v1.5: §3.3, §3.4 Grupo C, el párrafo "AgroFusion y M2M", §3.8 y la tabla de incidencias;
   - `registros/variables/VARIABLES-ENTORNO.md` (rama del PR #18 y §8);
   - `registros/incidencias/registro.md`;
   - `registros/variables/fichas/`.

   Para cada afirmación, anota qué dice el documento, qué muestra el código (archivo, línea y hash), qué dice Desarrollo (doc. y §) y qué cambio propones.

3. **Mapa de puertos.** Usa el subagente `contenedores` para verificar la hipótesis E:
   - los dominios del `.drawio` contra los documentos 01 y 05, y contra `curl -s -o /dev/null -w "%{http_code}"` a `/health` y a la raíz de cada frontend;
   - los flujos de AgroFusion que faltan.

   Concluye si hace falta una v1.6 del mapa y qué capas toca.

4. **Frontend (INC-FE-01).** El subagente `contenedores` revisa en `dev`, `test` y `main` del frontend:
   - si `VITE_AGROFUSION_LOGIN_URL` llega al build;
   - qué deja de funcionar si no llega (`ssoConfigurado`): ¿bloquea la ruta `/sso`, o solo oculta un botón?

   Solo diagnostica.

5. **Informe.** Guarda `<HU>/revisiones/VERIF-DOC-agrofusion.md` con:
   - El corte: los hashes del paso 0.
   - Una tabla con estas columnas: `Documento | Sección/línea | Dice hoy | Estado real (evidencia) | Fuente de Desarrollo | Cambio propuesto | Responsable`. Responsable es Implementación, Desarrollo o Despliegue.
   - El veredicto del mapa de puertos y del documento de ambiente: versión nueva, capas y secciones afectadas.
   - Un resumen de los informes de `/impacto`.
   - Los trabajos derivados que **no** son documentación, cada uno con una propuesta de HU o PR:
     - PR a dev para `.env.prod.example`, `AGROFUSION_ISSUER` y `AGROFUSION_HUB_*`;
     - PR a test para `SGPMP_ENTORNO` y `AGROFUSION_HUB_*`;
     - catálogo de `M07_*` y `FORWARDED_ALLOW_IPS`;
     - INC-FE-01.
   - Las preguntas que debo responder:
     1. ¿Dónde viven las versiones nuevas del documento y del mapa? Según ADR-002, propón la carpeta de entrega y los nombres.
     2. ¿La documentación va en CFG-03 o en una HU `DOC` nueva? Usa `planificar` si conviene numerarla.
     3. ¿Qué preguntas van a Despliegue? Por ejemplo, los códigos cargados por ambiente, si TEST y PROD tienen el *File Mount* antes de desplegar y la versión de Dokploy.
     4. ¿Qué preguntas van a Desarrollo?
   - Los datos de este brief que no se confirmaron. Para cada uno, la evidencia que lo desmiente.

   **Detente aquí y entrégame el informe.**

## Fase 2: ajustes (solo cuando yo apruebe)

Cuando apruebe, te diré qué filas del informe se aplican y dónde. Ese mensaje irá aparte. Haz los cambios en una rama propia de `SGMP-Integracion`, con este reparto:
- **`entornos`:**
  - filas del catálogo (códigos `SIGAB-*`, `M07_*`, `FORWARDED_ALLOW_IPS`) y §8 de `VARIABLES-ENTORNO.md`;
  - ficha para Despliegue en `registros/variables/fichas/` (ST-04), con el procedimiento del doc. 05 §7, la verificación con `curl` y la desviación de DEV;
  - `registros/incidencias/registro.md`;
  - corrección de `SGPMP-DEV` en `<HU>`.
- **`documentador`:**
  - versión nueva del documento de ambiente (`.md`, control de cambios y `.docx` generado con `md2docx.ps1`);
  - versión nueva del mapa de puertos si la fase 1 lo confirma.
- **`/revisar`:** revisión de la HU antes del push.

## Reporte de vuelta (fase 1)

1. La ruta del informe `VERIF-DOC-agrofusion.md` y su tabla.
2. Las rutas de los informes de `/impacto`.
3. Los trabajos derivados y las preguntas que debo responder.
4. Las hipótesis que no se confirmaron, con su evidencia.
