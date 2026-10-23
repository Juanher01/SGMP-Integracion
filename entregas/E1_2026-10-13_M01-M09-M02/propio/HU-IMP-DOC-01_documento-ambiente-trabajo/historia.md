# HU-IMP-DOC-01 — Documento de Ambiente de Trabajo de Implementación: v1.4 y actualización a v1.5 por la redefinición del rol

> Estado: lista para crear en Taiga · Redactado: 2026-10-12 · Tipo: historia retroactiva. La v1.4 ya existe; la v1.5 sale de [REV-01](revisiones/REV-01.md).

## Para copiar en Taiga — Descripción de la HU

**Rama:** `docs/ambiente-trabajo-v1.5` en `SGMP-Integracion` → PR a `main` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Entregable académico de Implementación (Proyecto Integrador IV). La v1.4 (octubre de 2026) fue elaborada por Sebastián Sandoval y Juan Hernando Perdomo. En octubre de 2026 el líder del proyecto redefinió el rol del equipo, y la revisión REV-01 (2026-10-12) pide una v1.5.

**Situación actual.** La v1.4 es técnicamente completa: catálogo de variables por grupos, compose por ambiente, Sandbox de TEST, criterios de red y salvedades. Tiene dos problemas:
1. **Contradice al código en 10 puntos** (REV-01, sección A). El más visible está en la §3.8: las cabeceras de seguridad las emite el `nginx.conf` del frontend, no Traefik, y con otros valores. Además, el catálogo tiene variables retiradas (`API_TOKEN`) y le faltan otras (TLS del broker, `VITE_AGROFUSION_LOGIN_URL`).
2. **Describe el rol anterior** (REV-01, sección B): pipeline E1→E7 por módulo, cuatro responsables y verificación de endpoints, puertos y protocolos.

**Descripción.** Publicar la v1.5 del documento, alineada con el código vigente y con el nuevo alcance de Implementación: imágenes, entornos DEV/TEST/PROD, variables de entorno, nginx, incidencias de comunicación y directrices de seguridad de Análisis, organizados en los tres flujos del Camino B (ADR-001). La v1.5 se escribe en Markdown dentro del repositorio y el Word se genera con la plantilla del equipo, de modo que el documento quede versionado y sea fácil de mantener.

**Alcance.** Contenido de la v1.5; tabla de trazabilidad entre la metodología anterior y los flujos nuevos; conversión a Word; control de cambios. · **Fuera de alcance:** redefinir los puertos y dominios (Despliegue); corregir el código señalado en los hallazgos (cada uno tiene su HU o va a triage).

**Criterios de aceptación.**
1. CA-1 Los 10 puntos de la sección A de REV-01 están corregidos y cada afirmación técnica cita rama y archivo, o la fuente externa con su fecha.
2. CA-2 Las secciones 1, 2, 4–8 y 11.3 describen el rol vigente: dos integrantes (el líder planifica y revisa, el integrante ejecuta); ramas propias con PR según el aprobador de cada rama; los tres flujos del Camino B.
3. CA-3 Dominios y puertos aparecen como información **recibida de Despliegue**, con fuente y fecha; los criterios de exposición (`expose` en lugar de `ports`, puertos de la BD) se mantienen como responsabilidad de Implementación.
4. CA-4 Incluye una tabla de trazabilidad: E1→E7, DOC-01…04 y FR-IMP-CE-04 hacia sus equivalentes nuevos (flujos y registros), con la justificación del cambio (ADR-001).
5. CA-5 Las salvedades de la §11.4 se migran a `registros/incidencias/registro.md` y el documento conserva solo el resumen con enlaces.
6. CA-6 Los puertos y flujos coinciden con el mapa de puertos v1.5 (HU-IMP-AMB-09).
7. CA-7 La fuente es `entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` y el Word se genera con `herramientas/md2docx.ps1`, conservando los estilos de la v1.4; portada y control de documento con los autores correctos.
8. CA-8 La sección "Control de cambios" resume las diferencias entre v1.4 y v1.5.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | REV-02: recorrer C1–C10 contra la v1.5 y reverificar con `git show origin/<rama>:<archivo>` | 10/10 corregidos | Tabla en REV-02 |
| CA-2 | Lectura de las secciones indicadas | Sin referencias al pipeline E1→E7 como flujo vigente ni a los roles A–D | Nota en REV-02 |
| CA-3 | Lectura de la §3.8 | Fuente "Despliegue" y fecha en dominios y puertos | Captura |
| CA-4 | Lectura | Tabla completa: cada elemento anterior tiene un equivalente o "retirado" con su motivo | Captura |
| CA-5 | `registros/incidencias/registro.md` | Cada salvedad vigente con ID, responsable y estado | Commit |
| CA-6 | Comparación con el mapa v1.5 | Sin diferencias | Nota en REV-02 |
| CA-7 | `powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` | `.docx` generado con portada, índice y tablas con estilo | Archivo `.docx` adjunto a la HU |
| CA-8 | Lectura | Control de cambios presente | Captura |

