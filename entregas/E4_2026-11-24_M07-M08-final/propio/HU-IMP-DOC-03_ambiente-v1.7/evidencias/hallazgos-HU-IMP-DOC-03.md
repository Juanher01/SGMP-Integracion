# Hallazgos de HU-IMP-DOC-03 (H-01 a H-06)

Adjunto de la subtarea ST-01 (Taiga #6072) de la HU #6071. Origen: corte del 2026-11-23 11:38 -0500 (`evidencias/CA-1_corte.txt`).
El documento v1.7 no describe estas irregularidades: §11.4 solo las cita como `H-0x (Taiga #6072)`.

---

## H-01 · El broker no promueve por TEST: la rama `test` está detenida desde el 2026-11-01

**Hallazgo.** En BROKER-MQTT-SGPMP los cambios pasan de `develop` a `main` sin pasar por `test` (PR #67, 2026-11-21, de `develop` a `main`). Al corte:
- `test@662e096` es del 2026-11-01.
- `test` tiene 14 commits que no están en `main`.
- `main` tiene 31 commits que no están en `test`.
- `develop` no tiene commits fuera de `main`.

**Evidencia.** `git rev-list --left-right --count origin/test...origin/main` → `14 31`.
**Impacto.** El broker de TEST no corresponde a lo que se despliega en PROD, así que no se puede verificar en TEST lo que llega a PROD.
**Responsable.** AIoT (dueño del repo), con Pruebas (aprueba los PR a `test`).

## H-02 · `inmero.co/sigab` captura `inmero.co/sigab-test`: TEST sirve el mismo frontend que PROD

**Hallazgo.** `https://inmero.co/sigab-test/` y `https://inmero.co/sigab/` devuelven el mismo ETag (`6b0248a0-f63`). En nginx, el ETag se arma con la fecha de modificación y el tamaño del archivo, así que es el mismo `index.html`.
**Evidencia.**
- `evidencias/curl-dominios.txt`, líneas 23-25: mismo ETag.
- `fc.exe evidencias\H-02_sigab-test.html evidencias\H-02_sigab.html` → «no se encontraron diferencias».
- `evidencias/H-02_sigab-test.html`: todas las rutas del HTML servido en `/sigab-test/` apuntan a `/sigab/` (por ejemplo, `/sigab/assets/index-CDLmW4jf.js` y `/sigab/manifest.json`). Ninguna apunta a `/sigab-test/`, que es el `VITE_BASE_PATH` de TEST.
**Impacto.** Quien abre el frontend de TEST está usando el build de PROD. Las pruebas de TEST no prueban el código de la rama `test`.
**Causa probable.** Prefijo de ruta de Traefik (`PathPrefix(/sigab)`) sin barra final ni prioridad, por lo que captura `/sigab-test`.
**Responsable.** Despliegue (dominios y rutas en Dokploy).

## H-03 · El gateway de DEV no responde

**Hallazgo.** `https://api.inmero.co/broker-sigab-dev/v1/healthz` devuelve 404. Los gateways de TEST y PROD sí devuelven 200.
**Evidencia.** `evidencias/curl-dominios.txt`, línea 11.
**Impacto.** El backend de DEV no puede enviar comandos al broker por la URL pública.
**Responsable.** Despliegue y AIoT.

## H-04 · CFG-01: el compose PROD del broker exige `BACKEND_URL` interna, pero el broker está en otro servidor

**Hallazgo.** `BRK main@2181993 docker-compose.prod.yml:246` describe `BACKEND_URL` como «URL interna de sgpmp-backend en sgpmp-network». El broker se despliega en un servidor distinto al del backend, sin red Docker común, así que el gateway solo puede llegar al backend por la URL pública (HTTPS).
**Impacto.** Si se configura como dice el compose, el gateway no entrega eventos al backend.
**Responsable.** AIoT (compose), con Despliegue.

## H-05 · El gateway de PROD llega a PostgreSQL por una red que no existe entre los dos servidores

**Hallazgo.**
- **PROD:** el gateway arma `DATABASE_URL` con `${DB_HOST}:5432` sobre la red externa `sgpmp-network` (`BRK main@2181993 docker-compose.prod.yml:195, 333-334`).
- **Red del backend:** el backend de PROD usa otra red, `dokploy-network` (`BE main@e3b07ae6 docker-compose.prod.yml:251-252`), y está en otro servidor.
- **DEV/TEST:** el gateway usa el puerto publicado de PostgreSQL (`.env.example:12`, host y puerto 5447).

**Impacto.**
- **El compose PROD del broker no puede conectar a la base** tal como está escrito.
- **Choca con la propuesta de #5478.** Cerrar el puerto publicado de PostgreSQL dejaría sin base al gateway mientras no exista otra vía.

**Relación.** Taiga #5478.
**Responsable.** AIoT y Despliegue, con Implementación.

## H-06 · Puertos de host de Mosquitto en PROD sin definir

**Hallazgo.** `BRK main@2181993 docker-compose.prod.yml:91-93` exige `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` sin valor por defecto. El propio compose los marca pendientes de AIoT y Despliegue.
**Impacto.** No hay puerto MQTTS/WSS acordado para que los dispositivos se conecten a PROD.
**Responsable.** Despliegue y AIoT.

---

**Ya registrados (solo se citan en §11.4):**
- **Taiga #5478:** puerto de PostgreSQL publicado.
- **SEG-03:** TEST sin TLS hacia los dispositivos (`BRK test@662e096 docker-compose.test.yml:28-30`, en claro).
