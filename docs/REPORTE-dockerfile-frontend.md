# Reporte — Prueba del Dockerfile del frontend

**Fecha:** 2026-08-14 · **Docker:** 29.7.2 (Client y Server, Docker Desktop, buildx v0.36.0-desktop.1)

> Esta es una segunda corrida del spike. La primera (mismo día) se detuvo en el paso 1 porque
> `Dockerfile`, `.dockerignore` y `nginx.conf` todavía no existían en el repo. Implementación los
> agregó y se repitió la prueba completa desde cero.

## Verificación de nombres de archivo

```
cd SGPMP-FRONT-END-PWA
ls Dockerfile .dockerignore nginx.conf
```

**Resultado:**
```
.dockerignore
Dockerfile
nginx.conf
```

Los tres archivos están presentes con el nombre exacto esperado. Se continuó con el resto del
spike.

## Build — target dev

- **Comando ejecutado:**
  ```
  docker build --target dev -t sgpmp-frontend:dev .
  ```

- **Contexto transferido:** `1.14MB → 2.29MB` (crece por streaming, valor final ~2.29MB). Del
  orden de cientos de KB/pocos MB como se esperaba — confirma que `.dockerignore` sí está
  excluyendo `node_modules/` esta vez (a diferencia del spike del backend).

- **Resultado: FALLÓ. Exit code `1`.**

  La imagen `sgpmp-frontend:dev` **no se generó**.

- **Causa raíz:** el Dockerfile usa `FROM node:20-slim AS base` y luego `RUN corepack enable` +
  `RUN pnpm install --frozen-lockfile`, sin fijar una versión de pnpm (no hay campo
  `packageManager` en `package.json`, ni `.npmrc`, ni `engines`). Al no estar fijada, Corepack
  descarga la última versión de pnpm disponible (`11.21.0`), y esa versión requiere Node.js
  **≥ 22.13**. La imagen base declarada es Node **20.20.2**, y el propio binario de pnpm 11.21.0
  se cae al arrancar porque intenta cargar el módulo nativo `node:sqlite`, que no existe en
  Node 20:

  ```
  #9 1.988 ! Corepack is about to download https://registry.npmjs.org/pnpm/-/pnpm-11.21.0.tgz
  #9 11.06 warn: This version of pnpm requires at least Node.js v22.13
  #9 11.06 warn: The current version of Node.js is v20.20.2
  #9 12.97 node:internal/modules/cjs/loader:1031
  #9 12.97       throw new ERR_UNKNOWN_BUILTIN_MODULE(request);
  #9 12.97 Error [ERR_UNKNOWN_BUILTIN_MODULE]: No such built-in module: node:sqlite
  #9 12.97     at ../store/index/lib/index.js (file:///root/.cache/node/corepack/v1/pnpm/11.21.0/dist/pnpm.mjs:102230:25)
  ...
  #9 ERROR: process "/bin/sh -c pnpm install --frozen-lockfile" did not complete successfully: exit code: 1
  ```

  El `lockfileVersion` en `pnpm-lock.yaml` es `'9.0'`, consistente con una línea de pnpm 9.x (no
  11.x), lo que sugiere que el lockfile se generó con una versión de pnpm bastante anterior a la
  que Corepack terminó descargando por no estar pineada.

  No se modificó el Dockerfile ni `package.json` para arreglarlo (fuera del alcance autorizado
  para este repo); se documenta como hallazgo bloqueante abajo.

## Fuga de archivos — imagen dev

**No aplica.** El build falló antes de producir la imagen `sgpmp-frontend:dev`; no hay nada que
inspeccionar con `docker run`.

## Ejecución — dev

**No aplica**, mismo motivo.

## Build — target prod (con build-arg)

- **Comando exacto usado:**
  ```
  docker build --target prod \
    --build-arg VITE_API_BASE_URL=http://smoke-test-marker.invalid:9999 \
    -t sgpmp-frontend:test .
  ```

- **Exit code:** `1`. Falla en el mismo punto (`base 5/5: RUN pnpm install --frozen-lockfile`),
  con el mismo `ERR_UNKNOWN_BUILTIN_MODULE: node:sqlite`, ya que el target `prod` depende de la
  etapa `build`, que a su vez depende de la misma etapa `base` que falla para `dev`. Se confirma
  que es el mismo problema raíz para ambos targets, no algo específico de `dev`.

  Nota adicional (no bloqueante, pero vale registrarla): el linter de BuildKit reportó 6
  advertencias `SecretsUsedInArgOrEnv` sobre los `ARG`/`ENV` de `VITE_FIREBASE_API_KEY`,
  `VITE_FIREBASE_AUTH_DOMAIN` y `VITE_VAPID_KEY` en la etapa `build` (líneas 26-40 del
  Dockerfile). Es el comportamiento esperado de BuildKit para cualquier `ARG`/`ENV` cuyo nombre
  contenga patrones como `KEY`; en este caso son valores de configuración de Firebase que de
  todas formas quedan públicos en el bundle de JS (client-side), no secretos reales — se menciona
  para que quede registrado, no como hallazgo urgente.

