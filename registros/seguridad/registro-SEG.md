# Registro de directrices de seguridad (SEG-*)

> Estado: vigente · Actualizado: 2026-10-12 · Responsable: Líder de Implementación · Mantiene: agente `auditor-seguridad`

Directrices del equipo de Análisis (líder: Miguel, `miguelortiz13`). Procedimiento: skill `seguridad-analisis`.
Evidencia verificada con git el 2026-10-12 (sin pruebas sobre los entornos desplegados).

## Resumen

| Código | Origen | Tema | dev | test | main | Estado global | HU |
|---|---|---|---|---|---|---|---|
| SEG-CICD-01 | [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266) | Permisos de workflows; hadolint en Dockerfiles | ✅ | ✅ | ⚠️ workflows sin `permissions:` | Parcial (falta main) | HU-IMP-SEG-01 |
| SEG-FE-02 | [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113) | Cabeceras de seguridad en nginx | ✅ | ✅ | ❌ | Parcial (falta main) | HU-IMP-SEG-02 |
| SEG-BROKER-02 | [BROKER-MQTT-SGPMP PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19) | TLS obligatorio hacia afuera (TC-M09-253) | ✅ código | ✅ código, sin activar | ❌ | En curso (activación pendiente) | HU-IMP-SEG-03 |

Leyenda: ✅ cumple · ⚠️ parcial · ❌ ausente. "Código" significa que el soporte existe pero no está activado en el entorno.

## SEG-CICD-01 — Endurecimiento de CI/CD y Dockerfiles del backend

| # | Criterio (issue #266) | dev | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | `permissions:` mínimo en `_migrate-template.yml`, `migrate-dev.yml`, `validate-migrations.yml` | ✅ `402739ec` | ✅ (`migrate-dev.yml` no existe en test) | ❌ | `git show origin/<rama>:.github/workflows/<wf>` |
| 2 | Ejecuciones reales con permisos reducidos | Pendiente de evidencia | — | — | HU-IMP-SEG-01 CA-6 |
| 3 | `release.yml` documenta su escritura | ❌ | ❌ | ❌ | HU-IMP-SEG-01 CA-5 |
| 4 | `gcc`/`libpq-dev` fuera de la imagen final | ✅ `388c0f01` | ✅ | ✅ | Paquetes eliminados (desviación 1) |
| 5 | `postgresql-18-cron` fijado | ✅ | ✅ | ✅ | `=1.6.8-1.pgdg13+1` |
| 6 | `useradd --uid` numérico y `USER` con UID | ✅ | ✅ | ✅ | UID 1000 (desviación 2) |
| 7 | hadolint sin hallazgos | ✅ | ✅ | ✅ | hadolint 2.12.0, 2026-10-12 |
| 8 | La imagen arranca y no corre como root | Pendiente de evidencia | — | Pendiente | HU-IMP-SEG-01 CA-2 |

**Desviaciones (por comunicar en el issue):**
1. No se usó multi-stage: `gcc` y `libpq-dev` se eliminaron porque ninguna dependencia compila (`psycopg2-binary` y ruedas `cp313`). El compilador queda fuera de la imagen final, que es la intención del criterio.
2. UID 1000 en vez del 10001 sugerido: los volúmenes de los tres entornos ya pertenecen a 1000.

## SEG-FE-02 — Cabeceras de seguridad del frontend

| # | Criterio (issue #113) | dev | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | nosniff, X-Frame-Options, Referrer-Policy, Permissions-Policy | ✅ `ce0a3a4` | ✅ | ❌ | `nginx.conf` |
| 2 | CSP afinada en Report-Only (API, Firebase/FCM, reCAPTCHA) | ✅ | ✅ | ❌ | `nginx.conf` + `envsubst ${API_ORIGIN}` |
| 3 | HSTS en un solo lugar, decisión documentada | ✅ en nginx, sin `includeSubDomains` | ✅ | ❌ | Comentario en `nginx.conf`; falta comprobar que Traefik no lo duplique |
| 4 | La app funciona con la CSP | Pendiente de evidencia | Pendiente | — | HU-IMP-SEG-02 CA-3 |
| 5 | Aplicado en producción | — | — | ❌ | HU-IMP-SEG-02 |

## SEG-BROKER-02 — TLS del broker MQTT

| # | Criterio (PR #19) | develop | test | main | Evidencia |
|---|---|---|---|---|---|
| 1 | Publicar al host solo los listeners TLS en TEST/PROD | ✅ código | ✅ código; activación pendiente | ❌ | `docker-compose.yml` (`MQTT_PUERTO_PUBLICO`) |
| 2 | El broker aborta si se pide TLS sin certificados | ✅ | ✅ | ❌ | `docker/mosquitto-entrypoint.sh` |
| 3 | Promoción a `main` y `test` | — | ✅ | ❌ | `merge-base` 2026-10-12 |
| 4 | ACK anti-replay obligatorio (`MQTT_ACK_REQUIERE_ID_COMANDO=true`) | `false` | `false` | — | Depende del firmware (AIoT) |

**Fuera del alcance de Implementación:** TC-M09-250/251 (credencial por dispositivo), de AIoT.
