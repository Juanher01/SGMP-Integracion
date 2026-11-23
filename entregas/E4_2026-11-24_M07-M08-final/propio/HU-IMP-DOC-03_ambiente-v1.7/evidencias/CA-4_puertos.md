# HU-IMP-DOC-03 — Puertos citados (CA-4)

Corte: `evidencias/CA-1_corte.txt` (git fetch 2026-11-23 11:38:28 -0500).
Comando: `git show origin/<rama>:<archivo> | grep -n -A3 ports` (y `expose`, `MQTT_*`, `BACKEND_URL`, `networks`).
Convención: `REPO rama@commit archivo:líneas`. BE = sgpmp-backend · FE = SGPMP-FRONT-END-PWA · BRK = BROKER-MQTT-SGPMP.

## Servidor del backend

| Componente | Amb. | Puerto (host → contenedor) | Fuente |
|---|---|---|---|
| PostgreSQL | DEV | `${DB_PORT:-5447}:5432`, publicado | BE dev@77e0d772 docker-compose.yml:40-41 |
| PostgreSQL | TEST | `${DB_PORT:-5448}:5432`, publicado | BE test@1ee56516 docker-compose.test.yml:29-30 |
| PostgreSQL | PROD | `${DB_PORT:-5449}:5432`, publicado | BE main@e3b07ae6 docker-compose.prod.yml:73-74 |
| Backend (FastAPI) | DEV | sin puerto de host · `expose: 8000` (Traefik) | BE dev@77e0d772 docker-compose.yml:112-113 |
| Backend (FastAPI) | TEST | sin puerto de host · `expose: 8000` | BE test@1ee56516 docker-compose.test.yml:87-88 |
| Backend (FastAPI) | PROD | sin puerto de host · `expose: 8000` | BE main@e3b07ae6 docker-compose.prod.yml:197-199 |
| Red del stack | PROD | `dokploy-network` (external) | BE main@e3b07ae6 docker-compose.prod.yml:251-252 |
| Frontend (nginx) | DEV | sin puerto de host · `expose: 80` | FE dev@1a8aad03 docker-compose.yml:18-19 · Dockerfile:56 |
| Frontend (nginx) | TEST | sin puerto de host · `expose: 80` | FE test@6ebc1faa docker-compose.test.yml:20-21 · Dockerfile:56 |
| Frontend (nginx) | PROD | sin puerto de host · `expose: 80` | FE main@ed446c62 docker-compose.yml:18-19 · Dockerfile:56 |
| Frontend subruta | las 3 | `VITE_BASE_PATH` → `subruta.conf` (`location ^~ <base>`) | FE dev@1a8aad03 / test@6ebc1faa / main@ed446c62 Dockerfile:13, 45-54 (idéntico) |

## Servidor del broker

| Componente | Amb. | Puerto (host → contenedor) | Fuente |
|---|---|---|---|
| Mosquitto MQTT | DEV | `${MQTT_HOST_PORT:-1884}:${MQTT_PUERTO_PUBLICO:-1883}`, en claro | BRK develop@2f8ea54 docker-compose.yml:46-47 |
| Mosquitto WS | DEV | `${MQTT_WS_HOST_PORT:-9001}:${MQTT_WS_PUERTO_PUBLICO:-9001}`, en claro | BRK develop@2f8ea54 docker-compose.yml:48 |
| Mosquitto TLS/WSS | DEV | 8883 y 9002 comentados (no publicados) | BRK develop@2f8ea54 docker-compose.yml:53-54 |
| Mosquitto MQTT | TEST | `${MQTT_HOST_PORT:-1885}:1883`, en claro | BRK test@662e096 docker-compose.test.yml:28-29 |
| Mosquitto WS | TEST | `${MQTT_WS_HOST_PORT:-9002}:9001`, en claro | BRK test@662e096 docker-compose.test.yml:30 |
| Mosquitto MQTTS | PROD | `${MQTT_HOST_PORT:?…}:${MQTT_PUERTO_PUBLICO:-8883}` (host sin valor por defecto) | BRK main@2181993 docker-compose.prod.yml:91-92 |
| Mosquitto WSS | PROD | `${MQTT_WS_HOST_PORT:?…}:${MQTT_WS_PUERTO_PUBLICO:-9002}` (host sin valor por defecto) | BRK main@2181993 docker-compose.prod.yml:93 |
| Gateway → Mosquitto | DEV | `MQTT_HOST: mosquitto` · `MQTT_PORT: 1883` | BRK develop@2f8ea54 docker-compose.yml:77, 83 |
| Gateway → Mosquitto | TEST | `MQTT_HOST: mosquitto` · `MQTT_PORT: 1883` | BRK test@662e096 docker-compose.test.yml:43, 46 |
| Gateway → Mosquitto | PROD | `mosquitto:1883` · `MQTT_TLS=${MQTT_TLS:-false}` | BRK main@2181993 docker-compose.prod.yml:203-204, 217 |
| Gateway HTTP | DEV | sin puerto de host · `expose: 8000` | BRK develop@2f8ea54 docker-compose.yml:86-87 |
| Gateway HTTP | TEST | sin puerto de host · `expose: 8000` | BRK test@662e096 docker-compose.test.yml:49-50 |
| Gateway HTTP | PROD | sin puerto de host · `expose: 8000` | BRK main@2181993 docker-compose.prod.yml:256-257 |
| Gateway → PostgreSQL | DEV/TEST | `DATABASE_URL` por `.env` (plantilla: host y puerto publicado 5447) | BRK develop@2f8ea54 y test@662e096 .env.example:12 |
| Gateway → PostgreSQL | PROD | `${DB_HOST}:5432` por la red `sgpmp-network` (external) | BRK main@2181993 docker-compose.prod.yml:195, 333-334 |
| Gateway → Backend | DEV/TEST | `BACKEND_URL` por `.env` (plantilla: `http://localhost:8000`) | BRK develop@2f8ea54 y test@662e096 .env.example:85 |
| Gateway → Backend | PROD | `BACKEND_URL` obligatoria, descrita como URL interna en `sgpmp-network` | BRK main@2181993 docker-compose.prod.yml:246 |

## Puertos que el código no fija

| Dato | Estado | Hallazgo |
|---|---|---|
| Puertos de host de Mosquitto en PROD | Por definir en el despliegue; el compose los exige sin valor por defecto (`MQTT_HOST_PORT`, `MQTT_WS_HOST_PORT`) | Hallazgo DOC03-H-06 (Despliegue / AIoT) |
| Valores de `DATABASE_URL` y `BACKEND_URL` del gateway en DEV/TEST | Se cargan desde `.env` en Dokploy: valor propio (Dokploy) | — |
