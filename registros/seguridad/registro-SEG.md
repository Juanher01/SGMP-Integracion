# Registro de directrices de seguridad (SEG-*)

> Estado: vigente · Actualizado: 2026-10-13 · Responsable: Líder de Implementación · Mantiene: agente `auditor-seguridad`

Directrices del equipo de Análisis (líder: Miguel, `miguelortiz13`). Procedimiento: skill `seguridad-analisis`.

**Corte vigente: 2026-10-13** (`git fetch --prune` a las 10:59:47 -0500). Fuente de hechos:
[`registros/entornos/corte-2026-10-13.md`](../entornos/corte-2026-10-13.md). Hashes usados:

| Repo | dev / develop | test | main |
|---|---|---|---|
| `sgpmp-backend` | `bd8b6d4f` | `81487428` | `8a7e6327` |
| `SGPMP-FRONT-END-PWA` | `8c30fa3` | `95fa674` | `2132c62` |
| `BROKER-MQTT-SGPMP` | `44e29b6` | `7cbdb3f` | `cebd430` |

Comprobaciones adicionales hechas el 2026-10-13 contra esos mismos hashes (sin nuevo fetch), citadas en cada sección.
Sin pruebas de comportamiento sobre los entornos desplegados: lo que depende de Dokploy queda `NO VERIFICABLE`.

## Resumen

