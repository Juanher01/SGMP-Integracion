# REV-01 — Mapa de puertos y protocolos (Diag_DESP_Ptos_Ptcls v1.4)

> Estado: dictamen emitido · Fecha: 2026-10-12 · Revisa: Líder de Implementación (con el agente `revisor`) · Autor del trabajo: Juan Hernando Perdomo

**Objeto revisado:** `Diag_DESP_Ptos_Ptcls_v1.4.drawio`: una página ("Despliegue — Puertos y Protocolos") con 6 capas: Base, DEV, TEST/Sandbox, PROD, Protocolos, Hallazgos y Detalle de comunicación.
**Contrastado con:** `sgpmp-backend` (`origin/dev@492c19f2`), `BROKER-MQTT-SGPMP` (`origin/develop@499b456`, `origin/test@7cbdb3f`, `origin/main@b6e8e28`), `SGPMP-FRONT-END-PWA` (`origin/dev@aab2625`), dominios informados por Despliegue y el documento de ambiente de trabajo v1.4.

## Dictamen global: SOLICITAR CAMBIOS

La estructura es muy buena y conviene conservarla. Las capas se encienden por ambiente, los puertos internos están separados de los publicados al host, y los hallazgos y la nota del backend monoproceso son aportes valiosos. Sin embargo, cuatro flechas no representan el flujo real del sistema y el estado de seguridad del broker está desactualizado frente al código. Además, por la redefinición del rol, el diagrama debe indicar la **fuente** de cada puerto y protocolo.

## Fortalezas

- **Capas por ambiente** con dominios correctos y vigentes: frontend DEV `dev.inmero.co`, TEST `api.inmero.co`; backend y gateway bajo `/back-sigab-<env>` y `/broker-sigab-<env>`.
- **Capa de protocolos invariante:** puertos internos (80, 8000, 1883, 5432) separados de los de host. Es la decisión correcta.
- **Frontend y backend "expose-only"**, sin puerto de host, coherente con los compose.
- **CN-001 confirmado con el código:** no hay `sslmode` en ninguna configuración del backend (`git grep sslmode` vacío).
- **Nota de arquitectura correcta:** el backend corre como un único proceso a propósito (limitador de tasa y semáforo en memoria), y escalar a dos instancias exige migrar ese estado.
- **Listener WebSocket sin consumidor** bien identificado.
- **Sandbox** acotada a TEST, con la advertencia de que el rollback no cubre SMTP, FCM ni MQTT.

## Hallazgos

