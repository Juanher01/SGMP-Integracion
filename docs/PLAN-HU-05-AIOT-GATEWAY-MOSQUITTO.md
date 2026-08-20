# Plan de trabajo HU-IMP-AMB-05

# Estado inicial y trabajo realizado

**Fecha de auditoría:** 2026-08-20  
**Estado global:** EN IMPLEMENTACIÓN  
**Rama observada:** `feat/aiot-gateway-mosquitto`

## Estado comprobado

| Actividad | Estado | Evidencia |
|---|---|---|
| Repositorio de integración | [VALIDADO] | `SGMP-Integracion` contiene `compose/`, `env/`, `database/`, `scripts/`, `docs/` y `evidencias/`. |
| Repositorio del gateway | [VALIDADO] | El repositorio local correcto es `BROKER-MQTT-SGPMP`; contiene `Dockerfile`, `app/`, `docker/`, `README.md` y `AGENTS.md`. |
| Corrección de contexto AIoT DEV | [COMPLETADO] | `compose/compose.dev.yml` usa `../../BROKER-MQTT-SGPMP` en lugar de `../../BROKER-MQTT-SGPMP-develop`. |
| Corrección de configuración Mosquitto TEST | [COMPLETADO] | `compose/compose.test.yml` usa `../../BROKER-MQTT-SGPMP/docker/mosquitto.conf`. |
| Procesamiento de Compose DEV | [VALIDADO] | `docker compose ... config` fue ejecutado correctamente según el estado recibido. |
| Servicios definidos | [VALIDADO] | `database`, `mosquitto`, `gateway`, `backend` y `frontend` están definidos en el compose base y sus overrides. |
| Puertos DEV | [VALIDADO] | Mosquitto `1883/9001`, gateway `8002:8000`, backend `8000:8000`, frontend `5173:5173`. |
| Puertos TEST | [VALIDADO] | Mosquitto `1884/9002`, gateway `8003:8000`, backend `8001:8000`, frontend `8081:80`. |
| Variables AIoT | [PENDIENTE] | `GATEWAY_API_TOKEN`, `DB_IOT_USER` y `DB_IOT_PASSWORD` están vacías en `env/.env.dev`; no se deben inventar. |
| Conexión Compose del gateway | [PENDIENTE] | La interpolación actual produce `postgresql+asyncpg://:@database:5432/dba` mientras faltan las credenciales. |
| Healthcheck del gateway | [VALIDADO] | El código expone `/v1/healthz` y el compose comprueba `127.0.0.1:8000/v1/healthz`. |
| Contrato de payload | [PENDIENTE] | `app/schemas.py` y el README lo marcan como propuesto/TODO y requieren confirmación de AIoT. |
| Configuración Mosquitto DEV | [PENDIENTE] | `docker/mosquitto.conf` usa `allow_anonymous true`; requiere decisión de seguridad para DEV/TEST y definición TLS para PROD. |
| DBIntegrador como Git | [VALIDADO] | `DBIntegrador-master` no es un repositorio Git local. |
| Nombre del contenedor DBA | [REQUIERE DECISIÓN] | La documentación alterna entre `SGP` y `SGPMP`; el compose original declara `SGP`. |
| Restauración | [PENDIENTE] | Existe `database/bd-8-08-26.dump` y `scripts/restaurar-bd.sh`; falta validar una restauración reproducible con la fuente de roles autorizada. |
| Archivo `roles.sql` | [BLOQUEADO] | El archivo/directorio no pudo leerse por permisos; también existe `backup_roles.sql`, pero no se puede elegir una fuente arbitrariamente. |

## Trabajo local no revertido

Los cambios locales detectados antes de esta actualización se conservan:

- `compose/compose.dev.yml`: reemplazo de `BROKER-MQTT-SGPMP-develop` por `BROKER-MQTT-SGPMP` en el volumen de Mosquitto y el contexto de build del gateway.
- `compose/compose.test.yml`: reemplazo de `BROKER-MQTT-SGPMP-develop` por `BROKER-MQTT-SGPMP` en el volumen de Mosquitto.
- `database/`: contiene `bd-8-08-26.dump` y permanece sin clasificar como entregable hasta validar su procedencia y uso.

## Arquitectura comprobada del Gateway

```text
Dispositivo IoT --MQTT--> Mosquitto --MQTT--> SGPMP Gateway --PostgreSQL--> modulo3/modulo9
Backend --HTTPS POST /v1/commands--> SGPMP Gateway --MQTT--> Dispositivo IoT
```

El Gateway usa Python 3.11+, FastAPI, Uvicorn, `aiomqtt`, SQLAlchemy async y `asyncpg`. Sus rutas identificadas son `GET /v1/healthz`, `POST /v1/commands` y `GET /v1/devices`. Su configuración requiere `DATABASE_URL` y `API_TOKEN`, y utiliza los esquemas `modulo3` y `modulo9`.

## Hallazgos y bloqueos actuales

### BLOQUEO — credenciales de base y API

