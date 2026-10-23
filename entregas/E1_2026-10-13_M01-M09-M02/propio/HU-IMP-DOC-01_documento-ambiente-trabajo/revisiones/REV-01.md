# REV-01 — Documento de Ambiente de Trabajo de Implementación v1.4

> Estado: dictamen emitido · Fecha: 2026-10-12 · Revisa: Líder de Implementación (con el agente `revisor`) · Autores del trabajo: Sebastián Sandoval Chavarro y Juan Hernando Perdomo Mosquera

**Objeto revisado:** `AMBIENTE_DE_TRABAJO_IMPLEMENTACION_v1.4.docx` (octubre de 2026): 11 secciones, Sandbox de TEST (§3.9) e infraestructura en Dokploy (§3.8).
**Contrastado con:** las ramas `dev`, `test` y `main` de `sgpmp-backend` y `SGPMP-FRONT-END-PWA`; `develop`, `test` y `main` de `BROKER-MQTT-SGPMP` (verificado el 2026-10-12); y la redefinición del rol de Implementación de octubre de 2026.

## Dictamen global: SOLICITAR CAMBIOS (v1.5)

Como documento técnico, la v1.4 es sólida y muy completa: el catálogo de variables por grupos, las diferencias entre los compose, la Sandbox, los criterios de red y las salvedades de la §11.4 son de calidad. Necesita una v1.5 por dos motivos independientes:

1. **Redefinición del rol.** Las secciones 2, 4, 5, 6, 7, 8.2 y parte de la 3.8 describen el modelo anterior: pipeline E1→E7 por módulo, cuatro responsables y verificación de endpoints, puertos y protocolos.
2. **Desactualización frente al código.** Hay afirmaciones que el código ya contradice, y la más visible es la de las cabeceras de seguridad (§3.8).

## A. Afirmaciones que contradicen el código (se corrigen sí o sí)

