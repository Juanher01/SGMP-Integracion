# HU-IMP-SEG-03 — Activar TLS del broker MQTT en TEST y preparar PROD (SEG-BROKER-02 / TC-M09-253)

> Estado: borrador para Taiga · Redactado: 2026-10-12 · Fuente: [BROKER-MQTT-SGPMP PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19)

## Para copiar en Taiga — Descripción de la HU

**Rama:** sin cambios de código previstos en el repo de AIoT; documentación en `SGMP-Integracion` (`historias/HU-IMP-SEG-03_tls-broker-test-prod/`) · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Directriz de seguridad — [BROKER-MQTT-SGPMP PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19) "Lote QA G127: anti-replay del ACK, TLS obligatorio hacia afuera y RFC de credencial por dispositivo" · Códigos `SEG-BROKER-02`, `TC-M09-253` · Autor: Arekkazu.

**Situación actual.** Verificado con git el 2026-10-12.

| Rama del broker | Soporte TLS y ACK anti-replay (PR #19) | Evidencia |
|---|---|---|
| develop | ✅ fusionado | `merge-base --is-ancestor` |
| test | ✅ fusionado (`7cbdb3f`, 2026-10-09) | ídem |
| main | ❌ (36 commits detrás de `develop`) | ídem |

El código ya permite TLS, pero **no está activo en ningún entorno** mientras no se definan las variables y se monten los certificados. Con `MQTT_PUERTO_PUBLICO=8883` y `MQTT_WS_PUERTO_PUBLICO=9002`, los puertos de host de siempre (1884/1885) pasan a atender solo TLS: no cambia el firewall, pero **todo cliente externo** (Edge, dispositivos, herramientas de Pruebas) debe conectarse con TLS desde ese momento. Si faltan `fullchain.pem` o `privkey.pem`, el broker no arranca.

**Descripción.** Coordinar y verificar la activación de TLS en TEST y dejar lista la de PROD. A Implementación le corresponde el catálogo y la ficha de variables, la coordinación entre Despliegue (certificados, variables en Dokploy), AIoT (clientes y promoción a `main`) y Pruebas, y la verificación con evidencia. No se modifica código del broker.

**Alcance.** Variables `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO` y `MQTT_ACK_REQUIERE_ID_COMANDO`; montaje de certificados; plan de activación; verificación TLS; registro. · **Fuera de alcance:** firmware o Edge y devolución de `id_comando` en el ACK (AIoT); emisión y renovación de certificados y valores en Dokploy (Despliegue); credencial por dispositivo, TC-M09-250/251 (RFC de AIoT).

**Criterios de aceptación.**
1. CA-1 El catálogo de variables y una ficha para Despliegue incluyen `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO` y `MQTT_ACK_REQUIERE_ID_COMANDO` con su valor no sensible por entorno (DEV 1883/9001/false; TEST y PROD 8883/9002, y `true` cuando AIoT lo confirme), y el requisito de certificados.
2. CA-2 Existe un plan de activación para TEST acordado con Despliegue, AIoT y Pruebas: quién provee los certificados y cómo se montan en Dokploy, fecha y hora, clientes afectados y cómo revertir.
3. CA-3 En TEST, el puerto MQTT de host (1885) negocia TLS y presenta un certificado válido y vigente.
4. CA-4 En TEST, una conexión MQTT en texto plano desde fuera al puerto de host **no** recibe CONNACK.
5. CA-5 En TEST, el gateway sigue operando: `/broker-sigab-test/v1/healthz` responde `{"status":"ok"}` y un comando del backend recibe su ACK.
6. CA-6 La promoción del PR #19 a `main` del broker está solicitada a AIoT, y el plan de PROD (variables y certificados) queda documentado.
7. CA-7 `registros/seguridad/registro-SEG.md` refleja SEG-BROKER-02 por rama y por entorno.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | Revisión de `registros/variables/VARIABLES-ENTORNO.md` y `registros/variables/fichas/HU-IMP-SEG-03.md` | Las 3 variables con su valor por entorno, sin secretos | Commit |
| CA-2 | Revisión de `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/plan-activacion.md` (en `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/`) y de la confirmación de cada equipo | Plan con responsables, fecha y reversión | Enlaces o capturas de las confirmaciones |
| CA-3 | `openssl s_client -connect <host-mqtt-test>:1885 -servername <host-mqtt-test> </dev/null 2>/dev/null \| openssl x509 -noout -subject -issuer -dates` | Certificado con el host correcto y fechas vigentes | Salida |
| CA-4 | `mosquitto_sub -h <host-mqtt-test> -p 1885 -u <usuario-de-prueba> -P "$MQTT_PASS" -t 'sgpmp/#' -C 1 -W 5` (texto plano; la contraseña sale de una variable de la sesión y nunca se escribe en la evidencia) | Error de conexión o protocolo, sin mensajes | Salida sin credenciales |
| CA-5 | `curl -sS https://api.inmero.co/broker-sigab-test/v1/healthz` y un comando de prueba desde TEST coordinado con Pruebas | `{"status":"ok"}` y ACK recibido | Salidas o capturas |
| CA-6 | Enlace al PR `develop → main` del broker o a la solicitud a AIoT; `registros/entornos/` con el plan de PROD | Solicitud hecha y plan documentado | Enlaces |
| CA-7 | Lectura del registro | Estado por rama y entorno | Commit |

**Definición de terminado.**
- [ ] CA-1 a CA-7 con evidencia.
- [ ] Ningún secreto (certificados, llaves, contraseñas) en documentos, issues ni chats.
- [ ] Equipos afectados notificados antes y después de la activación.

**Dependencias y aprobaciones.** Despliegue: certificados, variables en Dokploy y redespliegue. AIoT: clientes Edge compatibles con TLS, promoción a `main`, y `MQTT_ACK_REQUIERE_ID_COMANDO=true` cuando el firmware devuelva el id. Pruebas: ventana de activación en TEST.

**Riesgos.** (1) Activar TLS desconecta a los clientes que aún usan texto plano. Si hace falta convivencia, AIoT debe habilitar los mapeos `MQTT_TLS_HOST_PORT`/`MQTT_WSS_HOST_PORT`, con puertos libres que asigne Despliegue (en el host, el 8883 lo ocupa EMQX de otro proyecto). (2) Un certificado vencido o un montaje mal hecho impide arrancar el broker; la reversión es volver a `1883/9001` en las variables. (3) En el diagrama de Despliegue (v1.4), WebSocket de TEST figura en el host 9002, lo que puede confundirse con el listener TLS interno 9002; hay que aclararlo en el plan.

**Referencias.** PR #19 · `docker/certs/README.md` y `docker-compose.yml` de `origin/develop` del broker · skills `seguridad-analisis`, `variables-entorno`, `verificacion` §8.

## Para copiar en Taiga — Subtareas

### ST-01 actualizar el catálogo y la ficha de variables del broker
**Objetivo.** Cumplir CA-1.
**Pasos.**
1. Leer `.env.example` y `docker-compose.yml` de `origin/develop` y `origin/test` del broker.
2. Agregar o actualizar las 3 variables en `registros/variables/VARIABLES-ENTORNO.md`.
3. Redactar `registros/variables/fichas/HU-IMP-SEG-03.md` para Despliegue, con el requisito de `fullchain.pem` y `privkey.pem` en `docker/certs/`.
**Entregable.** Catálogo y ficha.
**Verificación.** CA-1.
**Estimación.** 2 h

### ST-02 acordar el plan de activación de TLS en TEST
**Objetivo.** Cumplir CA-2.
**Pasos.**
1. Inventariar con AIoT y Pruebas los clientes que se conectan al MQTT de TEST y si ya soportan TLS.
2. Preguntar a Despliegue cómo montará los certificados en Dokploy y quién los renueva.
3. Redactar `plan-activacion.md` (en `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/`): precondiciones, pasos, fecha y hora, verificación y reversión.
4. Obtener la confirmación de cada equipo.
**Entregable.** Plan acordado.
**Verificación.** CA-2.
**Estimación.** 3 h

### ST-03 verificar la activación en TEST
**Objetivo.** Cumplir CA-3, CA-4 y CA-5.
**Pasos.**
1. Cuando Despliegue active TLS, ejecutar las pruebas de CA-3, CA-4 y CA-5.
2. Guardar las salidas sin credenciales en `historias/HU-IMP-SEG-03_tls-broker-test-prod/evidencias/`.
3. Si algo falla, aplicar la reversión del plan y abrir un triage.
**Entregable.** Evidencias.
**Verificación.** CA-3, CA-4 y CA-5.
**Estimación.** 2 h

### ST-04 preparar PROD y solicitar la promoción a main
**Objetivo.** Cumplir CA-6.
**Pasos.**
1. Solicitar a AIoT la promoción `develop → main`, o un PR dirigido con el PR #19.
2. Documentar en `registros/entornos/` el plan de PROD (variables, certificados y clientes).
**Entregable.** Solicitud y plan de PROD.
**Verificación.** CA-6.
**Estimación.** 1,5 h

### ST-05 actualizar el registro de seguridad
**Objetivo.** Cumplir CA-7.
**Pasos.** Actualizar SEG-BROKER-02 en `registros/seguridad/registro-SEG.md` por rama y por entorno.
**Entregable.** Registro.
**Verificación.** CA-7.
**Estimación.** 0,5 h

## Notas para el líder (no copiar a Taiga)

- **Plazo sugerido:** 1 a 2 semanas, porque depende de tres equipos. Unas 9 h de trabajo de Juan Hernando.
- **Preguntas abiertas:**
  1. El PR #19 no tiene asignados. ¿Análisis espera que Implementación lidere la activación, o solo que acompañe a AIoT? Conviene confirmarlo con Miguel antes de crear la HU.
  2. ¿Cuál es el host público del MQTT de TEST (dominio o IP)? Se necesita para CA-3 y CA-4.
  3. ¿Hay dispositivos reales conectados a TEST que no soporten TLS?
- **Puntos de atención en la revisión:** que ninguna evidencia incluya credenciales MQTT ni el contenido de los certificados; que el plan tenga una reversión probada.
- **Nota de alcance:** los puertos de host los decide Despliegue; esta HU no elige ninguno.

---
Fuentes consultadas (2026-10-12): `origin/develop@499b456`, `origin/test@7cbdb3f`, `origin/main@b6e8e28` de BROKER-MQTT-SGPMP; PR #19.