| Código | Origen | Tema | dev | test | main | Estado global | HU |
|---|---|---|---|---|---|---|---|
| SEG-CICD-01 | [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266) | Permisos de workflows; hadolint en Dockerfiles | ✅ | ✅ | ⚠️ `permissions:` ✅; CA-2/3/8 pendientes | En curso | HU-IMP-SEG-01 |
| SEG-FE-02 | [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113) | Cabeceras de seguridad en nginx | ✅ | ✅ | ✅ código (`ce0a3a4`) | En curso (falta evidencia CA-4 y despliegue PROD) | HU-IMP-SEG-02 |
| SEG-BROKER-01 | Rama `feature/seg-broker-01-acl-mosquitto-v2` (PR #16, `869a315`) | ACL de mínimo privilegio (`acl_file`) | ✅ código, reemplazado por SEG-BROKER-03 | ✅ ídem | ✅ ídem | Por confirmar con Análisis (Miguel): reemplazado por dynamic-security (SEG-BROKER-03); sin issue con criterios | — |
| SEG-BROKER-02 | [PR #15](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/15) (rama `feature/seg-broker-02-tls-mosquitto`, `741c065`) y [PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19) (`bd1910f`, TC-M09-253) | TLS obligatorio hacia afuera (TC-M09-253) | ✅ código | ✅ código, sin activar | ✅ código, sin activar | En curso (activación pendiente) | HU-IMP-SEG-03 |
| SEG-BROKER-03 | `docker/mosquitto-entrypoint.sh` (commit `94f0387`) | ACL y autenticación con el plugin dynamic-security | ✅ código | ✅ código | ✅ código | Por confirmar con Análisis (Miguel): reemplaza a SEG-BROKER-01 con dynamic-security; sin issue con criterios | — |

Leyenda: ✅ cumple · ⚠️ parcial · ❌ ausente. "Código" significa que el soporte existe en la rama pero no está verificado (o no está activado) en el entorno.

## SEG-CICD-01 — Endurecimiento de CI/CD y Dockerfiles del backend

| # | Criterio (issue #266) | dev | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | `permissions:` mínimo en `_migrate-template.yml`, `migrate-dev.yml`, `validate-migrations.yml` | ✅ `402739ec` | ✅ (`migrate-dev.yml` no existe en test) | ✅ `8a7e6327` (2026-10-13) | `git -C sgpmp-backend merge-base --is-ancestor 402739ec 8a7e6327` → INCLUIDO; `git show 8a7e6327:.github/workflows/<wf>` → `permissions: contents: read` en los tres |
| 2 | Ejecuciones reales con permisos reducidos | Pendiente de evidencia | — | — | HU-IMP-SEG-01 CA-6 |
| 3 | `release.yml` documenta su escritura | ❌ | ❌ | ❌ | HU-IMP-SEG-01 CA-5 (no reverificado el 2026-10-13) |
| 4 | `gcc`/`libpq-dev` fuera de la imagen final | ✅ `388c0f01` | ✅ | ✅ | Paquetes eliminados (desviación 1) |
| 5 | `postgresql-18-cron` fijado | ✅ | ✅ | ✅ | `=1.6.8-1.pgdg13+1` |
| 6 | `useradd --uid` numérico y `USER` con UID | ✅ | ✅ | ✅ | UID 1000 (desviación 2) |
| 7 | hadolint sin hallazgos | ✅ | ✅ | ✅ | hadolint 2.12.0, 2026-10-12 |
| 8 | La imagen arranca y no corre como root | Pendiente de evidencia | — | Pendiente | HU-IMP-SEG-01 CA-2 |

Filas 2–8: verificadas el 2026-10-12; no forman parte del corte 2026-10-13.

**Desviaciones (por comunicar en el issue):**
1. No se usó multi-stage: `gcc` y `libpq-dev` se eliminaron porque ninguna dependencia compila (`psycopg2-binary` y ruedas `cp313`). El compilador queda fuera de la imagen final, que es la intención del criterio.
2. UID 1000 en vez del 10001 sugerido: los volúmenes de los tres entornos ya pertenecen a 1000.

## SEG-FE-02 — Cabeceras de seguridad del frontend

| # | Criterio (issue #113) | dev | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | nosniff, X-Frame-Options, Referrer-Policy, Permissions-Policy | ✅ `ce0a3a4` | ✅ | ✅ `2132c62` (2026-10-13) | `nginx.conf`; corte 2026-10-13 §2.3: `ce0a3a4` ancestro de dev, test y main |
| 2 | CSP afinada en Report-Only (API, Firebase/FCM, reCAPTCHA) | ✅ | ✅ | ✅ (2026-10-13) | `nginx.conf` + `envsubst ${API_ORIGIN}`; mismo commit `ce0a3a4` |
| 3 | HSTS en un solo lugar, decisión documentada | ✅ en nginx, sin `includeSubDomains` | ✅ | ✅ (2026-10-13) | Comentario en `nginx.conf`; falta comprobar que Traefik no lo duplique |
| 4 | La app funciona con la CSP | Pendiente de evidencia | Pendiente | Pendiente | HU-IMP-SEG-02 CA-3 |
| 5 | Aplicado en producción | — | — | ✅ código en `main`; despliegue NO VERIFICABLE | PROD sin URL definida: no hay `curl -sSI` posible |

Historial: hasta el 2026-10-12 `main` figuraba ❌ en CA-1 a CA-3; el corte 2026-10-13 lo resuelve.

## SEG-BROKER-01 — ACL de mínimo privilegio en Mosquitto

No hay issue SEG con criterios en el repositorio del broker (`gh issue list -R SerBy48/BROKER-MQTT-SGPMP --state all` sin coincidencias para SEG/ACL/TLS el 2026-10-13); el origen es la rama.

**Estado: por confirmar con Análisis (Miguel).** El esquema `passwd` + `acl_file` de esta rama fue reemplazado por el plugin dynamic-security (SEG-BROKER-03): sigue en la historia de las tres ramas, pero el entrypoint ya no lo lee. Análisis debe confirmar si la directriz se da por cubierta con SEG-BROKER-03 o se retira.

| # | Criterio (derivado del commit; sin issue) | develop | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | `acl_file` con privilegio mínimo por usuario (`869a315`) presente | ✅ | ✅ | ✅ | Corte 2026-10-13 §2.4: punta `869a315` ancestro de develop, test y main |
| 2 | El mecanismo sigue vigente | ❌ reemplazado | ❌ reemplazado | ❌ reemplazado | `docker/mosquitto-entrypoint.sh` l. 52–54 en `44e29b6`/`7cbdb3f`/`cebd430`: "Restos del esquema anterior (passwd + acl_file, SEG-BROKER-01). Ya no se leen" y los borra; la ACL vive ahora en dynamic-security (SEG-BROKER-03) |

## SEG-BROKER-02 — TLS del broker MQTT

**Orígenes (dos PR):** PR #15 fusionó la rama `feature/seg-broker-02-tls-mosquitto` (punta `741c065`, soporte de listeners TLS); PR #19 aportó `bd1910f` (TC-M09-253) y sus criterios, que son los de la tabla.

| # | Criterio (PR #19) | develop | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | Publicar al host solo los listeners TLS en TEST/PROD | ✅ código | ✅ código; activación NO VERIFICABLE | ✅ código; activación NO VERIFICABLE | `docker-compose.yml` (`MQTT_PUERTO_PUBLICO`). En las tres ramas: `MQTT_PUERTO_PUBLICO=1883` (`.env.example` l. 56) publicado por `"${MQTT_HOST_PORT:-1884}:${MQTT_PUERTO_PUBLICO:-1883}"` (`docker-compose.yml` l. 47), mapeo `8883` comentado (l. 53). `MQTT_TLS` es el TLS del cliente del gateway hacia Mosquitto interno, no aplica a este criterio. Valores de Dokploy no leídos (Despliegue) |
| 2 | El broker aborta si se pide TLS sin certificados | ✅ | ✅ | ✅ (2026-10-13) | `docker/mosquitto-entrypoint.sh` l. 93–95 en `44e29b6`/`7cbdb3f`/`cebd430` |
| 3 | Promoción a `main` y `test` | — | ✅ | ✅ (2026-10-13) | Corte §2.5: `741c065` ancestro de develop, test y main; `git -C BROKER-MQTT-SGPMP merge-base --is-ancestor bd1910f cebd430` → INCLUIDO (también `7cbdb3f`, `44e29b6`) |
| 4 | ACK anti-replay obligatorio (`MQTT_ACK_REQUIERE_ID_COMANDO=true`) | `false` | `false` | `false` | `.env.example` l. 70 en las tres ramas. Depende del firmware (AIoT) |

No se cierra: TLS está soportado pero desactivado por defecto y su activación en TEST/PROD no tiene evidencia (requiere Despliegue: certificados montados, `MQTT_PUERTO_PUBLICO=8883`, prueba `openssl s_client` y `nc` al puerto en texto plano).

## SEG-BROKER-03 — Autenticación y ACL con dynamic-security

Sin issue SEG con criterios (misma búsqueda que SEG-BROKER-01). Introducido por `94f0387` (2026-10-03, `feat(rf23): credencial MQTT por Raspberry con dynamic-security (TC-M09-250/251)`); el identificador SEG-BROKER-03 aparece en el propio `docker/mosquitto-entrypoint.sh`.

**Estado: por confirmar con Análisis (Miguel).** Reemplaza el esquema `passwd` + `acl_file` de SEG-BROKER-01 por el plugin dynamic-security en `develop`, `test` y `main`. Falta que Análisis confirme si es una directriz propia y con qué criterios.

| # | Criterio (derivado del código; sin issue) | develop | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | El entrypoint prepara `dynamic-security.json` | ✅ | ✅ | ✅ | Corte 2026-10-13 §2.6 (línea 2 en las tres ramas); `git -C BROKER-MQTT-SGPMP merge-base --is-ancestor 94f0387 <hash>` → INCLUIDO en `44e29b6`, `7cbdb3f`, `cebd430` |
| 2 | Retira el esquema `passwd` + `acl_file` | ✅ | ✅ | ✅ | `docker/mosquitto-entrypoint.sh` l. 52–54 |
| 3 | Funciona en los entornos desplegados | NO VERIFICABLE | NO VERIFICABLE | NO VERIFICABLE | Sin prueba de comportamiento en este corte |

**Fuera del alcance de Implementación:** TC-M09-250/251 (credencial por dispositivo), de AIoT. Nota: el código de SEG-BROKER-03 es el mismo trabajo de TC-M09-250/251; falta que Análisis confirme si SEG-BROKER-03 es una directriz propia y cuáles son sus criterios.
