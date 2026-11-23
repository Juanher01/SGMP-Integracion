# CA-7 y CA-8 — Plantillas y compose local (HU-IMP-AMB-11, ST-04)

Fecha: 2026-11-22. Rama de ejecución, sin commit.
Regenerada el 2026-11-23 sobre `9763e04` (decisión 9: placeholder de URL pública en `BACKEND_URL` de prod). Comandos ejecutados por el líder en Git Bash; salidas pegadas tal cual. Solo cambia el bloque de `env/.env.prod.example` (l. 100–105); el resto es igual al 2026-11-22.

```bash
$ docker compose version --short
5.7.0
```

## CA-7

```bash
$ T=$(mktemp -d); for e in dev test prod; do grep -oE "^[A-Z0-9_]+=" env/.env.$e.example | sort -u > "$T/n_$e"; done; diff "$T/n_dev" "$T/n_test" && diff "$T/n_dev" "$T/n_prod" && echo PARIDAD; rm -r "$T"
PARIDAD
```

```bash
$ grep -n -e GATEWAY_API_TOKEN -e MQTT_TLS -e BROKER_SERVICE_TOKEN -e BACKEND_URL env/.env.*.example
env/.env.dev.example:84:MQTT_TLS=false
env/.env.dev.example:101:# BACKEND_URL: base del backend para el reenvío del gateway. Local: servicio `backend` del compose.
env/.env.dev.example:102:BACKEND_URL=http://backend:8000
env/.env.dev.example:103:# BROKER_SERVICE_TOKEN: secreta; el mismo valor en el gateway y en el backend.
env/.env.dev.example:104:BROKER_SERVICE_TOKEN=
env/.env.prod.example:82:# MQTT_TLS: TLS del gateway hacia mosquitto por la red interna (en claro): false en DEV, TEST y PROD (ver catálogo).
env/.env.prod.example:83:MQTT_TLS=false
env/.env.prod.example:100:# BACKEND_URL: base del backend para el reenvío del gateway. En PROD, la URL pública del backend
env/.env.prod.example:103:BACKEND_URL=https://<dominio-publico-del-backend>/<prefijo>
env/.env.prod.example:104:# BROKER_SERVICE_TOKEN: secreta; el mismo valor en el gateway y en el backend.
env/.env.prod.example:105:BROKER_SERVICE_TOKEN=
env/.env.test.example:82:MQTT_TLS=false
env/.env.test.example:99:# BACKEND_URL: base del backend para el reenvío del gateway. Local: servicio `backend` del compose.
env/.env.test.example:100:BACKEND_URL=http://backend:8000
env/.env.test.example:101:# BROKER_SERVICE_TOKEN: secreta; el mismo valor en el gateway y en el backend.
env/.env.test.example:102:BROKER_SERVICE_TOKEN=
```

```bash
$ grep -n API_TOKEN compose/*.yml
(sin salida)
```

```bash
$ grep -n -e MQTT_ACK_REQUIERE_ID_COMANDO -e MQTT_TOPIC_RESULTADO -e BACKEND_URL -e BROKER_SERVICE_TOKEN -e BACKEND_TIMEOUT_SECONDS compose/docker-compose.yml
89:      MQTT_ACK_REQUIERE_ID_COMANDO: ${MQTT_ACK_REQUIERE_ID_COMANDO:-false}
90:      MQTT_TOPIC_RESULTADO: ${MQTT_TOPIC_RESULTADO:-resultado}
91:      BACKEND_URL: ${BACKEND_URL:-}
92:      BROKER_SERVICE_TOKEN: ${BROKER_SERVICE_TOKEN:-}
93:      BACKEND_TIMEOUT_SECONDS: ${BACKEND_TIMEOUT_SECONDS:-10}
126:      BROKER_SERVICE_TOKEN: ${BROKER_SERVICE_TOKEN:-}
```

## CA-8

