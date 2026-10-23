# HU-IMP-AMB-08 — Definición y entrega del ambiente PROD

> Estado en Taiga: **#1702 · CLOSED (Aprobado/Completado)** · Creada: 2026-08-19 por Sebastián Sandoval Chavarro · Asignados: Juan Sebastián Gutiérrez, Sebastián Sandoval Chavarro · Importada al repositorio: 2026-10-12 (texto tomado de Taiga, sin cambios)

**Rama:** `feat/ambiente-prod` · **Plazo:** definición jueves 09:00

**Descripción.** Definir PROD con las cuatro capas (imágenes de GHCR y capas recibidas) y delimitar la frontera con Despliegue, quien lo opera con Dokploy. Debe determinarse si el *gateway* y la BD en PROD los orquesta el compose entregado por Implementación o los gestiona Despliegue.

**Criterios de aceptación.**
1. Existe `compose.prod.yml` + `.env.prod.example` con las cuatro capas referenciando GHCR.
2. Se documenta la equivalencia TEST ≡ STAGING y la frontera de entrega (imágenes/*tags*, migraciones, *healthchecks*, volúmenes).
3. Se resuelve, con AIoT y Despliegue, quién orquesta el *gateway* y la BD en PROD.
4. Se elevan a los líderes las inconsistencias de la documentación de Despliegue.

## Subtareas (Taiga)

| # | Subtarea | Estado | Entregable en el repositorio |
|---|---|---|---|
| #1732 | ST-01 confirmar con Despliegue artefactos y equivalencia TEST/STAGING | Closed | [`registros/entornos/CONTRATO-PROD.md`](../../../../registros/entornos/CONTRATO-PROD.md) |
| #1733 | ST-02 documento de frontera Implementación → Despliegue | Closed | [`registros/entornos/CONTRATO-PROD.md`](../../../../registros/entornos/CONTRATO-PROD.md) |
| #1734 | ST-03 `compose.prod.yml` + `.env.prod.example` (cuatro capas, GHCR) | Closed | [`entregables/ST-03-configuracion-env-prod.md`](entregables/ST-03-configuracion-env-prod.md) |
| #1735 | ST-04 acordar orquestación de gateway/BD en PROD | Closed | [`entregables/ST-04-orquestacion-gateway-bd-prod.md`](entregables/ST-04-orquestacion-gateway-bd-prod.md) |

## Notas

- Los entregables de validación de PROD por repositorio (`PI4/entregables-prod-backend`, `-frontend` y `-broker`: reportes, descripciones de PR y `compose.local.yml`) están fuera del repositorio. Se incorporarán a `entregables/` de esta HU cuando se revisen; los `compose.local.yml` seguirán sin versionarse, a propósito.
- Observación de la revisión de 2026-10-12: el CA-1 menciona GHCR, pero ningún repositorio publica imágenes en GHCR; Dokploy construye desde la rama. Ver la salvedad "Imágenes sin publicar en GHCR" del documento de ambiente v1.4.