| ID | Sección | El documento dice | El código muestra (2026-10-12) | Corrección |
|---|---|---|---|---|
| C1 | §3.8 Cabeceras | Las inyecta **Traefik**; HSTS con `includeSubDomains; preload`; `Permissions-Policy` con `geolocation=(self)`; CSP con `script-src 'unsafe-inline'` y `worker-src blob:` | Las emite el **`nginx.conf` del frontend** (SEG-FE-02, `ce0a3a4`); HSTS `max-age=31536000` **sin** `includeSubDomains`, a propósito, porque el VPS es compartido; `geolocation=()`; CSP en **Report-Only**, sin `unsafe-inline` en scripts. Presente en dev y test, **no en main** | Reescribir la subsección con lo vigente y el estado por rama |
| C2 | §11.4 "Compose de TEST" | `docker-compose.test.yml` no reenvía `MQTT_BROKER_URL`, `MQTT_BROKER_TOKEN` ni `LOGOS_STORAGE_PATH` | Ya reenvía `MQTT_BROKER_URL` y `MQTT_BROKER_TOKEN`, ambos con `:?`. Siguen pendientes `LOGOS_STORAGE_PATH` y `MODELOS_STORAGE_PATH` (este último cae a `/tmp`) | Actualizar la salvedad |
| C3 | §11.4 "Sandbox: lectura y reenvío" y §11.3 ítem 6 | No se sabe si el backend lee `ENABLE_TEST_SANDBOX`; el compose no lo reenvía | El compose de TEST sí reenvía ambas variables. El código de la Sandbox existe **solo en la rama `test`** (`src/shared/rollback/…`, `main.py`), no en `dev` ni en `main` | Cerrar la parte del compose. Abrir un hallazgo: si `test` se reconstruye desde `dev`, la Sandbox desaparece (riesgo para Desarrollo y Pruebas) |
| C4 | §3.4 Grupo E | `API_TOKEN`, "token del endpoint POST /v1/commands" | El gateway ya no usa token estático: valida el Bearer contra `modulo1.credenciales_servicio` (README del broker, `develop`) | Eliminar `API_TOKEN`; referenciar `MQTT_BROKER_TOKEN` y su hash |
| C5 | §3.4 Grupo E | No incluye las variables nuevas de TLS ni del ACK | `MQTT_PUERTO_PUBLICO`, `MQTT_WS_PUERTO_PUBLICO`, `MQTT_WS_HOST_PORT` y `MQTT_ACK_REQUIERE_ID_COMANDO` (`develop` y `test`) | Agregar al grupo E |
| C6 | §3.4 Grupo D | Nueve variables `VITE_*` | El código de `dev` también usa `VITE_AGROFUSION_LOGIN_URL`, que no llega a ningún build de Docker (INC-FE-01, pendiente de triage) | Agregarla, con la nota del hallazgo |
| C7 | §3.4 Grupos A–C | — | El backend lee además `AUDITORIA_M02_EVENTOS_POR_SEGUNDO` y `ALEMBIC_DATABASE_URL`; el Dockerfile fija `FORWARDED_ALLOW_IPS` | Agregarlas o justificar por qué no se catalogan |
| C8 | §8.3 Pendientes con AIoT | "uso de TLS (puerto 8883) en TEST y PROD" pendiente | TLS ya está implementado en código (PR #19 en `develop` y `test`), pero no está activado; ACL dynamic-security también activa en `develop` y `test` | Pasar a "implementado en código; activación pendiente" (HU-IMP-SEG-03) |
| C9 | §3.3 Frontend | Compose `docker-compose.yml` y `docker-compose.prod.yml` | Cada rama tiene el suyo: `dev` → `docker-compose.yml`; `test` → `docker-compose.test.yml`; `main` → `docker-compose.prod.yml` | Corregir la tabla de archivos |
| C10 | Portada y control | Portada con cuatro autores ("Guttierez Tovar"); control con dos | El equipo actual son dos integrantes | Unificar autores y corregir "Gutiérrez Tobar" si se conserva |

## B. Secciones afectadas por la redefinición del rol

| Sección | Problema | Propuesta para la v1.5 |
|---|---|---|
| §1 Introducción | "Implementación no desarrolla… integra" módulos | Rol actual: dueño de imágenes, entornos, variables, nginx, incidencias de comunicación y directrices SEG |
| §2.1 Ramas | `integration`, `recep/*` y `fix/m0X` del pipeline por módulo | Ramas propias `feat/`, `fix/`, `chore/` con PR a `dev`, `test` o `main`, según el aprobador de cada rama (skill `promocion-entornos`) |
| §2.2 Roles A–D | Cuatro responsables ligados a DOC-01…04 | Dos roles: el líder planifica, revisa y aprueba; el integrante ejecuta |
| §2.3 / §2.4 | "Desarrollo entrega Dockerfiles y compose" | Invertir: Implementación entrega Dockerfiles, compose, plantillas y nginx; recibe dominios y puertos de Despliegue, y protocolos de AIoT y Desarrollo |
| §3.8 | Dominios y puertos como definición propia | Mantener la información, pero como **recibida de Despliegue** (fuente y fecha); conservar los criterios de exposición, que sí son de Implementación |
| §4–§7 | Verificación E1→E7, flujos principal y alternos del pipeline | Reemplazar por los tres flujos del Camino B (ADR-001), con trazabilidad hacia la metodología anterior |
| §8.2 | Endpoints y puertos del broker | Referencia a AIoT y Despliegue; Implementación conserva variables, compose y coordinación |
| §11.3 | "Docker **y puertos**: listo" | Separar: Docker y compose (Implementación), puertos (Despliegue) |
| §11.4 | Tabla de salvedades | Migrar al registro vivo `registros/incidencias/registro.md` y dejar en el documento solo el resumen |

## C. Coherencia con el mapa de puertos (HU-IMP-AMB-09)

- **PROD MQTT y WS:** el mapa dice "1886/9003 por confirmar" y el documento "por asignar con AIoT". Hay que unificarlo.
- **Flujo backend–gateway:** el documento (§8, §8.2) lo describe correctamente por HTTPS, pero el mapa lo dibuja como MQTT. Cuando el mapa se corrija, ambos quedarán coherentes.

## Retroalimentación para Juan Hernando (borrador para enviar)

> Juan Hernando, revisé el documento de ambiente de trabajo v1.4. Técnicamente quedó muy completo: el catálogo por grupos, las diferencias entre los compose y la Sandbox están muy bien documentados. Vamos a sacar una v1.5 por dos razones:
>
> 1. **Correcciones frente al código (sección A del dictamen).** La más importante es la §3.8: las cabeceras de seguridad no las pone Traefik sino el `nginx.conf` del frontend, y con valores distintos (HSTS sin `includeSubDomains`, CSP en Report-Only). También hay variables nuevas o retiradas en el catálogo (sale `API_TOKEN` del broker; entran las de TLS y `VITE_AGROFUSION_LOGIN_URL`) y salvedades que ya se resolvieron en el compose de TEST.
> 2. **Nuevo rol del equipo (sección B).** Las secciones del pipeline E1→E7 y de los roles A–D se reemplazan por los tres flujos que adoptamos (ADR-001). Dominios y puertos pasan a ser información recibida de Despliegue.
>
> La v1.5 la vamos a escribir en Markdown dentro del repo (`entregables/`) y a generar el Word con `herramientas/md2docx.ps1`, que ya usa los estilos de la v1.4. El detalle con la evidencia de cada punto está en `historias/HU-IMP-DOC-01_documento-ambiente-trabajo/revisiones/REV-01.md`.

## Criterios para la próxima revisión (REV-02)

Los CA de `historia.md`. Cada afirmación técnica de la v1.5 debe citar rama y archivo, o la fuente externa con su fecha.
