# HU-IMP-SEG-03 — Activar TLS del broker MQTT en TEST y preparar PROD (SEG-BROKER-02 / TC-M09-253)

> Estado: borrador para Taiga · Redactado: 2026-10-12 · Actualizado: 2026-10-13 contra el corte [`registros/entornos/corte-2026-10-13.md`](../../registros/entornos/corte-2026-10-13.md) · Fuente: [BROKER-MQTT-SGPMP PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19)

## Para copiar en Taiga — Descripción de la HU

**Rama:** documentación en `SGMP-Integracion` (`docs/seg-broker-02-tls` → PR a `main`); en el broker, solo si ST-02 lo confirma: `fix/seg-broker-02-compose-test` → PR a `test` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Directriz de seguridad — [BROKER-MQTT-SGPMP PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19) "Lote QA G127: anti-replay del ACK, TLS obligatorio hacia afuera y RFC de credencial por dispositivo" · Códigos `SEG-BROKER-02`, `TC-M09-253` · Autor: Arekkazu. Incidencia relacionada: INC-BRK-01 (MQTT en texto plano publicado al host mientras Dokploy no fije `MQTT_PUERTO_PUBLICO=8883`).

**Situación actual.** Corte del 2026-10-13 (`git fetch --prune` a las 10:59:47 -0500). Hashes del broker: `develop@44e29b6`, `test@7cbdb3f`, `main@cebd430` (release 0.3.0). El soporte TLS ya está en las tres ramas, incluida `main`: no hace falta pedir la promoción.

| Rama del broker | Soporte TLS (`741c065`) y PR #19 (`bd1910f`) | ACL dynamic-security (`94f0387`, SEG-BROKER-03) | TLS hacia afuera activo por defecto en el código | Evidencia |
|---|---|---|---|---|
| develop `44e29b6` | ✅ | ✅ | ❌ `MQTT_PUERTO_PUBLICO=1883`, mapeo 8883 comentado | Corte §2.5–§2.6; `git merge-base --is-ancestor bd1910f 44e29b6` → INCLUIDO |
| test `7cbdb3f` | ✅ | ✅ | ❌ ídem | ídem con `7cbdb3f` |
| main `cebd430` | ✅ | ✅ | ❌ ídem | ídem con `cebd430` |

`docker-compose.yml`, `.env.example` y `docker/mosquitto-entrypoint.sh` son idénticos en las tres ramas (blobs `af01e7c`, `a1c9ef3`, `97d599c`). En ellos: `.env.example` l. 48 `MQTT_TLS=false` (cliente del gateway hacia Mosquitto interno, no el listener hacia afuera), l. 56–57 `MQTT_PUERTO_PUBLICO=1883` y `MQTT_WS_PUERTO_PUBLICO=9001`, l. 70 `MQTT_ACK_REQUIERE_ID_COMANDO=false`; `docker-compose.yml` l. 47–48 publica `${MQTT_HOST_PORT:-1884}:${MQTT_PUERTO_PUBLICO:-1883}`, l. 53–54 dejan comentados los mapeos 8883/9002 y l. 60 monta `./docker/certs`. Con `MQTT_PUERTO_PUBLICO=8883` y `MQTT_WS_PUERTO_PUBLICO=9002`, el puerto de host de siempre pasa a atender solo TLS; si faltan `fullchain.pem` o `privkey.pem`, el broker no arranca (entrypoint l. 93–95).

**Hallazgo nuevo en `test`.** La rama `test` (`7cbdb3f`) tiene además `docker-compose.test.yml` (último cambio `d5b59ef`, 2026-09-08), que **no** sirve para TLS: publica fijo `${MQTT_HOST_PORT:-1885}:1883` y `${MQTT_WS_HOST_PORT:-9002}:9001`, no monta `./docker/certs` ni usa `MQTT_PUERTO_PUBLICO`, y pide `MQTT_USERNAME`/`MQTT_PASSWORD` del esquema anterior a dynamic-security. No existe en `develop` ni en `main`. Si Dokploy despliega TEST con ese archivo, cambiar las variables no activa TLS. El corte no dice qué archivo usa Dokploy (Despliegue).

Que TLS no esté activo en ningún entorno depende de los valores cargados en Dokploy, que este corte no lee: es `NO VERIFICABLE` por código.

