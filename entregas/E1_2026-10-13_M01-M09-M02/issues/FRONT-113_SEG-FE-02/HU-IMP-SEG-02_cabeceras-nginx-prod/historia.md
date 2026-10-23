# HU-IMP-SEG-02 — Cerrar SEG-FE-02: evidencia de las cabeceras de seguridad del frontend, validación de la CSP y cierre con Análisis

> Estado: borrador para Taiga · Redactado: 2026-10-12 · Actualizado: 2026-10-13 contra el corte [`registros/entornos/corte-2026-10-13.md`](../../../../../registros/entornos/corte-2026-10-13.md) · Fuente: [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113)

## Para copiar en Taiga — Descripción de la HU

**Rama:** sin cambios de código previstos en el frontend; evidencias en `SGMP-Integracion` (`docs/seg-fe-02-evidencia` → PR a `main`) · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Directriz de seguridad — [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113) · Código `SEG-FE-02` · Autor: miguelortiz13 (Análisis) · Abierto: 2026-09-12 · Asignado: Chebaztian.

**Situación actual.** Corte del 2026-10-13 (`git fetch --prune` a las 10:59:47 -0500). Hashes: `dev@8c30fa3`, `test@95fa674`, `main@2132c62` (release 1.3.1). Las cabeceras ya están en las tres ramas, incluida `main`: llegaron por promoción y ya no hace falta un PR dirigido.

| Rama | Cabeceras (`ce0a3a4`) | Caché `immutable` solo en `/assets/` (`f09af93`) | `nginx.conf` / `Dockerfile` | Evidencia |
|---|---|---|---|---|
| dev `8c30fa3` | ✅ | ✅ | blob `9171b7e` / `cf55808` | `git merge-base --is-ancestor <commit> 8c30fa3` → INCLUIDO |
| test `95fa674` | ✅ | ✅ | ídem (mismos blobs) | ídem con `95fa674` |
| main `2132c62` | ✅ | ✅ | ídem (mismos blobs) | Corte §2.3; ídem con `2132c62` |

Contenido común (`git show <hash>:nginx.conf`): `X-Content-Type-Options`, `X-Frame-Options DENY`, `Referrer-Policy`, `Permissions-Policy` (l. 34–37), `Strict-Transport-Security "max-age=31536000"` sin `includeSubDomains` (l. 41) y `Content-Security-Policy-Report-Only` con `${API_ORIGIN}` (l. 49), todas con `always`. El `Dockerfile` deriva `API_ORIGIN` de `VITE_API_BASE_URL` con `envsubst` (l. 43–44).

Lo que falta no es código: evidencia en los entornos desplegados (DEV, TEST), la prueba de la aplicación con la CSP, la verificación de la imagen de `main` (PROD no tiene URL definida) y el comentario de cierre. En `main` el frontend solo tiene `docker-compose.yml` (corte §2.2).

**Descripción.** Reunir la evidencia que pide el issue para cerrar SEG-FE-02: cabeceras presentes en todas las respuestas, HSTS emitido una sola vez y documentado, la aplicación funcionando con la CSP en modo Report-Only, y la imagen de PROD emitiendo las mismas cabeceras. Luego proponer el cierre a Análisis.

**Alcance.** Verificación en DEV y TEST desplegados; build local de la imagen de `main`; prueba de la CSP en TEST; comentario de cierre; registro. · **Fuera de alcance:** pasar la CSP a modo de bloqueo (otra HU, cuando no haya violaciones); reglas de Traefik y dominio de PROD (Despliegue); service worker y `vite.config.ts` (Desarrollo).

