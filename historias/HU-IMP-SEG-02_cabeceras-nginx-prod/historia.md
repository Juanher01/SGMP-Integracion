# HU-IMP-SEG-02 — Cerrar SEG-FE-02: cabeceras de seguridad del frontend en PROD y validación de la CSP

> Estado: borrador para Taiga · Redactado: 2026-10-12 · Fuente: [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113)

## Para copiar en Taiga — Descripción de la HU

**Rama:** `fix/seg-fe-02-main` → PR a `main` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Directriz de seguridad — [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113) · Código `SEG-FE-02` · Autor: miguelortiz13 (Análisis) · Abierto: 2026-09-12 · Asignado: Chebaztian.

**Situación actual.** Verificado con git el 2026-10-12.

| Rama | Cabeceras de seguridad (`ce0a3a4`) | Caché `immutable` solo en `/assets/` (`f09af93`) | Evidencia |
|---|---|---|---|
| dev | ✅ | ✅ | `git merge-base --is-ancestor` |
| test | ✅ | ✅ | ídem |
| main | ❌ | ❌ | `main` está a 214 commits de `dev` |

Ambos commits se aplican limpios sobre `origin/main` (probado con `cherry-pick` el 2026-10-12). Se necesitan juntos: con `ce0a3a4` solo, el `map` de caché marcaría `firebase-messaging-sw.js` y los íconos de `public/` como `immutable` en PROD, y un cambio en ellos no llegaría a los usuarios.

**Descripción.** Llevar a PROD las cabeceras de seguridad que ya funcionan en DEV y TEST, y reunir la evidencia que pide el issue: cabeceras presentes en todas las respuestas, HSTS emitido una sola vez y documentado, y la aplicación funcionando con la CSP en modo Report-Only.

**Alcance.** `nginx.conf` y el paso `envsubst` del `Dockerfile` del frontend; verificación en DEV y TEST desplegados; PR a `main`; comentario de cierre. · **Fuera de alcance:** pasar la CSP a modo de bloqueo (será otra HU, cuando no haya violaciones); reglas de Traefik (Despliegue); service worker y `vite.config.ts` (Desarrollo).

**Criterios de aceptación.**
1. CA-1 En DEV y TEST desplegados, las rutas `/`, `/index.html`, un archivo de `/assets/` y una ruta inexistente responden con `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, `Strict-Transport-Security` y `Content-Security-Policy-Report-Only`.
2. CA-2 `Strict-Transport-Security` aparece **una sola vez** por respuesta (Traefik no lo duplica), sin `includeSubDomains`.
3. CA-3 En TEST, el login, las llamadas a la API, la carga de logos, el reCAPTCHA del registro y la suscripción a push funcionan, y las violaciones de CSP que aparezcan en la consola quedan registradas (cero, o listadas con su origen).
4. CA-4 El PR a `main` contiene exactamente `ce0a3a4` y `f09af93` (con `cherry-pick -x`); la imagen construida desde esa rama pasa `nginx -t` y emite las cabeceras de CA-1 en local.
5. CA-5 El PR a `main` es aprobado por el Líder de Despliegue y queda fusionado.
6. CA-6 En PROD desplegado se cumple CA-1. Si PROD aún no tiene dominio, el criterio queda **No verificable aún** y se registra así, sin bloquear el resto.
7. CA-7 La decisión sobre HSTS (en nginx y no en Traefik, sin `includeSubDomains` por el VPS compartido) queda explicada en el issue #113.
8. CA-8 `registros/seguridad/registro-SEG.md` actualizado con el estado por rama.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | `for u in https://dev.inmero.co https://api.inmero.co; do for p in / /index.html /assets/<archivo>.js /no-existe; do echo "== $u$p"; curl -sSI "$u$p" \| grep -iE 'x-content\|x-frame\|referrer\|permissions\|strict-transport\|content-security'; done; done` (el nombre de un asset real sale de `curl -s <url> \| grep -o 'assets/[^"]*\.js' \| head -1`) | Las 6 cabeceras en cada respuesta | Salida pegada con fecha |
| CA-2 | `curl -sSI https://dev.inmero.co/ \| grep -ci strict-transport-security` (y TEST) | `1` y valor `max-age=31536000` | Salida |
| CA-3 | Navegador en ventana privada sobre `https://api.inmero.co/`: DevTools → Consola con filtro "Content-Security-Policy"; recorrer login → panel → vista con logo → registro (reCAPTCHA) → activar notificaciones | Flujos funcionando; violaciones listadas | Capturas y lista de violaciones |
| CA-4 | `git log --format='%h %s' origin/main..fix/seg-fe-02-main`; `docker build -t sgpmp-front:verif --build-arg VITE_API_BASE_URL=https://api.inmero.co/back-sigab-test .`; `docker run -d --rm -p 8088:80 --name fv sgpmp-front:verif`; `curl -sSI http://localhost:8088/` y `/no-existe`; `docker exec fv nginx -t` | 2 commits con "cherry picked from"; cabeceras presentes; `test is successful` | Salidas |
| CA-5 | `gh pr view <n> -R Arekkazu/SGPMP-FRONT-END-PWA --json state,mergedBy` | `MERGED` | Enlace al PR |
| CA-6 | El comando de CA-1 sobre el dominio de PROD | Igual que CA-1 | Salida, o la nota "No verificable aún: PROD sin dominio (fecha)" |
| CA-7 | Revisión del comentario publicado en #113 | Decisión y motivo explicados | Enlace |
| CA-8 | Lectura del registro | Estado por rama al día | Commit en SGMP-Integracion |