- **Estado:** [BLOQUEADO]
- **Problema:** `DB_APP_USER`, `DB_APP_PASSWORD`, `DB_IOT_USER`, `DB_IOT_PASSWORD` y `GATEWAY_API_TOKEN` están vacías en DEV.
- **Evidencia:** `env/.env.dev`; el Compose resuelve URLs con usuario y contraseña vacíos.
- **Archivos afectados:** `env/.env.dev`, `compose/compose.dev.yml`, `compose/compose.test.yml`, `compose/compose.prod.yml`.
- **Opciones:** recibir credenciales de los responsables de BD/AIoT; o definir formalmente un mecanismo de secreto para el ambiente local.
- **Recomendación:** no levantar el flujo funcional ni cambiar usuarios hasta recibir la matriz autorizada de roles.
- **Información requerida:** usuario/rol de aplicación, usuario/rol AIoT, contraseñas por ambiente y token de API de DEV/TEST.

### REQUIERE DECISIÓN — fuente de roles y contenedor DBA

- **Estado:** [REQUIERE DECISIÓN]
- **Problema:** `DBIntegrador-master` contiene `backup_roles.sql` y `roles.sql/`, la documentación usa `SGP` y `SGPMP`, y el archivo `roles.sql` no fue accesible.
- **Evidencia:** `DBIntegrador-master/docker-compose.yml`, `README.md`, `backup_roles.sql` y permisos observados sobre `roles.sql`.
- **Recomendación:** que DBA confirme la fuente única de roles, el nombre real del contenedor, la versión PostgreSQL y el procedimiento oficial de restauración.

### REQUIERE DECISIÓN — seguridad MQTT

- **Estado:** [REQUIERE DECISIÓN]
- **Problema:** `BROKER-MQTT-SGPMP/docker/mosquitto.conf` declara `allow_anonymous true` y no define TLS.
- **Evidencia:** configuración local del broker.
- **Recomendación:** aceptar explícitamente la configuración solo para DEV o entregar configuración autenticada para TEST/PROD; no endurecerla con credenciales inventadas.

## Capa AIoT: gateway y Mosquitto

**Responsable:** Juan Hernando Perdomo Mosquera  
**Rama sugerida:** `feat/aiot-gateway-mosquitto`  
**Repositorio:** `SGMP-Integracion`  
**Ambientes:** DEV, TEST y PROD  
**Dependencias:** HU-01 (compose), HU-02 (variables), HU-04 (base de datos), respuestas de AIoT y Despliegue.

## 1. Objetivo

Integrar el gateway AIoT y el broker Mosquitto en la definición de los tres ambientes sin duplicar la base de datos del DBA. El gateway debe ser el único componente de Implementación que se conecte por MQTT, exponer `POST /v1/commands` y conectarse a la base PostgreSQL compartida para los flujos de `modulo3` y `modulo9`.

El resultado debe permitir:

- recibir mensajes desde dispositivos mediante Mosquitto;
- enviar comandos al gateway por HTTPS;
- persistir o consultar la información AIoT en la base compartida;
- ejecutar la misma arquitectura en DEV y TEST;
- entregar en PROD una definición clara para Despliegue, aunque el equipo de Implementación no opere ese ambiente.

## 2. Estado actual y alcance

Al iniciar la tarea, verificar estos puntos:

- Los archivos `docker-compose.yml`, `docker-compose.dev.yml`, `docker-compose.test.yml` y `docker-compose.prod.yml` están en la raíz del repositorio.
- El compose actual define `database`, `mosquitto`, `gateway`, `backend` y `frontend` sobre `sgpmp-network`.
- La definición actual construye `database` desde `DBIntegrador-master` en DEV y consume `DATABASE_IMAGE` en TEST/PROD; no se debe duplicar la BD fuera de esa definición.
- La URL de base de datos se ensambla con `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_APP_USER` y `DB_APP_PASSWORD`.
- Los archivos de entorno ya contienen `IOT_PASSWORD`, pero todavía falta registrar el contrato MQTT completo.
- La documentación de variables identifica MQTT como una categoría futura.

La tarea incluye modificar compose, ejemplos de entorno y documentación. No incluye desarrollar la lógica interna del gateway ni modificar los esquemas de la base de datos, salvo que AIoT entregue una instrucción de integración explícita.

## 3. Paso 1: abrir la rama y registrar el punto de partida

1. Confirmar que el árbol de trabajo no contiene cambios ajenos a la HU.
2. Mantener la rama existente `feat/aiot-gateway-mosquitto`; no cambiar de rama ni crear otra durante esta ejecución.

   ```powershell
   git status --short --branch
   git diff -- compose/compose.dev.yml compose/compose.test.yml
   ```

3. Revisar los cuatro compose, `.env.dev`, `.env.test`, `.env.prod`, sus ejemplos y `docs/VARIABLES-ENTORNO.md`.
4. Registrar en la evidencia el estado inicial: ausencia/presencia de servicios, puertos usados y red Docker esperada.

## 4. Paso 2: solicitar y cerrar el contrato con AIoT

Antes de escribir valores concretos en compose, pedir a AIoT una respuesta versionada o aprobada con la siguiente información:

