# Brief: issue #1180 (SGPMP_ENTORNO en TEST) y PR #1204

> Fecha: 2026-11-20 (actualizado tras fusionar #18, #19 y #20) · Responsable: Sebastián Sandoval Chavarro · Entrega vigente: E4 (2026-11-24)
> Origen: https://github.com/Arekkazu/sgpmp-backend/issues/1180
> Cambio de otro equipo: https://github.com/Arekkazu/sgpmp-backend/pull/1204

Este brief se ejecuta en tres fases. **Al terminar cada fase, detente y espera mi respuesta.**

## Reglas

- No leas, escribas ni pidas valores de secretos. Solo nombres, sensibilidad y placeholders.
- No publiques comentarios en GitHub: redacta borradores y yo los publico.
- No fusiones ni apruebes el PR #1204. En `test` lo aprueba el Líder de Pruebas.
- No toques lógica de aplicación. Si la causa está en el código, va como borrador de issue a Desarrollo.
- Todo lo que digas sobre una rama se verifica con `git fetch` + `git show origin/<rama>:<archivo>`.
- Commits sin atribución a herramientas.

## Contexto

**Issue #1180** (Pruebas, TEX053, 2026-11-19; caso TC-M07-378-G025, RF-97). En TEST,
`SourceSystem.Environment` vale `"DEV"`. Pruebas lo vio en vivo el 17 y el 18 de noviembre.
Etiquetas: BLOQUEADO, DBA, no-es-desarrollo. Arekkazu lo cerró el 2026-11-20, **antes de que
la corrección estuviera desplegada**.

Comentarios del issue:
- SamuelPR21 (DBA) pide pasarlo a Implementación y Despliegue (menciona a chebaz-117 y soymoroo).
- Arekkazu explica la causa: `docker-compose.test.yml` enumera una por una las variables del
  contenedor y `SGPMP_ENTORNO` no está, así que el código usa su valor por defecto, `DEV`.
  Cambiar el valor en Dokploy no alcanza. Además pide a Implementación:
  - revisar el `.env` de TEST para `IOT_INFERENCIA_M04_URL` y `OTA_URL_*`;
  - «definir» `M04_FIRMA_MODELOS_KEY` en TEST.

**PR #1204** (Arekkazu, rama `fix/compose-test-entorno-m04-1180` → `test`, commit `b8968e6`,
abierto, sin revisiones al 2026-11-20). Según la descripción, agrega a `docker-compose.test.yml`
con la forma `${VAR:-default}`:
- `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}`;
- `M04_FIRMA_MODELOS_KEY`;
- `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_M04_TOKEN`, `IOT_INFERENCIA_TLS_MIN`, `IOT_INFERENCIA_CA_FILE`;
- `IOT_AUDITORIA_RESPALDO_PATH`, `LOGOS_STORAGE_PATH`;
- `OTA_URL_SECRET`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS`.

**Antecedente.** Esto ya estaba identificado como T2 de HU-IMP-CFG-03
(`entregas/E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-03_agrofusion-sso/`, informe
`revisiones/VERIF-DOC-agrofusion.md`): «PR a test con `SGPMP_ENTORNO` y sin `AGROFUSION_HUB_*`».
También está relacionado con INC-BE-08 (el compose de TEST no reenvía las variables del motor M04).

## Hipótesis (corte local del 2026-11-20: dev `6cee5fc4`, test `135bc318`, main `0abbeeef`)

Son hipótesis: verifícalas con git el día de la ejecución.

- **H1. El patrón coincide con dev.** En `dev`, tanto `docker-compose.yml` como
  `docker-compose.prod.yml` usan `${VAR:-}` para secretos (`M04_FIRMA_MODELOS_KEY` l. 82/156,
  `IOT_INFERENCIA_M04_TOKEN` l. 89/163, `OTA_URL_SECRET` l. 94/167). Si #1204 hace lo mismo, es
  coherente, pero un secreto vacío deja arrancar el contenedor. Hay que verificar en el código
  qué pasa con cada uno cuando falta: ¿falla al arrancar, falla la funcionalidad de forma
  controlada o falla en silencio? Con eso se decide si conviene proponer `${VAR:?}` en TEST y PROD.
- **H2. `AGROFUSION_HUB_*` sigue en TEST.** `docker-compose.test.yml` l. 66-67 en `test`.
  La descripción de #1204 no dice que las quite. Están obsoletas según el doc. 05 §3 de Desarrollo.
- **H3. PROD tiene el mismo defecto, todavía sin manifestarse.** En `main`,
  `docker-compose.prod.yml` no tiene `SGPMP_ENTORNO`, así que PROD reportaría `DEV`. `dev` y
  `test` ya traen `${SGPMP_ENTORNO:-PROD}` (l. 154), de modo que lo corrige el release a `main`.
  Hay que confirmarlo con `/promover`, y revisar también que `main` reciba las variables de M04 y OTA.
- **H4. `.env.test.example` y el catálogo están desactualizados.** Revisar si
  `.env.test.example` (solo en `test`) y `registros/variables/VARIABLES-ENTORNO.md` tienen las
  11 variables de #1204, con su sensibilidad.
- **H5. `M04_FIRMA_MODELOS_KEY` viene de SEG-M04-01.** Así lo dice la cabecera del compose de dev
  (l. 7, 2026-11-19, RF-69). Hay que ver si esa directriz está asignada a Implementación y qué
  exige por rama. **Confirmado por el revisor (2026-11-20):** el commit `d417c0c6` de dev
  (2026-11-19, SEG-M04-01) agregó `M04_FIRMA_MODELOS_KEY` a los compose y a las plantillas de dev
  sin pasar por Implementación, ya llegó a test y la variable no está en el catálogo. Incluye
  `d417c0c6` en el `/impacto` del paso 1 como cambio de otro equipo.
- **Dato del 2026-11-20:** el SSO responde 401 en DEV y 503 `SSO_NO_CONFIGURADO` en TEST y PROD.
- **H6. Orden de carga del motor.** `IOT_INFERENCIA_M04_URL` se carga **solo** cuando el motor
  tenga modelos (`modelos_cargados > 0`). Si no, los paquetes quedan en FALLIDO tras 5 intentos
  (`entregas/E2_2026-11-03_M03-M04/motor_ia/`). Hay que verificar que siga vigente.

## Fase 1: verificación (solo lectura)

0. **Corte.** `git fetch` en `sgpmp-backend` y `SGMP-Integracion`. Anota los hashes de
   `origin/dev`, `origin/test` y `origin/main`, y el de la cabeza del PR #1204.
   `SGMP-Integracion` debe estar en `main`, actualizado y limpio. Ya se fusionaron los PR #18
   (CFG-03), #19 (E2) y #20 (marcadores). Si `git status` no sale limpio, DETENTE e infórmame.
   Confirma que el PR #1204 sigue abierto. Al 2026-11-20 lo estaba, con 1 commit (`b8968e6`) y
   sin revisiones. Si ya se fusionó, el comentario de la ST-01 se convierte en un PR de
   seguimiento nuestro hacia `test`.
1. **`/impacto https://github.com/Arekkazu/sgpmp-backend/pull/1204`.** El informe debe confirmar
   o descartar H1 a H4 con el diff real del PR, y decir:
   - si el cambio es correcto y si queda en paridad con `docker-compose.yml` y
     `docker-compose.prod.yml` de `dev`;
   - si toca `.env.test.example` o algún otro archivo;
   - qué trabajo nos genera.
   El informe va a `entregas/E4_2026-11-24_M07-M08-final/prs/BE-PR1204_compose-test-entorno-m04/`.
