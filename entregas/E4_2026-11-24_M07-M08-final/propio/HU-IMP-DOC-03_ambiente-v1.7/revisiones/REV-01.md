# REV-01 — HU-IMP-DOC-03 (documento de ambiente y mapa de puertos v1.7)

**Lo que está bien:**
- **H-05** es un hallazgo nuevo y correcto: el gateway de PROD busca la base por `sgpmp-network`, que no existe entre los dos servidores.
- Corregiste el nombre `MQTT_ACK_REQUIERE_ID_COMANDO`, que la v1.6 tenía mal.
- Revisé con `git show` 15 citas `rama@commit` y las 15 coinciden con el código.

**Datos de la revisión:**
- **Fecha:** 2026-11-23, 15:05 -0500.
- **Qué se revisó:** rama `origin/docs/hu-imp-doc-03` en `e3c65ad` (Juan Hernando). Todavía no hay PR.
- **Contra qué:** los criterios de la HU (`historia.md`), `insumos-2026-11-23.md` y la base v1.6 del líder. Código: `git fetch` del 2026-11-23 a las 15:04.
- **Decisiones del líder:**
  - El entregable es el documento completo en `documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`, no `entregables/secciones-v1.7.md`.
  - Juan Hernando corrige solo las secciones de su alcance. El líder las pasa a su base v1.6 en la ST-04.
- **Ya verificado por el líder (no se repite):** no hay direcciones IP, no hay secretos y el drawio tiene 27 aristas con `source` y `target`.

## Dictamen: SOLICITAR CAMBIOS

Hay que corregir el dominio del frontend de TEST, el texto sobre los gateways del broker (con el dato de Despliegue de las 16:00), la redacción de los puertos de PROD, el mapa y §13. Después, abrir el PR antes de las 17:00.

## Criterios de aceptación

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-1 | CUMPLE | Los 10 hashes eran la punta de cada rama a las 11:38 (`git merge-base --is-ancestor`). BE y FE avanzaron hacia las 13:50, pero los archivos citados no cambiaron (`git diff --stat <hash> origin/<rama>` sobre compose, Dockerfile y `nginx.conf`: vacío). Ver ajuste 11. |
| CA-2 | CUMPLE (desviación aceptada) | Documento completo en lugar de secciones sueltas. |
| CA-3 | NO CUMPLE | El frontend de TEST figura en `https://inmero.co/sigab-test/`, que sirve el build de PROD (mismo ETag, H-02). El de TEST está en `https://api.inmero.co/sigab-test` (dominio en Dokploy: `ST-05_comparacion-dokploy.md`, «Hallazgos fuera de alcance») y no se probó. Los gateways `api.inmero.co/broker-sigab*` se presentan como endpoints en uso (ajustes 1 y 2). |
| CA-4 | NO CUMPLE | Las 15 citas muestreadas coinciden (ver abajo). Pero los puertos de host de PROD no dicen «por definir en el despliegue» (ajuste 3) y hay citas sin rama@commit (ajuste 7). |
| CA-5 | CUMPLE, con una observación | Dos servidores (§3.1) y dos tramos (§8.2) bien descritos. «TLS 8883/9002» solo aparece como vigente en PROD. Observación: la tabla de §3.8 pone «8883 TLS» sin decir que es solo PROD (ajuste 8). |
| CA-6 | CUMPLE | Verificado por el líder. |
| CA-7 | CUMPLE | La nota de §3.4 cita `VARIABLES-ENTORNO.md@13cd3aa` (está en `main`) y nombra solo los cinco cambios de E4. |
| CA-8 | NO CUMPLE | Están los cinco riesgos, pero «orígenes compartidos» incluye a TEST (es otro origen) y la captura de `PathPrefix` está mal explicada (ajuste 1). Falta el riesgo de gateways duplicados (ajuste 2). En §13, la v1.6 figura como «solo mapa» y §8.4 como «sección nueva» (ajuste 5). |
| CA-9 | NO CUMPLE | Las aristas están bien (líder). El PNG no coincide con el texto (ajuste 4). |
| CA-10 | NO VERIFICABLE AÚN | Sin PR. Plazo 17:00 (ajuste 6). |
| CA-11 | No aplica | Es la ST-04 del líder. |

**Muestreo de citas (todas coinciden con `git show`):**
- **BE:**
  - `dev@77e0d772 docker-compose.yml:40-41`, `:61`
  - `test@1ee56516 docker-compose.test.yml:29-30`, `:52-55`
  - `main@e3b07ae6 docker-compose.prod.yml:73-74`, `:129-131`, `:251-252`
