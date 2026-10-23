# ADR-002 — Organizar SGMP-Integracion por entregas al docente

> Estado: aceptada · Fecha: 2026-10-23 · Decide: Líder de Implementación

**Contexto.** El avance se reporta al docente por entrega y por módulo (E1 2026-10-13: M01, M09, M02 · E2 2026-11-03: M03, M04 · E3 2026-11-17: M05, M06 · E4 2026-11-24: M07, M08 y presentación final). Hasta ahora todas las HU estaban juntas en `historias/` y los documentos entregados estaban dispersos entre `entregables/`, las carpetas `entregables/` de cada HU y varias carpetas de Drive, con exportaciones (`.docx`, `.png`) versionadas junto a su fuente. Además, Implementación empieza a analizar PR y commits de otros equipos y necesita un lugar donde guardar ese análisis junto a la HU que genera.

**Opciones.**
1. *Índices por entrega*: dejar `historias/` como está y agregar un índice por entrega que enlace las HU. No mueve nada, pero lo entregado sigue disperso y una HU no muestra a qué entrega pertenece.
2. *Carpetas por entrega*: `entregas/E<N>_<fecha>_<módulos>/` con su índice, sus documentos y su trabajo agrupado por origen. Exige mover archivos y corregir enlaces una vez, pero cada entrega queda completa en un solo lugar.

**Decisión.** Opción 2.
- Una carpeta por entrega con `README.md` (alcance, trabajo, estado por módulo, documentos entregados y pendientes) y `documentos/`.
- El trabajo se agrupa por **origen**: `prs/<REPO>-PR<n>_<slug>/`, `commits/<REPO>-<sha7>_<slug>/`, `issues/<REPO>-<n>_<slug>/` y `propio/` (trabajo que no nace de algo ajeno). Dentro van el `analisis.md` del origen, si existe, y la HU que genere. `<REPO>` = `BACK`, `FRONT`, `BRK`, `DB`.
- Una HU vive en la entrega donde se plantea, aunque se cierre después; la entrega siguiente la enlaza en sus pendientes.
- Se versiona la fuente editable (`.md`, `.drawio`) y los recursos que incrusta (`documentos/img/`); las exportaciones del documento (`.docx`, `.pdf`) van a Drive (`G-Implementacion/entrega_N`). El README de la entrega anota el commit de la fuente entregada y el enlace de Drive.
- `registros/` se queda en la raíz: es estado del sistema que cruza entregas. `compose/`, `dockerfiles/`, `env/` y `scripts/` no se mueven.
- `entregas/README.md` reemplaza a `historias/README.md` como tablero general, con la columna Entrega.

**Consecuencias.**
- E1 se reorganizó con `git mv` (se conserva el historial); `historias/` y `entregables/` desaparecen. Las equivalencias de rutas están en el `README.md` del repositorio.
- Los dictámenes (`revisiones/REV-*.md`), los seguimientos y las evidencias conservan las rutas de su fecha: son registro histórico.
- Se retiró del repositorio el `.docx` del documento de ambiente de trabajo (sigue en el historial de Git y en Drive). El `.png` del mapa se conserva en `documentos/img/` porque el documento lo incrusta.
- La configuración de Claude Code del líder (agentes `planificador`, `revisor`, `documentador`, `analista-cambios` y skills relacionadas) ubica las HU con `entregas/*/**/HU-IMP-<DOM>-<NN>_*/` y guarda cada HU nueva en la entrega vigente: la primera cuya fecha es igual o posterior a hoy.
- Reemplaza el punto de ADR-001 que asignaba el trabajo a "las carpetas por historia de `historias/`".

**Referencias.** [ADR-001](ADR-001-flujos-por-tipo-de-trabajo.md) · [entregas/README.md](../entregas/README.md) · tablero de entregas del docente.