**Descripción.** Activar TLS en el MQTT de TEST con evidencia y dejar listo el plan de PROD, cerrando INC-BRK-01 en TEST. A Implementación le corresponde el catálogo y la ficha de variables, el archivo compose que usa cada entorno, la coordinación entre Despliegue (certificados, variables en Dokploy), AIoT (clientes) y Pruebas, y la verificación. No se modifica código del broker.

**Alcance.** Variables `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO` y `MQTT_ACK_REQUIERE_ID_COMANDO`; archivo compose de TEST; montaje de certificados; plan de activación; verificación TLS; registros. · **Fuera de alcance:** firmware o Edge y devolución de `id_comando` en el ACK (AIoT); emisión y renovación de certificados, puertos de host y valores en Dokploy (Despliegue); credencial por dispositivo, TC-M09-250/251 (AIoT).

**Criterios de aceptación.**
1. CA-1 El catálogo de variables y una ficha para Despliegue incluyen `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO` y `MQTT_ACK_REQUIERE_ID_COMANDO` con su valor no sensible por entorno (DEV 1883/9001/`false`; TEST y PROD 8883/9002, y `true` en el ACK cuando AIoT lo confirme), el requisito de certificados en `docker/certs/`, y una nota que aclare que `MQTT_TLS` es el TLS del gateway hacia Mosquitto por la red interna (`app/config.py` l. 27, `MQTT_PORT: 1883`) y se mantiene en `false` en todos los entornos.
2. CA-2 Despliegue confirma por escrito qué archivo compose usa Dokploy para el broker en TEST y en PROD. Si TEST usa `docker-compose.test.yml`, existe un PR a `test` del broker que lo alinea con `docker-compose.yml` (certificados, `MQTT_PUERTO_PUBLICO`, dynamic-security) o lo elimina, aprobado por AIoT.
3. CA-3 Existe un plan de activación para TEST acordado con Despliegue, AIoT y Pruebas: quién provee los certificados y cómo se montan, fecha y hora, clientes afectados y cómo revertir.
4. CA-4 En TEST, el puerto MQTT de host negocia TLS y presenta un certificado válido y vigente.
5. CA-5 En TEST, una conexión MQTT en texto plano desde fuera al puerto de host **no** recibe CONNACK (cierra INC-BRK-01 en TEST).
6. CA-6 En TEST, el gateway sigue operando: `/broker-sigab-test/v1/healthz` responde `{"status":"ok"}` y un comando del backend recibe su ACK.
7. CA-7 El plan de PROD (archivo compose, variables, certificados y clientes) queda documentado en `registros/entornos/`.
8. CA-8 `registros/seguridad/registro-SEG.md` refleja SEG-BROKER-02 por rama y por entorno, y `registros/incidencias/registro.md` refleja INC-BRK-01 con su estado en TEST.
9. CA-9 La HU y su evidencia citan la fecha de corte (`git fetch --prune` 2026-10-13 10:59:47 -0500) y los hashes `develop@44e29b6`, `test@7cbdb3f`, `main@cebd430`; antes de abrir cualquier PR, de la activación en TEST y del cierre se repite el `fetch` y, si alguna rama avanzó, se rehacen las comprobaciones de la Situación actual sobre el hash nuevo.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | Revisión de `registros/variables/VARIABLES-ENTORNO.md` y `registros/variables/fichas/HU-IMP-SEG-03.md` contra `git -C BROKER-MQTT-SGPMP show <hash>:.env.example` | Las 3 variables con su valor por entorno y la nota sobre `MQTT_TLS`, sin secretos | Commit |
| CA-2 | Confirmación escrita de Despliegue; si aplica, `gh pr view <n> -R SerBy48/BROKER-MQTT-SGPMP --json state,baseRefName` y `git -C BROKER-MQTT-SGPMP show origin/test:docker-compose.test.yml \| grep -nE 'certs\|MQTT_PUERTO_PUBLICO'` | Archivo identificado; si es `docker-compose.test.yml`, PR `MERGED` y el archivo monta `./docker/certs` y usa `MQTT_PUERTO_PUBLICO` (o ya no existe) | Captura o enlace a la confirmación; enlace al PR |
| CA-3 | Revisión de `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/plan-activacion.md` y de la confirmación de cada equipo | Plan con responsables, fecha y reversión | Enlaces o capturas |
| CA-4 | `openssl s_client -connect <host-mqtt-test>:<puerto-host-test> -servername <host-mqtt-test> </dev/null 2>/dev/null \| openssl x509 -noout -subject -issuer -dates` | Certificado con el host correcto y fechas vigentes | Salida |
| CA-5 | `mosquitto_sub -h <host-mqtt-test> -p <puerto-host-test> -u <usuario-de-prueba> -P "$MQTT_PASS" -t 'sgpmp/#' -C 1 -W 5` (texto plano; la contraseña sale de una variable de la sesión y nunca se escribe en la evidencia) | Error de conexión o de protocolo, sin mensajes | Salida sin credenciales |
| CA-6 | `curl -sS https://api.inmero.co/broker-sigab-test/v1/healthz` y un comando de prueba desde TEST coordinado con Pruebas | `{"status":"ok"}` y ACK recibido | Salidas o capturas |
| CA-7 | Lectura del documento en `registros/entornos/` | Plan de PROD con compose, variables, certificados, clientes y reversión | Commit |
| CA-8 | Lectura de los dos registros | Estado por rama y entorno; INC-BRK-01 actualizado | Commit |
| CA-9 | `git -C BROKER-MQTT-SGPMP fetch --prune origin && git -C BROKER-MQTT-SGPMP rev-parse --short origin/develop origin/test origin/main` | Iguales al corte, o la diferencia anotada y reverificada | Salida con fecha y hora |