| Dato requerido | Decisión que debe quedar escrita |
|---|---|
| Imagen del gateway | Registro, nombre exacto, tag o digest y arquitectura soportada |
| Puerto interno | Puerto donde escucha HTTP dentro del contenedor |
| Endpoint de salud | Ruta, método y respuesta esperada |
| Endpoint de comandos | Contrato de `POST /v1/commands`, payload y respuesta |
| Base de datos | `DATABASE_URL` requerida, nombre de base, rol y esquemas usados |
| MQTT | Host, puerto, protocolo, topics de publicación y suscripción |
| Autenticación | Nombre de la variable y forma de enviar `API_TOKEN` |
| TLS | Si aplica, certificados, CA, rutas montadas y validación del certificado |
| Persistencia | Si Mosquitto necesita volumen y qué archivos deben conservarse |
| Compatibilidad | Versión de Mosquitto y requisitos de CPU/memoria |
| Validación | Mensaje o flujo reproducible para M03, M04 y M09 |

No completar estos datos con suposiciones. Si AIoT no entrega una imagen utilizable, documentar el bloqueo y acordar si se recibe una imagen publicada, un Dockerfile o una URL de registro privada.

**Entregable:** `docs/CONTRATO-AIOT.md` o respuesta equivalente enlazada desde la HU, con fecha, responsable y versión del contrato.

## 5. Paso 3: resolver puertos y topología

Definir la topología antes de editar:

```text
Cliente/Pruebas -> backend:8000/8001/8002
Cliente/Pruebas -> gateway:<puerto_host>
Gateway -> mosquitto:1883 o 8883 (red Docker)
Gateway -> PostgreSQL del DBA:5432 (red docker_default)
```

Reglas:

- El gateway no puede publicar el puerto `8000`, porque ese puerto pertenece al backend en DEV.
- Mosquitto debe ser accesible por el gateway mediante el nombre de servicio `mosquitto`, no mediante `localhost`.
- El puerto HTTP del gateway debe usar un puerto de host diferente en cada ambiente si se levantan simultáneamente, por ejemplo `8100`, `8101` y `8102`, sujeto a confirmación con AIoT.
- El puerto MQTT interno puede ser `1883` sin TLS o `8883` con TLS. En PROD debe prevalecer la decisión de seguridad de Despliegue/AIoT.
- El gateway y Mosquitto deben pertenecer a la red externa donde pueda alcanzarse la BD del DBA, o se debe documentar una segunda red y su conexión explícita.

**Comprobación barata:** ejecutar `docker compose ... config` y confirmar que no hay puertos repetidos ni variables sin resolver.

## 6. Paso 4: ampliar el catálogo de variables

Agregar las mismas claves a `.env.example`, `env/.env.dev.example`, `env/.env.test.example` y `env/.env.prod.example` si se conserva la estructura de ejemplos por ambiente. Mantener los nombres iguales y variar solo sus valores.

Variables mínimas a acordar:

```dotenv
AIOT_GATEWAY_IMAGE=<registro>/<imagen>:<tag>
AIOT_GATEWAY_HOST_PORT=<puerto-host>
AIOT_GATEWAY_PORT=<puerto-interno>
AIOT_GATEWAY_HEALTH_PATH=/health
AIOT_MQTT_HOST=mosquitto
AIOT_MQTT_PORT=1883
AIOT_MQTT_TLS=false
AIOT_MQTT_USERNAME=<usuario>
AIOT_MQTT_PASSWORD=<secreto>
AIOT_MQTT_API_TOKEN=<secreto>
AIOT_MQTT_TOPIC_COMMANDS=<topic>
AIOT_MQTT_TOPIC_EVENTS=<topic>
AIOT_MQTT_CA_FILE=<ruta-si-aplica>
```

Si el gateway exige nombres diferentes, conservar los nombres oficiales del artefacto y documentar el mapeo. No exponer secretos en el repositorio ni en variables `VITE_*`. En PROD dejar valores vacíos o marcadores y explicar que se inyectan desde Dokploy/secret manager.

Actualizar `docs/VARIABLES-ENTORNO.md` con columnas para tipo, sensibilidad, servicio, DEV/TEST/PROD y fuente del valor.

## 7. Paso 5: definir Mosquitto

1. Crear o incorporar la configuración que AIoT entregue, por ejemplo `docker/mosquitto/mosquitto.conf`.
2. Definir listeners y autenticación según ambiente:
   - DEV: sin TLS solo si el equipo lo aprueba para desarrollo local;
   - TEST: configuración reproducible y credenciales de prueba;
   - PROD: TLS, autenticación y secreto inyectado externamente.
3. Montar configuración, archivo de contraseñas y certificados solo cuando sus rutas y permisos estén confirmados.
4. Crear un volumen para datos/logs si el contrato exige persistencia. TEST debe poder reiniciarse limpiamente.
5. Agregar `healthcheck` que pruebe que el broker está escuchando, sin depender de un cliente inexistente dentro de la imagen. Si la imagen no trae una herramienta adecuada, usar una comprobación TCP o una imagen auxiliar documentada.

Nunca commitear contraseñas, certificados privados ni tokens reales.

## 8. Paso 6: integrar los servicios en compose

En el compose base:

