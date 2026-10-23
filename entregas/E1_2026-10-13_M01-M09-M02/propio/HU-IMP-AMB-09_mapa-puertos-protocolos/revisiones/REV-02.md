# REV-02 — Mapa de puertos y protocolos (IMP_Diag_Despliegue_Puertos_Protocolos v1.5)

> Estado: dictamen emitido · Fecha: 2026-10-13 · Revisa: Líder de Implementación (con el agente `revisor`) · Autor del trabajo: Juan Hernando Perdomo

**Objeto revisado:** `entregables/imp_diag_despliegue_puertos_protocolos_v1.5.drawio` (2026-10-12 21:22 -0500; XML sin comprimir, 1 página, 7 capas: Base, DEV, TEST/Sandbox, PROD, Protocolos, Hallazgos, Detalle de comunicación), `imp_diag_despliegue_puertos_protocolos_v1.5.png` y `entregables/registro.md`.
**PR / commit:** no hay. Los tres archivos están sin seguimiento en git (`git status`: `?? historias/HU-IMP-AMB-09_mapa-puertos-protocolos/entregables/`); no existe la rama `docs/mapa-puertos-v1.5` ni un PR en `Juanher01/SGMP-Integracion`.
**Contrastado con** (después de `git fetch --prune`, 2026-10-13):

| Repo | Rama → commit |
|---|---|
| `sgpmp-backend` | `dev@bd8b6d4f` · `test@81487428` · `main@8a7e6327` |
| `SGPMP-FRONT-END-PWA` | `dev@9e5af40` · `test@95fa674` · `main@2132c62` |
| `BROKER-MQTT-SGPMP` | `develop@44e29b6` · `test@7cbdb3f` · `main@cebd430` |
| Documento hermano | `HU-IMP-DOC-01/entregables/ambiente_de_trabajo_implementacion_v1_5.docx` (2026-10-13 10:32) |

## Dictamen global: SOLICITAR CAMBIOS

La v1.5 avanza bien: los flujos Backend → Traefik → Gateway → Mosquitto y Edge → puerto de host (M1, M2 y M4) ya están correctos. También aparecen el recuadro de control, la leyenda de fuentes y el estilo "objetivo". Pero no se puede aprobar por cuatro motivos:

1. Hay dos afirmaciones que el código ya contradecía **antes** de la entrega: la base de PROD sí se publica (5449) y la rama `main` del broker ya tiene ACL y soporte TLS.
2. La flecha Gateway → PostgreSQL tiene un rótulo que no coincide con el código ni con la propia caja de detalle, y tres flechas están sueltas, sin anclar a ninguna caja.
3. No se cumplió CA-7: los CN no están en `registros/incidencias/registro.md`.
4. No se cumplió CA-8: falta el nombre exacto del archivo, la rama y el PR.

## Fortalezas

- **M1, M2 y M4 resueltos con precisión.** El Edge entra por el puerto de host (1884/1885 → 1883, con TLS → 8883). El backend llama por HTTPS a `POST /v1/commands` a través de Traefik. Traefik envía al gateway por `:8000` con Strip Path. El gateway habla MQTT 1883 con Mosquitto. Todo coincide con `edge_sincronizacion_mqtt_adapter.py` (`httpx.post(f"{base_url}/v1/commands")`, `Authorization: Bearer`) en `dev`, `test` y `main`, y con el `docker-compose.yml` del broker (`MQTT_PORT: 1883`, `expose: "8000"`).
- **Recuadro de control y leyenda de fuentes** con fecha de corte. Es justo lo que pedía REV-01.
- **Objetivo y desplegado separados** en la capa Base: Instancia 2, réplica, backup y servidor ML aparecen punteados y con el rótulo "OBJETIVO".
- **Caja de detalle del broker muy completa**: credenciales separadas, dynamic-security, listeners TLS y el WebSocket sin consumidor.
- **m2 resuelto**: "WS · host 9002 → 9001 (TLS → 9002)" ya no se confunde con el listener WSS interno.
- **Sin secretos** en el `.drawio`, el `.png` ni el `registro.md` (búsqueda de `password|secret|token|://…@`: solo aparece el rótulo "Bearer token").