```bash
$ cd compose; for e in dev test prod; do DATABASE_IMAGE=ficticia BACKEND_IMAGE=ficticia FRONTEND_IMAGE=ficticia GATEWAY_IMAGE=ficticia docker compose -f docker-compose.yml -f compose.$e.yml --env-file ../env/.env.$e.example config --quiet; echo "$e exit=$?"; echo "$e API_TOKEN: $(docker compose -f docker-compose.yml -f compose.$e.yml config --no-interpolate 2>/dev/null | grep -c API_TOKEN)"; docker compose -f docker-compose.yml -f compose.$e.yml config --no-interpolate 2>/dev/null | grep -n -e BACKEND_URL -e BROKER_SERVICE_TOKEN -e MQTT_ACK_REQUIERE -e MQTT_TOPIC_RESULTADO -e BACKEND_TIMEOUT; done
dev exit=0
dev API_TOKEN: 0
21:      - BROKER_SERVICE_TOKEN=${BROKER_SERVICE_TOKEN:-}
106:      - BACKEND_TIMEOUT_SECONDS=${BACKEND_TIMEOUT_SECONDS:-10}
107:      - BACKEND_URL=${BACKEND_URL:-}
108:      - BROKER_SERVICE_TOKEN=${BROKER_SERVICE_TOKEN:-}
111:      - MQTT_ACK_REQUIERE_ID_COMANDO=${MQTT_ACK_REQUIERE_ID_COMANDO:-false}
121:      - MQTT_TOPIC_RESULTADO=${MQTT_TOPIC_RESULTADO:-resultado}
test exit=0
test API_TOKEN: 0
14:      - BROKER_SERVICE_TOKEN=${BROKER_SERVICE_TOKEN:-}
82:      - BACKEND_TIMEOUT_SECONDS=${BACKEND_TIMEOUT_SECONDS:-10}
83:      - BACKEND_URL=${BACKEND_URL:-}
84:      - BROKER_SERVICE_TOKEN=${BROKER_SERVICE_TOKEN:-}
87:      - MQTT_ACK_REQUIERE_ID_COMANDO=${MQTT_ACK_REQUIERE_ID_COMANDO:-false}
97:      - MQTT_TOPIC_RESULTADO=${MQTT_TOPIC_RESULTADO:-resultado}
prod exit=0
prod API_TOKEN: 0
14:      - BROKER_SERVICE_TOKEN=${BROKER_SERVICE_TOKEN:-}
72:      - BACKEND_TIMEOUT_SECONDS=${BACKEND_TIMEOUT_SECONDS:-10}
73:      - BACKEND_URL=${BACKEND_URL:-}
74:      - BROKER_SERVICE_TOKEN=${BROKER_SERVICE_TOKEN:-}
77:      - MQTT_ACK_REQUIERE_ID_COMANDO=${MQTT_ACK_REQUIERE_ID_COMANDO:-false}
87:      - MQTT_TOPIC_RESULTADO=${MQTT_TOPIC_RESULTADO:-resultado}
```

Complemento (REV-03 m-03, 2026-11-23; ejecutado por el líder en Git Bash): las 5 variables de BRK-10 que no busca el grep anterior, y `MQTT_HOST`/`MQTT_PORT` (REV-02 m-05).

```bash
$ for e in dev test prod; do printf '%s ' $e; grep -cE '^(MQTT_ACK_REQUIERE_ID_COMANDO|MQTT_TOPIC_RESULTADO|BACKEND_TIMEOUT_SECONDS|MQTT_HOST|MQTT_PORT)=' env/.env.$e.example; done
dev 5
test 5
prod 5
$ grep -nE '^(MQTT_HOST|MQTT_PORT)=' env/.env.prod.example
78:MQTT_HOST=mosquitto
79:MQTT_PORT=1883
```

**Veredicto (2026-11-23):** cumplen CA-7 (con el texto de la decisión 9: placeholder de URL pública en prod, sin valor real) y CA-8 (`exit=0` también en prod con el placeholder). En cada entorno hay 0 `API_TOKEN`, las 5 variables están en el gateway y `BROKER_SERVICE_TOKEN` también está en el backend (REV-01 m-02).