## Verificación del build-arg horneado

**No aplica.** Sin imagen `sgpmp-frontend:test`, no hay bundle en el que buscar el marcador
`smoke-test-marker`.

## Ejecución — prod

**No aplica**, mismo motivo.

## Tamaño de las imágenes

```
docker images --format "{{.Repository}}:{{.Tag}}  {{.Size}}" | grep sgpmp-frontend
```

**Resultado:** sin coincidencias. Ninguna de las dos imágenes (`sgpmp-frontend:dev`,
`sgpmp-frontend:test`) existe.

## Veredicto (previo al fix)

**No.** Ninguno de los dos targets (`dev`, `prod`) construía en ese momento. El Dockerfile en sí
tiene una estructura razonable (multi-stage, `.dockerignore` correcto, `nginx.conf` con fallback
SPA — no se llegó a probar en ejecución pero la config luce correcta a simple vista), pero la
etapa `base`, compartida por ambos targets, fallaba de forma reproducible por la combinación
`node:20-slim` + pnpm sin pinear (Corepack resuelve pnpm 11.21.0, que requiere Node ≥22.13).
Esto bloqueaba el spike completo: no se pudo verificar fuga de archivos, servido de Vite, horneado
del build-arg, ni fallback de SPA de nginx, porque ninguna imagen llegó a construirse.

> Ver más abajo la sección **"Corrección aplicada y reverificación"** — el veredicto final del
> spike está ahí, no en esta sección (que se conserva tal cual quedó registrada en el momento del
> fallo original).

## Corrección aplicada y reverificación

Implementación corrigió el `Dockerfile`:

```diff
- FROM node:20-slim AS base
+ FROM node:22-slim AS base
  WORKDIR /app
- RUN corepack enable
+ RUN corepack enable && corepack prepare pnpm@11.21.0 --activate
```

Es decir: subió la imagen base a Node 22 (satisface el `≥22.13` que exige pnpm 11.21.0) **y**
además pineó explícitamente la versión de pnpm con `corepack prepare pnpm@11.21.0 --activate`, en
vez de dejarla sin fijar. Con esto se cubren las dos causas a la vez: la versión de Node ya es
compatible, y además queda fija para que una futura versión de pnpm no vuelva a romper el build.
Se repitió el spike completo desde el paso 2.

### Build — target dev (reverificado)

- **Comando:** `docker build --target dev -t sgpmp-frontend:dev .`
- **Resultado:** exit code `0`. La instalación de dependencias (843 paquetes) tardó
  ~6m47s por ser la primera vez que se descargaban sin caché de pnpm (varios `WARN Request took
  Ns` por lentitud de red contra `registry.npmjs.org`, pero todos terminaron resolviendo — no hubo
  errores reales, solo reintentos/latencia):
  ```
  #9 409.9 Done in 6m 47.5s using pnpm v11.21.0
  #9 DONE 411.8s
  ...
  #11 unpacking to docker.io/library/sgpmp-frontend:dev 341.4s done
  EXIT_CODE=0
  ```

### Fuga de archivos — imagen dev (reverificado)

```
docker run --rm sgpmp-frontend:dev sh -c \
  'test -e .env && echo "⚠️ LEAK: .env presente"; \
   test -e .git && echo "⚠️ LEAK: .git presente"; \
   echo "verificación terminada"'
```

**Resultado exacto:**
```
verificación terminada
```

Sin advertencias de `LEAK` — ni `.env` ni `.git` están presentes en la imagen `dev`.

### Ejecución — dev (reverificado)

```
docker run -d --name sgpmp-frontend-dev-test -p 5174:5173 \
  -e VITE_API_BASE_URL=http://localhost:8000 \
  sgpmp-frontend:dev
```

`curl -i http://localhost:5174/` →
```
HTTP/1.1 200 OK
Content-Type: text/html
...
<script type="module">import { injectIntoGlobalHook } from "/@react-refresh";
...
<title>Ionic App</title>
```

Logs (`docker logs sgpmp-frontend-dev-test`):
```
  VITE v5.4.21  ready in 1087 ms
  ➜  Local:   http://localhost:5173/
  ➜  Network: http://172.17.0.2:5173/
```

Vite sirve correctamente con HMR activo (`@react-refresh`, `@vite/client` inyectados). Contenedor
detenido y eliminado tras la verificación.

### Build — target prod con build-arg (reverificado)

- **Comando exacto:**
  ```
  docker build --target prod \
    --build-arg VITE_API_BASE_URL=http://smoke-test-marker.invalid:9999 \
    -t sgpmp-frontend:test .
  ```
