# REV-01 — HU-IMP-DOC-03 (documento de ambiente y mapa de puertos v1.7)

- **Fecha:** 2026-11-23, 15:05 -0500.
- **Qué se revisó:** rama `origin/docs/hu-imp-doc-03` en `e3c65ad` (Juan Hernando). Todavía no hay PR.
- **Contra qué:** la base v1.6 del líder (`ad1a03e`, rama `docs/ambiente-v1.7`, mismo archivo), los criterios de la HU (`historia.md`) y `insumos-2026-11-23.md`. Código: `git fetch` del 2026-11-23 a las 15:04.
- **Desviación aceptada por el líder:** el entregable es el documento completo en `documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` y no `entregables/secciones-v1.7.md`.
- **Ya verificado por el líder (no se repite):** no hay direcciones IP, no hay secretos y el drawio tiene 27 aristas con `source` y `target`.

## Dictamen: SOLICITAR CAMBIOS

Lo nuevo está bien trabajado. Las citas que revisé coinciden con el código y los hallazgos H-01 y H-05 son buenos. El problema principal es la base: el documento se armó sobre la **v1.5**, no sobre la v1.6. Las secciones que no tocaste quedaron idénticas a la v1.5 y se perdió todo lo que la v1.6 había agregado. Además, el frontend de TEST figura en un dominio que no es el suyo.

## Criterios de aceptación

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-1 | CUMPLE | Los 10 hashes eran la punta de cada rama a las 11:38 (`git merge-base --is-ancestor`). BE y FE avanzaron hacia las 13:50, pero los archivos citados no cambiaron (`git diff --stat <hash> origin/<rama>` sobre compose, Dockerfile y `nginx.conf`: vacío). Ver ajuste 12. |
| CA-2 | CUMPLE (desviación aceptada) | Documento completo en lugar de secciones sueltas. |
| CA-3 | NO CUMPLE | El frontend de TEST figura en `https://inmero.co/sigab-test/`, que sirve el build de PROD (mismo ETag, H-02). El de TEST está en `https://api.inmero.co/sigab-test` (dominio en Dokploy: `ST-05_comparacion-dokploy.md`, «Hallazgos fuera de alcance») y no se probó. Los gateways `api.inmero.co/broker-sigab*` se presentan como endpoints en uso (ajustes 3 y 4). |
| CA-4 | NO CUMPLE | Muestreo de 15 citas `rama@commit` con `git show`: las 15 coinciden (ver abajo). Pero los puertos de host de PROD no dicen «por definir en el despliegue» (ajuste 5) y hay citas sin rama@commit (ajuste 8). |
| CA-5 | CUMPLE, con una observación | Dos servidores (§3.1) y dos tramos (§8.2) bien descritos. «TLS 8883/9002» solo aparece como vigente en PROD. Observación: la tabla de §3.8 pone «8883 TLS» sin decir que es solo PROD (ajuste 9). |
| CA-6 | CUMPLE | Verificado por el líder. |
| CA-7 | CUMPLE | La nota de §3.4 cita `VARIABLES-ENTORNO.md@13cd3aa` (está en `main`) y nombra solo los cinco cambios de E4. |
| CA-8 | NO CUMPLE | Están los cinco riesgos, pero «orígenes compartidos» incluye a TEST (es otro origen) y la captura de `PathPrefix` está mal explicada (ajuste 3). Falta el riesgo de gateways duplicados (ajuste 4). En §13, la v1.6 figura como «solo mapa» y §8.4 como «sección nueva» (ajuste 2). |
| CA-9 | NO CUMPLE | Las aristas están bien (líder). El PNG no coincide con el texto en cuatro puntos: gateway por `/broker-sigab-*` a través del Traefik del servidor del backend, puerto de host de PROD, notas viejas y motor M04 (ajustes 4, 5, 7 y 1). |
| CA-10 | NO VERIFICABLE AÚN | Sin PR. Plazo 17:00. |
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

## Lo que está bien

- Las citas de puertos y variables son exactas y `CA-4_puertos.md` está muy completo.
- **H-05** (el gateway de PROD busca la base por `sgpmp-network`, que no existe entre servidores) es un hallazgo nuevo y correcto.
- **H-01** (el broker pasa de `develop` a `main` sin pasar por `test`) está bien demostrado.
- La nota de §3.4 es exacta.
- Corregiste el nombre `MQTT_ACK_REQUIERE_ID_COMANDO`, que la v1.6 tenía mal.
- Los dos tramos MQTT de §8.2 están claros y separados por ambiente.