**Definición de terminado.**
- [ ] CA-1 a CA-8 con evidencia.
- [ ] PR en `SGMP-Integracion` aprobado por el líder.
- [ ] REV-02 con dictamen APROBAR.
- [ ] Word de la v1.5 entregado en la carpeta de Drive del Proyecto Integrador IV.

**Dependencias y aprobaciones.** HU-IMP-AMB-09 (coherencia de puertos), HU-IMP-SEG-01/02/03 (estado de las directrices) e INC-FE-01 (triage de `VITE_AGROFUSION_LOGIN_URL`). Aprueba: Líder de Implementación.

**Riesgos.** El código cambia mientras se escribe: hay que fijar una fecha de corte y reverificar las ramas antes del PR. Un Word editado a mano se desalinea del Markdown: solo se edita el `.md` y el Word se regenera.

**Referencias.** [REV-01](revisiones/REV-01.md) · `decisiones/ADR-001-flujos-por-tipo-de-trabajo.md` · `entregables/Ambiente-Trabajo-Implementacion.md` (fuente de la v1.1).

## Para copiar en Taiga — Subtareas

### ST-01 elaborar la v1.4 del documento de ambiente de trabajo — ✅ cerrar
**Objetivo.** Documentar ramas, roles, entornos, catálogo de variables, Dokploy, Sandbox, flujos e integración con AIoT.
**Entregable.** `AMBIENTE_DE_TRABAJO_IMPLEMENTACION_v1.4.docx`.
**Verificación.** REV-01 (fortalezas y hallazgos).
**Estado.** Hecha: se crea como cerrada.

### ST-02 corregir las afirmaciones contradichas por el código
**Objetivo.** Cumplir CA-1 (REV-01, sección A, puntos C1–C10).
**Pasos.**
1. Pasar el contenido de la v1.4 a `entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` (con `pandoc v1.4.docx -t gfm`, revisando las tablas).
2. Corregir C1–C10, verificando cada punto en la rama correspondiente.
3. Anotar la rama y el archivo de cada afirmación técnica.
**Entregable.** Markdown corregido.
**Verificación.** CA-1.
**Estimación.** 4 h

### ST-03 reescribir las secciones afectadas por la redefinición del rol
**Objetivo.** Cumplir CA-2 y CA-3 (REV-01, sección B).
**Pasos.** Reescribir las §1, §2.1–2.4, §3.8, §4–§8 y §11.3 según la tabla de propuestas de REV-01, tomando como base `CLAUDE.md` (alcance) y ADR-001 (flujos).
**Entregable.** Secciones reescritas.
**Verificación.** CA-2 y CA-3.
**Estimación.** 5 h

### ST-04 redactar la trazabilidad con la metodología anterior y migrar las salvedades
**Objetivo.** Cumplir CA-4 y CA-5.
**Pasos.**
1. Tabla de equivalencias (E1→E7, DOC-01…04, FR-IMP-CE-04 → flujos y registros).
2. Pasar cada salvedad vigente de la §11.4 a `registros/incidencias/registro.md` y dejar el resumen en el documento.
**Entregable.** Tabla y registro actualizado.
**Verificación.** CA-4 y CA-5.
**Estimación.** 2,5 h

### ST-05 alinear con el mapa de puertos, generar el Word y abrir el PR
**Objetivo.** Cumplir CA-6, CA-7 y CA-8.
**Pasos.**
1. Contrastar los puertos con el mapa v1.5 (HU-IMP-AMB-09).
2. Completar portada, control de documento y control de cambios.
3. Generar el `.docx` con `herramientas/md2docx.ps1`, actualizar la tabla de contenido en Word y revisar tablas e imágenes.
4. Abrir el PR y adjuntar el `.docx` a la HU.
**Entregable.** PR y Word de la v1.5.
**Verificación.** CA-6, CA-7 y CA-8.
**Estimación.** 2,5 h

## Notas para el líder (no copiar a Taiga)

- **Numeración:** dominio `DOC` nuevo, por eso empieza en 01. Si ya registran los documentos dentro de AMB, puede ser AMB-10.
- **Plazo sugerido:** 1 semana (14 h de trabajo pendiente). Conviene hacerla después de ST-04 de AMB-09 (flujos del broker corregidos), para no corregir dos veces.
- **Versión más reciente:** mencionaste que tienes una versión más reciente que la v1.4. Si es así, compártela: ST-02 debe partir de ella.
- **Uso del agente `documentador`:** puedes pedirle el borrador de la v1.5 y que Juan Hernando lo valide y complete. Así ST-02 y ST-03 se reducen sobre todo a verificación.

---
Fuentes (2026-10-12): `AMBIENTE_DE_TRABAJO_IMPLEMENTACION_v1.4.docx`; ramas citadas en REV-01.
