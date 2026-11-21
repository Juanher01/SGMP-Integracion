# EXT-BACK-PR1204 — Variables de entorno de M04/M07 en el compose de TEST (incluye EXT-BACK-d417c0c)

## 1. Ficha

| Campo | Valor |
|---|---|
| Repo | Arekkazu/sgpmp-backend |
| Cambio principal | PR #1204 `fix/compose-test-entorno-m04-1180` → `test`, 1 commit `b8968e68` (2026-11-20 11:12 -05) |
| Autor / equipo | Arekkazu / Desarrollo |
| Estado | ABIERTO, `MERGEABLE`, 0 revisiones. Aprueba: Líder de Pruebas |
| Base del PR | `135bc318`; `origin/test` avanzó 9 commits a `12965211`, sin cambios en `docker-compose.test.yml` (`git diff --stat 135bc318 origin/test -- docker-compose.test.yml` vacío) |
| Origen | Issue #1180 (Pruebas, TC-M07-378-G025, RF-97): en TEST `SourceSystem.Environment` vale `"DEV"`. Cerrado el 2026-11-20 antes de desplegar la corrección |
| Cambio incluido | Commit `d417c0c6` (Arekkazu, 2026-11-19), SEG-M04-01 (#1161, autor Juandks12, asignado a Arekkazu: directriz de Desarrollo, no de Análisis) |
| Corte | `git fetch` del 2026-11-20 · `origin/dev 6cee5fc4` · `origin/test 12965211` · `origin/main 0abbeeef` · `origin/pr-1204 b8968e68` |
| Entrega | E4 (2026-11-24, M07-M08), por indicación del líder |
| Análisis | 2026-11-20 22:39 (America/Bogota) |

## 2. Qué se hizo

**Problema (verificado).** En `test`, `src/accounting_integration/infrastructure/configuracion.py:18@12965211` lee
`os.getenv("SGPMP_ENTORNO", "DEV")`. `docker-compose.test.yml@12965211` no tenía `SGPMP_ENTORNO` en `environment:`, así que
el contenedor nunca la recibía y el documento AAEF salía con `DEV` aunque Dokploy tuviera `TEST`. La descripción del PR lo
diagnostica igual, y coincide con lo que ya registraba HU-IMP-CFG-03 ST-02 (catálogo, `VARIABLES-ENTORNO.md:340`).

**Cambio (diff real, `git diff 135bc318 b8968e68`).** Solo `docker-compose.test.yml`, 18 líneas añadidas en el
`environment:` del `backend` (numeración en `b8968e68`):

| Línea | Variable | Expresión |
|---|---|---|
| 71 | `SGPMP_ENTORNO` | `${SGPMP_ENTORNO:-TEST}` |
| 73 | `M04_FIRMA_MODELOS_KEY` | `${…:-}` |
| 75 | `LOGOS_STORAGE_PATH` | `${…:-/tmp/sgpmp_logos}` |
| 78-81 | `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_M04_TOKEN`, `IOT_INFERENCIA_TLS_MIN` (`:-1.3`), `IOT_INFERENCIA_CA_FILE` | `${…:-}` salvo TLS |
| 82 | `IOT_AUDITORIA_RESPALDO_PATH` | `${…:-var/auditoria_iot/fallas.sqlite3}` |
| 84-86 | `OTA_URL_SECRET`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS` (`:-86400`) | `${…:-}` salvo TTL |

Más una fila en la tabla de cambios de la cabecera (l. 5) y comentarios por bloque. Se conservan
`AGROFUSION_HUB_CLIENT_ID/SECRET` (l. 67-68, líneas de contexto). No toca `.env.test.example`, Dockerfile ni otro archivo.

**Descripción vs. diff.** La descripción afirma "si no se definen en Dokploy, TEST se comporta igual que hoy". Es cierto para
10 de las 11 variables, **no** para `IOT_AUDITORIA_RESPALDO_PATH` (ver §5, hallazgo A). También dice que
`M04_FIRMA_MODELOS_KEY` "debe definirse en TEST antes de que llegue la firma de modelos (#1190)": la verificación de firma
**ya está en `test`** (`d417c0c6` es ancestro de `origin/test`), así que hoy TEST no puede registrar ni activar modelos.

**Commit `d417c0c6` (SEG-M04-01).** Lógica de Desarrollo (firma HMAC-SHA256 del SHA-256 del artefacto con
`M04_FIRMA_MODELOS_KEY`, `src/prediction/domain/services/firma_artefacto.py`) más cambios en archivos de Implementación sin
pasar por Implementación: `docker-compose.yml` (+`M04_FIRMA_MODELOS_KEY: ${…:-}`, hoy l. 82 de `dev`),
`docker-compose.prod.yml` (l. 156), `.env.example` (l. 182) y `.env.prod.example` (l. 266, "obligatoria … La define
Seguridad"). No tocó `docker-compose.test.yml` ni `.env.test.example`: de ahí el hueco que ahora cierra el PR.

## 3. Estado por rama

| Cambio | dev `6cee5fc4` | test `12965211` | main `0abbeeef` | Evidencia |
|---|---|---|---|---|
| `d417c0c6` | INCLUIDO | INCLUIDO | AUSENTE | `git merge-base --is-ancestor d417c0c6 origin/<rama>` |
| `b8968e68` (PR #1204) | No aplica (solo toca `docker-compose.test.yml`) | AUSENTE (PR abierto) | No aplica | `gh pr view 1204` → `OPEN`, `reviews: []` |
| Código que lee las 11 variables | Sí | Sí | Solo `LOGOS_STORAGE_PATH` (`src/shared/almacen_logos.py:45`) | `git grep` por rama |

## 4. Archivos de Implementación tocados y conformidad

Cambio de otro equipo en archivo de Implementación: `docker-compose.test.yml` (PR #1204) y `docker-compose.yml`,
`docker-compose.prod.yml`, `.env.example`, `.env.prod.example` (`d417c0c6`).

| Regla (skill) | PR #1204 | `d417c0c6` |
|---|---|---|
| Toda variable que el código lee pasa por `environment:` (compose-entornos 4, variables-entorno 3) | **Conforme**: cierra la brecha de 11 variables en TEST | Conforme en DEV/PROD; dejó TEST sin la variable |
| Plantilla `.env.<entorno>.example` (variables-entorno 2) | **Desviación**: `.env.test.example@12965211` (64 líneas, último cambio `efa68fef` 2026-10-09) no tiene ninguna de las 11 | Conforme en `.env.example` y `.env.prod.example`; omitió `.env.test.example` |
| Catálogo (`VARIABLES-ENTORNO.md`) | 10 de 11 sin fila (solo `SGPMP_ENTORNO`, l. 92) | `M04_FIRMA_MODELOS_KEY` sin fila |
| Variables críticas con `${VAR:?}` en TEST/PROD (compose-entornos 3) | `:-` en todas; ver H1 | `:-` en PROD aunque la plantilla la declara obligatoria |
| Rutas persistentes, nunca `/tmp` en TEST/PROD (compose-entornos 9) | **Desviación** (preexistente por el valor por defecto del código): logos en `/tmp` sin volumen | No aplica |
| No sobrescribir decisiones de la imagen | **Desviación**: sobrescribe el `ENV` del Dockerfile (hallazgo A) | No aplica |
| Variables exclusivas de TEST (compose-entornos 10) | `ENABLE_TEST_SANDBOX`/`TEST_SANDBOX_SECRET` siguen solo en TEST: conforme | No aplica |

## 5. Impacto

### Hipótesis del líder

**H1 — patrón `${VAR:-}` y comportamiento sin el secreto. CONFIRMADA la coincidencia con `dev`; el código falla de forma controlada.**
`docker-compose.yml@6cee5fc4` l. 82, 89, 94 y `docker-compose.prod.yml@6cee5fc4` l. 156, 163, 167 usan `${VAR:-}` igual que el PR.
Comportamiento en el código (idéntico en `test` y `dev`, mismas líneas):

| Secreto vacío | Qué hace el código | Clase |
|---|---|---|
| `M04_FIRMA_MODELOS_KEY` | Registro: `registrar_version_modelo_use_case.py:401-406` → `logger.error` + `ServiceUnavailableError FIRMA_MODELOS_NO_CONFIGURADA` (503). Activar / sombra / copiar a animal: `activar_version_modelo_use_case.py:47`, `asignar_version_animal_use_case.py:83` → `version_modelo.py:206-209` `firma_valida(..., "")` es `False` → `BusinessRuleError FIRMA_ARTEFACTO_INVALIDA` | Controlada al registrar; al activar, controlada pero **engañosa**: culpa a la firma del modelo, no a la clave faltante, y no deja log de configuración |
| `IOT_INFERENCIA_M04_TOKEN` | Entrante (motor → backend): `src/shared/broker_auth.py:33-38,70` → 503 `TOKEN_SERVICIO_NO_CONFIGURADO`. Saliente: `motor_inferencia_http_adapter.py:117,129-130` envía **sin** `Authorization`; si el motor rechaza, `logger.error` y el paquete queda pendiente | Controlada; solo aplica si `IOT_INFERENCIA_M04_URL` está definida (URL vacía = stub, estado válido por diseño, l. 110-111) |
| `OTA_URL_SECRET` (o `OTA_URL_BASE`) | `ota_edge_adapters.py:94-100` `configurada()` falso → `crear_distribucion_ota_use_case.py:78-81` 503 `OTA_NO_CONFIGURADA`; `es_valida` rechaza toda URL | Controlada |

Ninguno falla al arrancar. Recomendación sobre `${VAR:?}`: **no** en TEST (Pruebas necesita que el backend despliegue aunque
M04/OTA no estén listos; las tres funciones degradan con 503) ni para `IOT_INFERENCIA_M04_TOKEN`/`OTA_*` en PROD (su
obligatoriedad depende de que la función esté habilitada, y compose no expresa "obligatoria si X"). Candidata en PROD:
`M04_FIRMA_MODELOS_KEY`, que `.env.prod.example:264` declara "obligatoria", **cuando `d417c0c6` llegue a `main`**; el costo es
que su ausencia tumba todo el backend de PROD por una función de M04. Decide el líder (pregunta P2).

**H2 — `AGROFUSION_HUB_*` en TEST sin uso. CONFIRMADA.** `docker-compose.test.yml@b8968e68` l. 67-68 y
`.env.test.example@12965211` l. 54-55. `git grep AGROFUSION_HUB origin/test` solo encuentra esos dos archivos (cero en `*.py`);
lo mismo en `origin/dev`. En `origin/main` sí se leen (`main.py:671`, `src/shared/agrofusion_auth.py:19-20`) y están en
`docker-compose.prod.yml@0abbeeef` l. 149-150: no se retiran de PROD hasta el release (decisión ya registrada,
`VARIABLES-ENTORNO.md` "AGROFUSION_HUB_* en PROD"). El PR no las retira de TEST: ST-02 de HU-IMP-CFG-03 queda a medias.

**H3 — PROD sin `SGPMP_ENTORNO`. CONFIRMADA.** `docker-compose.prod.yml@0abbeeef`: ninguna de las 11 salvo `LOGOS_STORAGE_PATH`
(l. 145); `main` tampoco tiene el código que la lee (sin hits en `*.py`), así que hoy no hay efecto. `docker-compose.prod.yml`
de `dev` y de `test` sí la tienen (l. 154 `${SGPMP_ENTORNO:-PROD}`). Llega a PROD con el release; nada que adelantar.

**H4 — plantilla y catálogo. CONFIRMADA la brecha.**
- `.env.test.example@12965211`: **0 de 11**. El PR no lo toca.
- `.env.prod.example@6cee5fc4`: 7 de 11; faltan `OTA_URL_SECRET`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS` (aunque `docker-compose.prod.yml@6cee5fc4` l. 167-169 las referencia) y `IOT_AUDITORIA_RESPALDO_PATH` (coherente: PROD no la pasa).
- `.env.example@6cee5fc4`: 10 de 11 (falta `IOT_AUDITORIA_RESPALDO_PATH`, que DEV fija en el compose).
- `SGMP-Integracion/registros/variables/VARIABLES-ENTORNO.md` (main `f40300b`): solo `SGPMP_ENTORNO` (l. 92). Faltan las otras 10, con sensibilidad: **sensibles** `M04_FIRMA_MODELOS_KEY`, `IOT_INFERENCIA_M04_TOKEN`, `OTA_URL_SECRET`; **no sensibles** `LOGOS_STORAGE_PATH`, `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_TLS_MIN`, `IOT_INFERENCIA_CA_FILE`, `IOT_AUDITORIA_RESPALDO_PATH`, `OTA_URL_BASE`, `OTA_URL_TTL_SEGUNDOS`.

### Hallazgos adicionales

**A. Regresión: `IOT_AUDITORIA_RESPALDO_PATH` relativo sobrescribe el `ENV` de la imagen (severidad media).**
- Hecho: `Dockerfile@12965211` l. 55-56 crea `/app/storage/auditoria_iot` con dueño 1000 y l. 61 fija
  `ENV IOT_AUDITORIA_RESPALDO_PATH=/app/storage/auditoria_iot/fallas.sqlite3`. Hoy TEST usa esa ruta.
- Hecho: con el PR, el compose entrega `var/auditoria_iot/fallas.sqlite3` (el `environment:` del compose gana sobre el
  `ENV`). Es relativa a `WORKDIR /app` (l. 6). `var/` no está en el repo (`git ls-tree origin/test var` vacío) y
  `.dockerignore` l. 19 la excluye.
- Hecho (simulación): `docker run --rm --user 1000 -w /app python:3.13-slim sh -c 'mkdir -p var/auditoria_iot'` →
  `drwxr-xr-x root root /app` · `mkdir: cannot create directory 'var': Permission denied`.
- Consecuencia (hipótesis fuerte): `respaldo_auditoria_iot_sqlite_adapter.py:21` (`mkdir`) lanzará `PermissionError` justo
  cuando la base falla y hay que resguardar la auditoría (`resguardar_falla_persistencia_use_case.py:30`, RF-53/INC-M03-125-G12):
  se pierde la evidencia que el mecanismo debía proteger. Confirmación definitiva: construir la imagen de `b8968e68` y
  ejecutar `docker run --rm --entrypoint sh <img> -c 'mkdir -p /app/var/x'`.
- Corrección mínima: quitar la línea 82 (TEST hereda el `ENV` de la imagen, como PROD) o fijarla como en DEV
  (`/app/storage/auditoria_iot/fallas.sqlite3`). Aun así TEST no tiene volumen para esa ruta (ver C).

**B. `LOGOS_STORAGE_PATH` en `/tmp` sin volumen (preexistente, no lo introduce el PR).** El valor es el mismo que el código usa
por defecto (`almacen_logos.py:45`), así que no cambia nada hoy. Pero viola compose-entornos 9: los logotipos de TEST se
pierden en cada redespliegue (igual `MODELOS_STORAGE_PATH:-/tmp/sgpmp_modelos`, l. 63). DEV y PROD usan el volumen de modelos
(`/app/storage/modelos/logos`). Problema real para el ciclo de Pruebas (RF-26), de Implementación (AMB).

**C. Respaldo de auditoría IoT sin volumen en TEST y PROD.** DEV monta `sgpmp_auditoria_iot` (`docker-compose.yml@6cee5fc4`
l. 99, 123); `docker-compose.prod.yml@6cee5fc4` no pasa la variable (usa el `ENV` de la imagen, correcto) pero tampoco monta
volumen (l. 177-178): los pendientes se pierden si el contenedor se recrea antes de sincronizar. Hipótesis de impacto, a
confirmar con Desarrollo (Leandro, RF-53) si el respaldo debe sobrevivir a un redespliegue.

### Paridad (nombres en `environment:` del backend)

`comm` entre `docker-compose.test.yml@b8968e68` y `docker-compose.yml@6cee5fc4`: TEST tiene **todas** las de DEV; de más:
`AGROFUSION_HUB_*` (H2, sobran) y `ENABLE_TEST_SANDBOX`/`TEST_SANDBOX_SECRET` (intencionales). Frente a
`docker-compose.prod.yml@6cee5fc4`: falta `MQTT_BROKER_HTTP_TIMEOUT` en TEST (y en DEV; el código usa 35 por defecto, sin
efecto, solo visibilidad del acoplamiento con el broker) y TEST pasa `IOT_AUDITORIA_RESPALDO_PATH`, que PROD no pasa.
Valores: `SGPMP_ENTORNO` DEV `:-DEV` / TEST `:-TEST` / PROD `:-PROD` (correcto); `LOGOS_STORAGE_PATH` y
`IOT_AUDITORIA_RESPALDO_PATH` difieren (B y A). Variables que el código de `test` lee y ningún compose pasa (usan su valor por
defecto; no las introduce este PR): `CAPTURAS_STORAGE_PATH`, `OTA_ARTEFACTOS_DIR`, `AUDITORIA_M04_DIR_RESPALDO`, `M07_*`,
`IOT_POSTCOMMIT_*`, `REENTRENAMIENTO_*`, entre otras. Las tres de rutas (`CAPTURAS_STORAGE_PATH`, `OTA_ARTEFACTOS_DIR`,
`AUDITORIA_M04_DIR_RESPALDO`) merecen la misma revisión de persistencia (pregunta P4).

### Lista de impacto

| Punto | Resultado |
|---|---|
| Variables nuevas/renombradas/eliminadas | Sí: 11 nuevas en el compose de TEST; ninguna renombrada ni eliminada. Cadena rota en plantilla y catálogo (H4) |
| Paridad | Mejora fuerte; quedan A, B, `AGROFUSION_HUB_*` y `MQTT_BROKER_HTTP_TIMEOUT` |
| Dependencias, imagen base, usuario, etapa | No |
| Servicios, puertos, healthchecks, volúmenes, redes | No cambia; carece de volúmenes para logos y auditoría (B, C) |
| Orígenes externos / CSP / ROOT_PATH / CORS | No (el motor M04 lo llama el backend, no el navegador) |
| Workflows y SEG | No toca workflows. SEG-M04-01 es de Desarrollo; no requiere fila en `registro-SEG.md` salvo que el líder decida seguirla |
| Cambios temporales | No |
| Secretos | Solo nombres; ningún valor en el diff ni en este informe |
| Efecto al desplegar | Si Dokploy de TEST ya tiene `IOT_INFERENCIA_M04_URL` u `OTA_URL_*`, empiezan a aplicarse (el PR lo advierte). Sin `M04_FIRMA_MODELOS_KEY` cargada, M04 sigue en 503 al registrar |

### Veredicto técnico (no es aprobación)

El cambio es **correcto en su objetivo** (corrige la causa real de #1180 y alinea TEST con DEV) y recomendable de fusionar
**con una corrección**: quitar o fijar a ruta absoluta `IOT_AUDITORIA_RESPALDO_PATH` (l. 82). Queda incompleto en
plantilla, catálogo y retiro de `AGROFUSION_HUB_*`.

## 6. Trabajo derivado

| Tipo | Trabajo |
|---|---|
| Equipo autor (Desarrollo) | Comentario en PR #1204 sobre el hallazgo A (borrador 1). El líder decide si lo publica |
| Implementación (CFG) | HU: `.env.test.example` con las 11 variables y sensibilidad; retirar `AGROFUSION_HUB_*` de `docker-compose.test.yml` y `.env.test.example` (PR a `test`, después de que se fusione #1204 para no chocar); `OTA_URL_*` en `.env.prod.example` (PR a `dev`); 10 filas nuevas en `VARIABLES-ENTORNO.md`. Reescribir ST-02 de HU-IMP-CFG-03: `SGPMP_ENTORNO` lo resuelve #1204 |
| Implementación (AMB) | HU: volúmenes con nombre para logos y respaldo de auditoría en TEST (`sgpmp_modelos_test`, `sgpmp_auditoria_iot_test`) y respaldo de auditoría en PROD; revisar `CAPTURAS_STORAGE_PATH`, `OTA_ARTEFACTOS_DIR`, `AUDITORIA_M04_DIR_RESPALDO` |
| Implementación (decisión) | `${M04_FIRMA_MODELOS_KEY:?}` en `docker-compose.prod.yml` cuando SEG-M04-01 llegue a `main` (P2) |
| Despliegue | Ficha de variables (borrador 2). Sin cambios de puertos ni Traefik |
| Pruebas | Re-probar #1180 tras el despliegue (el issue está cerrado sin la corrección desplegada) |
| Seguimiento | Fusión de #1204 y redespliegue de TEST; luego `SourceSystem.Environment = "TEST"` |
| Promoción | Ninguna desde Implementación: el cambio de `d417c0c6` en DEV/PROD viaja con el release (estrategia A) |

### Borrador 1 — comentario para PR #1204 (lo publica el líder si lo decide)

> Gracias por cerrar la causa real de #1180. Una observación antes de fusionar, de Implementación:
>
> `IOT_AUDITORIA_RESPALDO_PATH: ${IOT_AUDITORIA_RESPALDO_PATH:-var/auditoria_iot/fallas.sqlite3}` (l. 82) sobrescribe el
> `ENV IOT_AUDITORIA_RESPALDO_PATH=/app/storage/auditoria_iot/fallas.sqlite3` del Dockerfile (l. 61), que es la carpeta que la
> imagen prepara con dueño 1000 (l. 55-56). La ruta relativa resuelve a `/app/var/...`; `/app` pertenece a root y el proceso
> corre como 1000, así que el `mkdir` del respaldo (`respaldo_auditoria_iot_sqlite_adapter.py:21`) fallaría con
> `Permission denied` justo cuando la base no responde. Reproducción: `docker run --rm --user 1000 -w /app python:3.13-slim sh -c 'mkdir -p var/auditoria_iot'`.
>
> Propuesta: quitar la línea (TEST hereda el valor de la imagen, como PROD) o fijarla a `/app/storage/auditoria_iot/fallas.sqlite3`
> como en `docker-compose.yml`. La plantilla `.env.test.example` y el retiro de `AGROFUSION_HUB_*` los tomamos en Implementación en un PR aparte.

### Borrador 2 — ficha de variables para Despliegue (sin valores)

| Variable | Servicio | Entorno(s) | Obligatoria | Tipo | Provee el valor | Acción en Dokploy | Rebuild |
|---|---|---|---|---|---|---|---|
| `SGPMP_ENTORNO` | backend | TEST | No (por defecto `TEST`) | Comportamiento | Implementación | Opcional: `TEST` | No |
| `M04_FIRMA_MODELOS_KEY` | backend | TEST (ya en DEV; PROD con el release) | Sí para registrar/activar modelos | Sensible | Seguridad / Desarrollo (proceso de entrenamiento) | Crear | No |
| `IOT_INFERENCIA_M04_URL` | backend | TEST | Solo si se habilita el motor M04 | Conexión | AIoT / Desarrollo | Crear cuando el motor de TEST exista | No |
| `IOT_INFERENCIA_M04_TOKEN` | backend | TEST | Sí si hay URL | Sensible | AIoT / Desarrollo | Crear con la URL | No |
| `IOT_INFERENCIA_TLS_MIN`, `IOT_INFERENCIA_CA_FILE` | backend | TEST | No | Comportamiento | Desarrollo | No cargar salvo indicación | No |
| `OTA_URL_SECRET` | backend | TEST | Solo si se usa OTA | Sensible | Desarrollo | Crear si Pruebas prueba OTA | No |
| `OTA_URL_BASE` | backend | TEST | Con `OTA_URL_SECRET` | Conexión | Despliegue (URL pública del backend de TEST) | Crear con la anterior | No |
| `OTA_URL_TTL_SEGUNDOS`, `LOGOS_STORAGE_PATH`, `IOT_AUDITORIA_RESPALDO_PATH` | backend | TEST | No | Comportamiento | — | **No cargar** (usar los del compose/imagen) | No |

Verificación posterior (sin imprimir valores): `docker exec <backend-test> sh -c 'for v in SGPMP_ENTORNO M04_FIRMA_MODELOS_KEY OTA_URL_SECRET; do [ -n "$(printenv $v)" ] && echo "$v presente" || echo "$v ausente"; done'`.

### Resumen para `/planificar`

Origen: EXT-BACK-PR1204 (este informe). Dominio sugerido **CFG** (con una subtarea AMB o HU AMB aparte para volúmenes).
Alcance: (1) `.env.test.example` en `test` con las 11 variables, retiro de `AGROFUSION_HUB_*` en compose y plantilla de TEST;
(2) `OTA_URL_*` en `.env.prod.example` de `dev`; (3) 10 filas del catálogo; (4) volúmenes de logos y auditoría IoT en TEST
y de auditoría en PROD; (5) actualizar ST-02 de HU-IMP-CFG-03. Dependencia: fusión de #1204 (con el hallazgo A resuelto).
Plazo: antes de E4 (2026-11-24) para (1) y (3).

## 7. Preguntas abiertas para el líder

1. ¿Se publica el borrador 1 en #1204 antes de que Pruebas lo fusione? Si se fusiona tal cual, la corrección de A pasa a la HU CFG.
2. ¿`${M04_FIRMA_MODELOS_KEY:?}` en PROD cuando SEG-M04-01 llegue a `main`, aceptando que su ausencia impida desplegar todo el backend?
3. ¿Se le pide a Pruebas reabrir #1180 hasta verificar en TEST, o se sigue desde este informe?
4. ¿Los logos, modelos y respaldos de TEST deben sobrevivir a un redespliegue? Si sí, HU AMB de volúmenes (y revisar las otras rutas con valor por defecto).
5. Cuarto cambio ajeno a archivos de Implementación en una semana (#1129, #1130, `d417c0c6`, #1204), todos sin plantilla de TEST ni catálogo: ¿se propone a Desarrollo un acuerdo (avisar a Implementación o etiquetarla como revisora cuando toquen compose o `.env*.example`)?