## Ajustes

### Bloqueantes

1. **Partir de la v1.6, no de la v1.5.** La base es el mismo archivo en la rama `docs/ambiente-v1.7` (commit «docs(ambiente): base v1.6 para la v1.7»). Lo más simple es copiar esa base y pegar encima solo tus secciones del alcance: control, fuentes, §3.1, nota de §3.4, §3.8, §8.2, §11.3, §11.4 y §13.

   Todo lo demás debe quedar **como en la v1.6**. Lo que hoy falta o volvió a la v1.5:
   - **§2.4:** las filas del motor M04 en Entradas (Desarrollo) y en Salidas (Despliegue y AIoT).
   - **§3.3:** el párrafo del motor y la subsección «Imagen del motor de inferencia M04 (PR #54)».
   - **§3.4:**
     - Grupo C: filas `IOT_INFERENCIA_*` y su nota.
     - Grupo F completo.
     - Reglas de estandarización: el ejemplo de las `IOT_INFERENCIA_*`.
   - **§3.8:** el motor en «Servicios web».
   - **§4:** el motor en «Imágenes y compose», en «Comunicación» y en los healthchecks.
   - **§5:** las rutas `entregas/<entrega>/**/<HU>/` (ADR-002). Hoy dicen `historias/<HU>/`, que ya no existe.
   - **§8.1:** la tabla de la v1.6 (motor y `test@662e096`).
   - **§8.3:** la mención del motor.
   - **§8.4:** completa.
   - **§9:** la mención de `entregas/README.md`.
   - **§11.1:** el motor en la fila del broker.
   - **§11.2:** los párrafos del motor en A y en B.
   - **§11.4:** las incidencias INC-BE-08, INC-BRK-04 e INC-BRK-05. Las dos últimas no están en `registros/incidencias/registro.md`: si se borran de aquí, se pierden.

   En §3.3, Grupo F, §8.4 y §11.4 agrega la nota «sin cambios en E4; pendiente de actualizar en la v1.8».

2. **§13, control de cambios.**
   - La v1.6 no fue «solo mapa»: el documento pasó a versión 1.6 (HU-IMP-DOC-02, 2026-11-02). Corrige esa fila.
   - Restaura la tabla «Actualización por la imagen del motor M04 (versión 1.6, 2026-11-02)».
   - Renombra «Cambios de la versión 1.5 a la 1.7» a «1.6 a la 1.7».
   - En «Pendientes para la v1.8»: §8.4 no es nueva, es «motor M04, sin cambios en E4». Agrega el Grupo F.

3. **Frontend de TEST.**
   - **Curl:** prueba `https://api.inmero.co/sigab-test/` (y con `www.`) y agrégalo a `curl-dominios.txt`.
   - **§3.8:** pon ese dominio en la tabla. Reescribe «Orígenes»: DEV y PROD comparten el origen `https://inmero.co`; TEST está en `https://api.inmero.co`, que es el mismo origen de los backends.
   - **§3.4, Grupo A:** `ALLOWED_ORIGINS` de TEST es `https://api.inmero.co` y `FRONTEND_URL` de TEST es `https://api.inmero.co/sigab-test`.
   - **H-02, §11.3 (elemento 5) y §11.4:** la captura de `PathPrefix(/sigab)` es real. Pero `inmero.co/sigab-test` no es el frontend de TEST: esa URL cae en el build de PROD. El riesgo es que alguien la use creyendo que es TEST. El riesgo de «orígenes compartidos» es solo DEV–PROD.

4. **Gateways del broker** (ver `insumos-2026-11-23.md`, parte b). Hoy el documento dice que el backend llama al gateway por `api.inmero.co/broker-sigab*` y «Igual» en PROD. No consta:
   - En DEV y TEST, el backend (`MQTT_BROKER_URL`) apunta a un host técnico del servidor del broker. No escribas su nombre: contiene la IP.
   - En PROD apunta al broker del Dokploy de AIoT (Arekkazu).

   Escribe «`api.inmero.co/broker-sigab` y `/broker-sigab-test` responden, pero no consta que el backend los use: por confirmar (Despliegue y AIoT)». Va en:
   - §3.1 (servidores)
   - §3.8 (tabla y «Entre servidores»)
   - §8 (introducción) y §8.2 (tabla y fila «Backend → gateway»)
   - §3.4, Grupo C (`MQTT_BROKER_URL` de PROD)
   - la flecha del mapa

   En H-03, no digas que el backend de DEV usa esa ruta. Agrega a §11.4 el riesgo «gateways duplicados» (Despliegue y AIoT).

   **Ojo:** a las 16:00 llega la información del broker de Despliegue. Si responde esto, escribe lo que diga y cítala como fuente. Este ajuste queda pendiente de ese dato.

5. **Puertos de host de Mosquitto en PROD.** Donde hoy dice solo `MQTT_HOST_PORT` / `MQTT_WS_HOST_PORT`, escribe «por definir en el despliegue; el compose los exige sin valor por defecto». Va en §3.1, §3.8, §8.2, Grupo E de §3.4 y el mapa.

6. **Saca el `.docx` de `documentos/`.** Las exportaciones no se versionan y la conversión es la ST-04.

### Menores

7. **Mapa:** actualiza dos notas que vienen de la v1.6 y ubica el motor.
   - «PostgreSQL — CN-001» todavía cita `main@c68775af`; usa `main@e3b07ae6`.
   - «Broker MQTT — CN-002» dice que el objetivo del gateway → BD es la red interna. Choca con H-05: déjalo coherente con el texto.
   - El motor M04 queda fuera de los dos servidores: indica en cuál corre o «por confirmar».

8. **Citas sin rama@commit:**
   - FE `Dockerfile:13, 45-54` (§3.1, §3.4 y §3.8): agrega `FE dev@1a8aad03 / test@6ebc1faa / main@ed446c62` (idéntico en las tres).
   - Introducción de §8: `BRK develop@2f8ea54 docker-compose.yml:77,83`.
   - Grupo C, `MQTT_BROKER_URL` de TEST: en `test@1ee56516` está en la l. 69, no en la 65.

9. **§3.8, tabla de Mosquitto:** la columna «puerto interno» dice «1883 en claro · 8883 TLS» para todos. Aclara «8883/9002 TLS: solo PROD».

10. **Numeración de hallazgos.** En AMB-11 y en los insumos, «H-01» es el `BACKEND_URL` interno (CFG-01); en tu entrega es la promoción del broker. Para no confundir, cita siempre el código: por ejemplo «H-04 (CFG-01)», o numera los tuyos como «DOC03-H-01».

11. **§11.2 B, paso 7 (firewall del 5448/5449):** escribe «alternativa en discusión, #5478».

12. **Antes de abrir el PR:**
    - Rebasa tu rama sobre `origin/main` (`2c059fb`, que ya trae `historia.md` e `insumos-2026-11-23.md`).
    - Repite el `git fetch`. BE y FE avanzaron a las 13:50; los archivos citados no cambiaron. Actualiza los hashes o anota que los citados siguen iguales.

13. **§3.4, Grupo D:** según ST-05, `VITE_API_BASE_URL` de DEV y PROD usa `www.api.inmero.co`. Si cambias filas de los grupos (es v1.8), que coincidan con ST-05; si no, déjalas como en la v1.6.

## Borrador del comentario para Juan Hernando

Juan Hernando: buen trabajo con las citas (revisé 15 y todas coinciden con el código) y con los hallazgos H-01 y H-05, que son nuevos y útiles. Hay que corregir sobre todo dos cosas:

1. El documento salió de la v1.5. Toma el archivo de la rama `docs/ambiente-v1.7` (base v1.6) y pega encima solo tus secciones. Así vuelve todo lo del motor M04 y las correcciones de la v1.6.
2. El frontend de TEST está en `https://api.inmero.co/sigab-test`, no en `inmero.co/sigab-test`.

Además:
- los gateways `broker-sigab*` quedan «por confirmar» hasta el dato de Despliegue de las 16:00;
- los puertos de PROD van como «por definir en el despliegue»;
- saca el `.docx`.

La lista completa está en `revisiones/REV-01.md`: primero los bloqueantes (1 a 6), luego los menores.