- **Resultado:** exit code `0`. `tsc && vite build` tardó 2m53s (2952 módulos transformados);
  reutilizó en caché la etapa `base` ya resuelta por el build de `dev`. Únicas advertencias:
  tamaño de chunk (`index-*.js` ~2.4MB sin gzip, señalado por Vite como candidato a code-splitting
  — no es un problema de la imagen, es una observación normal de bundle del propio proyecto) y las
  mismas 6 advertencias `SecretsUsedInArgOrEnv` de BuildKit ya documentadas arriba (siguen siendo
  falsos positivos).

### Verificación del build-arg horneado (reverificado)

```
docker run --rm sgpmp-frontend:test sh -c \
  "grep -rl 'smoke-test-marker' /usr/share/nginx/html/assets/ || echo 'NO SE ENCONTRÓ EL MARCADOR'"
```

**Resultado exacto:**
```
/usr/share/nginx/html/assets/index-legacy-BhiDsyBg.js
/usr/share/nginx/html/assets/index-BNm9PBQ7.js
```

El marcador **sí se encontró**, en ambos bundles (el moderno y el legacy que genera el plugin de
compatibilidad de Vite). Confirma que `--build-arg` → `ARG`/`ENV` → `vite build` queda horneado en
el JS de punta a punta.

### Ejecución — prod (reverificado)

```
docker run -d --name sgpmp-frontend-prod-test -p 8082:80 sgpmp-frontend:test
```

`curl -i http://localhost:8082/` → `HTTP/1.1 200 OK`, sirve `index.html` con los assets con hash
correctos.

`curl -i http://localhost:8082/una/ruta/inventada` → **`HTTP/1.1 200 OK`** (mismo `index.html`,
mismo `Content-Length: 2358`) — el fallback SPA del `try_files` en `nginx.conf` funciona como se
esperaba, no devuelve 404.

Logs de nginx (`docker logs sgpmp-frontend-prod-test`):
```
2026/08/15 00:29:43 [notice] 1#1: nginx/1.27.5
2026/08/15 00:29:43 [notice] 1#1: start worker process 29
...
172.17.0.1 - - [15/Aug/2026:00:29:52 +0000] "GET / HTTP/1.1" 200 2358 "-" "curl/8.15.0" "-"
172.17.0.1 - - [15/Aug/2026:00:29:52 +0000] "GET /una/ruta/inventada HTTP/1.1" 200 2358 "-" "curl/8.15.0" "-"
```

Sin `WARNING`/`ERROR`. Contenedor detenido y eliminado tras la verificación.

### Tamaño de las imágenes (reverificado)

```
docker images --format "{{.Repository}}:{{.Tag}}  {{.Size}}" | grep sgpmp-frontend
```

```
sgpmp-frontend:test  80MB
sgpmp-frontend:dev   2.58GB
```

`prod` (`sgpmp-frontend:test`) queda liviana como se espera de una imagen `nginx:alpine` sirviendo
solo estáticos. `dev` pesa 2.58GB porque incluye el `node_modules` completo con devDependencies
(TypeScript, ESLint, Vitest, Cypress, etc.) — esperable para una imagen de desarrollo, no es una
imagen pensada para desplegar, así que no se lo marca como hallazgo.

## Veredicto

**Sí.** Con el fix de base image + pin de pnpm ya aplicado, ambos targets construyen y pasan las
8 verificaciones del brief: `dev` sirve con Vite/HMR sin fugas de `.env`/`.git`, `prod` hornea
correctamente las variables `VITE_*` vía `--build-arg` y nginx sirve tanto la raíz como el
fallback SPA con `200`. Los dos targets quedan listos para integrarse al `docker-compose` por
entorno.

## Pendientes / notas

1. ~~Bloqueante: pin de pnpm~~ — **resuelto.** Ver "Corrección aplicada y reverificación" arriba.
2. Revisar las advertencias `SecretsUsedInArgOrEnv` de BuildKit con el equipo, para decidir si
   conviene silenciarlas explícitamente (son falsos positivos en este caso — esas variables
   `VITE_*` quedan públicas en el bundle de todas formas) o dejarlas como recordatorio visual en
   cada build.
3. El chunk principal (`index-*.js`, ~2.4MB sin gzip / ~570KB con gzip) supera el límite por
   defecto que avisa Vite (500KB). No es un problema de contenerización ni bloquea este spike,
   pero conviene que el equipo de frontend evalúe code-splitting en algún momento — impacta el
   tiempo de carga inicial de la SPA, no el build de Docker en sí.
4. La imagen `dev` (2.58GB) es pesada por diseño (incluye devDependencies completas). Si en el
   compose de dev se prefiere no reconstruirla seguido, tenerlo presente para decisiones de caché
   de capas, pero no requiere cambios en el Dockerfile.
