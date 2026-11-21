# CA-5 y CA-6 — Plantillas de TEST y de PROD (HU-IMP-CFG-04)

**Fecha:** 2026-11-21 (America/Bogota) · **Corte:** BE `dev@8d4981f6` · `test@cd5f36de` · PR #1204 OPEN `097f6d80`.
**PR:** ST-04a → [#1216](https://github.com/Arekkazu/sgpmp-backend/pull/1216) (`test`, `d873f740`) · ST-05 → [#1217](https://github.com/Arekkazu/sgpmp-backend/pull/1217) (`dev`, `d96449dd`). Los dos están abiertos: CA-5 y CA-6 se cumplen en `origin/test` y `origin/dev` cuando se fusionen. Hasta entonces, las salidas son las de la rama de cada PR.

En Git Bash: `MSYS_NO_PATHCONV=1`.

## CA-5 — `.env.test.example` (rama del #1216)

**(a)** `grep -c AGROFUSION_HUB_` → `0`

**(b)** Compose (`<`) contra plantilla (`>`), con el compose de la cabeza de #1204 (`097f6d80`), es decir, como quedará tras su fusión:

```
1,2d0
< AGROFUSION_HUB_CLIENT_ID
< AGROFUSION_HUB_CLIENT_SECRET
7,10d4
< BROKER_SERVICE_TOKEN
< COOKIE_SAMESITE
< COOKIE_SECURE
< DB_PORT
20d13
< JWT_LEEWAY_SECONDS
```

Ninguna variable de #1204 aparece de un solo lado. `AGROFUSION_HUB_*` es solo-compose hasta ST-04c. Las otras 5 son diferencias previas, opcionales en el compose y listadas en la descripción del #1216. Las obligatorias del compose (`MQTT_BROKER_URL`, `MQTT_BROKER_TOKEN`) entraron a la plantilla en el #1216. Con el compose actual de `test` (antes de #1204), las 10 variables de #1204 salen como solo-plantilla (`>`), como se espera.

**(c)** `grep -nE '^(M04_FIRMA_MODELOS_KEY|IOT_INFERENCIA_M04_TOKEN|OTA_URL_SECRET|MQTT_BROKER_TOKEN)=.+'` → sin salida. Las cuatro llevan el comentario «Sensible: la carga Despliegue».

**(d)** Copia temporal de la plantilla con los vacíos rellenos (`sed 's/=$/=x/'`), contra el compose de `097f6d80`. La copia se borró.

```
$ docker compose -f docker-compose.test.yml --env-file <copia> config --quiet
level=warning msg="The \"JWT_LEEWAY_SECONDS\" variable is not set. Defaulting to a blank string."
level=warning msg="The \"COOKIE_SAMESITE\" variable is not set. Defaulting to a blank string."
level=warning msg="The \"COOKIE_SECURE\" variable is not set. Defaulting to a blank string."
PLANTILLA-OK
```

Los tres avisos son diferencias previas opcionales. Control negativo: sin `MQTT_BROKER_URL` falla con `required variable MQTT_BROKER_URL is missing a value: MQTT_BROKER_URL requerido para TEST`. Ninguna variable obligatoria estaba definida en el entorno del shell. Docker Compose v5.7.0.

## CA-6 — `.env.prod.example` (rama del #1217)

**(a)** `grep -nE '^OTA_URL_(SECRET|BASE|TTL_SEGUNDOS)='`:

```
220:OTA_URL_SECRET=
222:OTA_URL_BASE=
224:OTA_URL_TTL_SEGUNDOS=86400
```

`grep -nE '^OTA_URL_SECRET=.+'` → sin salida.

**(b)** Lo mismo que CA-5 (d), con `docker-compose.prod.yml` de la misma rama:

```
$ docker compose -f docker-compose.prod.yml --env-file <copia> config --quiet
PLANTILLA-OK
```

Sin avisos. Control negativo: sin `FRONTEND_URL` falla con `required variable FRONTEND_URL is missing a value`. Nota (REV-06 n-03): (b) prueba que la plantilla levanta el compose, no que tenga `OTA_URL_*`. Como el compose usa `${OTA_URL_*:-}`, la plantilla de `origin/dev` sin OTA también pasa. La presencia de `OTA_URL_*` la prueba (a).

## Pendiente

Repetir (a), (b) y (c) sobre `origin/test` y `origin/dev` después de las fusiones. La parte (b) de CA-5 sobre `origin/test`, después de la fusión de #1204.
