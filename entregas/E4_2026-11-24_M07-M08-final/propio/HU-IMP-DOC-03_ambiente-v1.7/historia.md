# HU-IMP-DOC-03 — El documento de ambiente de trabajo y el mapa de puertos v1.7 reflejan los dos servidores, los dominios verificados y los tramos MQTT de E4

> Texto final cargado en Taiga el 2026-11-23 (HU #6071; ST-01 = #6072). Fuente para historia.md.

## Para copiar en Taiga — Descripción de la HU

**Rama:** `docs/hu-imp-doc-03` → PR a `main` (SGMP-Integracion) · **Plazo:** 2026-11-23 17:00 (entrega a revisión); E4 2026-11-24 · **Responsable:** Juan Hernando Perdomo (ST-01 a ST-03) · Sebastián Sandoval (ST-04) · **Revisa:** Sebastián Sandoval · **Entrega:** E4 · **Módulos:** Transversal

**Origen.** Hallazgos de E4: curl del 2026-11-23, HU-IMP-AMB-11 (PR #27 de SGMP-Integracion, decisión 9), HU-IMP-CFG-04 y Taiga #5478. Versión anterior: v1.6 (HU-IMP-DOC-02, E2).

**Situación actual.** La v1.6 (corte 2026-11-02) ya no describe el ambiente real:

- Supone un solo servidor; hoy el broker (gateway y Mosquitto) está en otro servidor, sin red Docker común con el backend.
- Los dominios son los de octubre; por ejemplo, el frontend de DEV figura en `api.inmero.co` y hoy está en `inmero.co/sigab-dev`.
- Muestra Mosquitto en 1884/1885 sin TLS hacia los dispositivos y no distingue los dos tramos MQTT.
- Mantiene `GATEWAY_API_TOKEN` (descartada) y conecta el broker a la base por red interna.

Los hashes de las ramas se fijan en ST-01.

**Descripción.** Reunir y redactar la información que cambia desde la v1.6, con cada dato respaldado por el código de su rama, el compose, un curl o el catálogo. Lo no verificado se marca «por confirmar». Juan Hernando entrega las secciones nuevas, las evidencias y el mapa; Sebastián las integra en el documento y genera el Word.

**Alcance (prioridad A, plazo 17:00).**

- Control del documento y tabla de fuentes y corte.
- §3.1: los dos servidores (servidor del backend y servidor del broker).
- §3.4: una nota que remite al catálogo vigente con los cambios de E4.
- §3.8: dominios, rutas, prefijo, orígenes, puertos y red.
- §8.2: broker por ambiente y tramos MQTT.
- §11.3 (estado), §11.4 (pendientes y riesgos) y §13 (control de cambios).
- Ajuste del mapa v1.6 → v1.7: servidores, tramos MQTT y puertos. No es un rediseño.

De Taiga #5478 solo se cita el riesgo del puerto publicado de PostgreSQL; no se mencionan credenciales.

**Pendiente declarado para la v1.8** (se lista en §13): §3.3 (volúmenes y migraciones), las filas del catálogo en §3.4, §8.1 y §8.4.

**Fuera de alcance:** asignar puertos y dominios (Despliegue); las variables del broker en el Dokploy de Arekkazu (AIoT); la decisión sobre el puerto 5449 (#5478, Despliegue y Análisis); las conversiones de formato (Sebastián); las secciones 1, 2, 4 a 7, 9, 10 y 12.

**Fuentes para verificar.** Manda el código. Se lee con `git fetch` y `git show origin/<rama>:<archivo>`, sin cambiar de rama.

| Fuente | Ramas | Qué revisar |
|---|---|---|
| `Arekkazu/sgpmp-backend` | `dev`, `test`, `main` | `docker-compose.yml`, `docker-compose.test.yml`, `docker-compose.prod.yml` (puertos de PostgreSQL, `expose`, redes, volúmenes); `Dockerfile`; `.github/workflows/_migrate-template.yml` y `migrate-*.yml` |
| `Arekkazu/SGPMP-FRONT-END-PWA` | `dev`, `test`, `main` | `Dockerfile` (`VITE_BASE_PATH`, `subruta.conf`), `nginx.conf` (CSP `connect-src`), compose |
| `SerBy48/BROKER-MQTT-SGPMP` | `develop`, `test`, `main` | DEV: `docker-compose.yml` (`develop`); TEST: `docker-compose.test.yml` (`test`); PROD: `docker-compose.prod.yml` (`main`, l. 240-246 sobre `BACKEND_URL`). Puertos 1883/8883/9001/9002, `MQTT_HOST_PORT`, `MQTT_WS_HOST_PORT`, `MQTT_TLS`, `BACKEND_URL`, `.env*.example` |
| `Juanher01/SGMP-Integracion` | `main` | `registros/variables/VARIABLES-ENTORNO.md`; `registros/entornos/CONTRATO-PROD.md` y `CONTRATO-TEST.md`; `registros/seguridad/registro-SEG.md` (SEG-BROKER-02); `entregas/E4_2026-11-24_M07-M08-final/prs/BRK-PR35_compose-prod-broker/HU-IMP-AMB-11_catalogo-broker-mqtt-tls/` (`historia.md` y `evidencias/ST-05_comparacion-dokploy.md`); `entregas/E4_2026-11-24_M07-M08-final/issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/historia.md` |
| Documento v1.6 | — | Drive, Implementacion/1_Ambientes: `AMBIENTE-DE-TRABAJO-IMPLEMENTACION_v1.6.docx` e `IMP_Diag_Despliegue_Puertos_Protocolos_v1.6.drawio` |
| Documentos de Desarrollo | — | Drive, 3_Fuentes externas: 01 (Integración SIGAB) y 05 (Despliegue), del 2026-11-14 |
| Contexto v1.7 | — | `contexto-documento-ambiente-v1.7.md` (lo entrega Sebastián): lista de cambios, pendientes por equipo y estado de las HU de E4 |
| Dominios públicos | — | `curl -s -o /dev/null -w "%{http_code}" <url>` (nunca `-v`) y `curl -sI <url>` para el `ETag` |

Si una fuente contradice el contexto v1.7, gana el código y la diferencia se anota como hallazgo en la entrega.

**Reglas para el trabajo con IA.**

- La IA redacta; los datos (dominios, puertos, hashes, nombres de variables) salen solo de las fuentes de arriba.
- No pegar en la IA archivos `.env`, variables de Dokploy, direcciones IP ni valores de secretos.
- Lo que no se haya verificado se escribe «por confirmar (Despliegue)» o «por confirmar (AIoT)».

**Criterios de aceptación.**

1. **CA-1** `evidencias/CA-1_corte.txt` tiene la fecha y hora del `git fetch` y el `git rev-parse --short` de BE `dev`/`test`/`main`, FE `dev`/`test`/`main`, BRK `develop`/`test`/`main` y SGMP-Integracion `main`.
2. **CA-2** `entregables/secciones-v1.7.md` trae cada sección con el mismo número y título de la v1.6 y una línea «Reemplaza §X.Y de la v1.6» o «Nueva», lista para integrar.
3. **CA-3** Cada dominio de §3.8 y §8.2 coincide con el código HTTP de `evidencias/curl-dominios.txt`. El gateway de DEV figura «por confirmar» mientras no responda.
4. **CA-4** Cada puerto citado lleva `repo rama@commit archivo:líneas` (tabla en `evidencias/CA-4_puertos.md`) o «por confirmar (Despliegue)».
5. **CA-5** Se describen el servidor del backend y el servidor del broker, y los dos tramos MQTT: dispositivo → Mosquitto con TLS donde exista; gateway → `mosquitto:1883` en claro, con `MQTT_TLS=false`. Ninguna entrega contiene direcciones IP.
6. **CA-6** Ninguna entrega contiene valores de secretos; los sensibles se nombran como «valor propio (Dokploy)».
7. **CA-7** La nota de §3.4 remite a `registros/variables/VARIABLES-ENTORNO.md@<hash>` y menciona solo los cambios de E4: `BROKER_SERVICE_TOKEN` reemplaza a `GATEWAY_API_TOKEN`; `MQTT_TLS=false`; `BACKEND_URL` pública; `ALLOWED_ORIGINS` y `FRONTEND_URL` por entorno; `VITE_BASE_PATH`.
8. **CA-8** §11.3 y §11.4 listan los pendientes por equipo con su responsable y estos riesgos: orígenes compartidos, captura de `PathPrefix`, puerto de PostgreSQL publicado (#5478), TEST sin TLS hacia los dispositivos (SEG-03) y `BACKEND_URL` interna en el compose PROD del broker (CFG-01). §13 lista los pendientes declarados para la v1.8.
9. **CA-9** `entregables/IMP_Diag_Despliegue_Puertos_Protocolos_v1.7.drawio` muestra los dos servidores, los tramos MQTT y los puertos de CA-4, con todas las flechas conectadas a sus dos cajas.
10. **CA-10** PR abierto a `main` de SGMP-Integracion antes de las 17:00, sin atribución a herramientas.
11. **CA-11** (Sebastián) La v1.7 integrada está en `entregas/E4_2026-11-24_M07-M08-final/documentos/`, el `.docx` está en Drive (Implementacion/1_Ambientes) y el README de E4 anota el commit y el enlace.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | `git fetch --all`; `git rev-parse --short origin/<rama>` en cada repo | 10 hashes con fecha | `evidencias/CA-1_corte.txt` |
| CA-3 | `curl -s -o /dev/null -w "%{http_code}" <url>` por URL | El mismo código que el documento | `evidencias/curl-dominios.txt` |
| CA-4 | `git show origin/<rama>:<compose> \| grep -n -A3 ports` | Puerto y líneas citadas | `evidencias/CA-4_puertos.md` |
| CA-5 | `grep -EnP "\b\d{1,3}(\.\d{1,3}){3}\b"` sobre `entregables/` | 0 líneas | Salida pegada en el PR |
| CA-6 | `grep -EniP "(password\|token\|secret\|key)\w*\s*[=:]\s*\S"` sobre `entregables/` | 0, o solo «valor propio (Dokploy)» | Salida pegada en el PR |
| CA-9 | Mover cada caja en draw.io | Las flechas la siguen | Captura en el PR |
| CA-11 | Integración y `md2docx.ps1` | `.docx` revisado y en Drive | Enlace en el README de E4 |

**Definición de terminado.**

- ☑ CA-1 a CA-10 cumplidos según REV-02 (APROBAR CON OBSERVACIONES). CA-10: PR #32 abierto el 2026-11-23 a las 17:57, después del plazo de las 17:00.
- ☑ Ajustes de REV-01 aplicados (REV-02). Observaciones A y C cerradas en la ST-04; B y E por confirmar (Despliegue); D pendiente en el PR #32.
- ☐ CA-11: v1.7 integrada en `documentos/` con el dato de Despliegue del 2026-11-23 y el mapa reorganizado; `.docx` generado con `md2docx.ps1` desde el commit fuente `5de6495` (ST-04, PR #33). PR #32 fusionado; falta fusionar el PR #33, subir el `.docx` a Drive y anotar el enlace en el README de E4.
- ☑ `entregas/README.md` y el README de E4 actualizados (en revisión final).

**Dependencias y aprobaciones.** El PR lo aprueba el líder de Implementación. Sin respuesta de Despliegue (puertos de Mosquitto, gateway de DEV) ni de AIoT (variables del broker), esos datos quedan «por confirmar» y no bloquean.

**Riesgos.**

- Datos inventados por la IA: se mitiga con evidencias de comandos y la revisión del líder.
- Falta de tiempo: la prioridad B ya está fuera del plazo de las 17:00.

**Referencias.** Taiga #5478 · HU-IMP-AMB-11 · HU-IMP-CFG-04 · PR #27 y #28 de SGMP-Integracion · v1.6 (HU-IMP-DOC-02).

## Para copiar en Taiga — Subtareas

### ST-01 fijar el corte y verificar dominios y puertos — Juan Hernando

**Objetivo.** Corte fijado y evidencia de dominios y puertos, antes de redactar.

**Pasos.**

1. `git fetch --all` en los 4 repos y `git rev-parse --short` de las 10 ramas → `evidencias/CA-1_corte.txt`.
2. Crear la rama `docs/hu-imp-doc-03` desde `origin/main` de SGMP-Integracion.
3. curl de los dominios de frontend, backend (con y sin `www.`) y gateway (`/v1/healthz`) en DEV, TEST y PROD; comparar el `ETag` de `inmero.co/sigab-test` con el de `inmero.co/sigab/` → `evidencias/curl-dominios.txt`.
4. `git show` de los compose por rama: PostgreSQL en BE (5447/5448/5449), Mosquitto y gateway en BRK (puertos, `MQTT_TLS`, `BACKEND_URL`, redes) → tabla en `evidencias/CA-4_puertos.md`, con «por confirmar» donde no haya dato.

**Entregable.** Las tres evidencias en `entregas/E4_2026-11-24_M07-M08-final/propio/HU-IMP-DOC-03_ambiente-v1.7/evidencias/`.

**Verificación.** CA-1, CA-3, CA-4.

**Estimación.** 2 h

### ST-02 redactar las secciones de la v1.7 — Juan Hernando

**Objetivo.** Texto listo para integrar, con citas a las fuentes.

**Pasos.**

1. Tomar como referencia el texto de la v1.6 (docx en Drive) y el contexto v1.7.
2. Redactar en `entregables/secciones-v1.7.md`, cada una con «Reemplaza §X.Y» o «Nueva»: control del documento, tabla de fuentes y corte, §3.1, nota de §3.4, §3.8, §8.2, §11.3, §11.4 y §13.
3. Citar cada dato técnico como `BE main@<hash> docker-compose.prod.yml:l-l`, o con la evidencia de ST-01.
4. Anotar como hallazgo cualquier diferencia entre el código y el contexto v1.7.

**Entregable.** `entregables/secciones-v1.7.md`

**Verificación.** CA-2, CA-5 a CA-8.

**Estimación.** 3 h

### ST-03 ajustar el mapa v1.7 y abrir el PR — Juan Hernando

**Objetivo.** Mapa ajustado y PR listo para revisión a las 17:00.

**Pasos.**

1. Sobre el drawio v1.6: agregar las cajas «Servidor del backend» y «Servidor del broker» (sin IP), las flechas dispositivo → Mosquitto (TLS) y gateway → `mosquitto:1883` (en claro), gateway → backend (HTTPS público), gateway → PostgreSQL (puerto publicado, nota #5478), y las etiquetas de puertos de CA-4.
2. Guardar como `entregables/IMP_Diag_Despliegue_Puertos_Protocolos_v1.7.drawio` y exportar un PNG al lado.
3. Correr los grep de CA-5 y CA-6 sobre `entregables/`.
4. Abrir el PR a `main` con las salidas de los grep y la captura del mapa.

**Entregable.** drawio, PNG y PR.

**Verificación.** CA-5, CA-6, CA-9, CA-10.

**Estimación.** 1 h

### ST-04 integrar la v1.7 y generar el Word — Sebastián Sandoval

**Objetivo.** Documento v1.7 entregable.

**Pasos.**

1. Regenerar la base .md desde el docx v1.6 (Pandoc) en `entregas/E4_2026-11-24_M07-M08-final/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`; commit base.
2. Integrar `secciones-v1.7.md` y el mapa (PNG en `documentos/img/`).
3. `md2docx.ps1`; actualizar la tabla de contenido; revisar tablas, imagen, portada y numeración.
4. Subir a Drive (Implementacion/1_Ambientes) y anotar el commit y el enlace en el README de E4.

**Verificación.** CA-11.

**Estimación.** 2 h

## Notas para el líder

No se copian a Taiga.

**Plazo.** Entrega a revisión 2026-11-23 17:00; la ST-04 (integración y Word) queda para la noche del 2026-11-23, antes de E4 (2026-11-24). La base `.md` de la v1.6 se adelanta en la rama `docs/ambiente-v1.7`.

**Insumos ya revisados.** `insumos-2026-11-23.md` (en esta carpeta) resume lo que el líder verificó el 2026-11-23: punto de partida para ST-01, no sustituye la evidencia propia de Juan Hernando.

**Preguntas abiertas.**

1. **AIoT:** ¿qué valores tienen `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` de PROD en el Dokploy de Arekkazu? El compose PROD del broker las exige sin valor por defecto y ninguna rama, documento ni commit las fija.
2. **Despliegue y AIoT:** ¿los gateways de `api.inmero.co/broker-sigab` y `api.inmero.co/broker-sigab-test` están en uso o son restos? El backend de cada entorno apunta a otro gateway (`MQTT_BROKER_URL`).

**Puntos de atención para `/revisar`.**

- Datos sin cita o inventados por la IA: cada dominio, puerto, hash y nombre de variable debe tener su fuente (rama@commit y líneas, curl o catálogo).
- Direcciones IP, incluidos los hosts `sslip.io`, que llevan la IP en el nombre.
- Valores de secretos.
- Puertos sin `repo rama@commit archivo:líneas` (ni «por confirmar»).
- Secciones sin «Reemplaza §X.Y de la v1.6» o «Nueva».
- La frase del contexto v1.7 «dispositivos → Mosquitto por TLS 8883/9002» copiada como si valiera para todos los entornos: solo vale para PROD (DEV y TEST publican en claro).

## Metadatos

- **Redacción:** 2026-11-23 (registro en el repositorio del texto cargado en Taiga; CA, subtareas, horas y asignación sin cambios).
- **Fuentes:** `PI4/hu-imp-doc-03-taiga.md` (texto final de Taiga #6071, ST-01 = #6072); SGMP-Integracion `main@f69094b`; BRK `develop@2f8ea54`, `test@662e096`, `main@2181993`; BE `dev@77e0d772`, `test@1ee56516`, `main@e3b07ae6` (`git fetch` del 2026-11-23).