2. **`/promover sgpmp-backend <commit de SGPMP_ENTORNO en dev> main`** (H3). Dime con qué
   commit de dev entró `SGPMP_ENTORNO` al compose de PROD y si llega a `main` con el release o
   hace falta un PR dirigido. Haz lo mismo para las variables de M04 y OTA.
3. **`auditor-seguridad` sobre SEG-M04-01** (H5). Dime el estado por rama, si está asignada a
   chebaz-117 o chebaztian, y qué exige sobre `M04_FIRMA_MODELOS_KEY`.
4. **Subagente `entornos`** (H4 y H6). Haz una tabla con las 11 variables de #1204 y estas
   columnas: nombre · sensibilidad · dónde la lee el código (archivo:línea) · comportamiento si
   falta (H1) · ¿en `.env.test.example`? · ¿en el catálogo? · ¿en `dev` y en `main`? ·
   condición de carga.
5. **Verificación de la re-prueba.** Dime con qué endpoint ve Pruebas
   `SourceSystem.Environment` (TC-M07-378-G025, M07, RF-97) y si se puede comprobar sin
   credenciales. Si hacen falta credenciales, la re-prueba queda en manos de Pruebas y nosotros
   solo verificamos el compose desplegado.
6. **`/planificar`** con el issue #1180 como origen para redactar una **HU nueva** (no CFG-03).
   Dominio sugerido CFG; numérala tú. Subtareas propuestas, que puedes ajustar con lo que encuentres:
   - **ST-01** Comentario en el PR #1204 con los hallazgos (borrador; lo publica el líder).
   - **ST-02** `.env.test.example` (PR a `test`) y catálogo `VARIABLES-ENTORNO.md` con las
     variables de #1204.
   - **ST-03** Ficha para Despliegue: `SGPMP_ENTORNO=TEST`, nombres y sensibilidad de los
     secretos (`M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN`, `OTA_URL_SECRET`), orden de
     carga de `IOT_INFERENCIA_M04_URL` (H6) y que se despliega con **Deploy, no Restart**.
   - **ST-04** Retirar `AGROFUSION_HUB_*` de TEST, solo si #1204 no lo hace (sustituye la T2 de CFG-03).
   - **ST-05** Paridad con PROD (H3), según `/promover`.
   - **ST-06** Registro en `registros/incidencias/registro.md` y verificación cuando #1204 esté
     desplegado en TEST.
   La carpeta de la HU va en `entregas/E4_2026-11-24_M07-M08-final/issues/<HU>_<slug>/`
   (origen: issue, ADR-002).

