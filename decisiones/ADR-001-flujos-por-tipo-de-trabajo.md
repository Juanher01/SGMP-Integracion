# ADR-001 — Reemplazar el pipeline E1→E7 por flujos según el tipo de trabajo (Camino B)

> Estado: aceptada · Fecha: 2026-10-12 · Decide: Líder de Implementación

**Contexto.** En octubre de 2026 el líder del proyecto (Daniel) redefinió el rol de Implementación. Los endpoints y la conexión backend–frontend pasaron a Desarrollo; los protocolos, a Desarrollo y AIoT; los puertos, a Despliegue. Implementación queda a cargo de las imágenes (Dockerfile, `.dockerignore`, compose), los entornos DEV/TEST/PROD, las variables de entorno, el nginx, los issues de comunicación entre componentes y el cumplimiento de las directrices de seguridad de Análisis. El pipeline E1→E7 procesaba **módulos** (M01…M09), y sus etapas E1–E3 verificaban endpoints, contratos, puertos y protocolos, que ya no son del equipo. Además, el equipo pasó a tener dos integrantes.

**Opciones.**
1. *Camino A*: conservar E1→E7 y redefinir cada etapa para cambios de infraestructura. Da continuidad con la metodología aprobada, pero impone siete compuertas a cambios a veces de una línea.
2. *Camino B*: reemplazarlo por tres flujos cortos según el tipo de trabajo, con registros vivos y una tabla de trazabilidad hacia la metodología anterior.

**Decisión.** Camino B. La unidad de trabajo pasa a ser la **solicitud de cambio sobre la infraestructura**, y no el módulo. Los tres flujos son:
- **Cambio de configuración**: solicitud → cambio en DEV → promoción a TEST → promoción a PROD.
- **Directriz de seguridad**: plan → implementación por rama → evidencia → cierre con Análisis.
- **Incidencia de comunicación**: síntoma → triage → causa → corrección o derivación.

**Consecuencias.**
- La metodología, las métricas y los formatos FR-IMP deben reescribirse. Se requiere una tabla de trazabilidad (DOC-01…04 y FR-IMP-CE-04 → registros nuevos) para justificar el cambio ante el docente.
- Los registros vivos de `registros/` y las carpetas por historia de `historias/` reemplazan a las matrices por módulo.
- El trabajo se planifica en Taiga como HUs con subtareas (`HU-IMP-<DOM>-<NN>`). Juan Hernando ejecuta, el líder revisa con el apoyo del agente `revisor`.
- La promoción DEV → TEST → PROD es el eje común de los tres flujos.

**Referencias.** Conversación de definición del 2026-10-12 · `CLAUDE.md` · skill `promocion-entornos`.
