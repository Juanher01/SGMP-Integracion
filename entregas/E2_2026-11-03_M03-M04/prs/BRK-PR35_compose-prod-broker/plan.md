# EXT-BRK-PR35 — Plan de corrección (H-01, H-03, H-04) y análisis de impacto de los dominios nuevos (H-02)

> Plan · Implementación · 2026-10-26 · Entrega E2 · Continúa [analisis.md](analisis.md)
> Documento para discutir con los líderes de Desarrollo y Despliegue antes de decidir. **No se ejecutó ningún cambio**:
> solo `git fetch` y lectura de las ramas remotas. No se tocó GitHub ni se leyeron valores de variables.

## 0. Contexto y estado verificado

| Repo | Ramas (fetch 2026-10-26) |
|---|---|
| BROKER-MQTT-SGPMP | `develop@69703f4` (0.4.0-rc.5) · `test@22e9ad0` · `main@cebd430` |
| sgpmp-backend | `dev@18b4ce67` · `test@254deee6` · `main@0abbeeef` |
| SGPMP-FRONT-END-PWA | `dev@28c21719` · `test@81058af5` · `main@95f3e563` |
| SGMP-Integracion | `main@0fa672e` |

Desde el informe del 2026-10-23, `develop` y `test` del broker avanzaron con BRK-11 (#38, #41), que no toca compose ni
plantillas. El hotfix `08247c0` (PR #40) **sigue ausente de `develop`** (`git merge-base --is-ancestor 08247c0 origin/develop` → AUSENTE).

Hallazgos que el líder de Implementación verificó y su decisión:

| ID | Hallazgo | Decisión |
|---|---|---|
| H-01 | El compose PROD del broker conecta el gateway a `sgpmp-network` (externa); el backend PROD usa `dokploy-network` | Corregir: gateway en `[broker-interna, dokploy-network]`, mosquitto solo en `broker-interna`, corregir comentarios. PR a `develop` del broker |
| H-03 | El catálogo de Implementación pone `MQTT_TLS=true` en PROD; el compose (bien) usa `false` | Corregir el catálogo con nota de los dos tramos MQTT |
| H-04 | El catálogo no tiene las 5 variables nuevas del gateway y conserva `GATEWAY_API_TOKEN` | Agregar las 5 y retirar `GATEWAY_API_TOKEN` |
| H-02 | Despliegue comunicó dominios nuevos con prefijo para frontend y backend | **Solo análisis de impacto** (este documento, §3) |

Dominios comunicados por Despliegue:

| Entorno | Frontend | Backend |
|---|---|---|
| DEV | `https://api.inmero.co/sigab-dev` | `https://api.inmero.co/api-sgpmp-dev` (también `www.api.inmero.co`) |
| TEST | `https://api.inmero.co/sigab-test` | `https://api.inmero.co/api-sgpmp-test` (también `www.`) |
| MAIN | `https://inmero.co/sigab` | `https://api.inmero.co/sigab` (también `www.`) |

No hay dominios del gateway del broker en la lista.

## 1. Decisiones pendientes (para la reunión)

| # | Decisión | Opciones | Propuesta de Implementación | Decide |
|---|---|---|---|---|
| D1 | Criterio de `BACKEND_URL` (broker → backend) | (a) interna por `dokploy-network` · (b) pública por Traefik | PROD interna con alias único; DEV/TEST pública salvo que Despliegue confirme que Dokploy los conecta a `dokploy-network` (§3.4) | Implementación + AIoT, con dato de Despliegue |
| D2 | Alias único del backend PROD en `dokploy-network` (H-01b) | Agregar alias · no agregar | Agregar `sgpmp-backend-prod` (§2.1) | Implementación (compose del backend) |
| D3 | Plantillas `env/` y `compose/` de SGMP-Integracion en el mismo PR del catálogo | Mismo PR · PR aparte | Mismo PR (regla 1 del catálogo: mismos nombres en los tres ejemplos) | Líder de Implementación |
| D4 | Colisión de la cookie de refresco entre DEV, TEST y PROD (§3.3) | (a) un host por entorno · (b) `path` de la cookie igual al prefijo · (c) nombre de cookie por entorno | (a); si no es posible, (b) | Despliegue (a) o Desarrollo (b, c) |
| D5 | Base IndexedDB compartida entre DEV y TEST (§3.3) | Nombre por entorno · aceptar el riesgo | Nombre por entorno | Desarrollo |
| D6 | Transición del SW heredado en la raíz de `api.inmero.co` (§3.3) | `sw.js` autodesregistrable en `/` · `Clear-Site-Data` · nada | `sw.js` autodesregistrable durante la transición | Implementación (nginx) + Despliegue (qué se sirve en `/`) |

## 2. Plan de corrección

### 2.1 H-01 — Red del compose PROD del broker

**Repo y ramas.** `BROKER-MQTT-SGPMP`, rama `fix/compose-prod-red-dokploy` desde `origin/develop@69703f4`, PR a `develop`
(aprueba AIoT). Llega a `test` y `main` con el release (estrategia A); no hace falta PR dirigido: `test` tiene el mismo
archivo (llegó con el #39) y `main` aún no lo tiene.

| Archivo | Líneas (`develop`) | Cambio |
|---|---|---|
| `docker-compose.prod.yml` | 320–322 | gateway: `networks: [broker-interna, dokploy-network]` |
| | 158–159 | mosquitto: solo `broker-interna` (sin cambio) |
| | 324–334 | `sgpmp-network: external: true` → `dokploy-network: external: true`, con su comentario |
| | 19–23 | Prerrequisito 1: la red la crea la instalación de Dokploy; no requiere `docker network create`. Es la misma de `sgpmp-backend/docker-compose.prod.yml` |
| | 80–82, 154–157 | "red compartida con el backend" → `dokploy-network`, compartida con todos los proyectos del host; mosquitto queda fuera a propósito |
| | 187–190, 240–246 | `DB_HOST` y `BACKEND_URL` "por `dokploy-network`", incluido el **mensaje de la guarda** de la l. 246 |
| | 314–319 | Comentario "las DOS redes": nombre de la red |
| `.env.prod.example` | 45, 198–203 | `sgpmp-network` → `dokploy-network` |

Nota de seguridad: copiar la del backend (`dev:docker-compose.prod.yml` l. 222–227): red compartida; la mejora futura es
una red dedicada.

**DEV y TEST del broker no tienen el problema.** `docker-compose.yml` (`develop`, `main`) y `docker-compose.test.yml`
(`test`) no declaran `networks:`: no dependen de una red externa y no pueden fallar con "network not found". La salvedad
(si el gateway alcanza al backend por red interna en esos entornos) se trata en §3.4.

**H-01b — alias del backend PROD (D2).** En `sgpmp-backend/docker-compose.prod.yml` el servicio se llama `backend`, sin
`container_name` ni alias. En `dokploy-network` también estarían, si Dokploy los conecta, los backends de DEV y TEST y
servicios de otros proyectos; con dos contenedores bajo el alias `backend`, el DNS de Docker los reparte y
`http://backend:8000` es ambiguo. Propuesta (PR a `dev` del backend):

```yaml
    networks:
      dokploy-network:
        aliases: [sgpmp-backend-prod]
```

**Criterios de aceptación y verificación.**

1. `docker compose -f docker-compose.prod.yml --env-file .env.prod.example config --quiet` falla por la guarda; con valores ficticios pasa.
2. En `docker compose … config`, el gateway aparece en 2 redes y mosquitto en 1.
3. `git grep -n sgpmp-network` sin resultados fuera de `CHANGELOG.md`.
4. El diff toca solo `docker-compose.prod.yml` y `.env.prod.example`.
5. La red externa del broker coincide con la de `origin/dev:docker-compose.prod.yml` del backend.
6. (H-01b) `docker compose -f docker-compose.prod.yml config` del backend muestra el alias en `dokploy-network`.

### 2.2 H-03 y H-04 — Catálogo de variables

**Archivo:** `SGMP-Integracion/registros/variables/VARIABLES-ENTORNO.md`. Rama `docs/catalogo-broker-brk10`, PR a
`main` de SGMP-Integracion (aprueba el líder de Implementación).

| Sección | Línea | Corrección |
|---|---|---|
| §3 | 102 | Reemplazar la fila de `MQTT_TLS` (abajo) |
| §3 | 97 | Retirar `GATEWAY_API_TOKEN` |
| §3 | tras 109 | Agregar las 5 filas nuevas (abajo) y la nota "Dos tramos MQTT" |
| §4 PROD | 164 | `MQTT_TLS=true` → `MQTT_TLS=false` |
| §5 Gateway | 187–199 | Quitar la traducción `GATEWAY_API_TOKEN → API_TOKEN`; dejar la composición de `DATABASE_URL` desde `DB_*` con `postgresql+asyncpg://` |
| §6 | lista | Agregar `GATEWAY_API_TOKEN`: diseño superado por `BROKER_SERVICE_TOKEN` + `modulo1.credenciales_servicio` (broker `.env.prod.example` l. 244–246) |

Fila de `MQTT_TLS`:

```markdown
| `MQTT_TLS` | Gateway AIoT | Comportamiento | No sensible | TLS del **gateway** hacia Mosquitto por la red interna del stack (listener 1883 en claro). **`false` en DEV, TEST y PROD.** Con `true` el handshake falla y el gateway queda `healthy` sin ingestar. No es el TLS de los dispositivos (ver nota "Dos tramos MQTT"). |
```

Nota bajo la tabla:

```markdown
> **Dos tramos MQTT.** (1) **Dispositivos → Mosquitto** (Internet): TLS obligatorio (SEG-BROKER-02, TC-M09-253), con mqtts 8883 y wss 9002 publicados en `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT`. Los activan `MQTT_PUERTO_PUBLICO`/`MQTT_WS_PUERTO_PUBLICO` (default 8883/9002 en PROD) con `fullchain.pem`/`privkey.pem` en `./docker/certs`; sin certificados, mosquitto no arranca. (2) **Gateway → Mosquitto** (red interna `broker-interna`, `mosquitto:1883`): en claro por diseño, no sale del host. `MQTT_TLS` controla solo este tramo y queda en `false`.
```

Filas nuevas:

```markdown
| `MQTT_ACK_REQUIERE_ID_COMANDO` | Gateway AIoT | Comportamiento | No sensible | Anti-replay (TC-M09-252): con `true`, todo ACK debe traer `id_comando`. Default `false` hasta que AIoT confirme el firmware. |
| `MQTT_TOPIC_RESULTADO` | Gateway AIoT | AIoT / Analítica | Interna | Sufijo del topic de resultado de ingesta (BRK-01). Default `resultado`. Contrato con el firmware. |
| `BACKEND_URL` | Gateway AIoT | Conexión | Interna | Base del backend para reenviar buffer, visión, eventos Edge y OTA (BRK-02). Obligatoria en PROD (`:?`); sin ella el reenvío falla en silencio. Valor por entorno según D1. |
| `BROKER_SERVICE_TOKEN` | Gateway AIoT y Backend | Autenticación / Seguridad | **Secreta** | Bearer broker → backend. El MISMO valor en broker y backend de cada entorno; se genera una vez por entorno. |
| `BACKEND_TIMEOUT_SECONDS` | Gateway AIoT | Comportamiento | No sensible | Timeout de las llamadas al backend. Default `10`. |
```

**El mismo error está en las plantillas de SGMP-Integracion (D3):**

- `env/.env.prod.example` l. 88: `MQTT_TLS=true`.
- `env/.env.{dev,test,prod}.example` l. 78–80: `GATEWAY_API_TOKEN`.
- `compose/compose.{dev,test,prod}.yml`: `API_TOKEN: ${GATEWAY_API_TOKEN}`.

**Fuera de lo pedido, pendiente de H-04:** `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO`, `MQTT_*_HOST_PORT`,
`MQTT_DEVICE_*`, `MQTT_ACK_TIMEOUT_SECONDS`, `MQTT_COLA_*`. Las dos primeras las nombra la nota de los dos tramos;
conviene catalogarlas en el mismo PR.

**Criterios de aceptación.** (1) `grep -n 'MQTT_TLS' VARIABLES-ENTORNO.md` sin ningún `true`; (2) `grep -c GATEWAY_API_TOKEN`
solo en §6; (3) las 5 variables en §3 con tipo y sensibilidad; (4) si entra D3, los tres `env/.env.*.example` con el
mismo conjunto de nombres (`diff` de nombres vacío).

### 2.3 Historias propuestas

| HU | Contenido | Repos y ramas |
|---|---|---|
| HU-IMP-CFG-01 (nueva) | H-01 + H-01b | broker `develop`; backend `dev` |
| HU-IMP-AMB-10 (nueva) | H-03 + H-04 (+ D3) | SGMP-Integracion `main` |

Se redactan con `/planificar` sobre [analisis.md](analisis.md) y este plan; las ejecuta Juan Hernando.

## 3. Análisis de impacto de H-02 (sin cambios)

### 3.1 Frontend con prefijo — mayormente resuelto por Desarrollo

`8589b809` (Arekkazu, 2026-10-19, "servir la app bajo una subruta del proxy con VITE_BASE_PATH") está en `dev`, `test`
y `main`; los archivos de build y servido son idénticos en las tres ramas.

| Pieza | Estado | Responsable |
|---|---|---|
| `vite.config.ts` l. 14: `base` desde `VITE_BASE_PATH` | Hecho | Desarrollo |
| `Dockerfile` l. 13 y 45 (`ARG VITE_BASE_PATH`) y `docker-compose*.yml` (`build.args`) | Hecho | Implementación (lo modificó Desarrollo) |
| `nginx.conf` l. 53 (`include /etc/nginx/subruta.conf`); el Dockerfile l. 52–54 genera `location ^~ /<base>/ { rewrite … last; }` | Hecho | Implementación (lo modificó Desarrollo) |
| Router `IonReactRouter basename={BASE_URL}` (`App.tsx` l. 389), redirecciones de logout y 401, `rutaRetorno.ts` | Hecho | Desarrollo |
| SW: `notificationclick` relativo al scope; registro con `${BASE_URL}sw.js` | Hecho | Desarrollo |
| `manifest.json`: `start_url` y `scope` `"."` (relativos al manifest) | Correcto si el manifest se sirve bajo la base | Desarrollo |

Comportamiento según Strip Path:

- **Strip Path activo:** nginx recibe `/index.html` y `/assets/…`; `subruta.conf` no interviene. Funciona.
- **Strip Path inactivo:** `subruta.conf` recorta el prefijo y `try_files` cae en `index.html`. El `map $uri` de
  Cache-Control se evalúa sobre la URI reescrita. Funciona.
- **En ambos casos:** cargar `VITE_BASE_PATH` (`/sigab-dev/`, `/sigab-test/`, `/sigab/`) y `VITE_API_BASE_URL`, y
  **reconstruir la imagen**.

**Pendiente de Implementación:**

1. `.env.example` del frontend no tiene `VITE_BASE_PATH` (regla: ARG + `build.args` + `.env.example`). PR a `dev`.
2. El catálogo no tiene `VITE_BASE_PATH`.
3. `/sigab-dev` sin barra final: sin Strip Path no entra en `^~ /sigab-dev/` y se sirve `index.html` en una URL que no
   coincide con el `basename` (posible pantalla en blanco). Opción: `location = <base sin barra> { return 301 <base>; }`
   en `subruta.conf`. Con Strip Path la redirección la tiene que hacer Traefik. **A verificar.**
4. SW heredado de la raíz (§3.3, D6).
5. El frontend no tiene `docker-compose.prod.yml` en ninguna rama; con PROD en `inmero.co/sigab` deja de ser teórico.

**Pendiente de Desarrollo:**

- `index.html` l. 30–34 usa rutas absolutas (`/manifest.json`, `/favicon.svg`, `/icons/…`). Vite debería anteponer la
  base en el build: **confirmar** con un build con `VITE_BASE_PATH=/sigab-dev/` y revisar `dist/index.html`. Si no, la
  PWA no es instalable.
- `navigateFallbackDenylist: [/^\/api\//]` (`vite.config.ts` l. 38) quedó obsoleto (inofensivo).
- `name` del manifest igual en todos los entornos: dos PWA "SIGAB" en el mismo origen (baja).

### 3.2 `ALLOWED_ORIGINS` y `FRONTEND_URL` — uso en el código (`sgpmp-backend@dev`)

- **`ALLOWED_ORIGINS`** (`main.py` l. 773–780) → `CORSMiddleware.allow_origins`; separados por comas, con `strip()` y
  `rstrip("/")`. Un origen **no lleva ruta**. `localhost` se permite siempre por regex. `src/shared/configuracion.py`
  l. 111 la usa solo para avisos de cookies.
- **`FRONTEND_URL`** **no interviene en CORS**: solo arma los enlaces de los correos
  (`src/identity_access/infrastructure/email_templates.py` l. 43, 66, 86: `{FRONTEND_URL}/activar?token=…`). Debe
  **incluir el prefijo** y no llevar barra final. El catálogo (l. 75) dice que la usa CORS: incorrecto.

| | `ALLOWED_ORIGINS` | `FRONTEND_URL` | `VITE_API_BASE_URL` | `VITE_BASE_PATH` | `ROOT_PATH` (backend) |
|---|---|---|---|---|---|
| DEV | `https://api.inmero.co` | `https://api.inmero.co/sigab-dev` | `https://api.inmero.co/api-sgpmp-dev` | `/sigab-dev/` | `/api-sgpmp-dev` |
| TEST | `https://api.inmero.co` | `https://api.inmero.co/sigab-test` | `https://api.inmero.co/api-sgpmp-test` | `/sigab-test/` | `/api-sgpmp-test` |
| MAIN | `https://inmero.co` (¿y `www.`?) | `https://inmero.co/sigab` | `https://api.inmero.co/sigab` | `/sigab/` | `/sigab` |

Consecuencias:

- La regla actual "`ALLOWED_ORIGINS` y `FRONTEND_URL` deben coincidir exactamente con el origen" deja de valer:
  `ALLOWED_ORIGINS` = origen; `FRONTEND_URL` = origen + prefijo.
- En DEV y TEST frontend y backend comparten origen: CORS no interviene y no separa entornos (el frontend de TEST
  puede llamar al backend de DEV).
- `ROOT_PATH` tiene default `/api` en TEST y PROD; sin el prefijo real, Swagger/OpenAPI genera rutas rotas (la API no se
  afecta).
- MAIN: `inmero.co` → `api.inmero.co` es *same-site*; basta `COOKIE_SAMESITE=lax`. El docstring de
  `sesiones_routers.py` l. 72 supone sitios distintos.

### 3.3 Riesgos de que DEV y TEST compartan origen

| Riesgo | Severidad | Detalle | Responsable |
|---|---|---|---|
| Cookie de refresco compartida entre DEV, TEST y PROD (D4) | **Crítica** | `_set_cookie_refresco` (`sesiones_routers.py` l. 66–88) usa `path="/"` en el host del backend. Con los dominios nuevos los **tres** backends están en `api.inmero.co` con el mismo nombre de cookie: iniciar sesión en TEST pisa la de DEV, cerrar sesión en uno la borra en el otro, y el refresh envía el token de otro entorno (401, cierres de sesión "al azar"). Además **el refresh token de PROD viaja a los backends de DEV y TEST**: tema de seguridad a informar a Análisis | Despliegue (host por entorno) o Desarrollo (`path` = prefijo, o nombre por entorno) |
| IndexedDB compartida (D5) | Alta | Dexie `super('sgpmp')` (`src/shared/db/db.ts` l. 268) se aísla por origen: DEV y TEST usan la misma base, con datos offline de dos backends e IDs que chocan. Si DEV sube la versión del esquema, TEST no puede abrirla (`VersionError`) y el modo offline se rompe | Desarrollo |
| SW heredado del frontend de TEST en la raíz (D6) | Alta (transición) | Quien usó TEST en `api.inmero.co/` tiene un SW con scope `/`, que intercepta la navegación a `/sigab-dev/…` y `/sigab-test/…` y responde con su `index.html` precacheado (build vieja con base `/`) hasta que se actualice | Implementación (nginx) + Despliegue |
| localStorage | Baja | `sgpmp-locale`, `sgpmp-theme` compartidos | Desarrollo |
| Permiso de notificaciones | Baja | Es por origen: concederlo en DEV lo concede en TEST | — |
| SW y caché de la PWA | Ninguno | Scopes distintos (`/sigab-dev/`, `/sigab-test/`); los nombres de caché de Workbox incluyen el scope | — |

### 3.4 `BACKEND_URL` del broker (D1)

- **Tras H-01, la URL interna es válida a nivel de red:** gateway y backend PROD quedan en `dokploy-network`. El cliente
  (`app/backend/client.py` l. 45) usa `base_url + ruta` y la llamada interna no pasa por Traefik, así que va **sin
  prefijo**: `http://<nombre>:8000` (`ROOT_PATH` es cosmético).
- **El nombre todavía no es válido:** `backend` es ambiguo en la red compartida. Con H-01b quedaría
  `http://sgpmp-backend-prod:8000`.
- **PR #40 (`08247c0`):** solo cambia `app/main.py` para registrar un ERROR al arrancar si falta la URL o el token;
  **no fija ningún valor**. La URL pública `https://api.inmero.co/api-sgpmp-test` venía en la descripción del PR. Con
  los dominios nuevos sigue valiendo para TEST; DEV sería `/api-sgpmp-dev` y PROD `https://api.inmero.co/sigab`.
  `08247c0` sigue fuera de `develop`, así que no llegará a `main` con el release.
- **Corrección al informe (§5.3 de [analisis.md](analisis.md)):** la URL interna no oculta `/iot/*`, porque Traefik
  publica el backend completo. La diferencia entre interna y pública es de salto de red y dependencia de DNS y TLS, no
  de exposición.
- **Propuesta:** interna con alias en PROD; pública en DEV y TEST, salvo que Despliegue confirme que Dokploy conecta esos
  servicios a `dokploy-network`.
- **Sin dominios del gateway:** el backend llama al gateway por `MQTT_BROKER_URL` (obligatoria en TEST, `:?`). Si
  desaparecen `broker-sigab-*`, esa URL tendría que ser interna, con alias del gateway.

### 3.5 Documentos que quedan desactualizados

| Documento | Qué cambia |
|---|---|
| `PI4/CLAUDE.md` | Tabla de infraestructura; "Frontend en la raíz `/` (no admite prefijo)"; "El frontend de TEST comparte host"; regla de `ALLOWED_ORIGINS`/`FRONTEND_URL` |
| `PI4/.claude/` | Skills `verificacion`, `nginx-frontend`, `triage-comunicacion`; memoria `agent-memory/analista-cambios/patrones-broker-aiot.md` (`sgpmp-network`) |
| `registros/variables/VARIABLES-ENTORNO.md` | H-03/H-04; faltan `ALLOWED_ORIGINS`, `ROOT_PATH`, `COOKIE_*`, `VITE_BASE_PATH`; descripción de `FRONTEND_URL`; §4 con valores `localhost` |
| Plantillas | Frontend `.env.example` sin `VITE_BASE_PATH`; broker `.env.example` con `BACKEND_URL=http://localhost:8000` (no sirve dentro de Docker); SGMP-Integracion `env/` y `compose/` |
| `registros/entornos/CONTRATO-TEST.md`, `CONTRATO-PROD.md` | URLs y redes |
| `registros/incidencias/registro.md` | Histórico: solo una nota, no se reescribe |
| Entregados en E1 | `AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`, HU-IMP-AMB-09 (mapa de puertos): fe de erratas en E2, sin reescribir |

## 4. Preguntas

### Para Despliegue

1. ¿Strip Path está activo en `/sigab-dev`, `/sigab-test`, `/sigab` (frontends) y en las rutas de los backends?
2. En `api.inmero.co`, `PathPrefix(/sigab)` (backend MAIN) es prefijo de `/sigab-dev` y `/sigab-test` (frontends DEV y
   TEST). ¿Hay prioridades explícitas? ¿Cómo se evita que el stripPrefix de `/sigab` se aplique a esas rutas?
3. ¿`www.api.inmero.co` sirve solo los backends o también los frontends? ¿Y `www.inmero.co` para MAIN? Cambia
   `ALLOWED_ORIGINS`.
4. Por la colisión de cookies (§3.3), ¿se puede dar un host propio a cada entorno (p. ej. `dev.api.inmero.co`,
   `test.api.inmero.co`)?
5. ¿Cuándo se retiran `dev.inmero.co` y la raíz de `api.inmero.co`? ¿Habrá redirección? ¿Qué se sirve en `/` durante la
   transición?
6. ¿Siguen los dominios `broker-sigab-dev/test` del gateway? Si no, ¿cómo llega el backend al gateway (`MQTT_BROKER_URL`)?
7. ¿Dokploy conecta automáticamente a `dokploy-network` los servicios con dominio en DEV y TEST?
8. ¿Qué compose usa TEST del broker: `docker-compose.test.yml` o `docker-compose.yml`? (pendiente desde H-05)
9. ¿Qué nombre de host MQTT de PROD irá en el certificado y usará el firmware? MQTT no pasa por Traefik.
10. Fecha del cambio: las `VITE_*` exigen reconstruir la imagen; `FRONTEND_URL`, `ALLOWED_ORIGINS` y `ROOT_PATH`
    exigen redespliegue.

### Para Desarrollo

1. Si no hay host por entorno, ¿pueden emitir la cookie de refresco con `path` igual al prefijo (`ROOT_PATH`) o con un
   nombre por entorno (D4)?
2. ¿Pueden nombrar la base Dexie por entorno (D5)?
3. ¿Pueden confirmar con un build con `VITE_BASE_PATH` que `dist/index.html` antepone la base al manifest y los iconos?
4. ¿Se llevará `08247c0` a `develop` del broker (AIoT / Arekkazu)?
5. Acuerdo de trabajo: `Dockerfile`, `docker-compose*.yml`, `.env*.example` y `nginx.conf` los mantiene Implementación;
   si los modifican (como en `8589b809` y el #35), ¿nos agregan como revisores?

## 5. Fila pendiente para el índice de E2

Para la tabla "Trabajo" de [`../../README.md`](../../README.md) (no se editó):

```markdown
| BRK PR #35 (+ dominios de Despliegue) | PR externo | HU-IMP-CFG-01, HU-IMP-AMB-10 (por crear) | M03/M04 (gateway) | analizado · plan H-01/H-03/H-04 listo · H-02 en consulta con Desarrollo y Despliegue | prs/BRK-PR35_compose-prod-broker/ |
```

---
Fuentes (2026-10-26): `git fetch --prune origin` en los cuatro repos; `git show origin/<rama>:<archivo>`; `git grep`;
`git merge-base --is-ancestor`; `git diff --stat` entre ramas; `git log -S VITE_BASE_PATH`; [analisis.md](analisis.md).