1. Agregar la definición común de `mosquitto` y `gateway`.
2. Declarar `depends_on` para que el gateway espere a que Mosquitto pase su healthcheck.
3. Configurar la red necesaria para el gateway, Mosquitto y la conexión a la red externa del DBA.
4. Agregar healthchecks para ambos servicios.
5. Mantener el gateway como servicio separado del backend.

En `docker-compose.dev.yml`:

- usar la imagen o build local acordado;
- publicar el puerto de gateway de DEV;
- usar token/credenciales de prueba;
- activar logs útiles y, si procede, configuración sin TLS;
- conservar la conexión a `SGPMP:5432` para la BD compartida.

En `docker-compose.test.yml`:

- usar la imagen versionada que Pruebas pueda reproducir;
- publicar el puerto de gateway de TEST;
- usar topics y credenciales aislados de DEV;
- garantizar que Mosquitto y el gateway arranquen junto al backend para Cypress, Newman, k6 y las pruebas IoT.

En `docker-compose.prod.yml`:

- referenciar la imagen inmutable o tag aprobado de GHCR/registro definido;
- no incluir secretos reales;
- dejar explícita la configuración TLS y los volúmenes;
- documentar si Despliegue orquesta estos servicios en Dokploy o consume esta definición directamente.

## 9. Paso 7: validar la configuración sin levantar todo

Ejecutar desde `SGMP-Integracion`:

```powershell
docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev config

docker compose -f docker-compose.yml -f docker-compose.test.yml --env-file .env.test config

docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.prod config
```

Comprobar en la salida:

- aparecen `backend`, `frontend`, `gateway` y `mosquitto`;
- el gateway apunta a `mosquitto`, no a `localhost`;
- la URL de PostgreSQL usa el host, puerto, base y rol definidos por HU-04;
- los puertos publicados no colisionan;
- PROD no contiene valores secretos reales;
- los healthchecks y volúmenes quedan resueltos.

Si falla `config`, corregir primero variables, interpolación YAML, redes o rutas de volumen antes de levantar contenedores.

## 10. Paso 8: levantar y probar DEV

1. Confirmar que el contenedor del DBA está encendido y conectado a la red esperada.
2. Levantar el ambiente:

   ```powershell
   docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev up -d --build
   ```

3. Revisar estado y logs:

   ```powershell
   docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev ps
   docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file .env.dev logs gateway mosquitto
   ```

4. Verificar el healthcheck del gateway con la ruta acordada:

   ```powershell
   curl http://localhost:<puerto-gateway-dev><AIOT_GATEWAY_HEALTH_PATH>
   ```

5. Publicar un mensaje de prueba en el topic acordado y comprobar que el gateway lo recibe.
6. Ejecutar `POST /v1/commands` con un payload de prueba y el token de DEV.
7. Comprobar en logs y en PostgreSQL que el flujo llega a los esquemas de `modulo3` y/o `modulo9` sin afectar otros esquemas.
8. Guardar respuestas HTTP, logs relevantes, `docker compose ps` y consultas de verificación en `evidencias/`.

## 11. Paso 9: validar los flujos M03, M04 y M09

Construir con AIoT una matriz como esta y completarla con datos reales del contrato:

| Módulo | Entrada | Punto de observación | Resultado esperado | Evidencia |
|---|---|---|---|---|
| M03 | Mensaje MQTT del topic acordado | Log del gateway y esquema `modulo3` | Mensaje aceptado y persistido | Captura/log/consulta |
| M04 | Evento o comando del flujo M04 | Gateway, backend y salida del modelo si aplica | Flujo procesado según DOC-03B | Captura/log/consulta |
| M09 | Mensaje MQTT del topic acordado | Log del gateway y esquema `modulo9` | Registro o evento persistido | Captura/log/consulta |

Para cada flujo registrar timestamp, payload anonimizado, topic, código de respuesta, correlation ID si existe y consulta de base de datos usada para verificarlo.

Elaborar o actualizar `DOC-03B` con AIoT: flujo, precondiciones, pasos, punto exacto de validación y criterio de aprobación.

## 12. Paso 10: reproducir TEST y preparar PROD

### TEST

- Cambiar únicamente el archivo de entorno y la imagen/tag aprobada.
- Confirmar que los topics y credenciales no son los de DEV.
- Ejecutar la misma matriz M03/M04/M09.
- Probar reinicio de Mosquitto y gateway y comprobar el comportamiento esperado.
- Entregar a Pruebas URLs, puertos, healthchecks, credenciales de prueba, topics, payloads y procedimiento de limpieza.

### PROD

- Validar con Despliegue la equivalencia TEST/STAGING.
- Confirmar quién administra la BD y quién administra gateway/Mosquitto.
- Entregar imagen, tag/digest, variables requeridas, certificados, volúmenes, healthchecks, puertos y procedimiento de rollback.
- Verificar que la definición no dependa de archivos locales ni secretos commiteados.
- Marcar como “definido/documentado” cualquier paso que dependa de acceso de Despliegue.

## 13. Paso 11: cerrar documentación y Pull Request

Actualizar, como mínimo:

- `docs/VARIABLES-ENTORNO.md`: variables MQTT/AIoT y sensibilidad;
- `docs/CONTRATO-AIOT.md`: contrato recibido y decisiones;
- `docs/BASE-DATOS.md`: conexión del gateway a `modulo3`/`modulo9`, sin duplicar la BD;
- `docs/AMBIENTES.md` o `docs/Ambiente-Trabajo-Implementacion.md`: presencia de gateway y Mosquitto en DEV, TEST y PROD;
- `docs/FLUJO-TRABAJO.md`: puntos DOC-03B y compuertas de validación;
- `evidencias/`: resultados de `config`, healthchecks, MQTT, endpoint y persistencia.

Antes del PR:

1. Revisar que no existan secretos con `git diff --check` y una inspección de cambios.
2. Confirmar que los ejemplos son consistentes entre ambientes.
3. Adjuntar la matriz de pruebas y declarar bloqueos externos abiertos.
4. Abrir el PR interno hacia `main` con la rama `feat/aiot-gateway-mosquitto`.
5. Solicitar revisión al Líder y compartir los pendientes con AIoT/Despliegue.

## 14. Criterio de terminado

La HU-05 puede marcarse como completa cuando se cumpla todo lo siguiente:

- [ ] Existe contrato aprobado de imagen, puertos, endpoint, MQTT, autenticación, TLS y BD.
- [ ] Gateway y Mosquitto están definidos en el compose base y sus tres overrides.
- [ ] Los servicios no colisionan con el backend ni entre ambientes.
- [ ] El gateway usa `mosquitto` como broker interno y alcanza la BD del DBA por la red acordada.
- [ ] Las variables MQTT/AIoT están en los ejemplos y en `docs/VARIABLES-ENTORNO.md`.
- [ ] No hay secretos reales, certificados privados ni tokens en Git.
- [ ] DEV levanta y pasa healthchecks.
- [ ] DEV prueba `POST /v1/commands` y al menos un mensaje MQTT.
- [ ] M03, M04 y M09 tienen puntos de validación documentados en DOC-03B.
- [ ] TEST tiene instrucciones reproducibles para Pruebas.
- [ ] PROD tiene definición entregable y una frontera clara con Dokploy/Despliegue.
- [ ] Las evidencias están guardadas y el PR fue abierto para revisión.

## 15. Bloqueos que deben escalarse

Escalar inmediatamente si falta cualquiera de estos datos:

- imagen o tag verificable del gateway;
- puerto y endpoint de salud;
- topics MQTT y formato de payload;
- nombre exacto de variables de autenticación;
- certificados o política TLS para PROD;
- permisos del rol del gateway sobre `modulo3` y `modulo9`;
- acceso a la red Docker o endpoint de la BD del DBA;
- decisión de Despliegue sobre la orquestación en PROD.

Mientras exista un bloqueo, entregar la definición documentada, el compose con placeholders no secretos y la lista de validaciones pendientes. No declarar operativo un ambiente con valores inventados.

# Plan de ejecución HU-05

## Fases y estado de ejecución

| Fase | Actividad | Estado | Resultado actual |
|---|---|---|---|
| 1 | Auditoría de repositorios y cambios locales | [VALIDADO] | Se inspeccionaron `SGMP-Integracion`, `BROKER-MQTT-SGPMP`, `DBIntegrador-master` y referencias del backend. |
| 2 | Auditoría del Gateway | [VALIDADO] | Se verificaron configuración, entrypoint, rutas, variables, topics, schemas, repositorios y healthcheck. |
| 3 | Auditoría de Mosquitto | [VALIDADO] | `mosquitto.conf` tiene listeners `1883` y websockets `9001`, con `allow_anonymous true`; seguridad pendiente. |
| 4 | Auditoría de PostgreSQL | [PENDIENTE] | Falta confirmar roles autorizados, permisos sobre `modulo3`/`modulo9`, versión final y procedimiento DBA. |
| 5 | Adaptación de restauración | [BLOQUEADO] | El script local referencia la estructura antigua `docuemntacionDB/DOCKER`, el contenedor `SGPMP` y una contraseña de prueba; no se modifica sin decisión DBA. |
| 6 | Configuración de variables | [BLOQUEADO] | Las credenciales de aplicación, AIoT y API están vacías en DEV; PROD permanece sin secretos. |
| 7 | Compose DEV | [VALIDADO] | `docker compose ... config` procesó DEV; los contextos apuntan a los repositorios locales correctos. |
| 8 | Healthchecks | [PENDIENTE] | Gateway y database tienen healthcheck en Compose; falta validar Mosquitto y la existencia de healthcheck compatible del backend ejecutando el stack. |
| 9 | Gateway/Mosquitto | [PENDIENTE] | La topología y variables están cableadas; falta conexión funcional por credenciales y prueba MQTT. |
| 10 | Gateway/PostgreSQL | [BLOQUEADO] | La URL se genera sin credenciales y no se puede probar el acceso ni los stored procedures. |
| 11 | Backend/Gateway | [PENDIENTE] | El backend contiene flujos de telemetría, pero no se ha demostrado aún un consumidor de `POST /v1/commands` ni una variable `GATEWAY_URL`. |
| 12 | TEST | [BLOQUEADO] | El ejemplo no define `DATABASE_IMAGE`, por lo que Compose rechaza el servicio `database`; no se inventa una imagen. |
| 13 | PROD | [PENDIENTE] | La definición usa imágenes y secretos externos, pero aún no tiene valores/artefactos aprobados para validación efectiva. |
| 14 | Documentación | [EN IMPLEMENTACIÓN] | Este plan fue actualizado; faltan contrato AIoT aprobado, evidencias de ejecución y actualización final del README. |
| 15 | Validación final | [PENDIENTE] | Solo puede ejecutarse después de resolver los bloqueos anteriores. |

