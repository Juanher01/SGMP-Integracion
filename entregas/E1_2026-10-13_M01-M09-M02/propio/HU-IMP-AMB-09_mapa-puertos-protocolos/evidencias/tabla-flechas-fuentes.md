# Tabla flecha → fuente — Mapa de puertos y protocolos v1.5

> Estado: vigente · Actualizado: 2026-10-13 · Responsable: Líder de Implementación

**Qué es.** Evidencia de CA-1 de HU-IMP-AMB-09: cada flecha (`edge="1"`) de `entregables/IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio` con el archivo y el commit que la respaldan, o con la marca "Objetivo (no desplegado)" o la fuente externa nombrada.

**Corte.** `registros/entornos/corte-2026-10-13.md`. Abreviaturas: BE = sgpmp-backend (`dev@bd8b6d4f`, `test@81487428`, `main@8a7e6327`); FE = SGPMP-FRONT-END-PWA (`dev@8c30fa3`, `test@95fa674`, `main@2132c62`); BRK = BROKER-MQTT-SGPMP (`develop@44e29b6`, `test@7cbdb3f`, `main@cebd430`). "3 ramas" significa que la línea citada es idéntica en las tres puntas del corte (comprobado con `git grep` sobre cada hash).

## Flechas desplegadas

| Id de la flecha | Rótulo | Origen → destino | Archivo y rama@hash |
|---|---|---|---|
| `Zfa-h7b1mF_UkIyc46Zn-36` | HTTPS 443 · TLS (Let's Encrypt) + JWT | Dispositivo usuario → Traefik | Fuente externa: Despliegue (dominios y TLS en Traefik, 2026-10-12) |
| `edge-lb-front` | HTTP :80 interno | Traefik → Frontend (nginx) | FE `docker-compose.yml:17-18` (`expose: "80"`), 3 ramas |
| `0P-6feL1eprvoFLn9LHD-18` | HTTP :8000 interno (Strip Path) | Traefik → Backend Instancia 1 | BE `dev@bd8b6d4f` `docker-compose.yml:86-87`; `test@81487428` `docker-compose.test.yml:71-72`; `main@8a7e6327` `docker-compose.prod.yml:171-172`. Strip Path: Despliegue |
| `edge-be-lb` | HTTPS 443 · POST /v1/commands (URL pública /broker-sigab-*) | Backend Instancia 1 → Traefik | BE `src/configuration/infrastructure/adapters/mqtt_http_adapter.py:113-114` y `edge_sincronizacion_mqtt_adapter.py:74-75`, 3 ramas. Ruta pública: Despliegue |
| `edge-lb-gw` | HTTP :8000 interno (Strip Path) | Traefik → Gateway | BRK `docker-compose.yml:86-87` (`expose: "8000"`), 3 ramas. Strip Path: Despliegue |
| `edge-gw-mosq` | MQTT 1883 interno (↔) | Gateway ↔ Mosquitto | BRK `docker-compose.yml:77,83` (`MQTT_HOST: mosquitto`, `MQTT_PORT: 1883`) y `app/mqtt/client.py:67` (suscripción a telemetría) y `:98` (publicación), 3 ramas |
| `edge-brk-1` | MQTT · host 1884/1885 → 1883 (con TLS → 8883; desactivado por defecto) | Edge Node → Mosquitto | BRK `docker-compose.yml:41,47`, 3 ramas (corte §2.6). Puertos de host: Despliegue |
| `edge-gw-db` | TCP · host 5447 DEV / 5448 TEST → 5432 (objetivo: red interna) | Gateway → Servidor BD | BRK plantilla de variables del gateway, l. 10-12 (`DATABASE_URL` a `host:5447`), 3 ramas; `docker-compose.yml` sin `networks:`, 3 ramas. Rol y vía: Despliegue, 2026-10-12 (INC-BD-01). PROD: por definir |
| `Zfa-h7b1mF_UkIyc46Zn-39` | TCP 5432 interno · ${POSTGRES_DB}-db | Backend Instancia 1 → Servidor BD | BE `dev@bd8b6d4f` `docker-compose.yml:49`; `test@81487428` `docker-compose.test.yml:41`; `main@8a7e6327` `docker-compose.prod.yml:117` |
| `Zfa-h7b1mF_UkIyc46Zn-41` | SMTP 587 · STARTTLS | Backend Instancia 1 → Correo SMTP | BE `src/shared/email.py:24,70-72`, 3 ramas. Proveedor (Gmail): Despliegue |
| `edge-be-fcm` | HTTPS 443 | Backend Instancia 1 → Firebase Cloud Messaging | BE `src/shared/firebase.py:36-39,79` (`firebase_admin`, `messaging.send`), 3 ramas. Destino: servicio externo de Google (FCM) |
| `edge-be-recaptcha` | HTTPS 443 | Backend Instancia 1 → Google reCAPTCHA | BE `src/identity_access/infrastructure/adapters/google_recaptcha_adapter.py:17,68` (`httpx.post` a `/recaptcha/api/siteverify`), 3 ramas |
| `edge-af-be` | HTTPS 443 entrante (vía Traefik) | AgroFusion Hub → Backend Instancia 1 | BE `src/identity_access/infrastructure/routers/agrofusion_integration_router.py:46` (`/integraciones/agrofusion`) y `src/shared/agrofusion_auth.py:28`, 3 ramas. El SSO RS256 se valida con clave pública local (`agrofusion_sso_adapter.py:49`): no hay llamada saliente a AgroFusion |
| `Zfa-h7b1mF_UkIyc46Zn-38` | LoRaWAN | Sensores IoT → Edge Node | Fuente externa: AIoT (dispositivos de campo); sin archivo en los repositorios del corte |
| `3mxXDTT2PxGYSkMZLNH4-0` | Contingencia | Dispositivo usuario → Edge Node | Fuente externa: diagrama de despliegue de Diseño (PI3). [PENDIENTE: confirmar con AIoT si existe este canal] |

## Flechas objetivo (no desplegadas)

| Id de la flecha | Rótulo | Origen → destino | Fuente |
|---|---|---|---|
| `0P-6feL1eprvoFLn9LHD-20` | Objetivo (no desplegado) · HTTP :8000 | Traefik → Backend Instancia 2 | Objetivo (no desplegado) |
| `Zfa-h7b1mF_UkIyc46Zn-40` | Objetivo (no desplegado) · HTTPS 443 | Backend Instancia 1 → Sistemas Externos | Objetivo (no desplegado): sin llamadas a UPRA, ICA ni entidades crediticias en BE `src` (REV-02 N5) |
| `S-_rEWRCBSLLvi32CNCP-3` | Objetivo (no desplegado) · REST | Backend Instancia 1 → Servidor ML | Objetivo (no desplegado) |
| `UYoWidx1297Aab-H_8bZ-0` | Objetivo (no desplegado) · predicción | Servidor ML → Backend Instancia 1 | Objetivo (no desplegado) |
| `0P-6feL1eprvoFLn9LHD-10` | Objetivo (no desplegado) · HTTPS 443 | Backend Instancia 2 → Sistemas Externos | Objetivo (no desplegado) |
| `0P-6feL1eprvoFLn9LHD-11` | SMTP 587 · STARTTLS | Backend Instancia 2 → Servicios externos desplegados | Objetivo (no desplegado): el origen no existe |
| `0P-6feL1eprvoFLn9LHD-14` | Objetivo (no desplegado) · REST | Backend Instancia 2 → Servidor ML | Objetivo (no desplegado) |
| `0P-6feL1eprvoFLn9LHD-12` | Objetivo (no desplegado) · predicción | Servidor ML → Backend Instancia 2 | Objetivo (no desplegado) |
| `0P-6feL1eprvoFLn9LHD-15` | TCP :5432 · PostgreSQL | Backend Instancia 2 → Servidor BD | Objetivo (no desplegado): el origen no existe |

**Resultado.** 24 flechas: 15 desplegadas (13 con archivo y commit; 2 con fuente externa nombrada) y 9 objetivo. Validación del XML (anclaje de `source` y `target`): sin errores.
