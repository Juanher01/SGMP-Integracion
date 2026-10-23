# SGMP-Integracion — Repositorio del equipo de Implementación (SGPMP / SIGAB)

> Actualizado: 2026-10-23 · Responsable: Líder de Implementación (Sebastián Sandoval Chavarro)

Documentación, planificación y orquestación local del equipo de Implementación del **Sistema de Gestión Pecuaria Multiespecie de Precisión**. No contiene código de aplicación.

## Alcance del equipo (desde octubre de 2026)

Implementación es responsable, en DEV, TEST y PROD, de:
- Dockerfile, `.dockerignore` y docker-compose de cada repositorio.
- Variables de entorno: catálogo, plantillas `.env*.example` y sensibilidad.
- El `nginx.conf` del frontend.
- Las incidencias de comunicación entre componentes.
- El cumplimiento de las directrices de seguridad de Análisis (`SEG-*`).

Los endpoints son de Desarrollo; los protocolos, de Desarrollo y AIoT; los puertos, dominios y Dokploy, de Despliegue. Ver [`decisiones/ADR-001`](decisiones/ADR-001-flujos-por-tipo-de-trabajo.md).

## Estructura

| Carpeta | Contenido |
|---|---|
| [`entregas/`](entregas/) | Una carpeta por entrega al docente (`E<N>_<fecha>_<módulos>/`) con su `README.md`, `documentos/` (fuente editable de lo entregado y sus recursos en `img/`; las exportaciones van a Drive) y el trabajo por origen: `prs/`, `commits/`, `issues/`, `propio/`. Cada HU conserva `historia.md`, `entregables/`, `evidencias/`, `revisiones/`. Tablero general en `entregas/README.md` ([ADR-002](decisiones/ADR-002-organizacion-por-entregas.md)) |
| [`registros/`](registros/) | Documentos vivos: `seguridad/` (directrices SEG), `variables/` (catálogo y fichas para Despliegue), `entornos/` (contratos TEST/PROD, requisitos de Pruebas), `contenedores/`, `base-datos/`, `incidencias/` |
| [`decisiones/`](decisiones/) | Registros de decisión (ADR) |
| [`runbooks/`](runbooks/) | Procedimientos para levantar y validar los ambientes |
| [`herramientas/`](herramientas/) | `md2docx.ps1` (Markdown → Word con la plantilla del equipo), filtros y plantilla |
| [`archivo/`](archivo/) | Documentos ya no vigentes, conservados por trazabilidad |
| `compose/`, `dockerfiles/`, `env/`, `scripts/`, `.env.example` | Orquestación local del ecosistema (**sin cambios de ubicación**: los compose usan rutas relativas `../../<repo>` y los runbooks dependen de ellas) |

## Generar un Word

```powershell
powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregas/<E>/documentos/<documento>.md
```
Requiere Pandoc (`winget install --id JohnMacFarlane.Pandoc`). El resultado queda en `salida/` (no se versiona; las exportaciones entregadas viven en Drive). En Word, actualiza la tabla de contenido: clic derecho → *Actualizar campos*.

## Ubicaciones anteriores

Los documentos históricos citan rutas `docs/…` (antes de 2026-10-12) o `historias/…` y `entregables/…` (antes de 2026-10-23). Equivalencias:

| Antes | Ahora |
|---|---|
| `historias/<HU>/` | `entregas/<E>/<origen>/<HU>/` (origen: `prs/…`, `commits/…`, `issues/…` o `propio/`) |
| `historias/README.md` | `entregas/README.md` |
| `entregables/` y `historias/<HU>/entregables/<documento entregado>` | `entregas/<E>/documentos/` |
| `docs/SEGUIMIENTO-HU-IMP-AMB-0X.md` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-0X_*/seguimiento.md` |
| `docs/FR-IMP-CE-04.md` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-02_catalogo-variables/entregables/FR-IMP-CE-04.md` |
| `docs/REPORTE-HU04-DBIntegrador.md` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-04_restauracion-dbintegrador/reporte.md` |
| `docs/PLAN-HU-05-…`, `docs/AUDITORIA-CREDENCIALES-HU-05.md`, `evidencias/hu05/` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-05_gateway-aiot-mosquitto/` |
| `evidencias/hu06/` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-06_ambiente-dev/evidencias/` |
| `docs/HU-IMP-AMB-07 ST-0X-….md` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-07_ambiente-test/entregables/` |
| `docs/HU-IMP-AMB-08 ST-0X-….md` | `entregas/E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-08_ambiente-prod/entregables/` |
| `docs/VARIABLES-ENTORNO.md` | `registros/variables/VARIABLES-ENTORNO.md` |
| `docs/CONTRATO-TEST.md`, `CONTRATO-PROD.md`, `REQUISITOS-PRUEBAS-TEST.md` | `registros/entornos/` |
| `docs/REPORTE-dockerfile-*.md`, `REPORTE-compose-dev.md` | `registros/contenedores/` |
| `docs/REPORTE-spike-restauracion-BD.md` | `registros/base-datos/` |
| `docs/RUNBOOK-*.md` | `runbooks/` |
| `docs/Ambiente-Trabajo-Implementacion.md` | `archivo/ecosistema-inicial-2026-08-10/Ambiente-Trabajo-Implementacion.md` (v1.1) |
| `docs/FLUJO-GIT.md` | `entregas/E1_2026-10-13_M01-M09-M02/documentos/FLUJO-GIT.md` |
| `docs/FLUJO-TRABAJO.md`, `PROCEDIMIENTO-RECEPCION.md`, `FORMATO-RECEPCION.md`, `API-VALIDACION.md` | `archivo/pipeline-e1-e7/` |
| `docs/AMBIENTES.md`, `BASE-DATOS.md`, `DOCKER.md`, `evidencias/*.png` | `archivo/ecosistema-inicial-2026-08-10/` |

## Seguridad

Los `.env` con valores reales **nunca se versionan** (`.gitignore`). Las plantillas sin valores están en `env/*.example` y en los `.env*.example` de cada repositorio.