## Decisiones requeridas

1. DBA debe confirmar la fuente única entre `backup_roles.sql` y `roles.sql`, además de entregar acceso legible si `roles.sql` es la fuente oficial.
2. DBA debe confirmar si la base integrada se identifica como `SGP` o `SGPMP`, qué imagen/tag de PostgreSQL se debe usar y qué usuarios tienen permisos sobre `modulo3` y `modulo9`.
3. AIoT debe confirmar `GATEWAY_API_TOKEN`, credenciales MQTT, política de autenticación y si los payloads del README son definitivos o solo propuestas.
4. AIoT/Despliegue deben definir autenticación y TLS de Mosquitto para TEST/PROD.
5. Implementación/Despliegue debe proporcionar `DATABASE_IMAGE`, `GATEWAY_IMAGE`, `BACKEND_IMAGE` y `FRONTEND_IMAGE` versionadas para TEST/PROD.

## Comandos utilizados y resultados

| Comando | Resultado |
|---|---|
| `git status --short --branch` | Rama `feat/aiot-gateway-mosquitto`; cambios en los dos compose, `database/` no versionado y este plan no versionado. |
| `git diff -- compose/compose.dev.yml compose/compose.test.yml` | Confirmó la corrección `BROKER-MQTT-SGPMP-develop` -> `BROKER-MQTT-SGPMP`. |
| `docker compose -f compose/docker-compose.yml -f compose/compose.dev.yml --env-file env/.env.dev config` | [VALIDADO] Procesa DEV. |
| `docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file env/.env.test.example config` | [BLOQUEADO] `database` no tiene `image` ni `build`, porque `DATABASE_IMAGE` está vacío. |
| `docker compose -f compose/docker-compose.yml -f compose/compose.prod.yml --env-file env/.env.prod.example config` | [BLOQUEADO] Mismo bloqueo por `DATABASE_IMAGE` vacío; no se inventa el artefacto. |
| `git diff --check` | Debe repetirse al cierre; no se declara validación final mientras existan pendientes. |

## Estado final de esta ejecución

**PARCIALMENTE AVANZADA — BLOQUEADA PARA VALIDACIÓN FUNCIONAL COMPLETA.**

La integración está cableada estáticamente en DEV: el Gateway usa el repositorio local correcto, escucha internamente en `8000`, se publica en `8002`, depende de `database` y `mosquitto`, y el broker se publica en `1883`/`9001`. Mosquitto puede probarse localmente sin autenticación porque su configuración declara `allow_anonymous true`, pero esa condición queda limitada a DEV. No se marca HU-05 como completada porque faltan credenciales autorizadas, restauración comprobada, contrato definitivo de payloads, validación MQTT funcional, validación de PostgreSQL, integración Backend -> Gateway y artefactos versionados para TEST/PROD.

## Checklist de validación pendiente

- [ ] Recibir y documentar la matriz de roles/secretos por ambiente.
- [ ] Resolver la fuente oficial de roles y el nombre del contenedor DBA.
- [ ] Adaptar `scripts/restaurar-bd.sh` solo después de la decisión DBA.
- [ ] Confirmar que `modulo3.fn_ingesta_telemetria` y las tablas/funciones requeridas existen.
- [ ] Validar `database`, Mosquitto y Gateway mediante healthchecks en DEV.
- [ ] Publicar y suscribir un mensaje MQTT con un dispositivo/serial autorizado.
- [ ] Probar `GET /v1/healthz` y `POST /v1/commands` con token autorizado.
- [ ] Verificar persistencia en `modulo3` y lectura/registro en `modulo9`.
- [ ] Confirmar si el backend consume el Gateway y documentar su URL/token si aplica.
- [ ] Obtener imágenes versionadas y validar TEST/PROD con `docker compose config`.
- [ ] Actualizar README, contrato AIoT, evidencias y abrir PR sin secretos.

## Auditoría de credenciales y mecanismos de autenticación

**Fecha:** 2026-08-20  
**Rama:** `feat/aiot-gateway-mosquitto`  
**Resultado:** [VALIDADO] Auditoría ejecutada y documentada en [AUDITORIA-CREDENCIALES-HU-05.md](AUDITORIA-CREDENCIALES-HU-05.md).

### Credenciales encontradas

