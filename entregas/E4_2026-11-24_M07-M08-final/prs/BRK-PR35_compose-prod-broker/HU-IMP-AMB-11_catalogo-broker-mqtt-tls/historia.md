# HU-IMP-AMB-11 — El catálogo de variables y las plantillas locales reflejan el contrato real del gateway del broker (`MQTT_TLS=false`, sin `GATEWAY_API_TOKEN`, variables de BRK-10)

> **Estado:** en ejecución (2026-11-22). La HU está en `main` (PR #25, fusionado). ST-01 a ST-04 ejecutadas en la rama `docs/amb-11-ejecucion-catalogo-broker` (desde `origin/main 9a099e4`), con evidencias en `evidencias/`; ST-05 (PR a `main`, segunda revisión y cierre) en curso. El PR de la ejecución **no se fusiona antes de comparar con las variables de Dokploy (Despliegue)**. **2026-11-23:** comparación hecha con la lista de Dokploy del backend (Despliegue): el broker está en otro servidor, por lo que `BACKEND_URL` del gateway pasa a ser la URL pública del backend en TEST y PROD (decisión 9); las variables del gateway y de Mosquitto quedan pendientes del Dokploy de Arekkazu (AIoT), y el PR se fusiona con ese pendiente registrado en §8 del catálogo. Antes: lista para Taiga (2026-11-21, noche), con las decisiones del líder aplicadas. Carpeta: `entregas/E4_2026-11-24_M07-M08-final/prs/BRK-PR35_compose-prod-broker/HU-IMP-AMB-11_catalogo-broker-mqtt-tls/` (decisión del líder: E4, citando el plan de E2 como origen; ADR-002).
> Fuente: [`plan.md`](../../../../E2_2026-11-03_M03-M04/prs/BRK-PR35_compose-prod-broker/plan.md) §2.2 (H-03, H-04) y decisión D3, y [`analisis.md`](../../../../E2_2026-11-03_M03-M04/prs/BRK-PR35_compose-prod-broker/analisis.md) (EXT-BRK-PR35), ambos de 2026-10-26/27, en E2. ID fijado el 2026-11-21 (`plan.md` l. 150 y 299, PR #24 de SGMP-Integracion).
> Corte: `git fetch` del 2026-11-21, 22:55 (America/Bogota) · Broker `origin/develop 2f8ea54` (0.4.1-rc.1) · `origin/test 662e096` · `origin/main 2181993` (0.4.1; releases 0.4.0 por el PR #64 y 0.4.1 por el PR #67, fusionados el 2026-11-21) · BE `origin/dev 5115b83d` · `origin/test c698c656` · `origin/main 9655f389` (release 1.4.0, PR #1219) · SGMP-Integracion `origin/main b372c82` (PR #24 fusionado; cambia filas del catálogo en el mismo lugar, sin mover líneas, y no toca `env/` ni `compose/`: las citas `@a910760` siguen vigentes). Entre el borrador (`develop 6a7f2e4`, `main cebd430`) y este corte no cambia ninguno de los archivos citados del broker (`git diff --stat 6a7f2e4 origin/develop` y `origin/develop origin/main` vacíos en `app/`, `docker-compose*.yml`, `.env*.example` y `docker/`): `develop` y `main` son iguales en esos archivos. `test` difiere de `develop` en `app/services/ingest.py` (la lectura de `MQTT_ACK_REQUIERE_ID_COMANDO` está en l. 302, no en l. 312), `app/services/credenciales_mqtt.py`, `app/services/reenvio_nodo.py` y `app/db/repositories/registry.py` (no citados), y es la única rama con `docker-compose.test.yml`; en `app/config.py`, `app/backend/client.py`, `app/api/dependencies.py`, `docker-compose.yml`, `docker-compose.prod.yml`, `.env*.example` y `docker/` es igual a `develop`.
> Corte de la ejecución: `git fetch` del 2026-11-22 · Broker `origin/develop 2f8ea54` · `origin/test 662e096` · `origin/main 2181993` (sin cambios desde el corte anterior; diff de `app/`, `docker-compose*.yml`, `.env*.example` y `docker/` vacío) · BE `origin/dev e0c5c0e4` · `origin/test c698c656` · `origin/main bcc3cd17` (release 1.4.3; desde `9655f389` solo cambia el Dockerfile, por el PR #1223, que crea `/app/storage/modelos` y mueve el puerto 8000 a las l. 69 y 79; las releases 1.4.2 y 1.4.3 no tocan Dockerfile, compose ni plantillas; `src/shared/broker_auth.py:61` sin cambios) · SGMP-Integracion `origin/main 9a099e4` (PR #25 y #26 fusionados; las líneas citadas del catálogo no se movieron desde `a910760`). Detalle: [`evidencias/CA-1_corte.md`](evidencias/CA-1_corte.md).

### Estado por subtarea (corte 2026-11-23)

| ST | Estado | Evidencia |
|---|---|---|
| ST-01 Corte | Hecha | [`evidencias/CA-1_corte.md`](evidencias/CA-1_corte.md) |
| ST-02 §3 del catálogo | Hecha (`78ad93f`; `BACKEND_URL` y nota «Dos tramos MQTT» ajustadas en `9763e04`) | [`evidencias/CA-2_a_CA-6_CA-10_catalogo.md`](evidencias/CA-2_a_CA-6_CA-10_catalogo.md) |
| ST-03 `MQTT_HOST`/`MQTT_PORT`, §4, §5, §6 y §8 | Hecha (`78ad93f`; §8 ampliada en `9763e04`) | ídem |
| ST-04 Plantillas `env/` y `compose/` | Hecha (`78ad93f`; `BACKEND_URL` de prod en `9763e04`, decisión 9) | [`evidencias/CA-7_CA-8_plantillas.md`](evidencias/CA-7_CA-8_plantillas.md) |
| ST-05 PR, segunda revisión y cierre | En curso: PR #27 abierto. Comparación con Dokploy hecha para el backend de PROD y TEST (`7bc8ff9`): broker en otro servidor → `BACKEND_URL` pública (`9763e04`). **Pendiente:** gateway y Mosquitto (Dokploy de Arekkazu, AIoT), que no bloquea la fusión (§8 del catálogo) | [`evidencias/ST-05_comparacion-dokploy.md`](evidencias/ST-05_comparacion-dokploy.md) |

---

## Para copiar en Taiga — Descripción de la HU

**Rama:** SGMP-Integracion `docs/hu-imp-amb-11-catalogo-broker` (redacción de la HU, PR #25, fusionado) · ejecución: `docs/amb-11-ejecucion-catalogo-broker` (desde `origin/main`) → PR a `main` · **Plazo:** ejecución antes de la reunión con el Líder de Despliegue; fusión después de ella y antes de E4 (2026-11-24) · **Responsable:** Sebastián Sandoval · **Revisa:** Sebastián Sandoval (segunda revisión con `/revisar`, porque no hay otra persona disponible) · **Entrega:** E4 (2026-11-24) · **Módulos:** M03/M04 (gateway AIoT), transversal

**Origen.** PR de otro equipo (informe EXT-BRK-PR35) — [SerBy48/BROKER-MQTT-SGPMP#35](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/35) «feat(prod): docker-compose y catálogo de variables de PROD del broker (BRK-10)» · Autor: Arekkazu · Fusionado en `develop`: 2026-10-19 · Hallazgos H-03 y H-04 y decisión D3 del plan de Implementación de E2 (2026-10-27).

**Situación actual (verificada el 2026-11-21).** Ninguna de las correcciones del plan está hecha en `main` de SGMP-Integracion. El documento de ambiente v1.5 ya dice `MQTT_TLS=false`: esta HU alinea el catálogo con el documento y con el código.

Catálogo `registros/variables/VARIABLES-ENTORNO.md@a910760`:
- l. 123: `MQTT_TLS` dice «DEV/TEST `false`; PROD `true`» y l. 185 (§4 PROD) `MQTT_TLS=true` (H-03).
- l. 118: `GATEWAY_API_TOKEN` sigue como variable secreta del gateway; §5 (l. 208–236) mantiene la traducción `GATEWAY_API_TOKEN → API_TOKEN`; §6 (l. 260–299) no la lista como descartada (H-04).
- l. 120: `MQTT_PORT` dice «PROD queda sujeto a configuración TLS definitiva» y §4 (l. 190–202) pone `MQTT_HOST` y `MQTT_PORT` como configuración externa de PROD. El compose PROD del broker los fija: `MQTT_HOST: mosquitto` y `MQTT_PORT: "1883"` (`docker-compose.prod.yml:203–204`).
- No figura ninguna de las 5 variables de BRK-10 ni `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO`.

Plantillas locales (D3) `@a910760`: `env/.env.prod.example:88` `MQTT_TLS=true`; `env/.env.dev.example:80`, `env/.env.test.example:78`, `env/.env.prod.example:78` `GATEWAY_API_TOKEN=`; `compose/compose.dev.yml:43`, `compose.test.yml:31`, `compose.prod.yml:30` `API_TOKEN: ${GATEWAY_API_TOKEN}`. El compose base `compose/docker-compose.yml` (gateway, l. 70–94) no pasa ninguna de las 5 variables. Los tres `env/.env.*.example` tienen hoy el mismo conjunto de nombres. El servicio del backend en el compose local se llama `backend` (`compose/docker-compose.yml:109`) y escucha en el puerto 8000 (BE `Dockerfile:64,74`).

Código del broker (manda el código):

| Rama | 5 variables de BRK-10 | `MQTT_TLS` | `GATEWAY_API_TOKEN` / `API_TOKEN` | Evidencia |
|---|---|---|---|---|
| `develop` | ✅ Las 5 en `app/config.py:48,65,77,78,79` | Default `False` (`config.py:27`); `docker-compose.prod.yml:217` `${MQTT_TLS:-false}`; DEV por `env_file` | ✅ Sin uso: no hay campo `api_token`; `require_api_token` valida el Bearer contra la tabla de credenciales de servicio (`app/api/dependencies.py:18–32`) | `2f8ea54` |
| `test` | ✅ Las 5, en las mismas líneas de `config.py` que `develop` (difiere en `ingest.py`: ver cabecera) | Igual que `develop`; `docker-compose.test.yml` por `env_file` | ✅ Sin uso | `662e096` |
| `main` (PROD) | ✅ Igual que `develop` desde el release 0.4.0 (PR #64); `docker-compose.prod.yml` presente | Igual que `develop` | ✅ Sin uso | `2181993` |

Detalle por variable (corte `develop@2f8ea54`; `main@2181993` igual en los archivos citados; `test@662e096` igual salvo `ingest.py`):

| Variable | Lectura en el código | Default | Compose PROD (`docker-compose.prod.yml`) | DEV / TEST |
|---|---|---|---|---|
| `MQTT_ACK_REQUIERE_ID_COMANDO` | `config.py:65`, usada en `app/services/ingest.py:312` (`develop`, `main`) y l. 302 (`test`) | `false` | l. 232 `:-false` | `env_file: .env` |
| `MQTT_TOPIC_RESULTADO` | `config.py:48`, `app/mqtt/publisher.py:30` | `resultado` | l. 234 `:-resultado` | `env_file: .env` |
| `BACKEND_URL` | `config.py:77`, `app/backend/client.py:41,45` | vacía → no reenvía y registra error (`client.py:56`, aviso al arrancar en `app/main.py:35`) | l. 246 `:?` (el mensaje aún dice `sgpmp-network`: H-01, otra HU) | `env_file: .env` |
| `BROKER_SERVICE_TOKEN` | `config.py:78`, `client.py:47`; backend `src/shared/broker_auth.py:61` (`dev@e0c5c0e4`, `test@c698c656`, `main@bcc3cd17`; antes `dev@5115b83d`, `main@9655f389`, misma línea) | vacía (igual que `BACKEND_URL`) | l. 247 `:?` | `env_file: .env` |
| `BACKEND_TIMEOUT_SECONDS` | `config.py:79`, `client.py:46` | `10` | l. 248 `:-10` | `env_file: .env` |
| `MQTT_PUERTO_PUBLICO` | `docker/mosquitto-entrypoint.sh:88` (tres ramas) | `1883` | l. 68 `:-8883` | DEV `docker-compose.yml:20` `:-1883`; **TEST no la pasa** (`docker-compose.test.yml` publica `1885:1883`, en claro) |
| `MQTT_WS_PUERTO_PUBLICO` | `mosquitto-entrypoint.sh:89` | `9001` | l. 69 `:-9002` | DEV l. 21 `:-9001`; TEST no la pasa (`9002:9001`) |
| `MQTT_HOST_PORT` (solo en la nota) | Solo compose (puerto de host) | — | l. 92 `:?` | DEV l. 47 `:-1884`; TEST `docker-compose.test.yml:29` `:-1885` |
| `MQTT_WS_HOST_PORT` (solo en la nota) | Solo compose (puerto de host) | — | l. 93 `:?` | DEV l. 48 `:-9001`; TEST l. 30 `:-9002` |

**Descripción.** El catálogo es lo que Despliegue consulta para cargar Dokploy. Hoy le dice que en PROD ponga `MQTT_TLS=true`, lo que deja el gateway `healthy` sin ingerir nada (el listener interno `mosquitto:1883` está en claro; advertencia en `docker-compose.prod.yml:209–216`). Además le pide un `GATEWAY_API_TOKEN` que el código ya no usa, trata `MQTT_HOST`/`MQTT_PORT` de PROD como valores externos cuando el compose los fija, y omite las variables con las que el gateway reenvía eventos al backend. Con el broker 0.4.x ya en `main`, el error afecta directamente a PROD. Esta HU corrige el catálogo para que refleje el código de las tres ramas del broker y alinea con él las plantillas de la orquestación local de SGMP-Integracion (D3), en un solo PR. El catálogo corregido sirve como propuesta para la reunión con el Líder de Despliegue sobre las variables de `main`.

**Alcance.** En SGMP-Integracion, un PR a `main`:
- Catálogo §3: fila de `MQTT_TLS` reescrita; fila de `GATEWAY_API_TOKEN` retirada; fila de `MQTT_PORT` corregida; 7 filas nuevas (las 5 de BRK-10, `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO`); nota «Dos tramos MQTT», que menciona `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` sin catalogarlas.
- Catálogo §4 (`MQTT_TLS=false` en PROD; `MQTT_HOST` y `MQTT_PORT` fuera de la configuración externa), §5 (sin la traducción a `API_TOKEN`), §6 (`GATEWAY_API_TOKEN` como descartada) y §8 (entrada de actualización con el corte).
- D3: `env/.env.{dev,test,prod}.example` sin `GATEWAY_API_TOKEN`, con `MQTT_TLS=false` y con las 5 variables de BRK-10 (`BACKEND_URL=http://backend:8000` en dev y test; en prod, ~~vacía~~ placeholder de URL pública desde el 2026-11-23, decisión 9); `compose/compose.{dev,test,prod}.yml` sin `API_TOKEN`; `compose/docker-compose.yml` pasa las 5 variables al gateway.

**Fuera de alcance:** H-01 (red `sgpmp-network` del compose PROD del broker, incluido el mensaje de la guarda de `BACKEND_URL`) → HU-IMP-CFG-01 (propuesta, por crear), PR al broker (aprueba AIoT) · valor de `BACKEND_URL` por entorno desplegado (decisión D1, con datos de Despliegue; el criterio, URL pública del backend, quedó fijado el 2026-11-23, decisión 9, y el valor lo carga Despliegue) · tramo gateway → PostgreSQL por el puerto publicado de la base → Taiga #5478 (HU-IMP-CFG-05) · `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT` como filas del catálogo y sus valores → Despliegue (regla 9 del catálogo: los puertos de host son de Despliegue) · TLS de dispositivos en TEST → HU-IMP-SEG-03 (ver nota de seguridad) · `MQTT_DEVICE_*`, `MQTT_ACK_TIMEOUT_SECONDS`, `MQTT_COLA_*`: quedan pendientes de H-04, sin HU · variables del motor M04 (`docker-compose.motor-ia.yml`, que tiene su propia `BACKEND_URL`) → HU-IMP-DOC-02 · cambios en el repo del broker → AIoT · carga de valores en Dokploy → Despliegue · aviso a Despliegue sobre `MQTT_TLS` → lo envía el líder.

**Nota de seguridad (fuera de alcance).** TEST publica MQTT en claro hacia los dispositivos (`1885:1883` y `9002:9001`, sin TLS; `docker-compose.test.yml@662e096` no pasa `MQTT_PUERTO_PUBLICO`), lo que incumple SEG-BROKER-02. Lo cubre HU-IMP-SEG-03, que sigue «por crear». Esta HU solo lo deja escrito en la nota «Dos tramos MQTT» y en §8, sin darlo por resuelto.

**Criterios de aceptación.**
1. CA-1 **Corte.** La HU y la descripción del PR registran la fecha del `git fetch` y los hashes de `develop`, `test` y `main` del broker, de `dev`, `test` y `main` del backend y de `main` de SGMP-Integracion, reverificados el día del PR. Si alguna rama avanzó, se confirma que no cambiaron `app/`, `docker-compose*.yml`, `.env*.example` ni `docker/` del broker, o se actualizan las citas.
2. CA-2 **`MQTT_TLS`.** En `registros/variables/VARIABLES-ENTORNO.md` ninguna línea con `MQTT_TLS` contiene `true`, salvo la frase de la advertencia («con `true` el handshake falla…») y la entrada de §8 de esta HU, que describe la corrección. La fila de §3 tiene Componente `Gateway AIoT`, dice «`false` en DEV, TEST y PROD» y remite a la nota «Dos tramos MQTT». §4 PROD dice `MQTT_TLS=false`.
3. CA-3 **`GATEWAY_API_TOKEN`.** En el catálogo, `GATEWAY_API_TOKEN` aparece solo en §6, con el motivo: diseño superado por `BROKER_SERVICE_TOKEN` y las credenciales de servicio en base de datos (broker `.env.prod.example:244–246`). `API_TOKEN` no aparece en §5. Se admite la mención en la entrada de §8 de esta HU.
4. CA-4 **Filas nuevas.** §3 tiene una fila por cada una de estas 7 variables, con Componente (con el criterio de las filas vecinas), Tipo y Sensibilidad del vocabulario del catálogo (§1), default y archivo:línea@hash del corte: `MQTT_ACK_REQUIERE_ID_COMANDO`, `MQTT_TOPIC_RESULTADO`, `BACKEND_URL`, `BROKER_SERVICE_TOKEN` (**Secreta**; mismo valor en broker y backend de cada entorno), `BACKEND_TIMEOUT_SECONDS`, `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO`. Cada fila dice en qué ramas del broker existe. `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` **no** tienen fila en §3.
5. CA-5 **Nota «Dos tramos MQTT».** Bajo la tabla de §3 hay una nota que distingue (1) dispositivos → Mosquitto, por puertos de host, y (2) gateway → Mosquitto por la red interna (`mosquitto:1883`, en claro), y dice por entorno qué publica el compose hoy: DEV en claro; TEST en claro (el compose de TEST no pasa `MQTT_PUERTO_PUBLICO`; incumple SEG-BROKER-02, pendiente de HU-IMP-SEG-03); PROD 8883/9002 con certificados en `./docker/certs`. Dice también que el compose de PROD exige `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` (`:?`) y que su valor lo define Despliegue. No contiene valores de puertos de host ni dominios.
6. CA-6 **§8.** El catálogo tiene una entrada «Actualización 2026-11-2x (HU-IMP-AMB-11)» con el corte y los pendientes: H-01 (HU-IMP-CFG-01), D1 (`BACKEND_URL`), TLS de TEST (HU-IMP-SEG-03, SEG-BROKER-02) y las variables de H-04 que quedaron fuera.
7. CA-7 **Plantillas (D3).** Los tres `env/.env.*.example` tienen exactamente el mismo conjunto de nombres; ninguno contiene `GATEWAY_API_TOKEN`; los tres tienen `MQTT_TLS=false` y las 5 variables de BRK-10; `BACKEND_URL=http://backend:8000` en dev y test y, en prod, un placeholder de URL pública (`BACKEND_URL=https://<…>/<…>`), sin valor real (texto anterior, sustituido el 2026-11-23 por la decisión 9: ~~«y `BACKEND_URL=` en prod»~~); `BROKER_SERVICE_TOKEN` queda con `=` y nada después. Los tres `compose/compose.*.yml` no contienen `API_TOKEN`; `compose/docker-compose.yml` pasa las 5 variables al servicio `gateway` con los mismos defaults que el compose PROD del broker (`:-false`, `:-resultado`, `:-10`), y pasa `BROKER_SERVICE_TOKEN: ${BROKER_SERVICE_TOKEN:-}` al servicio `backend` (el backend exige el mismo token, `src/shared/broker_auth.py:61`; REV-01 m-02).
8. CA-8 **Compose local válido.** Con cada plantilla, `docker compose … config --quiet` termina con código 0 (TEST y PROD con `*_IMAGE` ficticias en el entorno del shell), y el `config --no-interpolate` de cada entorno muestra las 5 variables en el gateway, `BROKER_SERVICE_TOKEN` también en el backend y ningún `API_TOKEN`.
9. CA-9 **Sin secretos y sin registros paralelos.** El diff del PR solo toca `registros/variables/VARIABLES-ENTORNO.md`, `env/.env.{dev,test,prod}.example`, `compose/compose.{dev,test,prod}.yml`, `compose/docker-compose.yml`, `entregas/README.md`, `entregas/E4_2026-11-24_M07-M08-final/README.md`, `registros/entornos/CONTRATO-PROD.md`, `registros/entornos/CONTRATO-TEST.md`, `runbooks/RUNBOOK-LEVANTAMIENTO-VALIDACION-SGPMP.md`, `registros/incidencias/registro.md` (ampliación del líder, 2026-11-22, REV-02 M-01) y la carpeta de esta HU; ninguna variable Secreta tiene valor.
10. CA-10 **`MQTT_HOST` y `MQTT_PORT`.** La fila de `MQTT_PORT` en §3 ya no dice «sujeto a configuración TLS definitiva»: dice que es el puerto interno de Mosquitto (`1883`, en claro) en los tres entornos y que el compose PROD lo fija (`docker-compose.prod.yml:203–204`), sin confundirlo con `MQTT_HOST_PORT`. La fila de `MQTT_HOST` dice `mosquitto` en los tres entornos. §4 ya no pone `MQTT_HOST` ni `MQTT_PORT` como configuración externa de PROD.

**Verificación.** Ejecutar desde `PI4/SGMP-Integracion`, en la rama del PR y en Git Bash, salvo que se indique otra carpeta. Los comandos van en el bloque de abajo, no en la tabla, para que se puedan copiar tal cual. Antes del cambio, CA-2, CA-3, CA-4, CA-7 y CA-10 fallan sobre `main` (comprobado el 2026-11-21).

| CA | Resultado esperado | Evidencia a adjuntar |
|---|---|---|
| CA-1 | Hashes del día; diff vacío o citas actualizadas | `evidencias/CA-1_corte.md` con la salida |
| CA-2 | Primer comando sin salida; el segundo da `3` (DEV, TEST y PROD) | Salida pegada |
| CA-3 | Primer comando sin salida; el segundo, `GATEWAY_API_TOKEN` en §6 (conteo ≥ 1) | Salida pegada |
| CA-4 | `1` para las 7 primeras; `0` para `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT`; `BROKER_SERVICE_TOKEN` con `**Secreta**`; citas con hash del corte | Salida + tabla variable → cita verificada en `evidencias/CA-4_filas.md` |
| CA-5 | La nota existe, cubre los dos tramos, el estado por entorno y la obligatoriedad de `MQTT_HOST_PORT` en PROD con valor de Despliegue, sin valores de puertos de host ni dominios | Texto de la nota pegado |
| CA-6 | Entrada en §8 con corte y los 4 pendientes | Salida |
| CA-7 | `PARIDAD`; sin `GATEWAY_API_TOKEN`; `MQTT_TLS=false` ×3; `BROKER_SERVICE_TOKEN=` vacío ×3; `BACKEND_URL=http://backend:8000` en dev y test, placeholder `BACKEND_URL=https://<…>/<…>` en prod (antes ~~`BACKEND_URL=` en prod~~; decisión 9); ningún `API_TOKEN` en `compose/`; 6 líneas en el compose base: las 5 del gateway y `BROKER_SERVICE_TOKEN` en el backend | Salidas pegadas |
| CA-8 | `exit=0` ×3; en cada entorno, las 5 variables en el gateway, `BROKER_SERVICE_TOKEN` dos veces (gateway y backend) y ningún `API_TOKEN` | Salidas pegadas (nunca `config` sin `--quiet`/`--no-interpolate`) |
| CA-9 | Solo los archivos del CA-9; el segundo comando sin salida | Salidas pegadas |
| CA-10 | Las dos filas con `mosquitto`/`1883` en los tres entornos y sin «sujeto a configuración TLS»; el segundo comando sin salida | Salidas pegadas |

```bash
F=registros/variables/VARIABLES-ENTORNO.md
export MSYS_NO_PATHCONV=1

# CA-1
for r in ../BROKER-MQTT-SGPMP ../sgpmp-backend .; do git -C "$r" fetch --prune -q origin; done
for b in develop test main; do git -C ../BROKER-MQTT-SGPMP log -1 --format="broker $b %h %ad" --date=short origin/$b; done
for b in dev test main; do git -C ../sgpmp-backend log -1 --format="backend $b %h %ad" --date=short origin/$b; done
git log -1 --format='SGMP-Integracion main %h' origin/main
# si cambió un hash del broker (ídem test desde 662e096 y main desde 2181993):
git -C ../BROKER-MQTT-SGPMP diff --stat 2f8ea54 origin/develop -- app 'docker-compose*.yml' '.env*.example' docker

# CA-2
awk '/^## 8\./{s=8} s==8 && /HU-IMP-AMB-11/{amb=1} /MQTT_TLS/ && /true/ && !/handshake/ && !amb {print NR": "$0}' "$F"
awk '/^## 4\./{f=1} /^## 5\./{f=0} f' "$F" | grep -cx 'MQTT_TLS=false'

# CA-3
awk '/^## 6\./{s=6} /^## 7\./{s=7} /^## 8\./{s=8} s==8 && /HU-IMP-AMB-11/{amb=1} /API_TOKEN/ && s!=6 && !amb {print NR": "$0}' "$F"
awk '/^## 6\./{f=1} /^## 7\./{f=0} f' "$F" | grep -c 'GATEWAY_API_TOKEN'

# CA-4
for v in MQTT_ACK_REQUIERE_ID_COMANDO MQTT_TOPIC_RESULTADO BACKEND_URL BROKER_SERVICE_TOKEN BACKEND_TIMEOUT_SECONDS MQTT_PUERTO_PUBLICO MQTT_WS_PUERTO_PUBLICO MQTT_HOST_PORT MQTT_WS_HOST_PORT; do
  printf '%s ' "$v"; grep -c "^| \`$v\` |" "$F"
done

# CA-5
grep -n -e 'Dos tramos MQTT' -e 'MQTT_HOST_PORT' -e 'SEG-BROKER-02' "$F"

# CA-6
grep -n 'HU-IMP-AMB-11' "$F"

# CA-7
T=$(mktemp -d)
for e in dev test prod; do grep -oE '^[A-Z0-9_]+=' env/.env.$e.example | sort -u > "$T/n_$e"; done
diff "$T/n_dev" "$T/n_test" && diff "$T/n_dev" "$T/n_prod" && echo PARIDAD
grep -n -e GATEWAY_API_TOKEN -e MQTT_TLS -e BROKER_SERVICE_TOKEN -e BACKEND_URL env/.env.*.example
grep -n 'API_TOKEN' compose/*.yml
grep -n -e MQTT_ACK_REQUIERE_ID_COMANDO -e MQTT_TOPIC_RESULTADO -e BACKEND_URL -e BROKER_SERVICE_TOKEN -e BACKEND_TIMEOUT_SECONDS compose/docker-compose.yml
rm -r "$T"

# CA-8
cd compose
for e in dev test prod; do
  DATABASE_IMAGE=ficticia BACKEND_IMAGE=ficticia FRONTEND_IMAGE=ficticia GATEWAY_IMAGE=ficticia \
    docker compose -f docker-compose.yml -f compose.$e.yml --env-file ../env/.env.$e.example config --quiet
  echo "$e exit=$?"
  docker compose -f docker-compose.yml -f compose.$e.yml config --no-interpolate \
    | grep -n -e API_TOKEN -e BACKEND_URL -e BROKER_SERVICE_TOKEN -e MQTT_ACK_REQUIERE -e MQTT_TOPIC_RESULTADO -e BACKEND_TIMEOUT
done
cd ..

# CA-9
git diff --stat origin/main...HEAD
git diff origin/main...HEAD -- env/ compose/ | grep -E '^[+][A-Z0-9_]*(TOKEN|PASSWORD|SECRET|KEY)[A-Z0-9_]*[=:] *[^ $]'

# CA-10
grep -nE '^[|] `MQTT_(HOST|PORT)` [|]' "$F"
awk '/^## 4\./{f=1} /^## 5\./{f=0} f' "$F" | grep -nxE 'MQTT_(HOST|PORT)'
```

**Definición de terminado.**
- [ ] Todos los CA verificados con evidencia en `evidencias/` de la carpeta de la HU.
- [ ] PR a `main` de SGMP-Integracion abierto con descripción que enlaza esta HU, el PR #35 del broker y `plan.md` §2.2.
- [ ] Segunda revisión con `/revisar` (dictamen en `revisiones/`) y observaciones atendidas.
- [ ] Reunión con el Líder de Despliegue realizada y, si cambió algo del gateway o del broker, ajustado con un commit más en el mismo PR.
- [ ] PR aprobado y fusionado por el Líder de Implementación (después de la reunión).
- [ ] Registro vivo actualizado: `registros/variables/VARIABLES-ENTORNO.md` (es el entregable; no se crea otro catálogo).
- [ ] Fila de AMB-11 actualizada en `entregas/README.md` y en el README de E4.

**Dependencias y aprobaciones.**
- De inicio: ninguna externa. Conviene que el PR #24 de SGMP-Integracion esté fusionado (la rama se rebasa sobre `main` antes de empezar).
- **De cierre (no de inicio):** la reunión con el Líder de Despliegue sobre las variables de `main`. La HU se ejecuta antes y su catálogo corregido sirve de propuesta; el PR no se fusiona hasta después de la reunión.
- Aprobación: un solo PR, a `main` de SGMP-Integracion, que aprueba el Líder de Implementación. Como responsable y revisor son la misma persona, `/revisar` hace de segunda revisión. Sin dependencia de otros equipos para el contenido: la HU documenta el código, no lo cambia. No espera a HU-IMP-CFG-01 (H-01).

**Riesgos.**
- La reunión con Despliegue cambia algo del gateway o del broker (nombres, obligatoriedad, qué carga Despliegue en `main`). Mitigación: el PR queda abierto hasta después de la reunión; el ajuste va en un commit más y se repiten los CA afectados.
- El broker avanza antes del PR (nuevo release en `main` o cambios en `develop`): las citas quedan viejas. Mitigación: CA-1 el día del PR.
- Conflicto con otro PR que toque el catálogo. Mitigación: rama desde `origin/main` del día y `git rebase origin/main` antes de la revisión.
- Prometer un valor de `BACKEND_URL` desplegada o de puertos de host. Mitigación: las filas describen, no fijan valores; D1 y los puertos quedan como pendientes de Despliegue en §8. El `http://backend:8000` de las plantillas locales es el nombre del servicio del stack local, no un dominio.
- Con el broker 0.4.x en `main` ([#64](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/64), [#67](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/67)), el `MQTT_TLS=true` del catálogo ya afecta a PROD: si Despliegue lo cargó siguiendo el catálogo, el gateway de PROD queda `healthy` sin ingerir, y solo se detecta en Dokploy. Mitigación: la HU se ejecuta antes de la reunión con el Líder de Despliegue, y el aviso a Despliegue lo da el Líder de Implementación (borrador en las notas).
- Autorrevisión: responsable y revisor son la misma persona. Mitigación: `/revisar` con dictamen por criterio antes de pedir la fusión.

**Referencias.** [BROKER #35](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/35) · [BROKER #64](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/64) y [#67](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/67) (releases 0.4.0 y 0.4.1) · `entregas/E2_2026-11-03_M03-M04/prs/BRK-PR35_compose-prod-broker/plan.md` §1 (D1, D3), §2.2 · `analisis.md` (H-03, H-04; l. 118, 218–219, 266) · broker `develop@2f8ea54`, `test@662e096`, `main@2181993` · backend `dev@e0c5c0e4`, `test@c698c656`, `main@bcc3cd17` (corte de la ejecución) · SGMP-Integracion `main@a910760` · HU-IMP-CFG-01 (H-01) · HU-IMP-SEG-03 (TLS del broker en TEST, SEG-BROKER-02) · HU-IMP-AMB-02 (catálogo original) · `entregas/E1_2026-10-13_M01-M09-M02/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` (v1.5, `MQTT_TLS=false`).

---

## Para copiar en Taiga — Subtareas

Todas las hace Sebastián Sandoval (responsable único); la segunda revisión es `/revisar`.

### ST-01 Reverificar el estado del broker y del catálogo y registrar el corte
**Objetivo.** Partir de los hashes del día, no de los de esta HU.
**Pasos.**
1. En SGMP-Integracion, `git fetch origin` y `git rebase origin/main` sobre la rama de ejecución `docs/amb-11-ejecucion-catalogo-broker` (la carpeta de la HU ya está en `main` por el PR #25).
2. Ejecutar los comandos de CA-1. Si un hash cambió, correr el `git diff --stat` de CA-1 y, si hay cambios, repetir los `git show origin/<rama>:<archivo> | grep -n <VAR>` para cada variable de la tabla «Detalle por variable».
3. Confirmar en las tres ramas que `API_TOKEN` sigue sin usarse como variable: `git -C ../BROKER-MQTT-SGPMP grep -niE 'api_token' origin/<rama> -- app` → solo `require_api_token` (nombre de función) y sus importaciones.
4. Guardar las salidas en `evidencias/CA-1_corte.md` (formato de la skill de verificación: fecha, rama@hash, comando, salida, veredicto).
**Entregable.** `evidencias/CA-1_corte.md`.
**Verificación.** Comandos de CA-1; hashes del día y diff vacío o citas nuevas anotadas (CA-1).
**Estimación.** 2 h.

### ST-02 Corregir §3 del catálogo: `MQTT_TLS`, `GATEWAY_API_TOKEN`, 7 filas nuevas y nota «Dos tramos MQTT»
**Objetivo.** Que la tabla de §3 describa el contrato real del gateway y de Mosquitto.
**Pasos.**
1. En `registros/variables/VARIABLES-ENTORNO.md` (hoy l. 123) reemplazar la fila de `MQTT_TLS` por el texto del plan §2.2 (l. 112), con Componente `Gateway AIoT` y Tipo `Comportamiento`, agregando la cita `app/config.py:27` y `docker-compose.prod.yml:217@<hash del corte>`.
2. Borrar la fila de `GATEWAY_API_TOKEN` (hoy l. 118).
3. Agregar, después de `MQTT_TOPIC_STATUS` (hoy l. 130), las 5 filas del plan §2.2 (l. 124–128) completadas con archivo:línea@hash y default de la tabla «Detalle por variable», y «existe en `develop`, `test` y `main` del broker (en `main` desde el release 0.4.0)». Donde el plan dice que el gateway «falla en silencio» sin `BACKEND_URL`, corregir: no reenvía y registra un error (`client.py:56`; aviso al arrancar en `app/main.py:35`); para `BROKER_SERVICE_TOKEN`, la lectura en el backend (`src/shared/broker_auth.py:61`, en `dev`, `test` y `main`); para `BACKEND_URL`, «valor por entorno según D1; no confundir con la `BACKEND_URL` del motor M04, que vive en otro compose».
4. Agregar 2 filas: `MQTT_PUERTO_PUBLICO` y `MQTT_WS_PUERTO_PUBLICO` (Componente `Gateway / Mosquitto`, como las filas vecinas; Tipo `Conexión`, porque §1 clasifica los puertos como Conexión; No sensible; la descripción dice que 8883/9002 activan TLS y exigen certificados; el entrypoint aborta sin ellos, `docker/mosquitto-entrypoint.sh:88–94`; defaults por compose de la tabla). `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` **no** llevan fila (regla 9).
5. Bajo la tabla, la nota «Dos tramos MQTT» del plan (l. 118) **corregida** según CA-5: el plan dice «TLS obligatorio» sin distinguir entornos; hoy TEST publica en claro (incumple SEG-BROKER-02; HU-IMP-SEG-03). La nota dice que el compose de PROD exige `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` y que el valor lo define Despliegue. No citar SEG-BROKER-02 como cumplido.
**Entregable.** Commit en la rama con §3 corregido.
**Verificación.** Comandos de CA-2 (parte §3), CA-3 (parte §3), CA-4 y CA-5.
**Estimación.** 3,5 h.

### ST-03 Corregir `MQTT_HOST`/`MQTT_PORT` y §4, §5, §6 y §8 del catálogo
**Objetivo.** Que el resto del catálogo no contradiga la nueva §3.
**Pasos.**
1. Filas de `MQTT_HOST` y `MQTT_PORT` (hoy l. 119–120): `mosquitto` y `1883` en DEV, TEST y PROD; en PROD los fija el compose del broker (`docker-compose.prod.yml:203–204`); quitar «PROD queda sujeto a configuración TLS definitiva»; aclarar que `MQTT_PORT` no es `MQTT_HOST_PORT`.
2. §4 PROD (hoy l. 185): `MQTT_TLS=true` → `MQTT_TLS=false`. En la lista de configuración externa de PROD (hoy l. 190–202), quitar `MQTT_HOST` y `MQTT_PORT`.
3. §5 «Gateway» (hoy l. 208–236): quitar el párrafo y los bloques de `GATEWAY_API_TOKEN` → `API_TOKEN`; conservar la composición de `DATABASE_URL` desde `DB_IOT_USER`, `DB_IOT_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_NAME` con `postgresql+asyncpg://`.
4. §6 (hoy l. 260–299): agregar `GATEWAY_API_TOKEN` al primer bloque y una línea con el motivo (diseño superado por `BROKER_SERVICE_TOKEN` + credenciales de servicio en base de datos; broker `.env.prod.example:244–246@<hash del corte>`).
5. §8: agregar «Actualización 2026-11-2x (HU-IMP-AMB-11; corte …)» con los 4 pendientes de CA-6.
**Entregable.** Commit en la rama con §3 (`MQTT_HOST`/`MQTT_PORT`) y §4–§8 corregidos.
**Verificación.** Comandos de CA-2, CA-3, CA-6 y CA-10.
**Estimación.** 2,5 h.

### ST-04 Alinear las plantillas `env/` y `compose/` de SGMP-Integracion (D3) y validar el compose local
**Objetivo.** Que la orquestación local use los mismos nombres que el catálogo.
**Pasos.**
1. En `env/.env.dev.example` (hoy l. 76–80), `env/.env.test.example` y `env/.env.prod.example` (hoy l. 74–78): quitar el bloque «Gateway AIoT / Seguridad» con `GATEWAY_API_TOKEN=`.
2. `env/.env.prod.example:88`: `MQTT_TLS=true` → `MQTT_TLS=false`, con un comentario de una línea (tramo interno en claro; ver catálogo).
3. En los tres, después del bloque «Broker MQTT», un bloque «Gateway → backend (BRK-10)» con `MQTT_ACK_REQUIERE_ID_COMANDO=false`, `MQTT_TOPIC_RESULTADO=resultado`, `BACKEND_URL=`, `BROKER_SERVICE_TOKEN=` (vacío), `BACKEND_TIMEOUT_SECONDS=10`. `BACKEND_URL=http://backend:8000` en dev y test (nombre del servicio `backend` del compose local, puerto 8000 de la imagen); vacía en prod.
4. `compose/compose.dev.yml:43`, `compose.test.yml:31`, `compose.prod.yml:30`: borrar la línea `API_TOKEN: ${GATEWAY_API_TOKEN}`.
5. `compose/docker-compose.yml`, servicio `gateway`, `environment:` (hoy l. 70–94): agregar `MQTT_ACK_REQUIERE_ID_COMANDO: ${MQTT_ACK_REQUIERE_ID_COMANDO:-false}`, `MQTT_TOPIC_RESULTADO: ${MQTT_TOPIC_RESULTADO:-resultado}`, `BACKEND_URL: ${BACKEND_URL:-}`, `BROKER_SERVICE_TOKEN: ${BROKER_SERVICE_TOKEN:-}`, `BACKEND_TIMEOUT_SECONDS: ${BACKEND_TIMEOUT_SECONDS:-10}`.
5b. `compose/docker-compose.yml`, servicio `backend` (hoy l. 109–115, sin `environment:`): agregar `environment:` con `BROKER_SERVICE_TOKEN: ${BROKER_SERVICE_TOKEN:-}`. Compose lo combina con el `environment:` del backend de cada `compose.<entorno>.yml`. Sin esto, con `BACKEND_URL=http://backend:8000` y el token lleno, el gateway reenvía y el backend lo rechaza (`src/shared/broker_auth.py:61`; REV-01 m-02).
6. Ejecutar los comandos de CA-7 y CA-8 y guardar las salidas.
**Entregable.** Commit en la rama con los 7 archivos; `evidencias/CA-7_CA-8_plantillas.md`.
**Verificación.** CA-7: `PARIDAD` y greps esperados (incluido `BROKER_SERVICE_TOKEN` en el backend del compose base); CA-8: `exit=0` ×3 y el token en gateway y backend (CA-7, CA-8).
**Estimación.** 3 h.

### ST-05 Abrir el PR a `main`, segunda revisión y cierre después de la reunión con Despliegue
**Objetivo.** Entregar el cambio revisable contra los CA, llevarlo como propuesta a la reunión y fusionarlo después.
**Pasos.**
1. `git fetch origin && git rebase origin/main`; repetir CA-1 (si cambió algún hash, actualizar `evidencias/CA-1_corte.md` y las citas).
2. Ejecutar CA-9 y completar `evidencias/` (un `.md` por CA o uno por HU).
3. Commits sin atribuciones a herramientas. `git push -u origin docs/amb-11-ejecucion-catalogo-broker` y `gh pr create -R Juanher01/SGMP-Integracion --base main` con la plantilla de PR de Implementación: qué, por qué (H-03, H-04, D3; BROKER #35), corte, comandos y resultados resumidos, «Variables: sin ficha (solo documentación)» y «No fusionar antes de la reunión con Despliegue».
4. Correr `/revisar` (segunda revisión), guardar el dictamen en `revisiones/` y atender las observaciones en la misma rama.
5. Después de la reunión con el Líder de Despliegue: si cambió algo del gateway o del broker, un commit más con el ajuste y los CA afectados repetidos; dejar constancia en la HU (fecha de la reunión y qué cambió, o «sin cambios»). Luego, fusión.
**Entregable.** URL del PR en la HU de Taiga; dictamen de `/revisar`; constancia de la reunión.
**Verificación.** `gh pr view <n> -R Juanher01/SGMP-Integracion --json state,baseRefName,files` → `OPEN` (antes de la reunión) o `MERGED` (después), `main`, solo los archivos del CA-9, incluidos los dos README (CA-1, CA-9).
**Estimación.** 2,5 h.

---

## Notas para el líder

**Plazo.** 13,5 h de trabajo documental. Se ejecuta antes de la reunión con el Líder de Despliegue y se fusiona después, antes de E4 (2026-11-24).

**Diferencias entre el plan del 2026-10-27 y el estado del 2026-11-21.**
1. Hashes: broker `develop 69703f4 → 2f8ea54` (0.4.0-rc.5 → 0.4.1-rc.1), `test 22e9ad0 → 662e096`, `main cebd430 → 2181993` (0.3.0 → 0.4.1); SGMP-Integracion `0fa672e → b372c82`.
2. Líneas del catálogo movidas (filas de CFG-03/CFG-04 en §3): `GATEWAY_API_TOKEN` l. 97 → **118**; `MQTT_TLS` l. 102 → **123**; fin de §3 «tras 109» → **tras 130**; §4 PROD `MQTT_TLS=true` l. 164 → **185**; §5 Gateway l. 187–199 → **208–236**; §6 → **260–299**.
3. Plantillas locales: los `GATEWAY_API_TOKEN` no están en l. 78–80 de las tres: `dev` l. **80**, `test` y `prod` l. **78**; `env/.env.prod.example:88` `MQTT_TLS=true` sin cambio.
4. **Ninguna corrección está hecha** en `main` (ni parcial). Nada cambió de nombre; `MQTT_TLS` sigue `false` (default y compose); `GATEWAY_API_TOKEN`/`API_TOKEN` sigue sin usarse en las tres ramas (`require_api_token` es solo un nombre de función que valida contra la base).
5. **TEST no publica TLS a los dispositivos.** `docker-compose.test.yml@662e096` no pasa `MQTT_PUERTO_PUBLICO`/`MQTT_WS_PUERTO_PUBLICO` a mosquitto y publica `1885:1883` y `9002:9001` (en claro): incumple SEG-BROKER-02 (HU-IMP-SEG-03, por crear).
6. **Nuevo (2026-11-21, noche): el broker 0.4.x llegó a `main`** (PR #64 y #67): las 5 variables y `docker-compose.prod.yml` existen en las tres ramas, así que el `MQTT_TLS=true` del catálogo ya afecta a PROD.
7. H-01 sigue sin corregir en `develop`, `test` y ahora `main` (`sgpmp-network`, incluida la guarda de `BACKEND_URL`, l. 246); no afecta a esta HU.
8. El plan no consideraba que el compose base `compose/docker-compose.yml` no pasa las 5 variables: sin ese cambio, D3 dejaría nombres en las plantillas que no llegan al contenedor. Se agregó al alcance (ST-04 paso 5).
9. `BROKER_SERVICE_TOKEN` del backend: existe en `dev`, `test` y, desde el release 1.4.0 (PR #1219), en `main` (`src/shared/broker_auth.py:61`).
10. `MQTT_PUERTO_PUBLICO`/`MQTT_WS_PUERTO_PUBLICO` solo los usa la imagen de Mosquitto del broker; el compose local de SGMP-Integracion usa `eclipse-mosquitto:2` directo, así que **no se agregan a `env/`**. `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT` tampoco (regla 9 del catálogo).
11. `docker compose config --quiet` de TEST y PROD falla hoy con las plantillas tal cual (`*_IMAGE` vacías): no es un error de esta HU; CA-8 usa imágenes ficticias en el shell.

**Decisiones del líder (2026-11-21), que cierran las preguntas del borrador.**
1. Ubicación: E4, citando el plan de E2 como origen.
2. Puertos de host: `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` solo en la nota «Dos tramos MQTT» (regla 9); CA-4 queda con 7 filas.
3. `BACKEND_URL` en las plantillas locales: `http://backend:8000` en dev y test (servicio `backend` verificado en `compose/docker-compose.yml:109`); vacía en prod (para prod, sustituida por la decisión 9).
4. Aviso a Despliegue sobre `MQTT_TLS`: lo envía el líder. Borrador:
   > Despliegue: el catálogo de Implementación decía `MQTT_TLS=true` para PROD; es un error que corregimos en HU-IMP-AMB-11. `MQTT_TLS` es el TLS del gateway hacia Mosquitto por la red interna y debe quedar en `false` (o sin definir) en DEV, TEST y PROD; con `true` el gateway queda `healthy` sin ingerir. El TLS de los dispositivos lo controlan `MQTT_PUERTO_PUBLICO`/`MQTT_WS_PUERTO_PUBLICO` en mosquitto. Tampoco hay que cargar `GATEWAY_API_TOKEN`. ¿Pueden confirmar qué valor de `MQTT_TLS` hay en cada entorno del broker, sin compartir otros valores?
5. `MQTT_HOST` y `MQTT_PORT`: se corrigen en esta HU, en ST-03 (+0,5 h; CA-10).
6. Orden: se ejecuta antes de la reunión con el Líder de Despliegue; el PR queda abierto hasta después (dependencia de cierre y riesgo).
7. Responsable y revisor: Sebastián Sandoval (Juan Hernando no está disponible); sin reparto por subtarea; `/revisar` como segunda revisión.
8. (2026-11-22, REV-02 M-01) CA-9 se amplía a `registros/entornos/CONTRATO-PROD.md`, `registros/entornos/CONTRATO-TEST.md`, `runbooks/RUNBOOK-LEVANTAMIENTO-VALIDACION-SGPMP.md`, `registros/incidencias/registro.md`, y se corrigen en el mismo PR: `CONTRATO-PROD.md` con `MQTT_TLS=false` y sin `GATEWAY_API_TOKEN`, con referencia a la nota «Dos tramos MQTT» del catálogo; `CONTRATO-TEST.md` y el runbook sin `GATEWAY_API_TOKEN`; INC-IMP-05 resuelta por esta HU (retiro de `API_TOKEN` de `compose/`). Se quita el pendiente provisional de §8 del catálogo que los listaba.
9. (2026-11-23, ST-05) **`BACKEND_URL` del gateway en PROD y TEST = URL pública del backend del entorno**, con su prefijo de ruta y sin `/` final. Motivo: la lista de variables de Dokploy del backend (Despliegue, 2026-11-23) muestra que el broker (gateway y Mosquitto) corre en un servidor distinto del backend y de PostgreSQL, sin red Docker común, así que la URL interna no es alcanzable. En consecuencia, `env/.env.prod.example` lleva un placeholder de URL pública y cambia el texto de CA-7. Texto anterior de CA-7: «`BACKEND_URL=http://backend:8000` en dev y test y `BACKEND_URL=` en prod»; texto nuevo: «… y, en prod, un placeholder de URL pública (`BACKEND_URL=https://<…>/<…>`), sin valor real». DEV y TEST locales (`compose/`) siguen con `http://backend:8000`. El compose PROD del broker todavía pide la URL interna: H-01 ampliado (HU-IMP-CFG-01, AIoT). Commits `9763e04` (catálogo, plantilla y `CONTRATO-PROD.md`) y `7bc8ff9` (comparación de ST-05).

**Puntos de atención para la revisión.**
- CA-2: la palabra `true` puede aparecer solo dentro de la advertencia de la fila; revisar también §4.
- CA-4: comprobar que las citas son del corte del día del PR y que no hay filas de `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT`.
- CA-5: la nota no debe dar TLS de TEST por hecho ni citar valores de puertos de host o dominios.
- CA-7: `BROKER_SERVICE_TOKEN=` sin nada después (ni comentario en la misma línea).
- Que el PR no toque `plan.md`.

---

## Metadatos

- Redactado: 2026-11-21 (America/Bogota) por el planificador, para el Líder de Implementación. Ajustado el mismo día (noche) con las decisiones del líder (ver «Decisiones del líder») y el corte nuevo (broker 0.4.1 en `main`, backend 1.4.0 en `main`).
- Fuentes: `plan.md` §1 (D1, D3), §2.2 (l. 95–143), §2.3 (l. 150), §5 (l. 299) y `analisis.md` (l. 118, 218–219, 266) de `entregas/E2_2026-11-03_M03-M04/prs/BRK-PR35_compose-prod-broker/`; `gh pr view 35 -R SerBy48/BROKER-MQTT-SGPMP` (MERGED 2026-10-19, Arekkazu); `gh pr list -R SerBy48/BROKER-MQTT-SGPMP --base main` (#64 y #67 MERGED 2026-11-22 UTC).
- `git fetch --prune` del 2026-11-21, 22:55, en BROKER-MQTT-SGPMP (`develop 2f8ea54`, `test 662e096`, `main 2181993`), sgpmp-backend (`dev 5115b83d`, `test c698c656`, `main 9655f389`) y SGMP-Integracion (`main b372c82`; las líneas citadas del catálogo no cambian desde `a910760`). `git diff --stat origin/develop origin/test -- app docker-compose.yml docker-compose.prod.yml .env.example .env.prod.example docker`: 4 archivos de `app/`, ninguno de configuración.
- Revisión: REV-01 (`/revisar`, 2026-11-21), solicitar cambios de redacción. Aplicados M-01 a M-03, m-01, m-03 a m-07 y n-01 a n-03; m-02 aplicado (decisión del líder, 2026-11-22: ST-04 paso 5b, CA-7 y CA-8).
- Broker: `app/config.py` (l. 27, 48, 65, 77–79); `app/backend/client.py:41–56`; `app/main.py:35`; `app/mqtt/publisher.py:30`; `app/services/ingest.py:312`; `app/api/dependencies.py:18–32`; `docker-compose.yml:20–21,47–48,74–75`; `docker-compose.test.yml:11–13,29–30,40–41`; `docker-compose.prod.yml:68–69,92–93,99,203–204,209–217,232–248`; `.env.example:48,56–57,67,72,85–87`; `.env.prod.example:133–134,153–154,162,180,192,203,212,215,244–246`; `docker/mosquitto-entrypoint.sh:88–94`; `docker/mosquitto.conf:16,19` (listeners 1883 y 9001); `git grep -niE api_token` en las tres ramas; `git diff --stat 6a7f2e4 origin/develop` y `origin/develop origin/main` (vacíos en los archivos citados).
- Backend: `src/shared/broker_auth.py:61` (`dev`, `test`, `main`); `Dockerfile:64,74@9655f389` (puerto 8000; l. 69 y 79 desde el PR #1223, `main@bcc3cd17`).
- Ejecución (2026-11-22): ST-01 a ST-04 sobre `origin/main 9a099e4`, con corte reverificado (broker sin cambios; backend `dev e0c5c0e4`, `main bcc3cd17`, misma línea en `broker_auth.py`). CA-2 a CA-8 y CA-10 cumplidos en local; CA-1 y CA-9 se cierran con el PR (evidencias en `evidencias/`; la tabla de citas de CA-4 está en `CA-2_a_CA-6_CA-10_catalogo.md`, no en un `CA-4_filas.md` aparte). Segunda revisión: REV-02 (2026-11-22), solicitar cambios; aplicados M-02, m-01 a m-05, n-01 a n-03 y n-05; M-01 con la salida (b), por decisión del líder (ver «Decisiones del líder», punto 8); n-04 no se aplica.
- SGMP-Integracion `@a910760`: `registros/variables/VARIABLES-ENTORNO.md` l. 41–52, 118–130, 134–204, 206–258, 260–299, 333–367; `env/.env.{dev,test,prod}.example` (paridad de nombres: `diff` vacío); `compose/docker-compose.yml:43–94,109`; `compose/compose.dev.yml:29–45`, `compose.test.yml:25–33`, `compose.prod.yml:24–30`; `docker compose config --quiet` (dev 0; test/prod 1 sin `*_IMAGE`, 0 con imágenes ficticias).
- ST-05 (2026-11-23): comparación con la lista de Dokploy del backend (Despliegue), sin valores, en `evidencias/ST-05_comparacion-dokploy.md` (`7bc8ff9`). Cambió el catálogo (`9763e04`, decisión 9). Pendiente: la lista del gateway y de Mosquitto (Dokploy de Arekkazu, AIoT); no bloquea la fusión del PR #27. Cuando llegue: completar esas filas y, si contradice el catálogo, un commit de ajuste.
- Numeración: AMB-11 indicada por el líder (`plan.md` l. 150, PR #24).