**Definición de terminado.**
- [ ] CA-1 a CA-9 con evidencia.
- [ ] Si hubo PR al broker (CA-2): aprobado y fusionado por AIoT.
- [ ] PR de documentación en `SGMP-Integracion` aprobado por el Líder de Implementación.
- [ ] Ningún secreto (certificados, llaves, contraseñas) en documentos, issues ni chats.
- [ ] Equipos afectados notificados antes y después de la activación.

**Dependencias y aprobaciones.** Despliegue: archivo compose de cada entorno, certificados, variables en Dokploy, puertos de host y redespliegue. AIoT: aprueba el PR a `test` del broker si hace falta, clientes Edge compatibles con TLS y `MQTT_ACK_REQUIERE_ID_COMANDO=true` cuando el firmware devuelva el id. Pruebas: ventana de activación en TEST.

**Riesgos.** (1) Activar TLS desconecta a los clientes que aún usan texto plano. Si hace falta convivencia, se habilitan los mapeos `MQTT_TLS_HOST_PORT`/`MQTT_WSS_HOST_PORT` (comentados en `docker-compose.yml` l. 53–54), con puertos libres que asigne Despliegue (en el host, el 8883 lo ocupa EMQX de otro proyecto). (2) Un certificado vencido o un montaje mal hecho impide arrancar el broker; la reversión es volver a `1883/9001` en las variables. (3) Si TEST usa `docker-compose.test.yml` y se cambian las variables sin el PR de CA-2, TLS no se activa y no hay error visible: lo detecta CA-4. (4) WebSocket de TEST figura en el host 9002, que puede confundirse con el listener TLS interno 9002; hay que aclararlo en el plan.

**Referencias.** PR #19 · commits `741c065`, `bd1910f`, `94f0387` · `docker/certs/README.md`, `docker-compose.yml` y `docker-compose.test.yml` del broker · corte `registros/entornos/corte-2026-10-13.md` §2.4–§2.6 · skills `seguridad-analisis`, `variables-entorno`, `compose-entornos`, `verificacion` §8.

## Para copiar en Taiga — Subtareas

### ST-01 actualizar el catálogo y la ficha de variables del broker
**Objetivo.** Cumplir CA-1.
**Pasos.**
1. Leer `.env.example` y `docker-compose.yml` en `44e29b6`, `7cbdb3f` y `cebd430` (`git -C BROKER-MQTT-SGPMP show <hash>:<archivo>`).
2. Agregar o actualizar las 3 variables en `registros/variables/VARIABLES-ENTORNO.md`, con la nota de que `MQTT_TLS` (TLS del gateway hacia Mosquitto interno) se queda en `false`.
3. Redactar `registros/variables/fichas/HU-IMP-SEG-03.md` para Despliegue, con el requisito de `fullchain.pem` y `privkey.pem` en `docker/certs/`.
**Entregable.** Catálogo y ficha.
**Verificación.** CA-1.
**Estimación.** 2 h