- **BRK:**
  - `main@2181993 docker-compose.prod.yml:91-93`, `:195`, `:246-247`, `:256-257`, `:327`, `:333-334`
  - `develop@2f8ea54 docker-compose.yml:86-87`, `.env.example:12`, `:85`
  - `test@662e096 docker-compose.test.yml:49-50`
- **FE:** `Dockerfile:13`, `:45-54`, idéntico en `1a8aad03`, `6ebc1faa` y `ed446c62`
- **H-01:** `git rev-list --left-right --count origin/test...origin/main` → `14 31`, igual que en tu evidencia.

## Ajustes para Juan Hernando

**Alcance de las correcciones.** Corrige solo las secciones de tu alcance:
- control del documento y tabla de fuentes;
- §3.1, nota de §3.4, §3.8 (y las filas de los grupos de §3.4 que ya cambiaste);
- §8, §8.2, §11.3, §11.4 y §13;
- el mapa.

**No restaures** contenido de otras secciones aunque falte respecto de la v1.6: eso lo hace el líder en la ST-04. En la descripción del PR, lista exactamente qué secciones modificaste (número y título); son las que el líder pasará a su base.

### Bloqueantes

1. **Frontend de TEST.**
   - **Curl:** prueba `https://api.inmero.co/sigab-test/` (y con `www.`) y agrégalo a `evidencias/curl-dominios.txt`.
   - **§3.8:** pon ese dominio en la tabla. Reescribe «Orígenes»: DEV y PROD comparten el origen `https://inmero.co`; TEST está en `https://api.inmero.co`, que es el mismo origen de los backends.
   - **§3.4, Grupo A:** `ALLOWED_ORIGINS` de TEST es `https://api.inmero.co` y `FRONTEND_URL` de TEST es `https://api.inmero.co/sigab-test`.
   - **§11.4, riesgo «orígenes compartidos»:** solo DEV–PROD.
   - **H-02, §11.3 (elemento 5) y §11.4, riesgo de `PathPrefix`:** la captura de `PathPrefix(/sigab)` es real. Pero `inmero.co/sigab-test` no es el frontend de TEST: esa URL cae en el build de PROD. El riesgo es que alguien la use creyendo que es TEST.

2. **Gateways del broker.** Hoy el documento dice que el backend llama al gateway por `api.inmero.co/broker-sigab*` y «Igual» en PROD. No consta: según `insumos-2026-11-23.md` (parte b), el backend apunta a otros gateways.
   - **Corrígelo con la información del broker que envía Despliegue a las 16:00** y cítala como fuente, en:
     - §3.1 (servidores)
     - §3.8 (tabla y «Entre servidores»)
     - §8 (introducción) y §8.2 (tabla y fila «Backend → gateway»)
     - §3.4, Grupo C (`MQTT_BROKER_URL`)
     - la flecha del mapa
   - **Si no se nombra un host técnico, no escribas su nombre:** contiene la IP. Escribe «host técnico del servidor del broker».
   - **Lo que no llegue a las 16:00 queda así:** «`api.inmero.co/broker-sigab` y `/broker-sigab-test` responden, pero no consta que el backend los use: por confirmar (Despliegue y AIoT)». Agrega a §11.4 el riesgo «gateways duplicados» (Despliegue y AIoT).
   - **H-03:** no digas que el backend de DEV usa esa ruta.

3. **Puertos de host de Mosquitto en PROD.** Donde hoy dice solo `MQTT_HOST_PORT` / `MQTT_WS_HOST_PORT`, escribe «por definir en el despliegue; el compose los exige sin valor por defecto». Va en §3.1, §3.8, §8.2, Grupo E de §3.4 y el mapa.