**Criterios de aceptación.**
1. CA-1 En DEV y TEST desplegados, las rutas `/`, `/index.html`, un archivo de `/assets/` y una ruta inexistente responden con `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, `Strict-Transport-Security` y `Content-Security-Policy-Report-Only`.
2. CA-2 `Strict-Transport-Security` aparece **una sola vez** por respuesta en DEV y TEST (Traefik no lo duplica), sin `includeSubDomains`.
3. CA-3 En TEST, el login, las llamadas a la API, la carga de logos, el reCAPTCHA del registro y la suscripción a push funcionan, y las violaciones de CSP de la consola quedan registradas (cero, o listadas con su origen).
4. CA-4 La imagen construida desde `main@2132c62` pasa `nginx -t` y, en local, emite las cabeceras de CA-1 en las mismas cuatro rutas, con la API presente en `connect-src`.
5. CA-5 En PROD desplegado se cumple CA-1. Si PROD aún no tiene dominio, el criterio queda **No verificable aún** con fecha y se registra así, sin bloquear el resto.
6. CA-6 La decisión sobre HSTS (en nginx y no en Traefik, sin `includeSubDomains` por el VPS compartido) y la tabla de violaciones de CSP quedan en el comentario de cierre de #113.
7. CA-7 `registros/seguridad/registro-SEG.md` actualizado con el estado de SEG-FE-02 por rama y por entorno.
8. CA-8 La HU y su evidencia citan la fecha de corte (`git fetch --prune` 2026-10-13 10:59:47 -0500) y los hashes `dev@8c30fa3`, `test@95fa674`, `main@2132c62`; antes de abrir el PR de evidencias y antes de entregar el cierre se repite el `fetch` y, si alguna rama avanzó, se rehace la comprobación de `ce0a3a4` y del blob de `nginx.conf` sobre el hash nuevo.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | `for u in https://dev.inmero.co https://api.inmero.co; do for p in / /index.html /assets/<archivo>.js /no-existe; do echo "== $u$p"; curl -sSI "$u$p" \| grep -iE 'x-content\|x-frame\|referrer\|permissions\|strict-transport\|content-security'; done; done` (el asset real sale de `curl -s <url>/ \| grep -o 'assets/[^"]*\.js' \| head -1`) | Las 6 cabeceras en cada respuesta | Salida pegada con fecha y hora |
| CA-2 | `curl -sSI https://dev.inmero.co/ \| grep -ci strict-transport-security` y lo mismo con `https://api.inmero.co/` | `1` y valor `max-age=31536000` | Salida |
| CA-3 | Navegador en ventana privada sobre `https://api.inmero.co/`: DevTools → Consola con filtro "Content-Security-Policy"; recorrer login → panel → vista con logo → registro (reCAPTCHA) → activar notificaciones | Flujos funcionando; violaciones listadas | Capturas y tabla de violaciones |
| CA-4 | `git -C SGPMP-FRONT-END-PWA archive 2132c62 \| docker build -t sgpmp-front:main-verif --build-arg VITE_API_BASE_URL=https://api.inmero.co/back-sigab-test -`; `docker run -d --rm -p 8088:80 --name fv sgpmp-front:main-verif`; `docker exec fv nginx -t`; `for p in / /index.html /assets/<archivo>.js /no-existe; do curl -sSI "http://localhost:8088$p"; done`; `docker stop fv` | `test is successful`; las 6 cabeceras en las 4 rutas; `connect-src 'self' https://api.inmero.co` en la CSP | Salidas |
| CA-5 | El comando de CA-1 sobre el dominio de PROD | Igual que CA-1 | Salida, o la nota "No verificable aún: PROD sin dominio (aaaa-mm-dd)" |
| CA-6 | Revisión del comentario publicado en #113 | Decisión de HSTS y violaciones de CSP explicadas | Enlace |
| CA-7 | Lectura del registro | Estado por rama y entorno al día | Commit en SGMP-Integracion |
| CA-8 | `git -C SGPMP-FRONT-END-PWA fetch --prune origin && git -C SGPMP-FRONT-END-PWA rev-parse --short origin/dev origin/test origin/main` y `git -C SGPMP-FRONT-END-PWA rev-parse --short origin/main:nginx.conf` | Hashes iguales al corte y blob `9171b7e`, o la diferencia anotada y reverificada | Salida con fecha y hora |

**Definición de terminado.**
- [ ] CA-1 a CA-4, CA-6 a CA-8 cumplidos con evidencia; CA-5 cumplido o registrado como "No verificable aún".
- [ ] PR de evidencias en `SGMP-Integracion` aprobado por el Líder de Implementación.
- [ ] Comentario de cierre en #113 publicado por el líder.
- [ ] Si CA-3 encontró violaciones de CSP: hallazgo registrado para una HU de ajuste.

**Dependencias y aprobaciones.** Dominio y despliegue de PROD: Despliegue. Si CA-2 encuentra HSTS duplicado, coordinar con Despliegue para quitarlo de Traefik. Cierre: Análisis (Miguel). No hay PR en el repo del frontend.

