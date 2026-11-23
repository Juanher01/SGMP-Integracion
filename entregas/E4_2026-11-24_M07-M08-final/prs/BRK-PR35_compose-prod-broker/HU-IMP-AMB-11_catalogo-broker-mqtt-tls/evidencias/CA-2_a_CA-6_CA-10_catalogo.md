# CA-2 a CA-6 y CA-10 — Catálogo (HU-IMP-AMB-11, ST-02 y ST-03)

Fecha: 2026-11-22. Archivo `registros/variables/VARIABLES-ENTORNO.md` en la rama de ejecución, sin commit. Corte del CA-1.

## CA-2 (esperado: el primer comando sin salida y el segundo `3`)

```bash
$ awk '/^## 8\./{s=8} s==8 && /HU-IMP-AMB-11/{amb=1} /MQTT_TLS/ && /true/ && !/handshake/ && !amb {print NR": "$0}' $F
(sin salida)
```

```bash
$ awk '/^## 4\./{f=1} /^## 5\./{f=0} f' $F | grep -cx 'MQTT_TLS=false'
3
```

## CA-3 (esperado: el primer comando sin salida y el segundo ≥ 1)

```bash
$ awk '/^## 6\./{s=6} /^## 7\./{s=7} /^## 8\./{s=8} s==8 && /HU-IMP-AMB-11/{amb=1} /API_TOKEN/ && s!=6 && !amb {print NR": "$0}' $F
(sin salida)
```

```bash
$ awk '/^## 6\./{f=1} /^## 7\./{f=0} f' $F | grep -c 'GATEWAY_API_TOKEN'
2
```

## CA-4 (esperado: `1` en las 7 primeras, `0` en las dos de puertos de host y `**Secreta**` en el token)

```bash
$ for v in MQTT_ACK_REQUIERE_ID_COMANDO MQTT_TOPIC_RESULTADO BACKEND_URL BROKER_SERVICE_TOKEN BACKEND_TIMEOUT_SECONDS MQTT_PUERTO_PUBLICO MQTT_WS_PUERTO_PUBLICO MQTT_HOST_PORT MQTT_WS_HOST_PORT; do printf '%s ' "$v"; grep -c "^| \`$v\` |" $F; done; grep "^| \`BROKER_SERVICE_TOKEN\` |" $F | grep -o '\*\*Secreta\*\*'
MQTT_ACK_REQUIERE_ID_COMANDO 1
MQTT_TOPIC_RESULTADO 1
BACKEND_URL 1
BROKER_SERVICE_TOKEN 1
BACKEND_TIMEOUT_SECONDS 1
MQTT_PUERTO_PUBLICO 1
MQTT_WS_PUERTO_PUBLICO 1
MQTT_HOST_PORT 0
MQTT_WS_HOST_PORT 0
**Secreta**
```

Citas de cada fila, verificadas el 2026-11-22 con `git show origin/main:<archivo> | sed -n <línea>p` en el broker. En estos archivos `main@2181993` es igual a `develop@2f8ea54`.

| Variable | Cita verificada |
|---|---|
| `MQTT_ACK_REQUIERE_ID_COMANDO` | `app/config.py:65` (`bool = False`); `app/services/ingest.py:312` (l. 302 en `test`); `docker-compose.prod.yml:232` `:-false` |
| `MQTT_TOPIC_RESULTADO` | `app/config.py:48`; `app/mqtt/publisher.py:30`; `docker-compose.prod.yml:234` `:-resultado` |
| `BACKEND_URL` | `app/config.py:77`; `app/backend/client.py:41,45,56`; `app/main.py:35`; `docker-compose.prod.yml:246` `:?` |
| `BROKER_SERVICE_TOKEN` | `app/config.py:78`; `app/backend/client.py:47`; `docker-compose.prod.yml:247` `:?`; backend `src/shared/broker_auth.py:61` en `dev`, `test` y `main` |
| `BACKEND_TIMEOUT_SECONDS` | `app/config.py:79` (`10.0`); `app/backend/client.py:46`; `docker-compose.prod.yml:248` `:-10` |
| `MQTT_PUERTO_PUBLICO` | `docker/mosquitto-entrypoint.sh:88` (default `1883`; aborta sin certificados, l. 88–94); `docker-compose.prod.yml:68` `:-8883`; `docker-compose.yml:20` `:-1883` |
| `MQTT_WS_PUERTO_PUBLICO` | `docker/mosquitto-entrypoint.sh:89` (default `9001`); `docker-compose.prod.yml:69` `:-9002`; `docker-compose.yml:21` `:-9001` |

