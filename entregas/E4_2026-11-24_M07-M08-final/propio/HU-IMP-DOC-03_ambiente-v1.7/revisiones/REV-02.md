# REV-02 — HU-IMP-DOC-03 (correcciones al REV-01)

**Lo que está bien:**
- Corregiste los seis bloqueantes del REV-01 y los seis menores, sin salirte del alcance.
- Los gateways quedaron sin nombrar el host técnico y con su fuente citada.
- La renumeración a `DOC03-H-0x` quedó coherente en el documento, los hallazgos y el mapa.

**Datos de la revisión:**
- **Fecha:** 2026-11-23, 17:40 -0500.
- **Qué se revisó:** rama `origin/docs/hu-imp-doc-03` en `9cf7631` (Juan Hernando):
  - `c60c23e` aplica el REV-01;
  - `9cf7631` integra `origin/main`. `origin/main` (`48f185b`) es ancestro de la punta.
  - Todavía no hay PR.
- **Contra qué:** `revisiones/REV-01.md` (en `main`), `historia.md` e `insumos-2026-11-23.md`.
  - Diff de las correcciones: `git diff e3c65ad c60c23e`.
  - Lista de secciones: diff por secciones contra la v1.5 y contra la base v1.6 del líder (`ad1a03e`).
- **Código:** `git fetch` del 2026-11-23 a las 17:26.

## Dictamen: APROBAR CON OBSERVACIONES

Los seis bloqueantes del REV-01 están corregidos. Quedan cinco observaciones menores; las cierra el líder en la ST-04 (tabla de abajo).

**Condición:** el PR a `main` se abre desde `9cf7631`, sin más cambios. Debe llevar:
- la lista de secciones modificadas (la de «Para el líder (ST-04)» sirve);
- las salidas de los grep de CA-5 y CA-6;
- la captura del mapa.

Si la punta cambia, se revisa solo el diff nuevo.

## Ajustes del REV-01