**Riesgos.** (1) En PROD, `API_ORIGIN` sale de `VITE_API_BASE_URL`; si esa variable está vacía o es relativa en Dokploy, la CSP deja la API bajo `'self'`. En Report-Only no rompe nada, pero genera violaciones: confirmar con Despliegue que el build arg de PROD es una URL absoluta (no es secreto). (2) Que el código esté en `main` no prueba que PROD haya redesplegado: por eso CA-5 es separado de CA-4. (3) En TEST, el service worker puede servir la PWA en rutas del backend que comparten host (INC-FE-02, pendiente de triage); si interfiere con CA-3, usar ventana privada y anotarlo.

**Referencias.** Issue #113 · commits `ce0a3a4`, `f09af93` · corte `registros/entornos/corte-2026-10-13.md` §2.2–§2.3 · skills `nginx-frontend`, `verificacion` §5.

## Para copiar en Taiga — Subtareas

### ST-01 verificar las cabeceras en DEV y TEST desplegados
**Objetivo.** Cumplir CA-1 y CA-2.
**Pasos.**
1. Obtener el nombre de un asset real de cada entorno.
2. Ejecutar los comandos de CA-1 y CA-2.
3. Guardar las salidas en `entregas/E1_2026-10-13_M01-M09-M02/issues/FRONT-113_SEG-FE-02/HU-IMP-SEG-02_cabeceras-nginx-prod/evidencias/ca1-ca2.md` con fecha, hora y el hash de rama del corte.
**Entregable.** Archivo de evidencias.
**Verificación.** Las 6 cabeceras en las 4 rutas de ambos entornos y HSTS una sola vez.
**Estimación.** 1,5 h

### ST-02 validar la aplicación con la CSP en TEST
**Objetivo.** Cumplir CA-3.
**Pasos.**
1. Ventana privada → `https://api.inmero.co/` con DevTools abiertas (Consola y Red).
2. Recorrer: login, panel, una vista con logo, registro con reCAPTCHA, activar notificaciones push.
3. Copiar cada violación de CSP (directiva y origen bloqueado) y tomar capturas de los flujos.
4. Clasificar cada violación como "esperada" (ej. extensiones del navegador) o "hay que permitir" (con el origen exacto).
**Entregable.** `entregas/E1_2026-10-13_M01-M09-M02/issues/FRONT-113_SEG-FE-02/HU-IMP-SEG-02_cabeceras-nginx-prod/evidencias/ca3-csp.md` con capturas y la tabla de violaciones.
**Verificación.** CA-3.
**Estimación.** 2 h

### ST-03 llevar las cabeceras de seguridad a main — ✅ cerrar
**Objetivo.** `ce0a3a4` y `f09af93` en `main` del frontend.
**Entregable.** Ninguno de Implementación: llegaron a `main` por promoción. No se hizo cherry-pick ni PR dirigido.
**Verificación.** Corte 2026-10-13 §2.3: `git -C SGPMP-FRONT-END-PWA merge-base --is-ancestor ce0a3a4 2132c62` → SI; `f09af93` también INCLUIDO; `nginx.conf` de `main` idéntico al de `dev` y `test` (blob `9171b7e`).
**Estado.** Se crea como cerrada.

### ST-04 verificar en local la imagen de main
**Objetivo.** Cumplir CA-4 (evidencia de PROD por código mientras PROD no tenga URL).
**Pasos.**
1. Construir la imagen desde `2132c62` con `git archive` y el build arg de CA-4.
2. Levantarla, ejecutar `nginx -t` y los `curl` de las cuatro rutas.
3. Confirmar que la CSP lleva `https://api.inmero.co` en `connect-src` e `img-src`.
4. Guardar las salidas en `entregas/E1_2026-10-13_M01-M09-M02/issues/FRONT-113_SEG-FE-02/HU-IMP-SEG-02_cabeceras-nginx-prod/evidencias/ca4.md`.
**Entregable.** Archivo de evidencias.
**Verificación.** CA-4.
**Estimación.** 1,5 h

