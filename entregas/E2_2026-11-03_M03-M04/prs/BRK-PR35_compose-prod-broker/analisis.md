# EXT-BRK-PR35 — Compose y catálogo de variables de PROD del broker (BRK-10)

> Análisis de cambio externo · Implementación · 2026-10-23 · Entrega E2 (indicada por el líder)
> Solo lectura: no se comentó en GitHub ni se editó ningún repositorio de código ni registro vivo.

## 1. Ficha

| Campo | Valor |
|---|---|
| Repositorio | `SerBy48/BROKER-MQTT-SGPMP` (carpeta local `BROKER-MQTT-SGPMP`) |
| PR | [#35](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/35) "feat(prod): docker-compose y catálogo de variables de PROD del broker (BRK-10)" · Taiga #3518 |
| Autor del PR | Arekkazu (Desarrollo) |
| Rama origen → destino | `feat/ambiente-prod` → `develop` |
| Estado | `MERGED` el 2026-10-19 22:17 UTC (17:17 -0500), commit de fusión `8dbb3c2`. Sin revisores (`reviews: []`) |
| Archivos | `.env.prod.example`, `.gitignore`, `docker-compose.prod.yml` (los tres son de Implementación) |
| Commits | `591c022`, `55a8bd9`, `af9da57` (chebaz-117/chebaztian, 2026-09-11, Implementación) · `37baf34` (merge de `develop` en la rama, Arekkazu, 2026-10-17) · `bb8fc19` (alineación del compose de PROD, Arekkazu, 2026-10-17) |
| Fetch | 2026-10-23 ~19:05 -0500, `git fetch --prune origin` |
| Hashes del broker | `develop@4895f08` (0.4.0-rc.4, 2026-10-20) · `test@c10d81a` (PR #40, 2026-10-22) · `main@cebd430` (0.3.0, 2026-10-12) |
| Hashes del backend (contraste) | `dev@0995813c` · `test@06a68aca` · `main@0abbeeef` |

## 2. Qué se hizo

**Problema que resuelve (según la descripción).** La rama `feat/ambiente-prod` que abrió Implementación en septiembre
(compose y plantilla de PROD) había quedado atrás de `develop`, que en el intervalo cambió de modelo de autenticación
(archivo de contraseñas → plugin dynamic-security, SEG-BROKER-03), agregó TLS hacia afuera (SEG-BROKER-02 / TC-M09-253)
y nuevas variables del gateway (BRK-01, BRK-02, TC-M09-252). Arekkazu integró `develop` (`37baf34`, merge limpio) y
reescribió el compose y la plantilla de PROD para que coincidan con ese código (`bb8fc19`).

**Qué muestra el diff de `bb8fc19` contra nuestra versión (`af9da57`)** (`git diff af9da57 bb8fc19 -- docker-compose.prod.yml .env.prod.example`):

| # | Cambio | Nuestra versión (`af9da57`) | Versión fusionada (`bb8fc19`, = `develop`) |
|---|---|---|---|
| 1 | Credencial compartida de dispositivos en `mosquitto` | `MQTT_DEVICE_USERNAME/PASSWORD` **obligatorias** (`:?`) | **Opcionales** (`:-`), "lo esperado en PROD es dejarlas vacías" (compose l. 61–62; plantilla l. 96–112). Cada Gateway Edge tiene credencial propia en dynamic-security |
| 2 | Credencial compartida en `gateway` | No se pasaba | Se pasa también al gateway (compose l. 238–239): el gateway la mantiene o la borra en dynamic-security |
| 3 | TLS hacia afuera | Comentado y desactivado, con un bloque explicativo de 4 prerrequisitos; mapeo `:1883`/`:9001` en claro | **Activo por defecto**: `MQTT_PUERTO_PUBLICO` 8883 y `MQTT_WS_PUERTO_PUBLICO` 9002 (l. 68–69); mapeos `${MQTT_HOST_PORT:?}:${MQTT_PUERTO_PUBLICO:-8883}` y `${MQTT_WS_HOST_PORT:?}:${MQTT_WS_PUERTO_PUBLICO:-9002}` (l. 92–93) |
| 4 | Certificados | Montaje `./docker/certs` comentado | Montaje activo `./docker/certs:/mosquitto/certs:ro` (l. 99). Sin `fullchain.pem`/`privkey.pem`, el entrypoint aborta (`docker/mosquitto-entrypoint.sh` l. 93–95) |
| 5 | Variables nuevas del gateway | No existían | `MQTT_ACK_REQUIERE_ID_COMANDO` (l. 232), `MQTT_TOPIC_RESULTADO` (l. 234), `BACKEND_URL` (l. 246, `:?`), `BROKER_SERVICE_TOKEN` (l. 247, `:?`), `BACKEND_TIMEOUT_SECONDS` (l. 248) |
| 6 | Notas de operación | Rotación/revocación con `mosquitto_passwd -D`; nota de que TEST omitía las credenciales de dispositivos | Revocación desde la plataforma (`DELETE /v1/devices/{serial}/credential`); se borró la advertencia sobre el compose de TEST |
| 7 | Sin cambios | — | `name: sgpmp-broker-prod`, redes `broker-interna` + `sgpmp-network` externa (l. 322, 333–334), `DATABASE_URL` armada desde `DB_*`, healthchecks, `restart: always`, límites y `logging` |

**Descripción vs. diff.** Lo que dice la descripción coincide con el diff. Dos matices: (a) la descripción no menciona que
`BACKEND_URL` se define como **URL interna por `sgpmp-network`** (plantilla l. 198–203: "Nunca el dominio público"),
que choca con lo que el mismo autor indicó tres días después para TEST (§5.3); (b) "docker compose config renderiza con
valores ficticios" se reprodujo hoy (ver §4).

## 3. Estado por rama

Comando: `git merge-base --is-ancestor <commit> origin/<rama> && echo INCLUIDO || echo AUSENTE` tras el fetch del 2026-10-23.

| Commit | `develop@4895f08` | `test@c10d81a` | `main@cebd430` |
|---|---|---|---|
| `591c022` `55a8bd9` `af9da57` (Implementación) | INCLUIDO | INCLUIDO | AUSENTE |
| `37baf34` (merge de develop) | INCLUIDO | INCLUIDO | AUSENTE |
| `bb8fc19` (alineación PROD) | INCLUIDO | INCLUIDO | AUSENTE |
| `8dbb3c2` (fusión del PR #35) | INCLUIDO | INCLUIDO | AUSENTE |
| `08247c0` (hotfix aviso `BACKEND_URL`, PR #40) | **AUSENTE** | INCLUIDO | AUSENTE |

- El PR #35 llegó a `test` con el PR #39 (`develop → test`, `39ad6a0`, 2026-10-22).
- `main` no los tiene: `git cherry -v origin/main bb8fc19` lista los 5 commits con `+` (sin equivalentes por cherry-pick) y
  `git ls-tree origin/main` no contiene `docker-compose.prod.yml` ni `.env.prod.example`.
- `develop` no tiene el hotfix `08247c0` (`git cherry -v origin/develop 08247c0` → `+`). Como el release va
  `develop → main`, ese aviso **no llegará a PROD** si AIoT no lo lleva de vuelta a `develop`.
- `docker-compose.test.yml` existe **solo** en `test` (último cambio `d5b59ef`, 2026-09-08, Miguel Ortiz); el PR #35 no lo tocó.

## 4. Archivos de Implementación tocados y conformidad

Los tres archivos son **de Implementación** y fueron modificados por **otro equipo** (Desarrollo, Arekkazu) sin revisión.

| Archivo | Regla (skill) | Resultado |
|---|---|---|
| `docker-compose.prod.yml` | Guardas `${VAR:?mensaje}` en críticas (compose-entornos 3, variables-entorno 5) | Conforme. Verificado: `docker compose -f docker-compose.prod.yml --env-file .env.prod.example config --quiet` → exit 1 con "MQTT_HOST_PORT es obligatoria en PROD…"; con valores ficticios → exit 0; quitando `BROKER_SERVICE_TOKEN` → falla con su mensaje |
| | Toda variable en `environment:` (compose-entornos 4) | Parcial: faltan `MQTT_COLA_CAPACIDAD`, `MQTT_COLA_WORKERS` (BRK-09, `app/config.py` l. 71–72) y `MQTT_TOPIC_VISION/EVENTO/OTA` (l. 52–54). Toman su default del código, pero en PROD no se pueden ajustar desde Dokploy, a diferencia de DEV/TEST (`env_file: .env`) |
| | Servicios web sin `ports:` (regla 1) | Conforme: el gateway solo `expose: 8000`. `mosquitto` publica puertos porque MQTT no pasa por Traefik (excepción documentada) |
| | Puertos de host los asigna Despliegue (regla 2) | Conforme: `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT` sin default y con guarda |
| | `restart: always`, `logging` 10m×3, límites, healthcheck en 127.0.0.1 (reglas 5–6) | Conforme (l. 134, 303; healthcheck del gateway contra `http://127.0.0.1:8000/v1/healthz`) |
| | Red PROD: `dokploy-network` externa (regla 8) | **Desviación (heredada de nuestro `55a8bd9`, no introducida por `bb8fc19`)**: el broker declara `sgpmp-network` externa. El backend la abandonó en PROD por el error "network sgpmp-network not found" y usa `dokploy-network` (`sgpmp-backend` `origin/dev:docker-compose.prod.yml` l. 15–19 y 215–230). Ver H-01 |
| | Volúmenes con nombre por entorno (regla 9) | Conforme: `mosquitto_secrets_prod` |
| | Comentarios en español con el porqué (regla 11) | Conforme; se eliminó nuestra advertencia sobre la omisión en TEST (ver H-05) |
| `.env.prod.example` | Sin valores reales; sensibles vacías; comentario por variable (variables-entorno 2) | Conforme. Todas las sensibles vacías (`DB_IOT_PASSWORD`, `MQTT_PASSWORD`, `MQTT_DEVICE_PASSWORD`, `BROKER_SERVICE_TOKEN`); valores de ejemplo solo en no sensibles (puertos, topics, timeouts). No hay cadenas con forma de credencial |
| | Un nombre, tres valores (regla 1) | Conforme en nombres; ver paridad §5.2 |
| `.gitignore` (`591c022`, nuestro) | Excluir `.env*` locales | Conforme |

Fuera del PR, pero visto al recorrer la cadena: el `Dockerfile` del gateway no declara `USER` (corre como root) — es de AIoT
y no cambió aquí; queda como observación.

## 5. Impacto

| Punto | Sí/No | Evidencia |
|---|---|---|
| Variables nuevas | Sí | 5 en el gateway (§5.1). Además `MQTT_PUERTO_PUBLICO`/`MQTT_WS_PUERTO_PUBLICO` pasan a tener default 8883/9002 en PROD |
| Variables renombradas o eliminadas | No | `MQTT_DEVICE_*` cambian de obligatorias a opcionales |
| Paridad | **No hay** | §5.2 |
| Dependencias, imágenes base, usuario | No | Ni `Dockerfile` ni `Dockerfile.mosquitto` cambian |
| Servicios, puertos, volúmenes, redes | Sí | Puertos de contenedor publicados pasan a 8883/9002; nuevo montaje `./docker/certs`; red `sgpmp-network` sin cambios pero ahora también la usa `BACKEND_URL` |
| Orígenes externos / CSP / service worker / CORS | No | El gateway llama al backend servidor a servidor; no afecta nginx ni CORS |
| Workflows | No | No se tocó `.github/` |
| Cambios temporales | Sí | `MQTT_ACK_REQUIERE_ID_COMANDO=false` "hasta que AIoT confirme el firmware" y credencial compartida legacy "hasta que todos los Edge migren" (§6, Seguimiento) |
| Secretos en el diff | No | Solo nombres. No se vio ningún valor real |

### 5.1 Variables nuevas del gateway — cadena completa

El gateway lee la configuración con `pydantic-settings` (`app/config.py`, campos en minúscula ↔ variable en mayúscula). Son
variables de ejecución: **no** necesitan `ARG`/`ENV` en el `Dockerfile` (correcto que no estén; el `Dockerfile` no tiene
ningún `ARG`). En DEV y TEST el gateway recibe **todo** el `.env` de Dokploy por `env_file: .env`
(`docker-compose.yml` l. 74 en `develop`; `docker-compose.test.yml` l. 40 en `test`); en PROD solo lo enumerado en `environment:`.

| Variable | Código `develop` | Compose DEV (`develop`) | Compose TEST (`test`) | Compose PROD | `.env.example` (DEV=TEST, idénticos) | `.env.prod.example` | Catálogo | Tipo / sensibilidad |
|---|---|---|---|---|---|---|---|---|
| `MQTT_ACK_REQUIERE_ID_COMANDO` | l. 65, `False` | vía `env_file` | vía `env_file` | l. 232, `:-false` | l. 72 `false` | l. 192 `false` | **No** | Comportamiento · no sensible |
| `MQTT_TOPIC_RESULTADO` | l. 48, `"resultado"` | vía `env_file` | vía `env_file` | l. 234, `:-resultado` | l. 67 | l. 180 | **No** | AIoT · no sensible (contrato con firmware) |
| `BACKEND_URL` | l. 77, `""` | vía `env_file`, **sin guarda** | vía `env_file`, **sin guarda** | l. 246, `:?` | l. 85 `http://localhost:8000` | l. 203 vacía, "URL interna" | **No** | Conexión · no sensible, valor distinto por entorno |
| `BROKER_SERVICE_TOKEN` | l. 78, `""` | vía `env_file`, sin guarda | vía `env_file`, sin guarda | l. 247, `:?` | l. 86 vacía | l. 212 vacía | **No** | **Secreto** · mismo valor en broker y backend del mismo entorno |
| `BACKEND_TIMEOUT_SECONDS` | l. 79, `10.0` | vía `env_file` | vía `env_file` | l. 248, `:-10` | l. 87 | l. 215 | **No** | Comportamiento · no sensible |

- Las 5 están en las tres plantillas y llegan al contenedor en los tres entornos (DEV/TEST por `env_file`, PROD explícitas). La cadena está completa en el repo; falta el último eslabón (valor en Dokploy) y el catálogo.
- Sin `BACKEND_URL` o sin `BROKER_SERVICE_TOKEN`, `app/backend/client.py` l. 41–43 no crea el cliente y cada reenvío (`/iot/eventos-buffer`, visión, eventos Edge, OTA) solo deja un `logger.error`: **falla en silencio**. Es justo lo que Arekkazu reportó en TEST (PR #40: el `.env` de `broker-test` tiene el token pero no `BACKEND_URL`).
- Contraparte en el backend: `BROKER_SERVICE_TOKEN` está en el compose de `dev` (`docker-compose.yml` l. 78) y de `test` (`docker-compose.test.yml` l. 74, `:-`, PR Arekkazu/sgpmp-backend#654 fusionado el 2026-10-23 03:08 UTC), y en `docker-compose.prod.yml` de `dev`/`test` (l. 154, `:-` opcional), pero **no** en `main` del backend (`grep -c` = 0). Asimetría: el broker PROD lo exige (`:?`), el backend PROD no.
- **Catálogo `registros/variables/VARIABLES-ENTORNO.md`: ninguna de las 5 figura.** Tampoco `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO`, `MQTT_HOST_PORT`, `MQTT_WS_HOST_PORT`, `MQTT_DEVICE_*`, `MQTT_ACK_TIMEOUT_SECONDS`, `MQTT_COLA_*`. Y conserva `GATEWAY_API_TOKEN` (l. 97), que la plantilla de PROD declara superado (l. 244–246), y `MQTT_TLS=true` para PROD (l. 102 y l. 164), que **rompería** el gateway (ver H-03).

### 5.2 Paridad DEV / TEST / PROD

| Aspecto | DEV (`develop:docker-compose.yml`) | TEST (`test:docker-compose.test.yml`) | PROD (`develop:docker-compose.prod.yml`) |
|---|---|---|---|
| Credencial compartida opcional en `mosquitto` | Sí (`:-`) | **No se pasa** | Sí (`:-`) |
| Credencial del gateway con guarda | No (`${MQTT_USERNAME}`) | Sí (`:?`) | Sí (`:?`) |
| `MQTT_PUERTO_PUBLICO` / `MQTT_WS_PUERTO_PUBLICO` | Sí, default 1883/9001 (claro) | **No existen**; mapeo fijo `:1883`/`:9001` (l. 29–30) | Sí, default 8883/9002 (TLS) |
| Montaje `./docker/certs` | Sí (l. 60) | **No** | Sí (l. 99) |
| Variables del backend en el gateway | Por `env_file` | Por `env_file` | Explícitas, `BACKEND_URL`/`BROKER_SERVICE_TOKEN` con guarda |
| Red con el backend | Ninguna compartida (red por defecto del stack) | Ninguna compartida | `sgpmp-network` externa (el backend PROD usa `dokploy-network`) |
| `restart` | `unless-stopped` | `unless-stopped` | `always` |

Conclusión: DEV ya tiene el modelo nuevo (credencial opcional, certificados montados, TLS seleccionable; TLS apagado por
defecto, aceptable en DEV). **TEST está desalineado** si Dokploy usa `docker-compose.test.yml`: no puede activar TLS ni
recibe en `mosquitto` la credencial compartida. Es el mismo hallazgo de HU-IMP-SEG-03 (CA-2/ST-02), que sigue abierto.
Si Dokploy usara `docker-compose.yml` en TEST, la paridad sería la de DEV y bastaría con cargar `MQTT_PUERTO_PUBLICO=8883`,
`MQTT_WS_PUERTO_PUBLICO=9002` y los certificados. Qué archivo usa Dokploy en TEST sigue **sin confirmar**.

### 5.3 `BACKEND_URL`: tres criterios distintos y una URL de referencia que no responde

| Fuente | Valor o criterio para `BACKEND_URL` |
|---|---|
| Líder / `CLAUDE.md` (tabla de infraestructura) | Público por Traefik: DEV `https://api.inmero.co/back-sigab-dev`, TEST `https://api.inmero.co/back-sigab-test`, PROD por definir |
| `.env.prod.example` l. 198–203 y compose PROD l. 241–246 (`bb8fc19`) | **Interno** por `sgpmp-network`, "nombre del servicio del backend + puerto interno… Nunca el dominio público" |
| PR #40 a `test` (Arekkazu, 2026-10-23) | Público: `https://api.inmero.co/api-sgpmp-test` |
| `.env.example` l. 85 (DEV y TEST) | `http://localhost:8000` (dentro del contenedor del gateway, `localhost` es el propio gateway: no sirve en Docker) |

Comprobación en vivo (2026-10-23 19:06 -0500, `curl -s -o /dev/null -w '%{http_code}'`):

| URL | Código | Quién responde |
|---|---|---|
| `https://api.inmero.co/back-sigab-dev/health` | 404 | Traefik ("404 page not found", `text/plain`) |
| `https://api.inmero.co/back-sigab-test/health` | 404 | Traefik |
| `https://api.inmero.co/api-sgpmp-dev/health` | 200 | uvicorn, `{"status":"ok",…}` |
| `https://api.inmero.co/api-sgpmp-test/health` | 200 | uvicorn |
| `https://api.inmero.co/broker-sigab-test/v1/healthz` | 200 | gateway TEST |
| `https://api.inmero.co/broker-sigab-dev/v1/healthz` | 404 | uvicorn `{"detail":"Not Found"}` (el router existe pero la ruta no; candidato a `/triage`) |

Hechos verificados: hoy el backend responde bajo `/api-sgpmp-dev` y `/api-sgpmp-test`, **no** bajo `/back-sigab-*`
(H-02). Con prefijo + Strip Path la URL pública funciona con el cliente: `httpx` concatena `base_url` + `ruta`
(`/iot/eventos-buffer`), y Traefik quita el prefijo.

Análisis de la opción interna para PROD (hipótesis a confirmar con Despliegue): (1) el gateway PROD está en
`sgpmp-network`, el backend PROD en `dokploy-network` → no se ven; (2) el servicio del backend PROD no tiene
`container_name` (solo la BD, l. 34), y en `dokploy-network`, compartida por todos los proyectos del host, el alias
`backend` puede ser ambiguo. La opción pública expone `/iot/*` a Internet, protegidos solo por el Bearer; la interna los
mantiene dentro del servidor. Es una decisión de diseño (pregunta P1).

### 5.4 Puertos de host y certificados

| Tema | Implementación (compose, plantilla) | Despliegue (host, Dokploy) |
|---|---|---|
| Puerto MQTT/WS publicado en PROD | Parametrizado sin default: `MQTT_HOST_PORT`, `MQTT_WS_HOST_PORT` (l. 92–93), con guarda. Conforme | Elegir y abrir los puertos de host (no 1883: EMQX; 1884/9001 DEV; 1885/9002 TEST según los comentarios) |
| Qué puerto del contenedor se publica | `MQTT_PUERTO_PUBLICO`/`MQTT_WS_PUERTO_PUBLICO` default 8883/9002 en PROD | Solo cargar si se quiere cambiar (no debería) |
| Certificados | Montaje `./docker/certs:/mosquitto/certs:ro`; nombres `fullchain.pem` y `privkey.pem`; `.gitignore` excluye `*.pem/*.crt/*.key` en `docker/certs/` | Emitirlos, colocarlos y renovarlos. **Riesgo (hipótesis):** el montaje es relativo al clon que Dokploy recrea en cada despliegue; si se copian a mano en ese directorio pueden perderse al redesplegar. Conviene que Despliegue use un mecanismo persistente (p. ej. File Mounts de Dokploy o ruta absoluta del host) y lo confirme |
| Dominio/host del MQTT | — | Definir el nombre que irá en el certificado y que usará el firmware |
| Firewall | — | Abrir los puertos de host elegidos |

### 5.5 Plantilla de PROD y comportamiento del entrypoint en DEV/TEST

- `.env.prod.example`: sin valores reales ni formatos que parezcan credenciales (§4). Hecho verificado.
- No es parte del PR, pero sí de la misma familia: `.env.example` (DEV/TEST) trae `MQTT_PASSWORD=changeme`,
  `MQTT_DEVICE_PASSWORD=changeme` y `DATABASE_URL=postgresql+asyncpg://usuario:cambiar_esta_clave@host:5447/sgpmp`
  (l. 12, 36, 46): no son reales, pero sí "formatos de credencial", contra la regla 2 de `variables-entorno` (H-08, baja).
- Entrypoint (`develop:docker/mosquitto-entrypoint.sh`, idéntico a `test`): aborta **solo** si
  `MQTT_PUERTO_PUBLICO=8883` o `MQTT_WS_PUERTO_PUBLICO=9002` **y** faltan los certificados (l. 87–96). Sin certificados y
  con los puertos en claro, solo emite un AVISO y sirve en 1883/9001 (l. 125).
  - DEV: defaults 1883/9001 → **no aborta**. `./docker/certs` existe en el repo (contiene `README.md` versionado), así
    que el montaje no crea un directorio vacío de root (la preocupación que dejamos en `af9da57` ya no aplica).
  - TEST con `docker-compose.test.yml`: no pasa `MQTT_PUERTO_PUBLICO` ni monta certificados → **no aborta**, sirve en
    claro (sigue INC-BRK-01). TEST con `docker-compose.yml` y 8883/9002 sin certificados → aborta, como se diseñó.
  - PROD: default 8883/9002 → **sin certificados, `mosquitto` no arranca** y con `restart: always` queda en bucle. El
    gateway arranca igual (`depends_on` sin condición), reintenta MQTT y `/v1/healthz` puede seguir en 200 (según la
    propia plantilla, l. 88–89). Es el comportamiento buscado, pero hace de los certificados un **prerrequisito duro** del primer despliegue de PROD.
  - El entrypoint también aborta si falta `MQTT_USERNAME`/`MQTT_PASSWORD` (l. 23–26) o si se cambia el usuario del
    gateway en un volumen ya inicializado (l. 38–42). DEV no tiene guarda en el compose para esas dos.

### 5.6 Directrices SEG

`gh issue list -R SerBy48/BROKER-MQTT-SGPMP --search SEG` y `--assignee chebaz-117|chebaztian`: **sin resultados** hoy.
No hay issue SEG asignado a Implementación en este repo. Relación con `registros/seguridad/registro-SEG.md`:

| Directriz | Efecto del PR #35 | Estado por rama tras el PR |
|---|---|---|
| SEG-BROKER-02 (TLS hacia afuera, TC-M09-253) | Avanza: PROD queda con TLS por defecto en el compose | `develop`/`test`: código y compose PROD con TLS por defecto; `main`: sin compose PROD. Activación en entornos: pendiente (HU-IMP-SEG-03). El registro no menciona el compose PROD; hay que actualizarlo cuando se haga ST-07 |
| SEG-BROKER-03 (dynamic-security) | Alinea el compose PROD con dynamic-security | Sin cambios de código; `docker-compose.test.yml` sigue con el comentario del esquema `passwd` |
| SEG-BROKER-01 | No aplica (reemplazada) | — |

No toca workflows ni bloques `permissions:`.

## 6. Trabajo derivado

### Hallazgos

| ID | Severidad | Hallazgo | Evidencia | Responsable |
|---|---|---|---|---|
| H-01 | **Alta** | El compose PROD del broker usa la red externa `sgpmp-network`; el backend PROD la abandonó por "network sgpmp-network not found" y usa `dokploy-network`. El primer despliegue del broker en PROD fallará igual, y aunque la red exista, el gateway no verá la BD (`DB_HOST`) ni el backend (`BACKEND_URL` interna). Desviación de la regla 8 de `compose-entornos`. Viene de nuestro `55a8bd9`; `bb8fc19` la mantuvo y sumó la dependencia de `BACKEND_URL` | broker `develop:docker-compose.prod.yml` l. 19–20, 322, 333–334; backend `dev:docker-compose.prod.yml` l. 15–19, 215–230 | Implementación (con aprobación de AIoT) |
| H-02 | **Alta** | Las URL del backend en la tabla de infraestructura de `CLAUDE.md` (`/back-sigab-dev`, `/back-sigab-test`) devuelven 404 de Traefik; el backend responde en `/api-sgpmp-dev` y `/api-sgpmp-test`. Tres criterios distintos para `BACKEND_URL` (§5.3) | `curl` del 2026-10-23 19:06 -0500 | Líder (documentación) + Despliegue (confirmar rutas) |
| H-03 | **Alta** (documental) | El catálogo indica `MQTT_TLS=true` en PROD; el código y la plantilla dicen que debe quedar en `false` (es el TLS gateway→Mosquitto interno). Si Despliegue sigue el catálogo, el gateway no ingesta y sigue `healthy` | `VARIABLES-ENTORNO.md` l. 102, 164; `.env.prod.example` l. 156–162 | Implementación |
| H-04 | Media | Catálogo sin las 5 variables nuevas ni `MQTT_PUERTO_PUBLICO`, `MQTT_*_HOST_PORT`, `MQTT_DEVICE_*`, `MQTT_ACK_TIMEOUT_SECONDS`, `MQTT_COLA_*`; conserva `GATEWAY_API_TOKEN`, ya superado | `VARIABLES-ENTORNO.md` l. 97–109 | Implementación |
| H-05 | Media | `docker-compose.test.yml` (solo en `test`) sigue con el modelo anterior: sin `MQTT_PUERTO_PUBLICO`, sin certificados, sin credencial compartida. `bb8fc19` borró nuestra advertencia sobre esa omisión | `test:docker-compose.test.yml` l. 11–33 | Implementación (HU-IMP-SEG-03 ST-02) + Despliegue (qué archivo usa) |
| H-06 | Media | Hotfix `08247c0` (aviso de arranque sin `BACKEND_URL`/token) fusionado solo en `test`; no está en `develop`, así que no llegará a `main` con el release | `merge-base --is-ancestor 08247c0 origin/develop` → AUSENTE | AIoT / Arekkazu |
| H-07 | Media | `BROKER_SERVICE_TOKEN` es obligatorio en el broker PROD (`:?`) pero opcional en el backend PROD (`:-`, l. 154) y ausente en `main` del backend. El backend responde 503 sin él (`src/shared/broker_auth.py`) | backend `dev:docker-compose.prod.yml` l. 154; `main` sin la variable | Implementación (compose del backend) |
| H-08 | Baja | `.env.example` DEV/TEST con `changeme` y una `DATABASE_URL` con forma de credencial; `BACKEND_URL=http://localhost:8000` no sirve dentro de Docker | `develop:.env.example` l. 12, 36, 46, 85 | Implementación (con AIoT) |
| H-09 | Baja | PROD no pasa `MQTT_COLA_CAPACIDAD`, `MQTT_COLA_WORKERS`, `MQTT_TOPIC_VISION/EVENTO/OTA` (sí llegan en DEV/TEST por `env_file`) | `app/config.py` l. 52–54, 71–72 | Implementación |
| H-10 | Baja | El PR modificó archivos de Implementación sin revisor ni aviso | `gh pr view 35 --json reviews` → `[]` | Líder (acuerdo con Desarrollo/AIoT) |
| O-01 | Observación | `broker-sigab-dev/v1/healthz` → 404 de uvicorn (la ruta existe en el código) | `curl` 2026-10-23 | `/triage` si importa a E2 |
| O-02 | Observación | El `Dockerfile` del gateway no declara `USER` (corre como root) | `develop:Dockerfile` | AIoT (fuera del PR) |

### Trabajo por responsable

| Tipo | Qué | Rama / vía | Producto |
|---|---|---|---|
| Implementación | **HU CFG nueva**: (1) red del compose PROD del broker → `dokploy-network` (o lo que decida Despliegue) en los dos servicios que la usan; (2) criterio único de `BACKEND_URL` por entorno escrito en las plantillas (`.env.example` y `.env.prod.example`) y en el mensaje de la guarda; (3) `MQTT_COLA_*` y `MQTT_TOPIC_VISION/EVENTO/OTA` opcionales en PROD; (4) limpiar placeholders con forma de credencial en `.env.example` | PR a `develop` del broker (aprobación AIoT) → viaja con el release a `test` y `main` (estrategia A: PROD sin fecha) | Resumen para `/planificar` (abajo) |
| Implementación | **Ampliar HU-IMP-SEG-03** (ST-01 y ST-02) o HU AMB aparte: catálogo con las variables del broker, corregir `MQTT_TLS` PROD, retirar `GATEWAY_API_TOKEN`; alinear `docker-compose.test.yml` (o eliminarlo si Dokploy usa `docker-compose.yml`) | Catálogo: PR a `main` de `SGMP-Integracion`. Compose TEST: PR dirigido a `test` del broker (estrategia B; el archivo solo existe en `test`) | `/planificar` con este informe |
| Implementación | Backend PROD: `BROKER_SERVICE_TOKEN` con guarda `:?` en `docker-compose.prod.yml` (y en TEST si se decide), para no desplegar un backend que responde 503 | PR a `dev` del backend → release a `test`/`main` | Incluir en la HU CFG o aparte |
| Implementación | Promoción del PR #35 a `main` del broker | Estrategia A (release de AIoT), **después** de corregir H-01. No hace falta cherry-pick: PROD está "por definir" | `/promover BROKER-MQTT-SGPMP 8dbb3c2 main` cuando AIoT anuncie el release |
| Despliegue | Ficha de variables y prerrequisitos (abajo) | Dokploy | Ficha |
| Equipo autor (AIoT / Arekkazu) | Llevar `08247c0` a `develop`; aclarar criterio de `BACKEND_URL`; avisar antes de tocar archivos de Implementación | Comentario o issue | Borrador (abajo) |
| Seguimiento | `MQTT_ACK_REQUIERE_ID_COMANDO=false` → `true` cuando AIoT confirme firmware (TC-M09-252); retirar `MQTT_DEVICE_*` cuando todos los Edge migren (TC-M09-250/251) | Sin fecha en el código | Revisar al cierre de E2 (2026-11-03) |

### Resumen para `/planificar` (HU CFG sugerida)

> **Origen:** EXT-BRK-PR35 (este informe). **Dominio:** CFG. **Repos:** BROKER-MQTT-SGPMP (`develop`), sgpmp-backend (`dev`).
> **Objetivo:** que el compose de PROD del broker pueda desplegarse y hablar con la BD y el backend, con un criterio
> único y documentado para `BACKEND_URL`. **Incluye:** H-01, H-07, H-08, H-09 y la parte de plantillas de H-02.
> **CA sugeridos:** (1) `docker compose -f docker-compose.prod.yml --env-file .env.prod.example config --quiet` falla
> por las guardas y con valores ficticios pasa; (2) `grep` de la red en el compose del broker coincide con la del backend
> PROD; (3) `BACKEND_URL` descrita igual en `.env.example`, `.env.prod.example` y en el mensaje de la guarda, con el valor
> no sensible de cada entorno; (4) backend PROD con `BROKER_SERVICE_TOKEN` `:?`; (5) `.env.example` sin `changeme` ni URL
> con credenciales. **Depende de:** respuesta a P1 y P2. **Promoción:** release (estrategia A).

### Ficha para Despliegue (borrador; nombres, nunca valores)

```markdown
### Ficha de variables — EXT-BRK-PR35 (broker BRK-10) — 2026-10-23
| Variable | Servicio | Entorno(s) | Obligatoria | Tipo | Provee el valor | Acción en Dokploy | Requiere rebuild |
|---|---|---|---|---|---|---|---|
| BACKEND_URL | gateway | DEV, TEST, PROD | PROD sí (guarda); DEV/TEST sí en la práctica (sin ella los eventos no llegan al backend, sin error visible) | Conexión | Implementación fija el criterio (P1); Despliegue el valor | DEV: crear · TEST: crear (falta, según PR #40) · PROD: crear | No (redeploy) |
| BROKER_SERVICE_TOKEN | gateway **y** backend del mismo entorno | DEV, TEST, PROD | PROD sí; DEV/TEST sí en la práctica | Secreto | Se genera una vez por entorno; canal seguro | Crear con el MISMO valor en broker y backend de cada entorno | No |
| BACKEND_TIMEOUT_SECONDS | gateway | todos | No (default 10) | Comportamiento | — | No crear salvo ajuste | No |
| MQTT_ACK_REQUIERE_ID_COMANDO | gateway | todos | No (default false) | Comportamiento | AIoT decide cuándo true | No crear hasta aviso de AIoT | No |
| MQTT_TOPIC_RESULTADO | gateway | todos | No (default resultado) | AIoT | AIoT | No crear | No |
| MQTT_PUERTO_PUBLICO / MQTT_WS_PUERTO_PUBLICO | mosquitto | DEV (1883/9001 default) · TEST (8883/9002 al activar TLS) · PROD (8883/9002 default) | No | Conexión | Implementación | TEST: crear al activar TLS (HU-IMP-SEG-03) | No |
| MQTT_HOST_PORT / MQTT_WS_HOST_PORT | mosquitto | PROD | Sí (sin default) | Conexión | Despliegue | Crear con los puertos de host asignados | No |
| MQTT_DEVICE_USERNAME / MQTT_DEVICE_PASSWORD | mosquitto y gateway | todos | No; en PROD dejar sin definir | Secreto | AIoT | PROD: no crear | No |
| MQTT_TLS | gateway | todos | No; debe quedar false | Comportamiento | — | No poner en true (el catálogo dice lo contrario, H-03) | No |

**Prerrequisitos que no son variables:** certificados `fullchain.pem` y `privkey.pem` del host MQTT en `./docker/certs`
del stack del broker (PROD siempre; TEST al activar TLS), montados de forma que sobrevivan al redespliegue; red común con
el backend (P2); puertos de host abiertos en el firewall; confirmar qué compose usa cada entorno; respaldo del volumen
`mosquitto_secrets_prod` (dynamic-security.json).
**Verificación posterior:** log de arranque del gateway sin el ERROR "BACKEND_URL y/o BROKER_SERVICE_TOKEN sin configurar"
(TEST; en DEV/PROD cuando llegue `08247c0`); `openssl s_client -connect <host-mqtt>:<puerto-host> -servername <host-mqtt> </dev/null | openssl x509 -noout -subject -dates`;
un evento de buffer de prueba visible en el backend sin 401/503.
```

### Borrador de comentario para AIoT / Arekkazu (el líder decide si lo publica)

> Hola, gracias por alinear `docker-compose.prod.yml` y `.env.prod.example` con `develop` en el #35; el modelo de
> dynamic-security y TLS por defecto quedó bien reflejado y las guardas funcionan (`config --quiet` falla con la
> plantilla vacía y pasa con valores ficticios). Desde Implementación vemos tres puntos para coordinar:
> 1. **Red de PROD.** El compose del broker usa `sgpmp-network` externa (esto venía de nuestra primera versión), pero el
>    backend PROD pasó a `dokploy-network` porque `sgpmp-network` no existe en el host. Proponemos alinear la red en un
>    PR nuestro a `develop`; antes queremos confirmar con Despliegue.
> 2. **`BACKEND_URL`.** La plantilla de PROD la define como URL interna ("nunca el dominio público") y el #40 propone
>    para TEST la pública `https://api.inmero.co/api-sgpmp-test`. ¿Cuál es el criterio que quieren para cada entorno? Lo
>    dejaríamos igual en las plantillas y en el catálogo.
> 3. **Hotfix `08247c0` (#40).** Está en `test` pero no en `develop`; como el release sale de `develop`, no llegaría a
>    `main`. ¿Pueden llevarlo a `develop`?
>
> Una petición: `docker-compose*.yml`, `.env*.example` y `Dockerfile` son archivos que mantiene Implementación; si los
> tocan, agrégennos como revisores para mantener el catálogo y la ficha de Despliegue al día.

### Fila propuesta para el índice de E2 (no se editó: el líder pidió escribir solo el informe)

`| BRK PR #35 | PR externo | — | M03/M04 (gateway) | analizado | prs/BRK-PR35_compose-prod-broker/ |`

## 7. Preguntas abiertas para el líder

1. **P1 — Criterio de `BACKEND_URL`:** ¿pública por Traefik con prefijo y Strip Path en todos los entornos (como en el
   PR #40) o interna por red compartida (como la plantilla de PROD)? La pública funciona hoy sin tocar redes, pero deja
   `/iot/*` expuestos a Internet detrás de un Bearer.
2. **P2 — Red de PROD:** ¿alineamos el broker a `dokploy-network` (como el backend) o se le pide a Despliegue crear
   `sgpmp-network`? Sin esto, el broker de PROD no despliega.
3. **P3 — URL reales del backend:** hoy responden `/api-sgpmp-dev` y `/api-sgpmp-test`, no `/back-sigab-*`. ¿Actualizas
   la tabla de `CLAUDE.md` y la skill `verificacion` §7, o Despliegue va a mover las rutas?
4. **P4 — Alcance:** ¿la parte del catálogo y del compose de TEST se suma a HU-IMP-SEG-03 (ST-01/ST-02) o va en una HU
   AMB aparte en E2? HU-IMP-SEG-03 está en E1 y figura como pendiente en E2.
5. **P5 — Compose del backend:** ¿ponemos `BROKER_SERVICE_TOKEN` con guarda `:?` en el compose PROD del backend (H-07)?
6. **P6 — Acuerdo con Desarrollo/AIoT:** ¿publicas el borrador de comentario y pides que Implementación sea revisor de
   los archivos de infraestructura (H-10)?
7. **P7 — Certificados:** ¿Despliegue ya tiene definido cómo montará `./docker/certs` en Dokploy sin que se pierdan al
   redesplegar? Es prerrequisito duro de PROD.
8. **P8 — O-01:** ¿abrimos `/triage` por el 404 de `broker-sigab-dev/v1/healthz`?

---
Fuentes (2026-10-23): `gh pr view 35/40 -R SerBy48/BROKER-MQTT-SGPMP`; `gh pr view 654 -R Arekkazu/sgpmp-backend`;
`git diff af9da57 bb8fc19`; `git show origin/{develop,test,main}:<archivo>`; `git merge-base --is-ancestor`; `git cherry -v`;
`docker compose … config --quiet` sobre copias en el scratchpad; `curl` a los endpoints públicos;
`registros/variables/VARIABLES-ENTORNO.md`, `registros/seguridad/registro-SEG.md`, `registros/incidencias/registro.md`,
`registros/entornos/CONTRATO-TEST.md`, `CONTRATO-PROD.md`, HU-IMP-SEG-03.