## CA-5 (esperado: la nota cubre los dos tramos, el estado por entorno y que PROD exige `MQTT_HOST_PORT`, sin puertos de host ni dominios)

```bash
$ grep -n -e 'Dos tramos MQTT' -e 'MQTT_HOST_PORT' -e 'SEG-BROKER-02' "$F" | cut -c1-80
119:| `MQTT_PORT` | Gateway / Mosquitto | Conexión | No sensible | Puerto inter
122:| `MQTT_TLS` | Gateway AIoT | Comportamiento | No sensible | TLS del **gatew
135:| `MQTT_PUERTO_PUBLICO` | Gateway / Mosquitto | Conexión | No sensible | Pu
136:| `MQTT_WS_PUERTO_PUBLICO` | Gateway / Mosquitto | Conexión | No sensible |
138:> **Dos tramos MQTT.** (1) **Dispositivos → Mosquitto**, por los puertos p
368:- **Corregido**: `MQTT_TLS` en `false` en DEV, TEST y PROD (el catálogo dec
371:- **TLS de los dispositivos en TEST**: el compose de TEST publica MQTT en cl
```

```bash
$ grep '^> \*\*Dos tramos MQTT' $F
> **Dos tramos MQTT.** (1) **Dispositivos → Mosquitto**, por los puertos publicados al host. Los listeners los fijan `MQTT_PUERTO_PUBLICO` y `MQTT_WS_PUERTO_PUBLICO`: con 8883/9002, Mosquitto publica TLS y exige `fullchain.pem`/`privkey.pem` en `./docker/certs` (sin ellos no arranca). Estado por entorno según los compose del broker (corte `develop@2f8ea54`, `test@662e096`, `main@2181993`): **DEV**, en claro; **TEST**, en claro: `docker-compose.test.yml` no pasa `MQTT_PUERTO_PUBLICO` y publica los listeners sin TLS, lo que incumple SEG-BROKER-02 (pendiente de HU-IMP-SEG-03); **PROD**, 8883/9002 con los certificados en `./docker/certs`. El compose de PROD exige `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT` (`:?`, `docker-compose.prod.yml:92–93`): su valor lo define Despliegue y no se cataloga (regla 9). (2) **Gateway → Mosquitto**, por la red interna del stack (`mosquitto:1883`; en PROD, la red `broker-interna`, `docker-compose.prod.yml:327`; en DEV y TEST, la red por defecto del compose): en claro por diseño, no sale del host. `MQTT_TLS` controla solo este tramo y queda en `false`. **Servidores.** En los entornos desplegados, Mosquitto y el gateway corren en un servidor distinto del que aloja el backend y PostgreSQL (lista de Dokploy del backend, Despliegue, 2026-11-23): el gateway llega al backend por su URL pública (`BACKEND_URL`, HTTPS) y a PostgreSQL por el puerto publicado de la base. Este último tramo se trata en Taiga #5478 (HU-IMP-CFG-05) y queda fuera del alcance de HU-IMP-AMB-11.
```

> Regenerado el 2026-11-23 sobre `9763e04`: la nota se amplió con el párrafo «Servidores» (decisión 9 de la HU). Sigue sin valores de puertos de host ni dominios (CA-5): `grep '^> \*\*Dos tramos MQTT' $F | grep -cE 'inmero|sslip|arekkazu|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|544[7-9]|188[56]'` → `0`.

## CA-6 (esperado: entrada en §8 con el corte y los 4 pendientes)