| ID | Severidad | Dónde | Hallazgo | Evidencia | Corrección esperada |
|---|---|---|---|---|---|
| M1 | Mayor | Capa Protocolos: Edge → Broker | La flecha dice `MQTT (TCP) :1883`, pero los Edge son externos y llegan por el **puerto de host** (DEV 1884, TEST 1885). El 1883 solo es interno y lo usa el gateway. Con TLS activo, en TEST y PROD el puerto de host apunta al listener 8883 del contenedor. | `BROKER-MQTT-SGPMP/docker-compose.yml`: `"${MQTT_HOST_PORT:-1884}:${MQTT_PUERTO_PUBLICO:-1883}"` | Rotular "MQTT · host del ambiente (1884/1885) → contenedor 1883; TLS → 8883" |
| M2 | Mayor | Capa Protocolos: Broker → Backend ×2 | Muestra `MQTT :1883 · Gateway HTTP :8000` hacia el backend. **El backend no habla MQTT**: llama al gateway por HTTPS (`POST {MQTT_BROKER_URL}/v1/commands`) a través de Traefik. Solo el gateway habla MQTT con Mosquitto. La dirección está invertida. | `sgpmp-backend/src/configuration/infrastructure/adapters/edge_sincronizacion_mqtt_adapter.py`; el backend no tiene dependencias MQTT | Dos flechas: Backend → Traefik → Gateway (HTTPS, `/broker-sigab-<env>` → :8000) y Gateway ↔ Mosquitto (MQTT 1883 interno) |
| M3 | Mayor | Capa Protocolos | Falta la flecha **Gateway → PostgreSQL**. El gateway persiste telemetría y registro de dispositivos directamente en la base (esquemas `modulo3` y `modulo9`), por la red interna. | `BROKER-MQTT-SGPMP/app/config.py`: `db_schema_ingest = "modulo3"`, `db_schema_registry = "modulo9"` | Agregar "TCP 5432 · red interna (dokploy-network)" |
| M4 | Mayor | Capa Protocolos | Falta **Traefik → Gateway**. El gateway se publica por dominio, igual que el backend. | Dominios informados por Despliegue: `/broker-sigab-dev`, `/broker-sigab-test` | Agregar "HTTP :8000 interno (Strip Path)" |
| M5 | Mayor | Base (Mosquitto) y Detalle (CN-002/CN-003) | Dice "autenticado, sin TLS" y "ACL por tópico: NO existe". En `develop` y `test` ya están el plugin **dynamic-security** (credencial y ACL por Edge, SEG-BROKER-03) y el **soporte TLS** 8883/9002 (SEG-BROKER-02), aunque TLS no está activado en ningún entorno. En `main` no hay ninguno de los dos. | `docker/mosquitto.conf` en `origin/develop` (`plugin mosquitto_dynamic_security.so`); `merge-base` de las ramas `seg-broker-01/02` | Estado por rama: "ACL: sí en DEV/TEST, no en PROD; TLS: soportado en DEV/TEST, sin activar; PROD pendiente de promoción" |
| A1 | Mayor (alcance) | Todo el diagrama | Con la redefinición, los puertos de host los asigna Despliegue y los protocolos los definen Desarrollo y AIoT. El diagrama los presenta como definiciones propias. | Redefinición del rol (octubre de 2026) | Leyenda "Fuente": Despliegue (dominios, puertos de host), AIoT (MQTT, TLS), compose (expose/ports), con fecha de corte |
| A2 | Mayor | Capa Base | Mezcla lo **desplegado** con la **arquitectura objetivo**: segunda instancia del backend, réplica de BD, servidor ML separado, SendGrid, balanceo round-robin, backup diario. Un mapa de puertos debe mostrar lo que existe. | "Objetivo PROD — sin verificar" solo aparece en la capa Hallazgos, que está apagada | Estilo punteado y rótulo "Objetivo (no desplegado)" en esos elementos, o moverlos a una capa "Arquitectura objetivo" |
| m1 | Menor | Capa PROD | MQTT host 1886 y WS 9003 "por confirmar"; el documento de ambientes v1.4 dice "por asignar con AIoT". | Documento v1.4, §3.8 y §8.2 | Unificar el criterio en ambos documentos y citar quién lo asigna (Despliegue) |
| m2 | Menor | Capa TEST | "WebSocket · host 9002" coincide en número con el listener **WSS interno 9002**, lo que confunde. | `docker/certs/README.md` del broker | Aclarar "host 9002 → contenedor 9001 (texto plano); con TLS → contenedor 9002" |
| m3 | Menor | Capa Hallazgos | CN-001…003 no están enlazados a ningún registro ni tienen estado ni responsable. | — | Registrarlos en `registros/incidencias/registro.md` y anotar el ID en el diagrama |
| m4 | Menor | Archivo | El nombre `Diag_DESP` puede leerse como "del equipo de Despliegue". No hay control de versiones dentro del diagrama. | — | Renombrar `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio` y agregar un recuadro con versión, fecha, autor y cambios |
| m5 | Menor | Capa DEV y TEST | No muestra que el puerto de PostgreSQL publicado (5447/5448) es un hallazgo de seguridad mitigable por firewall (lo dice el documento v1.4, §3.8). | Documento v1.4, §3.8 | Anotar "restringido por firewall a IPs conocidas (Despliegue)" |

## Retroalimentación para Juan Hernando (borrador para enviar)

> Juan Hernando, revisé el mapa de puertos y protocolos v1.4. La estructura por capas está muy bien pensada: separar los puertos internos de los publicados por ambiente y dejar los hallazgos en capas aparte es justo lo que necesitamos, y el detalle del backend monoproceso es un aporte importante. Para la v1.5 te pido estos ajustes, por prioridad:
>
> 1. **Flujos del broker (M1–M4).** El backend no habla MQTT: llama al gateway por HTTPS (`/broker-sigab-<env>/v1/commands`) a través de Traefik. Solo el gateway habla MQTT con Mosquitto, y además escribe directo en PostgreSQL (`modulo3` y `modulo9`). Los Edge entran por el puerto de host del ambiente (1884/1885), no por el 1883.
> 2. **Seguridad del broker (M5).** En `develop` y `test` ya hay ACL con dynamic-security y soporte TLS (todavía sin activar). Indícalo por rama.
> 3. **Fuente y alcance (A1–A2).** Con el nuevo rol, los puertos los define Despliegue y los protocolos AIoT y Desarrollo: agrega una leyenda con la fuente de cada dato. Marca como "objetivo" lo que aún no está desplegado (segunda instancia, réplica, ML separado).
> 4. **Ajustes menores (m1–m5)**, según la tabla del dictamen.
>
> Te dejé el detalle con la evidencia de cada punto en `historias/HU-IMP-AMB-09_mapa-puertos-protocolos/revisiones/REV-01.md`. Cuando tengas la v1.5, la reviso de nuevo con los mismos criterios.

## Criterios para la próxima revisión (REV-02)

Los CA de `historia.md`. Para cada flecha y cada puerto, la v1.5 debe poder rastrearse a un archivo de una rama o a una fuente externa nombrada.