### ST-02 confirmar el compose de TEST y PROD y, si hace falta, alinear docker-compose.test.yml
**Objetivo.** Cumplir CA-2.
**Pasos.**
1. Preguntar a Despliegue qué archivo compose usa Dokploy para el broker en TEST y en PROD; guardar la respuesta.
2. Si TEST usa `docker-compose.yml`: registrar la confirmación y cerrar la subtarea.
3. Si TEST usa `docker-compose.test.yml`: reverificar el corte (CA-9), crear `fix/seg-broker-02-compose-test` desde `origin/test`, dejar el servicio `mosquitto` igual al de `docker-compose.yml` (variables, `MQTT_PUERTO_PUBLICO`, montaje de `./docker/certs`, sin `MQTT_USERNAME`/`MQTT_PASSWORD`) conservando los puertos de host por defecto de TEST (1885/9002), validar con `docker compose -f docker-compose.test.yml --env-file .env.example config --quiet` y abrir el PR a `test` para AIoT. Alternativa a proponer en el PR: eliminar el archivo si Despliegue puede usar `docker-compose.yml`.
**Entregable.** Confirmación de Despliegue y, si aplica, PR a `test` del broker.
**Verificación.** CA-2.
**Estimación.** 3 h (1 h si no hace falta el PR)

### ST-03 acordar el plan de activación de TLS en TEST
**Objetivo.** Cumplir CA-3.
**Pasos.**
1. Inventariar con AIoT y Pruebas los clientes que se conectan al MQTT de TEST y si ya soportan TLS.
2. Preguntar a Despliegue cómo montará los certificados en Dokploy y quién los renueva.
3. Redactar `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/plan-activacion.md`: precondiciones (incluido el resultado de ST-02), pasos, fecha y hora, verificación y reversión.
4. Obtener la confirmación de cada equipo.
**Entregable.** Plan acordado.
**Verificación.** CA-3.
**Estimación.** 3 h

### ST-04 verificar la activación en TEST
**Objetivo.** Cumplir CA-4, CA-5 y CA-6.
**Pasos.**
1. Reverificar el corte (CA-9). Cuando Despliegue active TLS, ejecutar las pruebas de CA-4, CA-5 y CA-6.
2. Guardar las salidas sin credenciales en `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/ca4-ca6.md`.
3. Si algo falla, aplicar la reversión del plan y abrir un triage.
**Entregable.** Evidencias.
**Verificación.** CA-4, CA-5 y CA-6.
**Estimación.** 2 h

### ST-05 solicitar la promoción del soporte TLS a main — ✅ cerrar
**Objetivo.** PR #19 y el soporte TLS en `main` del broker.
**Entregable.** Ninguno de Implementación: llegó a `main` por promoción (release 0.3.0). No se pidió a AIoT ni se hizo PR dirigido.
**Verificación.** Corte 2026-10-13 §2.5: `git -C BROKER-MQTT-SGPMP merge-base --is-ancestor origin/feature/seg-broker-02-tls-mosquitto cebd430` → SI; `git -C BROKER-MQTT-SGPMP merge-base --is-ancestor bd1910f cebd430` → INCLUIDO.
**Estado.** Se crea como cerrada.

### ST-06 documentar el plan de PROD
**Objetivo.** Cumplir CA-7.
**Pasos.**
1. Con la respuesta de ST-02 sobre el compose de PROD, documentar en `registros/entornos/` las variables, los certificados, los clientes y la reversión para PROD.
2. Anotar que el código de `main` (`cebd430`) ya soporta TLS y que la activación depende de Dokploy.
**Entregable.** Documento del plan de PROD.
**Verificación.** CA-7.
**Estimación.** 1 h

### ST-07 actualizar los registros de seguridad e incidencias
**Objetivo.** Cumplir CA-8 y CA-9.
**Pasos.**
1. Reverificar el corte (CA-9).
2. Actualizar SEG-BROKER-02 en `registros/seguridad/registro-SEG.md` por rama y entorno.
3. Actualizar INC-BRK-01 en `registros/incidencias/registro.md` con el resultado de CA-5.
4. Abrir el PR de documentación en `SGMP-Integracion`.
**Entregable.** Registros actualizados y PR.
**Verificación.** CA-8 y CA-9.
**Estimación.** 1 h

## Notas para el líder (no copiar a Taiga)