**Definición de terminado.**
- [ ] CA-1 a CA-5, CA-7 y CA-8 cumplidos con evidencia; CA-6 cumplido o registrado como "no verificable aún".
- [ ] PR a `main` fusionado por el Líder de Despliegue.
- [ ] Comentario de cierre en #113 publicado por el líder.
- [ ] Si CA-3 encontró violaciones de CSP: hallazgo registrado para una HU de ajuste.

**Dependencias y aprobaciones.** PR a `main`: Líder de Despliegue. Dominio de PROD: Despliegue. Cierre: Análisis (Miguel). Si CA-2 encuentra HSTS duplicado, coordinar con Despliegue para quitarlo de Traefik.

**Riesgos.** (1) En PROD, `API_ORIGIN` sale de `VITE_API_BASE_URL`; si esa variable está vacía o es relativa, la CSP deja la API bajo `'self'`. Como está en Report-Only, no rompe nada, pero genera violaciones: verificar el valor con Despliegue (sin pedir secretos, es una URL pública). (2) Conflicto trivial en `nginx.conf` cuando llegue el release `dev → main`. (3) En TEST, el service worker puede servir la PWA en rutas del backend que comparten host; si interfiere con CA-3, usar ventana privada y anotarlo (está pendiente de triage aparte).

**Referencias.** Issue #113 · commits `ce0a3a4`, `f09af93` · skills `nginx-frontend`, `promocion-entornos`.

## Para copiar en Taiga — Subtareas

### ST-01 verificar las cabeceras en DEV y TEST desplegados
**Objetivo.** Cumplir CA-1 y CA-2 en DEV y TEST.
**Pasos.**
1. Obtener el nombre de un asset real de cada entorno.
2. Ejecutar los comandos de CA-1 y CA-2.
3. Guardar las salidas en `historias/HU-IMP-SEG-02_cabeceras-nginx-prod/evidencias/ca1-ca2.md`.
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
**Entregable.** `historias/HU-IMP-SEG-02_cabeceras-nginx-prod/evidencias/ca3-csp.md` con capturas y la tabla de violaciones.
**Verificación.** CA-3.
**Estimación.** 2 h

### ST-03 preparar la rama de promoción a main
**Objetivo.** Cumplir CA-4.
**Pasos.**
1. `git -C SGPMP-FRONT-END-PWA fetch origin && git switch -c fix/seg-fe-02-main origin/main`.
2. `git cherry-pick -x ce0a3a4 f09af93`.
3. Construir, levantar y verificar con los comandos de CA-4 (incluido `nginx -t`).
4. Guardar las salidas en `historias/HU-IMP-SEG-02_cabeceras-nginx-prod/evidencias/ca4.md`.
**Entregable.** Rama local verificada.
**Verificación.** CA-4.
**Estimación.** 2 h

### ST-04 abrir el PR a main y acompañar la aprobación
**Objetivo.** Cumplir CA-5.
**Pasos.**
1. Push de `fix/seg-fe-02-main` y PR a `main` con: los dos commits y qué hace cada uno, por qué no se espera el release (214 commits de diferencia), evidencias de ST-01 a ST-03, el riesgo de conflicto trivial en el próximo release, y enlaces a #113 y la HU.
2. Avisar al Líder de Despliegue.
3. Responder sus observaciones.
**Entregable.** PR fusionado.
**Verificación.** CA-5.
**Estimación.** 1,5 h

### ST-05 verificar en PROD, redactar el cierre y actualizar el registro
**Objetivo.** Cumplir CA-6, CA-7 y CA-8.
**Pasos.**
1. Cuando PROD tenga dominio y redespliegue, ejecutar CA-1 contra PROD. Si no hay dominio, registrar "No verificable aún" con la fecha.
2. Redactar el comentario de cierre para #113 con la plantilla de la skill `seguridad-analisis`, incluyendo la decisión sobre HSTS y la tabla de violaciones de CSP de ST-02.
3. Entregarlo al líder y actualizar `registros/seguridad/registro-SEG.md`.
**Entregable.** Borrador del comentario y registro actualizado.
**Verificación.** CA-6, CA-7 y CA-8.
**Estimación.** 1,5 h

## Notas para el líder (no copiar a Taiga)

- **Plazo sugerido:** 2 a 3 días hábiles. Unas 8,5 h de trabajo; CA-6 puede quedar abierto mientras PROD no tenga dominio.
- **Preguntas abiertas:**
  1. ¿El Líder de Despliegue acepta un PR dirigido a `main` en el frontend? La alternativa es esperar el release `dev → main` y solo verificar.
  2. ¿Se cierra el issue con CA-6 "no verificable aún", o Análisis prefiere esperar a que PROD esté desplegado? Conviene preguntarle a Miguel.
- **Puntos de atención en la revisión:** que el PR traiga solo los dos commits (nada de `abed246`, que es el service worker y es de Desarrollo); que la evidencia de CA-1 incluya una ruta 404; que HSTS no salga duplicado.
- **Relación con el triage pendiente:** el problema del service worker en TEST (host compartido) puede interferir con ST-02. No se resuelve en esta HU.

---
Fuentes consultadas (2026-10-12): `origin/dev@aab2625`, `origin/main@e6418df` de SGPMP-FRONT-END-PWA; prueba local de `cherry-pick` de `ce0a3a4` y `f09af93` sobre `origin/main`; issue #113.