- [ENCONTRADA_PERO_REQUIERE_CONFIRMACION] DBIntegrador declara un usuario administrador y una contraseña en su Compose. No se copian ni se reutilizan automáticamente.
- [HASH] `backup_roles.sql` contiene roles DBA, grupos y usuarios LOGIN con hashes SCRAM. Los hashes no son contraseñas reutilizables.
- [LOCAL_DEV_PUEDE_USARSE] `.sgpmp-local/dbintegrador/.env` contiene `DBA_PASSWORD`, está ignorado por Git y no se expuso. Solo puede usarse dentro del procedimiento local autorizado de HU-04.
- [PLACEHOLDER] El `.env.example` del Gateway contiene una URL y un token de ejemplo; no son credenciales del stack integrado.
- [PLACEHOLDER VACÍO] `env/.env.dev` mantiene vacíos `DB_APP_*`, `DB_IOT_*` y `GATEWAY_API_TOKEN`.

### Credenciales no reutilizables

- [NO REUTILIZAR] Contraseña escrita en `DBIntegrador-master/docker-compose.yml` hasta confirmación/rotación del DBA.
- [NO REUTILIZAR] Hashes de `backup_roles.sql`.
- [NO REUTILIZAR] Valores de `docs/RUNBOOK-local.md`, reportes históricos y ejemplos del Gateway como si fueran contrato vigente.
- [NO REUTILIZAR] Cualquier valor de PROD o TEST que no haya sido entregado por sus responsables.

### Mecanismos de autenticación existentes

- [VALIDADO] El Gateway exige `API_TOKEN` mediante `Authorization: Bearer ...`; no existe bypass condicionado por `ENVIRONMENT=dev`.
- [VALIDADO] Mosquitto DEV permite conexión anónima en `1883`; no hay `password_file`, ACL ni TLS en la configuración auditada.
- [VALIDADO] PostgreSQL usa roles declarados por DBIntegrador, pero faltan permisos efectivos y autorización de los roles para el Gateway.
- [PENDIENTE] TEST/PROD requieren configuración MQTT autenticada/TLS y secretos administrados externamente.

### Bloqueos reales

- [BLOQUEADO] Autorización de `DB_APP_USER`, `DB_APP_PASSWORD`, `DB_IOT_USER` y `DB_IOT_PASSWORD`.
- [BLOQUEADO] `GATEWAY_API_TOKEN` autorizado para DEV.
- [REQUIERE DECISIÓN] Fuente oficial entre `roles.sql` y `backup_roles.sql`, además del nombre `SGP`/`SGPMP`.
- [BLOQUEADO] Validación del dump: `pg_restore` y `psql` no están disponibles en el host y la versión/roles deben confirmarse.
- [REQUIERE DECISIÓN] Payloads definitivos de AIoT y política de seguridad MQTT para TEST/PROD.

### Bloqueos evitables localmente

- [COMPLETADO] Corregido `BROKER-MQTT-SGPMP-develop` por `BROKER-MQTT-SGPMP` en los Compose existentes.
- [AVANZABLE LOCALMENTE] Construir Gateway/Mosquitto y validar Compose DEV.
- [AVANZABLE LOCALMENTE] Probar conectividad MQTT anónima en DEV usando únicamente topics ya definidos, sin afirmar persistencia.
- [PENDIENTE] Ejecutar el flujo local HU-04 con la copia `.sgpmp-local` solo después de confirmar su autorización.

### Cambios realizados y validaciones

- [COMPLETADO] Creado `docs/AUDITORIA-CREDENCIALES-HU-05.md`.
- [VALIDADO] Revisados Compose, entornos, Dockerfiles, scripts, README, Gateway, backend, roles y configuración Mosquitto.
- [VALIDADO] Confirmado que el backend usa `MqttStubAdapter` y no tiene llamadas HTTP al Gateway.
- [BLOQUEADO] El test del Gateway, ejecutado con `DATABASE_URL` y `API_TOKEN` temporales solo de proceso, no llegó a colección porque el Python del host no tiene `asyncpg`; la dependencia sí aparece en `requirements.lock`.
- [BLOQUEADO] TEST/PROD no procesan Compose mientras `DATABASE_IMAGE` y demás imágenes permanezcan vacías.

### Estado de HU-05

**[PARCIALMENTE AVANZADA]**. La capa Mosquitto/Gateway está integrada estáticamente y es adelantable en DEV. La validación funcional completa sigue requiriendo autorizaciones externas, restauración y contrato AIoT. El informe completo se encuentra en [AUDITORIA-CREDENCIALES-HU-05.md](AUDITORIA-CREDENCIALES-HU-05.md).


# HU-05 — Integración AIoT Gateway / Mosquitto

## Estado

EN IMPLEMENTACIÓN

## Evidencia disponible

La rama integra:

- Gateway AIoT mediante servicio `gateway`.
- Broker MQTT mediante Mosquitto.
- Variables de entorno MQTT.
- Token de autenticación del gateway.
- Configuración de conexión PostgreSQL para AIoT.
- Esquemas `modulo3` y `modulo9`.
- Healthcheck del gateway.
- Puertos DEV/TEST definidos.
- Dependencias entre gateway, database y mosquitto.

## Dependencia externa

El gateway y la configuración Mosquitto provienen del repositorio local correcto:

`BROKER-MQTT-SGPMP`