### ST-05 verificar PROD, redactar el cierre y actualizar el registro
**Objetivo.** Cumplir CA-5, CA-6, CA-7 y CA-8.
**Pasos.**
1. Reverificar el corte (comando de CA-8).
2. Si PROD ya tiene dominio, ejecutar CA-1 contra PROD; si no, registrar "No verificable aún" con la fecha.
3. Redactar el comentario de cierre para #113 con la plantilla de la skill `seguridad-analisis`: criterio × rama × entorno, decisión de HSTS y tabla de violaciones de ST-02.
4. Entregarlo al líder, actualizar `registros/seguridad/registro-SEG.md` y abrir el PR de evidencias en `SGMP-Integracion`.
**Entregable.** Borrador del comentario, registro actualizado y PR de evidencias.
**Verificación.** CA-5, CA-6, CA-7 y CA-8.
**Estimación.** 1,5 h

## Notas para el líder (no copiar a Taiga)

- **Plazo sugerido:** 2 días hábiles. Unas 6,5 h de trabajo; CA-5 puede quedar abierto mientras PROD no tenga dominio.
- **Preguntas abiertas:**
  1. ¿Se pide el cierre a Análisis con CA-5 "No verificable aún" y CA-4 (imagen de `main` en local) como evidencia de PROD, o Miguel prefiere esperar a que PROD esté desplegado? Conviene preguntárselo.
  2. ¿Quién confirma el valor (no secreto) de `VITE_API_BASE_URL` del build de PROD? Lo necesita CA-5 para interpretar la CSP.
- **Puntos de atención en la revisión:** que la evidencia de CA-1 y CA-4 incluya una ruta 404; que HSTS no salga duplicado; que CA-4 se haga sobre el hash `2132c62` (o el nuevo de CA-8), no sobre la rama de trabajo local.
- **Relación con el triage pendiente:** INC-FE-02 (service worker en el host compartido de TEST) puede interferir con ST-02. No se resuelve en esta HU.

### Cambios respecto a la versión anterior (2026-10-12)

- **Título y rama:** antes el resultado era "llevar las cabeceras a PROD" con la rama `fix/seg-fe-02-main` → PR a `main`. Ahora el código ya está en `main`; la HU solo reúne evidencia y propone el cierre. La única rama es la de evidencias en `SGMP-Integracion`.
- **Situación actual:** `main` pasa de ❌ a ✅ en `ce0a3a4` y `f09af93` (corte §2.3). Se agregan los blobs idénticos de `nginx.conf` y `Dockerfile` en las tres ramas. Se elimina la nota de "214 commits detrás" y la prueba local de cherry-pick.
- **CA:** el CA-4 anterior (PR a `main` con exactamente los dos commits por cherry-pick) se reescribe como verificación local de la imagen de `main@2132c62`. Se elimina el CA-5 anterior (PR aprobado por el Líder de Despliegue): ya no hay PR. Renumeración: antiguos CA-6, CA-7, CA-8 → CA-5, CA-6, CA-7. Nuevo CA-8 de fecha de corte. CA-6 ahora exige también la tabla de violaciones de CSP en el cierre.
- **Subtareas:** ST-03 (cherry-pick de `ce0a3a4` y `f09af93`) y ST-04 (PR a `main` y aprobación) se fusionan en una ST-03 cerrada sin ejecutar, porque el cambio llegó por promoción. Nueva ST-04: verificar en local la imagen de `main`. Trabajo pendiente: de 8,5 h a 6,5 h.
- **Pregunta retirada:** ya no hay que pedir al Líder de Despliegue un PR dirigido a `main`.

---
Redactado: 2026-10-12 · Actualizado: 2026-10-13.
Fuentes consultadas (2026-10-13, sin nuevo fetch): corte `registros/entornos/corte-2026-10-13.md` §2.2–§2.3; SGPMP-FRONT-END-PWA `dev@8c30fa3`, `test@95fa674`, `main@2132c62` (`git merge-base --is-ancestor ce0a3a4|f09af93 <hash>`, `git show <hash>:nginx.conf`, `git show <hash>:Dockerfile`, `git rev-parse <hash>:nginx.conf|Dockerfile`, `git ls-tree <hash>`); `registros/seguridad/registro-SEG.md`; `registros/incidencias/registro.md` (INC-FE-02); issue #113. Versión anterior: `dev@aab2625`, `main@e6418df` (2026-10-12).