## Criterios de aceptación

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-1 Cada flecha con fuente rastreable | **NO CUMPLE** | Hay 3 flechas sin anclar: `edge-lb-front` no tiene `source`; `Zfa-…-39` (Backend → BD) no tiene `source`; `edge-gw-db` no tiene `target`. El rótulo de Gateway → BD no tiene respaldo en el código (ver N3). Las flechas Backend 1 ↔ Servidor ML (`S-_rEWRCBSLLvi32CNCP-3`, `UYoWidx1297Aab-H_8bZ-0`) son sólidas, aunque apuntan a un nodo no desplegado. "Sistemas Externos (UPRA, ICA, crediticias)" no tiene ninguna llamada saliente en el backend (ver N5). Tampoco se entregó la tabla flecha → fuente (entregable de ST-04). |
| CA-2 Flujo del broker (4 conexiones) | **PARCIAL** | Cumplen 3 de 4: Backend → Traefik → Gateway, Gateway → Mosquitto 1883 y Edge → host. La cuarta, Gateway → PostgreSQL, dice "5432 · red interna (dokploy-network)". Pero el compose del broker (las 3 ramas) no declara `networks:`, y `.env.example` (`origin/develop`) indica conectarse "al host/puerto donde esa base es alcanzable… mismo DB_PORT publicado" (`host:5447`). Además, la flecha sale del nodo Broker y no del Gateway, y su punta no llega a la BD. |
| CA-3 Seguridad del broker por rama | **NO CUMPLE** | El diagrama dice "ACL: DEV/TEST sí · PROD no" y "PROD pendiente de promoción". Pero `git merge-base --is-ancestor` da **INCLUIDO** para `feature/seg-broker-01-acl-mosquitto-v2` y `feature/seg-broker-02-tls-mosquitto` en `develop`, `test` **y `main`**, y `git show origin/main:docker/mosquitto.conf` ya carga `mosquitto_dynamic_security.so` e `include_dir` para TLS. La promoción entró con `1b5fd84` (PR #30, 2026-10-12 17:33 -0500), cuatro horas antes de guardar el archivo (21:22). |
| CA-4 Leyenda "Fuente" con fecha de corte | **PARCIAL** | Existe `ctl-fuente` con corte 2026-10-12. Problemas: (a) atribuye "compose (expose / ports)" a **Desarrollo**, cuando los compose son de Implementación; (b) los hashes son los de REV-01 copiados, no reverificados (el broker `main` ya era `cebd430`); (c) no cita el frontend ni las ramas `test`/`main` del backend. |
| CA-5 Objetivo vs. desplegado | **PARCIAL** | En la capa Base está bien. Falta en: las flechas sólidas Backend ↔ ML; "Instancia 2" en la capa PROD (`env-prod-back2`), que no tiene estilo punteado; "Sistemas Externos", sin marcar como objetivo; y el rótulo "Load Balancer" del nodo Traefik, que sigue presentándose como desplegado (el balanceo es objetivo). |
| CA-6 Puertos de PROD = DOC-01 v1.5, con fuente | **NO CUMPLE** | Coincide con DOC-01 ("5449 reservado, no publicado, túnel SSH"), pero **ambos contradicen el código de `main`**: `docker-compose.prod.yml` publica `"${DB_PORT:-5449}:5432"` desde `c68775af` (2026-10-12 15:19 -0500), con el comentario "el equipo no tiene acceso SSH… debe restringirse por firewall". La capa PROD tampoco cita la fuente de cada puerto. |
| CA-7 CN-001…003 en `registros/incidencias/registro.md` | **NO CUMPLE** | `grep CN-00 registros/incidencias/registro.md` no devuelve nada. Se creó un `entregables/registro.md` aparte, con columnas y estados distintos de los del registro oficial (`Abierto` en lugar de `detectado/diagnosticado/…`). La etiqueta `tag-reg` del diagrama sigue diciendo "registrar… (ID pendiente)". |
| CA-8 Versionado con nombre exacto, PNG y recuadro de control | **NO CUMPLE** | El recuadro de control está presente. Pero el nombre es `imp_diag_despliegue_puertos_protocolos_v1.5.drawio`, en minúsculas, y no `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio`. Los archivos están sin seguimiento en git: no hay rama, commit ni PR. |

**DoD:** sin evidencias (la carpeta `evidencias/` solo contiene `.gitkeep`), sin PR y sin REV con APROBAR → incompleta.

## Estado de los hallazgos de REV-01

| ID | Estado | Evidencia |
|---|---|---|
| M1 Edge → puerto de host | **Corregido** | `edge-brk-1`: "MQTT · host 1884/1885 → 1883 (con TLS → 8883)". Coincide con `"${MQTT_HOST_PORT:-1884}:${MQTT_PUERTO_PUBLICO:-1883}"`. Detalle menor: en el PNG el rótulo se superpone con la caja de Mosquitto. |
| M2 Backend no habla MQTT | **Corregido** | Ya no están las flechas Broker → Backend. Ahora hay `edge-be-lb` (Backend → Traefik, "HTTPS 443 · POST /v1/commands") y `edge-gw-mosq` (Gateway → Mosquitto, "MQTT :1883 interno"). El backend no tiene bibliotecas MQTT en `src/` (solo pruebas en `test`). Matiz: la flecha es unidireccional; el CA dice ↔ (el gateway también se suscribe a la telemetría). |
| M3 Gateway → PostgreSQL | **Parcialmente corregido** | La flecha existe, pero su rótulo ("red interna (dokploy-network)") no coincide con el código. El compose del broker no tiene `networks:`, la plantilla usa `host:5447` y el compose PROD del backend dice que el gateway llegará a la red "más adelante". El rótulo contradice además la caja `det-broker` ("hoy DATABASE_URL usa host:puerto publicado"). La flecha sale del nodo Broker, no del Gateway, y no está anclada a la BD. *Nota: el rótulo lo sugirió REV-01; lo vigente es el código.* |
| M4 Traefik → Gateway | **Corregido** | `edge-lb-gw`: "HTTP :8000 interno (Strip Path)", anclada a `broker-3` (Gateway). |
| M5 Seguridad del broker por rama | **Corregido según REV-01, pero desactualizado al entregar** | Refleja `develop`/`test` correctamente, pero dice "PROD no" cuando `main` ya incluye ACL y TLS (ver CA-3). Hay que actualizar `broker-2`, `det-broker`, `tag-brk-2` y CN-002. |
| A1 Leyenda "Fuente" | **Parcialmente corregido** | Leyenda presente; atribuye los compose a Desarrollo y usa hashes no reverificados (ver CA-4). |
| A2 Objetivo vs. desplegado | **Parcialmente corregido** | Capa Base correcta; quedan flechas ML sólidas, Instancia 2 en la capa PROD y "Sistemas Externos" (ver CA-5). |
| m1 Puertos MQTT/WS de PROD | **Corregido en el diagrama; la incoherencia sigue en DOC-01** | El diagrama dice "host por asignar (Despliegue)". DOC-01 todavía dice "por asignar con AIoT" en §3.4 y en la tabla de §3.8, y "Despliegue" en §3.1 y §8.2. |
| m2 WS 9002 de TEST | **Corregido** | `env-test-ws`: "WS · host 9002 → 9001 (TLS → 9002)". |
| m3 CN registrados | **Sin corregir** | Los IDs están en el diagrama, pero no en el registro oficial (ver CA-7). |
| m4 Nombre y recuadro de control | **Parcialmente corregido** | Hay recuadro de control. El nombre no es exacto y no está versionado (ver CA-8). El recuadro dice "m1–m4", aunque m5 también se tocó. |
| m5 Firewall de 5447/5448 | **Parcialmente corregido** | "firewall 5448" aparece solo dentro de la caja de la Sandbox. No hay nota para 5447 (DEV) y ahora también falta para 5449 (PROD, publicado). |

## Hallazgos nuevos

| ID | Severidad | Dónde | Hallazgo | Evidencia | Corrección esperada |
|---|---|---|---|---|---|
| N1 | **Mayor (bloqueante)** | Base `Zfa-…-27`, PROD `env-prod-db`, `det-bd`, `proto-legend` | La BD de PROD **sí se publica** en 5449. El diagrama dice "NO publicado" y "acceso por túnel SSH". | `git show origin/main:docker-compose.prod.yml` l. 60-68: `ports: "${DB_PORT:-5449}:5432"`, "el equipo no tiene acceso SSH… restringirse por firewall a IPs conocidas". Commit `c68775af` (2026-10-12 15:19 -0500). En `origin/test` el `docker-compose.prod.yml` es anterior y aún dice "SIN ports". | "PostgreSQL · host 5449 → 5432 · restringido por firewall a IPs del equipo (Despliegue) · fuente `main@c68775af`". Quitar "túnel SSH". |
| N2 | **Mayor (bloqueante)** | `broker-2`, `det-broker`, `tag-brk-2`, CN-002 | El broker `main` ya tiene dynamic-security y los listeners TLS condicionales. | `merge-base --is-ancestor` → INCLUIDO en `main`. `origin/main:docker/mosquitto.conf` l. 13-14 y 28. Commit `1b5fd84` (PR #30). | "ACL: sí en las 3 ramas · TLS: soportado en las 3, sin activar". CN-002 pasa de "falta en PROD" a "verificar en PROD cuando se despliegue". |
| N3 | **Mayor (bloqueante)** | `edge-gw-db` | Rótulo sin respaldo en el código y contradictorio con `det-broker` (ver M3). | Compose del broker sin `networks:` en las 3 ramas. `.env.example` (`develop`) l. 6-12. Comentario del compose PROD del backend, l. 57-59 ("más adelante, el gateway"). | Anclar la flecha de `broker-3` (Gateway) a `Zfa-…-27` (BD), con el rótulo "TCP · host 5447 DEV / 5448 TEST (publicado) → 5432 · objetivo: red interna dokploy-network". En PROD, "por definir": la BD está publicada, pero el gateway no se une a `dokploy-network`. |
| N4 | **Mayor** | `edge-lb-front`, `Zfa-…-39`, `edge-gw-db` | Tres flechas tienen un extremo libre (sin `source`/`target`). En la imagen parecen correctas, pero al mover una caja quedan apuntando a la nada, y no se pueden rastrear en el XML. | Atributos `source`/`target` ausentes en el `.drawio`. | Anclar Traefik → Frontend, Backend 1 → BD y Gateway → BD a sus cajas. |
| N5 | Mayor (alcance) | `Zfa-…-31` Sistemas Externos y flechas `Zfa-…-40`, `S-_rEWRCBSLLvi32CNCP-3`, `UYoWidx1297Aab-H_8bZ-0` | (a) No hay ninguna integración saliente con UPRA, ICA o entidades crediticias. En el código, "ICA" es el índice de conversión alimenticia (`supplies/.../calcular_ica_use_case.py`) y NIC41 es un cálculo interno. (b) Las flechas hacia el Servidor ML (objetivo) son sólidas. (c) Faltan integraciones reales: Firebase/FCM (`src/shared/firebase.py`), reCAPTCHA (`google_recaptcha_adapter.py`, `httpx.post` a `www.google.com`), SMTP 587 STARTTLS (sí está) y AgroFusion SSO/Hub. | `git grep` sobre `origin/dev -- src`. | Marcar Sistemas Externos y las flechas ML como "Objetivo". Agregar flechas HTTPS 443 salientes del backend a FCM, reCAPTCHA y AgroFusion, o un nodo "Servicios externos desplegados". |
| N6 | Menor | `ctl-fuente` | Atribuye "compose (expose / ports)" a Desarrollo. Los compose son de Implementación (alcance de octubre de 2026). Los hashes de corte se copiaron de REV-01 y no se citan el frontend ni el backend `test`/`main`. | CLAUDE.md, "Alcance de Implementación". `git log -1 origin/main` del broker = `cebd430`. | "Implementación: compose (expose/ports)". Hacer el fetch el día del corte y citar las 9 ramas. |
| N7 | Menor | Capa Hallazgos | Etiquetas obsoletas: `tag-sbx` "Sandbox: reenvío en compose por verificar" (ya se reenvía), `tag-reg` "(ID pendiente)", `tag-brk-2` "ACL: falta PROD". | `origin/test:docker-compose.test.yml` l. 69-70: `ENABLE_TEST_SANDBOX`, `TEST_SANDBOX_SECRET`. | Actualizar o retirar. |
| N8 | Menor | `entregables/registro.md` | Formato propio, distinto del registro oficial. Además, CN-001 (PostgreSQL sin TLS) se asigna solo al DBA, pero también requiere `sslmode` en el `DATABASE_URL` del compose (Implementación) y certificados en la imagen (Implementación + DBA). | `registros/incidencias/registro.md` (columnas ID, Fecha, Entorno, Síntoma, Capa, Responsable, Estado, Enlace). | Agregar las 3 filas al registro oficial con su vocabulario de estados y borrar el archivo suelto. |
| N9 | Menor | Nodos Backend 1/2 | "Linux · Docker · HTTPS/TLS": TLS termina en Traefik; el contenedor sirve HTTP 8000. | `CMD uvicorn … --port 8000` (Dockerfile, 3 ramas). | Quitar "HTTPS/TLS" del nodo o escribir "HTTP 8000 (TLS en Traefik)". |
| N10 | Menor | PNG | Solo exporta Base + Protocolos (las capas DEV/TEST/PROD están apagadas), y el rótulo del Edge se superpone con Mosquitto. | Inspección del PNG. | Exportar un PNG por ambiente (o uno con PROD encendida para el DOC-01) y mover el rótulo. |

## Coherencia con DOC-01 v1.5 (`ambiente_de_trabajo_implementacion_v1_5.docx`)

| # | Tema | Diagrama v1.5 | DOC-01 v1.5 | Código (manda) | Clasificación |
|---|---|---|---|---|---|
| D1 | BD de PROD | "5449 reservado — NO publicado; túnel SSH" | §3.1, §3.3 ("Ninguno"), §3.4 `DB_PORT` ("No existe"), §3.8 ("sin publicación por diseño"; "túnel SSH y docker exec"), §11.3, §11.4 SAL-IMP-09 | `main`: publica `5449:5432`; sin SSH; firewall | Coherentes entre sí, **ambos desactualizados** |
| D2 | Seguridad del broker en `main` | "ACL PROD no · PROD pendiente de promoción" | §7 ("ausente en main"), §8.1 ("main sin dynamic-security ni TLS"), §8.3 | `main` incluye ambas ramas SEG | Coherentes entre sí, **ambos desactualizados** |
| D3 | Gateway → PostgreSQL | Flecha: "5432 · red interna (dokploy-network)"; detalle: "hoy host:puerto publicado y rol dba" | §3.8 y §11.4: DEV/TEST por host 5447/5448 con rol dba; **§8 (intro): "por la red interna"**; §3.4 Grupo E PROD: "hostname interno" | Plantilla `host:5447`; sin `networks:` en el broker | **Incoherente**: la flecha choca con DOC-01 §3.8/§11.4 y con su propia caja; DOC-01 §8 se contradice con su §3.8 |
| D4 | Puerto MQTT de PROD (quién lo asigna) | "por asignar (Despliegue)" | §3.1 y §8.2: Despliegue; **§3.4 (`MQTT_HOST_PORT`, `MQTT_HOST/PORT`) y tabla de §3.8: "con AIoT"** | Despliegue (alcance) | **Incoherente** (el lado DOC-01 está pendiente; m1 de REV-01) |
| D5 | Backend → Gateway | Backend → Traefik, HTTPS 443, `POST /v1/commands`, `/broker-sigab-*`; Traefik → GW `:8000` Strip Path; Bearer | §8 y §8.2: HTTPS `{MQTT_BROKER_URL}/v1/commands` vía Traefik, `MQTT_BROKER_TOKEN`, rutas `/broker-sigab-dev|test`, gateway 8000 | Adaptador en las 3 ramas | **Coherente** (DOC-01 no menciona Strip Path; no es contradicción) |
| D6 | Edge → Mosquitto | host 1884/1885 → 1883, TLS → 8883 | §8.2 idéntico | Compose del broker | **Coherente** |
| D7 | WS por ambiente | DEV "9001 → 9001"; TEST "9002 → 9001 (TLS → 9002)"; PROD "por asignar (Despliegue)" | §3.4: DEV "por confirmar con Despliegue"; TEST igual; PROD "Despliegue" | Valor de host no versionado (Dokploy) | Coherente; el diagrama omite "por confirmar" en DEV |
| D8 | Gateway en PROD | "expose :8000 (por definir)" | §8.2: "Por definir (Despliegue y AIoT)" | `expose: "8000"` en `main` | Coherente |
| D9 | Fuente de la Diagrama 3 de DOC-01 | — | Cita "mapa de puertos v1.5 (HU-IMP-AMB-09)" | — | DOC-01 depende de este diagrama: al corregir N1 y N2 hay que actualizar ambos a la vez |

## Recomendaciones al líder (no se envían a Juan Hernando)

- **Actualizar el texto de CA-3 en `historia.md`**: dice "PROD pendiente de promoción" y el código ya no lo respalda. Propuesta: "ACL dynamic-security y soporte TLS presentes en `develop`, `test` y `main`; TLS sin activar en ningún entorno".
- **Corregir la sugerencia de REV-01 (M3)**: el rótulo "red interna (dokploy-network)" era la arquitectura objetivo, no el estado actual.
- **Aplicar N1 y N2 también en DOC-01 (HU-IMP-DOC-01)**: §3.1, §3.3, §3.4, §3.8, §7, §8, §8.1, §8.3, §11.3 y §11.4 (SAL-IMP-09).
- **Riesgo para PROD (para triage, no para esta HU):** en `main`, la BD de PROD queda publicada y el gateway no declara red. Si el gateway de PROD usa la vía de DEV/TEST (host:puerto), dependerá del 5449 publicado; si se pretende usar la red interna, el compose del broker necesita `networks: dokploy-network` (AIoT). Conviene un issue a AIoT.
- **Error recurrente:** se reutilizaron los hashes de la revisión anterior en vez de hacer `git fetch` el día de la entrega. Sugiero que el planificador agregue a toda HU documental un CA explícito: "fecha de corte = fecha del fetch, con los hashes de las ramas citadas".

## Retroalimentación para Juan Hernando (borrador para enviar)

> Juan Hernando, revisé la v1.5 del mapa de puertos. Los flujos del broker quedaron muy bien: Edge por el puerto de host, backend → Traefik → gateway por HTTPS y gateway → Mosquitto por 1883 coinciden exactamente con el código de las tres ramas. El recuadro de control, la leyenda de fuentes y el estilo "objetivo" en la capa Base también son lo que necesitábamos. Todavía no puedo aprobarla. Esto es lo que falta, en orden de prioridad:
>
> 1. **Haz `git fetch` hoy y vuelve a contrastar.** El 12 de octubre, antes de que guardaras el archivo, entraron dos cambios que lo contradicen:
>    - **BD de PROD:** `sgpmp-backend` `main` (commit `c68775af`) ahora **publica** el 5449 (`"${DB_PORT:-5449}:5432"`), restringido por firewall, y el comentario aclara que no hay acceso SSH. Corrige la caja de la BD, la capa PROD, `det-bd` y la leyenda de protocolos: "host 5449 → 5432 · firewall a IPs del equipo (Despliegue)". Quita "túnel SSH".
>    - **Broker `main`:** ya tiene ACL dynamic-security y soporte TLS (PR #30, `1b5fd84`; compruébalo con `git merge-base --is-ancestor origin/feature/seg-broker-01-acl-mosquitto-v2 origin/main`). Cambia "ACL: PROD no" por "ACL y TLS soportado en las 3 ramas; TLS sin activar", y actualiza CN-002 y la etiqueta `tag-brk-2`.
> 2. **Flecha Gateway → PostgreSQL.** Hoy el gateway no está en `dokploy-network`: su compose no declara `networks:` y la plantilla `.env.example` usa `host:5447`. Tu propia caja de detalle lo dice bien. Haz que la flecha salga del **Gateway** (no del nodo Broker), que llegue a la caja de la BD y que diga "TCP · host 5447 DEV / 5448 TEST → 5432 (objetivo: red interna)". En PROD: "por definir".
> 3. **Flechas sueltas.** Hay tres flechas con un extremo sin anclar: Traefik → Frontend, Backend 1 → BD y Gateway → BD. Arrastra cada extremo hasta que la caja se resalte en azul.
> 4. **Objetivo vs. desplegado (lo que falta).** Pon en punteado las flechas Backend ↔ Servidor ML y la caja "Instancia 2" de la capa PROD. Marca "Sistemas Externos" como objetivo: el backend no llama a UPRA, ICA ni a entidades crediticias (el "ICA" del código es el índice de conversión alimenticia). En su lugar, agrega las salidas reales del backend por HTTPS 443: Firebase/FCM, reCAPTCHA y AgroFusion.
> 5. **Leyenda "Fuente".** Los compose son de **Implementación**, no de Desarrollo. Cita los hashes del día del corte de las 9 ramas (backend y frontend dev/test/main; broker develop/test/main).
> 6. **Registro de incidencias (CA-7).** Agrega CN-001, CN-002 y CN-003 a `registros/incidencias/registro.md`, con sus columnas y estados (`detectado`, `diagnosticado`…), y elimina el `entregables/registro.md` suelto. En CN-001, el responsable es compartido: DBA, más Implementación por el `sslmode` del compose y los certificados de la imagen.
> 7. **Publicación (CA-8).** Renombra a `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio` (y el `.png`), crea la rama `docs/mapa-puertos-v1.5`, haz commit y abre el PR hacia `main` enlazando la HU. Adjunta en `evidencias/` la tabla flecha → fuente (archivo y rama de cada flecha) y la salida de los `merge-base`.
> 8. **Menores.** Quita "HTTPS/TLS" de los nodos del backend (TLS termina en Traefik). Agrega la nota de firewall en 5447 (DEV) y 5449 (PROD), no solo en 5448. Actualiza las etiquetas `tag-sbx` (el compose de TEST ya reenvía la Sandbox) y `tag-reg`. Despega el rótulo del Edge de la caja de Mosquitto. Exporta además un PNG con la capa PROD encendida.
>
> Los puntos 1 y 2 también afectan al documento de ambiente de trabajo v1.5 (§3.8, §7, §8 y §11.4). Cámbialos en los dos a la vez para que sigan coincidiendo. El detalle con la evidencia de cada punto está en `historias/HU-IMP-AMB-09_mapa-puertos-protocolos/revisiones/REV-02.md`. Cuando tengas el PR, lo reviso con los mismos criterios.

---
Fuentes (2026-10-13, después de `git fetch --prune`): `sgpmp-backend` `c68775af`, `bd8b6d4f`, `81487428`, `8a7e6327`; `SGPMP-FRONT-END-PWA` `9e5af40`, `95fa674`, `2132c62`; `BROKER-MQTT-SGPMP` `44e29b6`, `7cbdb3f`, `cebd430`, `1b5fd84`; DOC-01 v1.5 extraído con `pandoc -t gfm`.
