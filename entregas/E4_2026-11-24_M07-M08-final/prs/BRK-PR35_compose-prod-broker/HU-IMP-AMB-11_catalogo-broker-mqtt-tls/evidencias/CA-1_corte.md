# CA-1 — Corte (HU-IMP-AMB-11, ST-01)

Fecha: 2026-11-22 (America/Bogota). Rama SGMP-Integracion `docs/amb-11-ejecucion-catalogo-broker`, rebasada sobre `origin/main 9a099e4` (PR #25 y #26 fusionados).

```bash
$ for b in develop test main; do git -C $B log -1 --format="broker $b %h %ad" --date=short origin/$b; done
broker develop 2f8ea54 2026-11-22
broker test 662e096 2026-11-01
broker main 2181993 2026-11-22
```

```bash
$ for b in dev test main; do git -C $BE log -1 --format="backend $b %h %ad" --date=short origin/$b; done
backend dev e0c5c0e4 2026-11-22
backend test c698c656 2026-11-21
backend main bcc3cd17 2026-11-22
```

```bash
$ git log -1 --format="SGMP-Integracion main %h" origin/main
SGMP-Integracion main 9a099e4
```

Broker: mismos hashes que la HU (`develop 2f8ea54`, `test 662e096`, `main 2181993`); el diff de configuración desde el corte de la HU sale vacío:

```bash
$ for p in '2f8ea54 origin/develop' '662e096 origin/test' '2181993 origin/main'; do echo \"[$p]\"; git -C $B diff --stat $p -- app 'docker-compose*.yml' '.env*.example' docker; done
"[2f8ea54 origin/develop]"
"[662e096 origin/test]"
"[2181993 origin/main]"
```

Backend: avanzó (`dev 5115b83d → e0c5c0e4`; `main 9655f389 → bcc3cd17`, release 1.4.3). La cita de `broker_auth.py` sigue en la misma línea:

```bash
$ for b in dev test main; do git -C $BE grep -n "_exigir_token(authorization, \"BROKER_SERVICE_TOKEN\"" origin/$b -- src/shared/broker_auth.py; done
origin/dev:src/shared/broker_auth.py:61:    _exigir_token(authorization, "BROKER_SERVICE_TOKEN", "con el broker MQTT", "del broker")
origin/test:src/shared/broker_auth.py:61:    _exigir_token(authorization, "BROKER_SERVICE_TOKEN", "con el broker MQTT", "del broker")
origin/main:src/shared/broker_auth.py:61:    _exigir_token(authorization, "BROKER_SERVICE_TOKEN", "con el broker MQTT", "del broker")
```

Cambios de infraestructura desde `9655f389`: solo el Dockerfile, por el PR #1223 (crea `/app/storage/modelos`). Mueve el puerto 8000 a las l. 69 y 79; las releases 1.4.2 y 1.4.3 no tocan infraestructura:

```bash
$ git -C $BE log --oneline 9655f389..origin/main -- Dockerfile "docker-compose*.yml" ".env*.example" .dockerignore; git -C $BE show origin/main:Dockerfile | grep -nE "EXPOSE|--port"
21ab30e5 fix(rf69-mod4): crear el almacenamiento de modelos del usuario 1000 en la imagen
69:EXPOSE 8000
79:CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

`API_TOKEN` no se usa como variable en ninguna de las tres ramas del broker. Se cuentan las líneas que no son `require_api_token`:

```bash
$ for b in develop test main; do echo "$b: $(git -C $B grep -niE api_token origin/$b -- app | grep -vc require_api_token)"; done
develop: 0
test: 0
main: 0
```

Catálogo: cambió desde `a910760` (PR #24), pero las líneas citadas por la HU no se movieron:

```bash
$ git diff --stat a910760 9a099e4 -- $F env compose; for n in 118 119 120 123 130 185; do printf "%s: " $n; git show 9a099e4:$F | sed -n "${n}p" | cut -c1-60; done
 registros/variables/VARIABLES-ENTORNO.md | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)
118: | `GATEWAY_API_TOKEN` | Gateway AIoT | Autenticación / Segu
119: | `MQTT_HOST` | Gateway / Mosquitto | Conexión | Interna | 
120: | `MQTT_PORT` | Gateway / Mosquitto | Conexión | No sensibl
123: | `MQTT_TLS` | Gateway / Mosquitto | Autenticación / Seguri
130: | `MQTT_TOPIC_STATUS` | Gateway / Mosquitto | AIoT / Analít
185: MQTT_TLS=true
```

**Veredicto:** cumple al corte de la ejecución. Las citas del broker siguen vigentes. Las del backend pasan a `dev@e0c5c0e4` y `main@bcc3cd17`, en la misma línea. Se repite el día del PR.