| # | Ajuste | Veredicto | Evidencia (punta `9cf7631`) |
|---|---|---|---|
| 1 | Frontend de TEST | CORREGIDO | **Curl:** `curl-dominios.txt` agrega `api.inmero.co/sigab-test/` → 200 y `www.api.inmero.co/sigab-test/` → 404.<br>**§3.8:** l. 419 (tabla) y l. 432 (Orígenes: DEV y PROD en `https://inmero.co`, TEST en `https://api.inmero.co`).<br>**Grupo A:** l. 295-296 (`ALLOWED_ORIGINS` = `https://api.inmero.co`; `FRONTEND_URL` = `https://api.inmero.co/sigab-test`).<br>**Riesgos y hallazgos:**<ul><li>§11.4 l. 723 y 724: orígenes compartidos solo DEV–PROD; captura de `PathPrefix` bien explicada.</li><li>§11.3, elemento 5, l. 707.</li><li>DOC03-H-02, «Impacto».</li></ul>Resto en la observación A. |
| 2 | Gateways del broker | CORREGIDO | **Fuente:** `insumos-2026-11-23.md` parte b (variables de Dokploy de Despliegue) y ST-05. No cita un dato propio de las 16:00.<br>**Dónde aparece:** fila nueva en Fuentes (l. 55) y en todas las ubicaciones pedidas:<ul><li>§3.1, l. 169</li><li>§3.8: tabla, l. 421-422; nota, l. 425; «Entre servidores», l. 448</li><li>§8 introducción, l. 596</li><li>§8.2: tabla, l. 617-621; «Backend → gateway», l. 629</li><li>Grupo C, l. 329</li><li>flecha del mapa</li></ul>**Rutas públicas:** `/broker-sigab` y `/broker-sigab-test` dicen «no consta que el backend la use: por confirmar (Despliegue y AIoT)».<br>**Riesgo:** «Gateways duplicados» en §11.4, l. 725, a cargo de Despliegue y AIoT.<br>**DOC03-H-03:** «el backend de DEV no la usa».<br>**Sin IP ni sslip.io** (punto 4 de abajo). Ver la observación B. |
| 3 | Puertos de host de PROD | CORREGIDO | «Por definir en el despliegue; el compose los exige sin valor por defecto» en:<ul><li>§3.1, l. 179</li><li>§3.8, l. 439-440</li><li>§8.2, l. 621</li><li>Grupo E, l. 362-363</li><li>`CA-4_puertos.md`</li><li>mapa: capa PROD, rótulo del tramo 1 y leyenda de protocolos</li></ul> |
| 4 | Mapa | CORREGIDO (motor: observación C) | **Flecha `MQTT_BROKER_URL`:** su `source` es «Servidor Backend Instance 1» y su `target` es «Gateway HTTP». No pasa por Traefik y lleva el rótulo DEV/TEST/PROD.<br>**Flecha `BACKEND_URL`:** va del broker al Traefik del backend.<br>**Puerto de PROD:** según el ajuste 3.<br>**CN-001:** cita `BE main@e3b07ae6 docker-compose.prod.yml:73-74`.<br>**CN-002:** «entre servidores no hay red Docker común; DEV y TEST usan el puerto publicado; PROD pendiente (#5478; DOC03-H-05)». |
| 5 | §13 | CORREGIDO | Fila «1.6 | 2026-11-02 | Documento y mapa…» (l. 771).<br>Título «Cambios de la versión 1.6 a la 1.7» (l. 774).<br>Fila de §8.4: «ya existía; sin cambios en E4» (l. 799). |
| 6 | Entrega | PARCIAL | El `.docx` se borró en `c60c23e`.<br>`origin/main` está integrado en `9cf7631`.<br>**Falta el PR:** era para las 17:00 y es la condición del dictamen. |
| 7 | Citas sin rama@commit | CORREGIDO | **FE `Dockerfile:13, 45-54`** con `dev@1a8aad03 / test@6ebc1faa / main@ed446c62`: §3.1 l. 177, nota de §3.4 l. 273, §3.8 l. 430 y `CA-4_puertos.md`.<br>**§8 introducción:** `BRK develop@2f8ea54`.<br>**Grupo C:** `test@1ee56516 … :69`. |
| 8 | «8883/9002 TLS: solo PROD» | CORREGIDO | §3.8, l. 439-440: «8883 TLS (solo PROD)» y «9002 WSS (solo PROD)». |
| 9 | Numeración de hallazgos | CORREGIDO (observación D) | `DOC03-H-01` a `DOC03-H-06` en la tabla de fuentes, §3.8, §11.3, §11.4, `hallazgos-HU-IMP-DOC-03.md` y el mapa. DOC03-H-04 lleva «(CFG-01)». |
| 10 | §11.2 B, paso 7 | CORREGIDO | l. 695: «el control de acceso al puerto 5448 (alternativa en discusión, #5478)». |
| 11 | Corte CA-1 | CORREGIDO | Nota en `CA-1_corte.txt`: repitió el fetch a las 16:40 y anotó que los archivos citados no cambiaron.<br>**Lo repetí a las 17:26:** `git diff --stat <commit> origin/<rama>` sobre compose, Dockerfile, `nginx.conf` y `.env.example` sale vacío en las 9 ramas. FE `test` avanzó a `520c4afa` después de su nota, sin tocar esos archivos. |
| 12 | Grupo D | CORREGIDO | l. 341: `https://www.api.inmero.co/api-sgpmp-dev` y `https://www.api.inmero.co/sigab` (ST-05). TEST sin `www.` |

### Observaciones menores (no bloquean; las cierra el líder en la ST-04)

- **A. Nota vieja en el mapa.** En la capa «Hallazgos» (apagada por defecto, no sale en el PNG) quedó: «DEV y TEST del frontend comparten origen https://api.inmero.co». Ya estaba en `e3c65ad` y contradice §3.8. Corregir a «DEV y PROD comparten `https://inmero.co`».
- **B. «Broker del Dokploy de Arekkazu».** §3.1 dice que el servidor del broker es el Dokploy de AIoT, y la fila del gateway de §3.8 lo pone en el servidor «Broker». Pero en PROD el backend apunta al «broker del Dokploy de Arekkazu», y los insumos (parte b) dicen que el gateway y Mosquitto viven en ese Dokploy.
  - **Falta saber:** si ese Dokploy es el servidor del broker o el del backend. Si es el del backend, cambian DOC03-H-05 y la frase «sin red Docker común» para PROD.
  - **Propuesta:** confirmarlo con Despliegue. Mientras tanto, escribir en §3.1, en la fila del gateway de §3.8 y en la nota de §8.2 «servidor por confirmar (Despliegue)».
- **C. Motor M04 en el mapa.** Lo acordado es dejarlo fuera de los dos servidores con la nota «ubicación por confirmar (AIoT)».
  - Juan Hernando siguió el REV-01 («como en la v1.6») y lo puso dentro del servidor del backend (drawio: x=840, y=300, dentro del contenedor x=374–1290).
  - No tiene la nota. No es un error suyo: el acuerdo cambió después del REV-01.
  - **ST-04:** moverlo fuera de los dos servidores, agregar la nota y exportar de nuevo el PNG.
- **D. Nombres de archivo en DOC03-H-02.** La evidencia cita `evidencias\DOC03-H-02_sigab-test.html` y `DOC03-H-02_sigab.html`, pero los archivos se siguen llamando `H-02_sigab-test.html` y `H-02_sigab.html`. Corregir la cita o renombrar los archivos.
- **E. Afirmación del riesgo «Gateways duplicados».** El riesgo (§11.4, l. 725) dice «el backend usa otros gateways». La fila de §3.8 dice «no consta». Las dos salen de la misma fuente (insumos, parte b), así que es coherente; solo hay que verificarla cuando llegue la confirmación de Despliegue y AIoT.

## Verificaciones repetidas (punto 4 de la solicitud)

Sobre los 14 archivos de texto de la HU y `documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` en `9cf7631`:

| Verificación | Comando (resumen) | Resultado |
|---|---|---|
| IPv4 y sslip.io | `grep -nEi '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b\|sslip'` | Un solo resultado: `historia.md:185`. Es la nota del líder que prohíbe los hosts sslip.io, no un host. |
| Asignaciones a password, token, secret o key | `grep -noEi '[A-Z_]*(password\|token\|secret\|key)[A-Z_]*\s*=\s*…'` y su variante con `:` | Sin resultados. |
| Aristas del drawio sin `source` o `target` | Script sobre los `mxCell` con `edge="1"` | 27 aristas; 0 sin `source` o `target`. |

**PNG contra el drawio y las tablas (punto 5).**
- **Rótulos:** el PNG muestra las capas Base y Protocolos con los rótulos del drawio actual: tramo 1 con «PROD host por definir en el despliegue», flecha `MQTT_BROKER_URL` con DEV/TEST/PROD y nota CN-002 nueva.
- **Puertos:** PostgreSQL 5447/5448/5449 → 5432; Mosquitto 1884/1885 → 1883 y PROD → 8883 TLS; WS 9001 y 9002 → 9001 y PROD → WSS 9002; gateway `:8000 (expose)`. Coinciden con §3.8 (l. 419-440) y §8.2 (l. 617-621).
- **Capas por ambiente:** DEV, TEST y PROD están apagadas en el PNG. Sus rótulos en el drawio coinciden con las tablas.
- **Única diferencia:** la ubicación del motor (observación C).

**Alcance (punto 6).**
- El diff `e3c65ad..c60c23e` solo toca las secciones del alcance del REV-01. Además toca §11.2 B paso 7 (ajuste 10), el Grupo D (ajuste 12) y la fila de `VITE_BASE_PATH` de la nota de §3.4 (ajuste 7).
- No restauró contenido de la v1.6: las dos líneas nuevas que nombran el motor están en §13 y las pidió el ajuste 5.
- No rompió secciones fuera de su alcance: el diff no tiene hunks en §2, §3.2, §3.5–3.7, §3.9, §4–§7, §9, §10 ni §12.
- `9cf7631` solo agrega lo que traía `main` (README, `historia.md`, insumos y REV-01).

## Para el líder (ST-04)

Secciones de la entrega (`9cf7631`) que cambian respecto de la v1.5, con cómo pasarlas a la base v1.6 (`ad1a03e`, rama local `docs/ambiente-v1.7`).
- **Reemplaza:** la sección de la entrega sustituye a la de la base.
- **Integra:** se une con lo que agregó la v1.6.

Los cambios de solo formato (tablas `|---|`, listas `1.` y código en línea) no se cuentan.

| Sección | Qué cambió Juan Hernando | Cómo pasarla |
|---|---|---|
| Portada (YAML) | `version: "1.7"`, fecha «Noviembre de 2026». | Reemplaza `version`; la fecha ya es Noviembre en la base. |
| Control del documento | Versión 1.7, HU-IMP-DOC-03, corte 2026-11-23. | Reemplaza. |
| Fuentes y fecha de corte | Corte 2026-11-23 con los 10 commits, evidencias, DOC03-H-0x, insumos parte b, #5478 y SEG-BROKER-02. | **Integra:** tabla de Juan Hernando más las fuentes del motor de la v1.6 (corte complementario 2026-11-02, PR #54, #55, #60 y #61, y `docs/MOTOR_IA_MODELOS_DOKPLOY.md`). |
| 1. Introducción | Segundo párrafo: dos servidores, DEV, TEST y PROD desplegados, corte 2026-11-23. | Reemplaza ese párrafo; el resto es igual. |
| 3.1, «Estado de los entornos» | DEV, TEST y PROD responden (curl). | Reemplaza el párrafo. |
| 3.1, «Los dos servidores» | Subsección nueva (tabla de servidores y `MQTT_BROKER_URL`). | Se agrega. Ver la observación B. |
| 3.1, «Las capas por entorno» | Tabla nueva con columnas Servidor y DEV/TEST/PROD, citas rama@commit y puertos de PROD por definir. | **Integra:** tabla de Juan Hernando más la fila «Motor de inferencia M04» y la nota de las Applications de la v1.6 (INC-BRK-05). |
| 3.3 | Nota de corte 2026-10-13; fila de BRK TEST: `docker-compose.test.yml` (test@662e096; HU-IMP-AMB-11). | **Integra:** conserva el párrafo del motor y «Imagen del motor de inferencia M04 (PR #54)». Aplica la fila de BRK TEST. Ajusta la nota a «sin cambios en E4; pendiente de actualizar en la v1.8». |
| 3.3, «Diferencias… compose del backend» | Fila «Puerto de BD al host» de PROD: «riesgo en Taiga #5478» en lugar de «restringir por firewall (INC-BD-02)». | Reemplaza esa fila. |
| 3.4, introducción y nota de E4 | Nota con los cambios de E4 (catálogo `@13cd3aa`) y la tabla con `MQTT_TLS`, `BACKEND_URL`, `ALLOWED_ORIGINS`/`FRONTEND_URL` y `VITE_BASE_PATH`. | **Integra:** la nota de Juan Hernando se agrega a la introducción de la v1.6, sin quitar las menciones del motor. |
| 3.4, Grupos A, C, D y E | **A:** `ALLOWED_ORIGINS` y `FRONTEND_URL`.<br>**C:** `MQTT_BROKER_URL`.<br>**D:** `VITE_API_BASE_URL`.<br>**E:** `MQTT_HOST_PORT`, `MQTT_WS_HOST_PORT`, y filas nuevas `BACKEND_URL` y `BROKER_SERVICE_TOKEN`. | **Reemplazan:** las filas que tocó Juan Hernando (A, D y E reemplazan la tabla entera).<br>**Grupo C:** conserva las filas `IOT_INFERENCIA_*` y su nota de la v1.6.<br>**Se conservan sin cambios:** el Grupo B, el **Grupo F** completo, la regla 3 de «Reglas de estandarización» con el ejemplo de las `IOT_INFERENCIA_*`, y la nota «sin cambios en E4; pendiente de actualizar en la v1.8» en el Grupo F. |
| 3.8 (introducción y cuatro subsecciones) | Reescrita:<ul><li>«Servicios web»: tabla con gateway que usa el backend y rutas `/broker-sigab*`, más notas</li><li>«Prefijo de ruta y orígenes» (nueva)</li><li>«Datos y mensajería»</li><li>«Criterios de red y exposición»</li></ul>«Cabeceras de seguridad» no cambió. | **Integra:** «Servicios web» de Juan Hernando más la fila del motor M04 de la v1.6 (la subsección de la v1.6 se llama «… y motor M04»; conserva ese título). Las otras tres se reemplazan. |
| 7 | Solo una nota «Corte de esta sección: 2026-10-13 (v1.5)». | Se conserva la de la base; la nota es opcional. |
| 8 (introducción) | Segundo párrafo: `BRK develop@2f8ea54`, gateway según `MQTT_BROKER_URL` (DEV/TEST host técnico, PROD Dokploy de Arekkazu). | Reemplaza el segundo párrafo; el primero (M03, M04 y M09) es igual. |
| 8.1 | Solo una nota de corte v1.5. | **No se pasa:** se conserva la tabla de la v1.6 (motor, `test@662e096`). La nota de Juan Hernando diría un corte falso. |
| 8.2 | Reescrita: dos tramos, tabla por ambiente con rutas `/broker-sigab*` por confirmar, tabla «Cómo se conecta el gateway», `expose: 8000`. | Reemplaza; en la v1.6 no tiene contenido del motor. |
| 8.3 | Quita la mención del motor y cambia «Pendientes con AIoT y Despliegue» por «Se listan en la Sección 11.4». | **Integra:** primer párrafo de la v1.6 (con el motor y §8.4); el párrafo de pendientes, el de Juan Hernando. |
| 8.4 | No existe en la entrega. | Se conserva entera de la base, con la nota «sin cambios en E4; pendiente de actualizar en la v1.8». |
| 11.2 B | Paso 6: «en el servidor del broker». Paso 7: «alternativa en discusión, #5478». | **Integra:** pasos 6 y 7 de Juan Hernando; el paso 8 del motor de la v1.6 se conserva. En 11.2 A, conserva el párrafo del compose local del motor. |
| 11.3 | Tabla de nueve elementos con el corte 2026-11-23 y DOC03-H-0x. | Reemplaza. |
| 11.4 | Reescrita como «Riesgos» y «Pendientes por equipo». Quitó «Resumen (mismo contenido que el registro)» y «Correspondencia con los identificadores provisionales». | **Integra:** las dos tablas nuevas de Juan Hernando, más «Resumen» y «Correspondencia» de la v1.6 (con INC-BE-08, INC-BRK-04 e INC-BRK-05). Nota «sin cambios en E4; pendiente de actualizar en la v1.8» en las INC. |
| 13, «Versiones» | Fila 1.6 reescrita y fila 1.7 nueva. | **Integra:** fila 1.6 de la base (más precisa: PR #54 y siguientes) y fila 1.7 de Juan Hernando. |
| 13, «Cambios de la versión 1.6 a la 1.7» | Subsección nueva. | Se agrega. |
| 13, «Pendientes para la v1.8» | Subsección nueva (3.3, 3.4, 8.1, 8.4). | **Integra:** agregar el Grupo F. |
| 13, «Actualización por la imagen del motor M04 (versión 1.6, 2026-11-02)» | No existe en la entrega. | Se conserva de la base. |

**Sin cambios de Juan Hernando** (se quedan como en la base): §2 completa (incluida §2.4 con el motor), §3.2, §3.5–3.7, §3.9, §4, §5 (rutas de ADR-002), §6, §9, §10, §11.1, §12 y «Cambios de la versión 1.4 a la 1.5».

**Mapa:** se toma el drawio y el PNG de la entrega, y se corrigen las observaciones A y C (y B si Despliegue lo confirma).