4. **Mapa** (drawio y PNG):
   - **Gateway:** la flecha de `/broker-sigab-*` no pasa por el Traefik del servidor del backend, porque el gateway está en el servidor del broker. Rotúlala según el ajuste 2.
   - **Puerto de host de PROD:** según el ajuste 3.
   - **Nota «PostgreSQL — CN-001»:** cita `main@c68775af`; usa `BE main@e3b07ae6` (`docker-compose.prod.yml:73-74`).
   - **Nota «Broker MQTT — CN-002»:** dice que el objetivo del gateway → BD es la red interna (`dokploy-network`). Déjala coherente con H-05: entre servidores no hay red común; DEV y TEST usan el puerto publicado y PROD está pendiente (#5478).
   - **Motor M04:** ubícalo como en el mapa v1.6. Hoy queda fuera de los dos servidores.

5. **§13, control de cambios.**
   - La v1.6 existió como versión del documento y del mapa (HU-IMP-DOC-02, 2026-11-02). Corrige la fila «1.6 (solo mapa) … El documento no cambió de versión».
   - Renombra «Cambios de la versión 1.5 a la 1.7» a «1.6 a la 1.7».
   - En «Pendientes para la v1.8»: §8.4 no es «sección nueva», ya existía (motor M04, sin cambios en E4).

6. **Entrega antes de las 17:00.**
   - Quita el `.docx` de `documentos/`: las exportaciones no se versionan y la conversión es la ST-04.
   - Integra `origin/main` en tu rama (merge o rebase). `main` (`2c059fb`) ya trae `historia.md` e `insumos-2026-11-23.md` en la carpeta de la HU.
   - Abre el PR a `main`. Incluye la lista de secciones modificadas, las salidas de los grep de CA-5 y CA-6 y la captura del mapa.

### Menores

7. **Citas sin rama@commit:**
   - FE `Dockerfile:13, 45-54` (§3.1, §3.4 y §3.8): agrega `FE dev@1a8aad03 / test@6ebc1faa / main@ed446c62` (idéntico en las tres).
   - Introducción de §8: `BRK develop@2f8ea54 docker-compose.yml:77,83`.
   - Grupo C, `MQTT_BROKER_URL` de TEST: en `test@1ee56516` está en la l. 69, no en la 65.

8. **§3.8, tabla de Mosquitto:** la columna «puerto interno» dice «1883 en claro · 8883 TLS» para todos. Aclara «8883/9002 TLS: solo PROD».

9. **Numeración de hallazgos.** En AMB-11 y en los insumos, «H-01» es el `BACKEND_URL` interno (CFG-01); en tu entrega es la promoción del broker. Para no confundir, cita siempre el código: por ejemplo «H-04 (CFG-01)», o numera los tuyos como «DOC03-H-01».

10. **§11.2 B, paso 7 (firewall del 5448/5449):** escribe «alternativa en discusión, #5478».

11. **Corte (CA-1):** repite el `git fetch` antes del PR. BE y FE avanzaron a las 13:50, pero los archivos citados no cambiaron. Actualiza los hashes o anota en `CA-1_corte.txt` que los archivos citados siguen iguales.

12. **§3.4, Grupo D:** según ST-05, `VITE_API_BASE_URL` de DEV y PROD usa `www.api.inmero.co`. Corrige las filas que cambiaste para que coincidan con ST-05, o déjalas como estaban.

## Para el líder (ST-04)

No requiere acción de Juan Hernando. La entrega se armó sobre la v1.5. Las secciones fuera del alcance son idénticas a la v1.5 y les falta lo que agregó la v1.6. Al pasar las secciones de Juan Hernando a la base v1.6 (`ad1a03e`, rama local `docs/ambiente-v1.7`), estas secciones se conservan de la base:

- **§2.4:** filas del motor M04 en Entradas (Desarrollo) y en Salidas (Despliegue y AIoT).
- **§3.3:** párrafo del motor y subsección «Imagen del motor de inferencia M04 (PR #54)».
- **§3.4:**
  - Grupo C: filas `IOT_INFERENCIA_*` y su nota.
  - Grupo F completo.
  - Reglas de estandarización: ejemplo de las `IOT_INFERENCIA_*`.
- **§3.8:** el motor en «Servicios web». Integrar con la tabla nueva de Juan Hernando.
- **§4:** el motor en «Imágenes y compose», en «Comunicación» y en los healthchecks.
- **§5:** rutas `entregas/<entrega>/**/<HU>/` (ADR-002). La entrega volvió a `historias/<HU>/`.
- **§8.1:** tabla de la v1.6 (motor y `test@662e096`).
- **§8.3:** mención del motor.
- **§8.4:** completa.
- **§9:** mención de `entregas/README.md`.
- **§11.1:** el motor en la fila del broker.
- **§11.2:** párrafos del motor en A y B (el paso 7 de B va con el ajuste 10).
- **§11.4:** incidencias INC-BE-08, INC-BRK-04 e INC-BRK-05. Las dos últimas no están en `registros/incidencias/registro.md`: solo existen en la v1.6.
- **§13:** tabla «Actualización por la imagen del motor M04 (versión 1.6, 2026-11-02)». Agregar el Grupo F a los pendientes de la v1.8.

En §3.3, Grupo F, §8.4 y §11.4 va la nota «sin cambios en E4; pendiente de actualizar en la v1.8».