```bash
$ sed -n '/^Actualización 2026-11-22 (HU-IMP-AMB-11/,/^Estos valores/p' $F
Actualización 2026-11-22 (HU-IMP-AMB-11; corte broker `develop@2f8ea54` · `test@662e096` · `main@2181993`, BE `dev@e0c5c0e4` · `test@c698c656` · `main@bcc3cd17`):

- **Corregido**: `MQTT_TLS` en `false` en DEV, TEST y PROD (el catálogo decía `true` para PROD; con `true` el gateway queda `healthy` sin ingerir); `GATEWAY_API_TOKEN` retirada (§6) y sin traducción a `API_TOKEN` (§5); `MQTT_HOST` y `MQTT_PORT` fijados por el compose; 7 filas nuevas (BRK-10 y puertos públicos de Mosquitto) y nota «Dos tramos MQTT» en §3.
- **H-01**: el compose PROD del broker sigue con la red `sgpmp-network`, incluido el mensaje de la guarda de `BACKEND_URL` (`docker-compose.prod.yml:246`): HU-IMP-CFG-01 (propuesta, por crear).
- **D1 `BACKEND_URL`**: el valor por entorno desplegado queda pendiente con Despliegue.
- **TLS de los dispositivos en TEST**: el compose de TEST publica MQTT en claro; incumple SEG-BROKER-02 (HU-IMP-SEG-03, por crear).
- **Variables de H-04 que quedan fuera**: `MQTT_DEVICE_*`, `MQTT_ACK_TIMEOUT_SECONDS` y `MQTT_COLA_*` (sin HU).
- **Registros vivos que todavía contradicen esta actualización** (fuera del alcance de HU-IMP-AMB-11, REV-02 M-01): `registros/entornos/CONTRATO-PROD.md` (`MQTT_TLS=true` y `GATEWAY_API_TOKEN`, l. 52, 54, 75, 93 y 115), `registros/entornos/CONTRATO-TEST.md` (`GATEWAY_API_TOKEN`, l. 91, 96, 135 y 151), `runbooks/RUNBOOK-LEVANTAMIENTO-VALIDACION-SGPMP.md` (`GATEWAY_API_TOKEN`, l. 465, 915, 978 y 1046) e INC-IMP-05 de `registros/incidencias/registro.md` (el `API_TOKEN` de `compose/` lo retira esta HU; la fila sigue «detectado»). Mientras no se corrijan, manda este catálogo.

Estos valores deben completarse cuando las historias dependientes entreguen sus contratos definitivos.
```

## CA-10 (comandos de la HU; esperado: las dos filas con `mosquitto` y `1883` en los tres entornos; el segundo comando sin salida, porque en §4 `MQTT_HOST` y `MQTT_PORT` ya no aparecen como líneas sueltas de configuración externa (en el bloque PROD van con valor, `MQTT_HOST=mosquitto` y `MQTT_PORT=1883`, REV-02 m-05); y `0` de «sujeto a configuración TLS»)

```bash
$ grep -nE '^[|] `MQTT_(HOST|PORT)` [|]' "$F" 
118:| `MQTT_HOST` | Gateway / Mosquitto | Conexión | Interna | Host del broker MQTT para el gateway: `mosquitto` en DEV, TEST y PROD (servicio de la red interna del stack). Lo fijan los compose del broker: DEV `docker-compose.yml:77@2f8ea54`, TEST `docker-compose.test.yml:43@662e096` y PROD `docker-compose.prod.yml:203@2181993`. |
119:| `MQTT_PORT` | Gateway / Mosquitto | Conexión | No sensible | Puerto interno de Mosquitto para el gateway: `1883`, en claro, en DEV, TEST y PROD. Lo fijan los compose del broker: DEV `docker-compose.yml:83@2f8ea54`, TEST `docker-compose.test.yml:46@662e096` y PROD `docker-compose.prod.yml:203–204@2181993`. No es `MQTT_HOST_PORT`, el puerto publicado al host, que define Despliegue (nota «Dos tramos MQTT»). |
```

```bash
$ awk '/^## 4\./{f=1} /^## 5\./{f=0} f' "$F" | grep -nxE 'MQTT_(HOST|PORT)'
(sin salida)
```

```bash
$ grep -c 'sujeto a configuración TLS' $F
0
```

**Veredicto:** cumplen CA-2, CA-3, CA-4, CA-5, CA-6 y CA-10.