**Entrega de la fase 1** (no crees archivos fuera de la carpeta del informe de `/impacto`):
- el corte;
- H1 a H6, cada una confirmada o descartada con su evidencia (archivo, línea y hash);
- el resumen del informe de `/impacto`, `/promover` y `auditor-seguridad`;
- la tabla del paso 4;
- el borrador de la HU;
- el **borrador del comentario para el PR #1204**: breve, respetuoso y con evidencia. Debe
  agradecer la corrección, señalar lo que falte (H2, H1 si aplica) y aclarar que el valor de
  `M04_FIRMA_MODELOS_KEY` lo carga Despliegue, mientras que Implementación documenta el nombre,
  la sensibilidad y la regla;
- el **borrador de respuesta en el issue #1180**: indicar que la re-prueba depende de que #1204
  esté desplegado. ¿Conviene pedir que se reabra hasta entonces?;
- las preguntas para mí, para Despliegue y para Desarrollo.

**Detente y espera mi respuesta.**

## Fase 2: ejecución (solo cuando yo apruebe)

Cuando apruebe, te diré qué subtareas se ejecutan. Lo previsto:
1. Crear la rama de la HU nueva desde `origin/main` de `SGMP-Integracion`.
2. Crear la carpeta de la HU (`historia.md`, `entregables/`, `evidencias/`, `revisiones/`),
   guardar este brief y el informe de la fase 1, y agregar la fila en el README de E4.
3. ST-02, ST-03, ST-04 y ST-06 (registro), según lo aprobado. Las tareas de `sgpmp-backend` van
   en una rama nueva hacia `test`, y el PR lo abro yo.
4. En CFG-03, anotar que su T2 pasa a la HU nueva.
5. `/revisar <HU>`. Si el resultado es SOLICITAR CAMBIOS o BLOQUEADO, **detente**.
6. Muéstrame `git diff --cached --stat` antes de cada commit y **espera mi respuesta**.

## Fase 3: cierre (cuando #1204 esté desplegado en TEST)

- Comprobar con Despliegue que se hizo Deploy y no Restart, y verificar según el paso 5 de la fase 1.
- Coordinar la re-prueba con Pruebas (TEX053). Registrar la evidencia y cerrar ST-06.
- Dejar ST-05 en seguimiento hasta el release a `main`.