La integración DEV utiliza dicho repositorio como contexto de build. La referencia anterior a `BROKER-MQTT-SGPMP-develop` quedó corregida en los overrides y se conserva aquí únicamente como antecedente del error detectado.

## Contrato actualmente identificado

Gateway:
- Puerto interno: 8000
- Healthcheck: /v1/healthz
- API token: GATEWAY_API_TOKEN

MQTT:
- MQTT_HOST
- MQTT_PORT
- MQTT_USERNAME
- MQTT_PASSWORD
- MQTT_TLS
- MQTT_CLIENT_ID
- MQTT_RECONNECT_DELAY

Topics:
- MQTT_TOPIC_PREFIX
- MQTT_TOPIC_TELEMETRY
- MQTT_TOPIC_HEARTBEAT
- MQTT_TOPIC_COMMAND
- MQTT_TOPIC_STATUS

PostgreSQL:
- DB_IOT_USER
- DB_IOT_PASSWORD
- DB_SCHEMA_INGEST
- DB_SCHEMA_REGISTRY

## Cierre de implementación local — 2026-08-20

| Actividad | Estado | Evidencia |
|---|---|---|
| Corrección contexto Gateway | VALIDADO | `compose/compose.dev.yml`; contexto `../../BROKER-MQTT-SGPMP`. |
| Corrección Mosquitto | VALIDADO | `compose/compose.dev.yml` y `compose/compose.test.yml`; configuración desde el repositorio local correcto. |
| Compose DEV | VALIDADO | `evidencias/hu05/compose-dev-config.txt`; `docker compose ... config` terminó con código 0. |
| Mosquitto DEV | VALIDADO | `evidencias/hu05/mosquitto-status.txt`; contenedor healthy, puertos `1883` y `9001` accesibles. |
| Gateway | VALIDADO | `evidencias/hu05/compose-dev-ps.txt`; build local correcto, contenedor healthy y `GET /v1/healthz` respondió HTTP 200. Se ejecutó con `--no-deps`. |
| Gateway -> Mosquitto | BLOQUEADO | La conectividad del broker se probó por `$SYS/broker/version`, pero el flujo de negocio requiere contrato/payload y validación funcional AIoT. |
| Gateway -> PostgreSQL | BLOQUEADO — CREDENCIALES DBA/AIOT | `DB_IOT_USER`, `DB_IOT_PASSWORD` y roles autorizados no están disponibles; no se inventaron. |
| POST /v1/commands | BLOQUEADO | Requiere `GATEWAY_API_TOKEN` autorizado y dispositivo/contrato válido; no se usó el placeholder del ejemplo. |
| GET /v1/devices | BLOQUEADO | Requiere token autorizado y acceso funcional a `modulo9`. |
| M03 | BLOQUEADO | Falta conexión Gateway -> PostgreSQL y confirmación del payload/serial AIoT. |
| M09 | BLOQUEADO | Falta conexión Gateway -> PostgreSQL y confirmación del registro/contrato AIoT. |
| TEST | BLOQUEADO | Faltan `DATABASE_IMAGE`, `GATEWAY_IMAGE`, `BACKEND_IMAGE` y `FRONTEND_IMAGE`; no se inventaron imágenes. |
| PROD | BLOQUEADO | Faltan artefactos, secretos administrados, TLS y decisiones de Despliegue. |

### Bloqueos externos

- **DBA:** autorización de usuarios/contraseñas para backend y Gateway, permisos sobre `modulo3`/`modulo9`, fuente oficial de roles, versión de PostgreSQL y procedimiento de restauración.
- **AIoT:** `GATEWAY_API_TOKEN` de DEV, credenciales/política MQTT, payloads definitivos, serial de prueba y validación de M03/M04/M09.
- **Despliegue:** imágenes versionadas de TEST/PROD, certificados/TLS y frontera de operación en PROD.

### Trabajo completado

- Corregido el contexto inexistente `BROKER-MQTT-SGPMP-develop` por `BROKER-MQTT-SGPMP` en DEV y TEST.
- Validado el Compose DEV con las cinco capas: `database`, `mosquitto`, `gateway`, `backend` y `frontend`.
- Levantado Mosquitto DEV y comprobados sus listeners MQTT/WebSocket.
- Construido y levantado el Gateway localmente con `--no-deps`.
- Validado healthcheck y `GET /v1/healthz` del Gateway en `http://127.0.0.1:8002/v1/healthz`.
- Creado el informe de auditoría de credenciales y evidencias no sensibles en `evidencias/hu05/`.

### Trabajo pendiente

- Recibir credenciales autorizadas y validar Gateway -> PostgreSQL.
- Ejecutar prueba MQTT de negocio con payload y serial aprobados.
- Validar `POST /v1/commands`, `GET /v1/devices`, M03 y M09.
- Resolver imágenes de TEST/PROD y configuración TLS.
- Revisar/autorizar el PR; no se realizó commit ni push automáticamente.

### Estado de cierre

**[PARCIALMENTE AVANZADA]**. La configuración DEV y la salud de Mosquitto/Gateway están entregables y evidenciadas. La HU-05 no puede marcarse completada porque persisten bloqueos externos y no se demostró la integración funcional con PostgreSQL ni el contrato Backend -> Gateway.