- **Plazo sugerido:** 1 a 2 semanas, porque depende de tres equipos. Unas 12 h de trabajo de Juan Hernando (10 h si ST-02 no requiere PR).
- **Preguntas abiertas:**
  1. **Nueva:** ¿qué compose usa Dokploy para el broker de TEST? Si es `docker-compose.test.yml`, TLS no se puede activar sin el PR de ST-02, y además ese archivo usa el esquema anterior (`MQTT_USERNAME`/`MQTT_PASSWORD`), lo que pondría en duda que SEG-BROKER-03 esté vigente en TEST. Si prefieres que la alineación del compose sea una HU `CFG` aparte, saco ST-02 y CA-2 de esta.
  2. El PR #19 no tiene asignados. ¿Análisis espera que Implementación lidere la activación o solo que acompañe a AIoT? Conviene confirmarlo con Miguel.
  3. ¿Cuál es el host público y el puerto de host del MQTT de TEST? Se necesitan para CA-4 y CA-5 (el valor por defecto de `docker-compose.test.yml` es 1885; el de `docker-compose.yml` es 1884; el real lo fija Despliegue).
  4. ¿Hay dispositivos reales conectados a TEST que no soporten TLS?
- **INC-BRK-01:** ya figura en `registros/incidencias/registro.md` (alta del 2026-10-13, estado `detectado`, responsable Despliegue + AIoT). Su nota de detección cita `MQTT_TLS=false` como parte del síntoma; en el código, `MQTT_TLS` es el TLS del gateway hacia Mosquitto interno (`app/config.py` l. 27), no el listener hacia afuera. Conviene corregir esa nota para que nadie lo ponga en `true` en Dokploy (rompería la conexión gateway → Mosquitto en 1883). No lo toqué: está fuera de lo que me pediste modificar.
- **Puntos de atención en la revisión:** que ninguna evidencia incluya credenciales MQTT ni el contenido de los certificados; que el plan tenga una reversión probada; que el PR de ST-02, si existe, no cambie puertos de host por su cuenta.
- **Nota de alcance:** los puertos de host los decide Despliegue; esta HU no elige ninguno.

### Cambios respecto a la versión anterior (2026-10-12)

- **Situación actual:** `main` pasa de ❌ (36 commits detrás de `develop`) a ✅ en soporte TLS, PR #19 y dynamic-security (corte §2.5–§2.6). Se citan los blobs idénticos de `docker-compose.yml`, `.env.example` y el entrypoint en las tres ramas, con líneas. Se agrega el hallazgo de `docker-compose.test.yml` en `test` y la relación con INC-BRK-01.
- **Rama:** se agrega la rama condicional `fix/seg-broker-02-compose-test` → `test` del broker, y la de documentación en `SGMP-Integracion`.
- **CA:** el CA-6 anterior ("promoción del PR #19 a `main` solicitada a AIoT y plan de PROD") pierde la parte de la promoción, ya cumplida, y queda como CA-7 (plan de PROD). Nuevo CA-2 (compose real de TEST/PROD). CA-1 suma una nota sobre `MQTT_TLS`: es el TLS del gateway hacia Mosquitto interno (`app/config.py`) y no debe activarse; el corte lo usaba como indicador de TLS, lo que podía inducir a ponerlo en `true` y romper el gateway. CA-4 y CA-5 dejan de suponer el puerto 1885 y usan el puerto de host que confirme Despliegue. CA-8 suma INC-BRK-01. Nuevo CA-9 de fecha de corte. Renumeración: antiguos CA-2…CA-5 → CA-3…CA-6; CA-7 → CA-8.
- **Subtareas:** la antigua ST-04 (solicitar a AIoT la promoción `develop → main` o un PR dirigido con el PR #19) se divide: la promoción queda como ST-05 cerrada sin ejecutar, porque llegó por el release 0.3.0; el plan de PROD queda como ST-06. Nueva ST-02 (compose de TEST). ST-07 suma la incidencia. Trabajo: de 9 h a unas 12 h, por la nueva ST-02.

---
Redactado: 2026-10-12 · Actualizado: 2026-10-13.
Fuentes consultadas (2026-10-13, sin nuevo fetch): corte `registros/entornos/corte-2026-10-13.md` §2.4–§2.6; BROKER-MQTT-SGPMP `develop@44e29b6`, `test@7cbdb3f`, `main@cebd430` (`git merge-base --is-ancestor 869a315|741c065|bd1910f|94f0387 <hash>`, `git show <hash>:.env.example|docker-compose.yml`, `git rev-parse <hash>:<archivo>`, `git ls-tree <hash>`, `git show 7cbdb3f:docker-compose.test.yml`, `git log -3 7cbdb3f -- docker-compose.test.yml`); `registros/seguridad/registro-SEG.md`; `registros/incidencias/registro.md`; PR #19. Versión anterior: `develop@499b456`, `test@7cbdb3f`, `main@b6e8e28` (2026-10-12).
