# Entregas e historias de usuario de Implementación

> Estado: vigente · Actualizado: 2026-10-23 · Responsable: Líder de Implementación

Una carpeta por entrega al docente ([ADR-002](../decisiones/ADR-002-organizacion-por-entregas.md)). Dentro, el trabajo se agrupa por **origen**:

```
E<N>_<fecha>_<módulos>/
├── README.md        ← índice de la entrega: trabajo, estado por módulo, documentos entregados, pendientes
├── documentos/      ← fuente de lo entregado (.md, .drawio) y los recursos que incrusta (img/)
├── prs/       <REPO>-PR<n>_<slug>/   ← analisis.md + HU-IMP-…/
├── commits/   <REPO>-<sha7>_<slug>/  ← analisis.md + HU-IMP-…/
├── issues/    <REPO>-<n>_<slug>/     ← p. ej. directrices SEG + HU-IMP-…/
└── propio/    HU-IMP-…/              ← trabajo que no nace de algo ajeno
```

Se versiona la fuente editable y los recursos que incrusta; las exportaciones del documento (`.docx`, `.pdf`) van a Drive.

`<REPO>` = `BACK`, `FRONT`, `BRK` o `DB`. Una HU vive en la entrega donde se plantea, aunque se cierre después; la entrega siguiente la enlaza en sus pendientes.

Cada carpeta de HU conserva su estructura:

```
HU-IMP-XXX-NN_slug/
├── historia.md      ← texto de la HU y sus subtareas (lo que se copia a Taiga)
├── entregables/     ← lo que produce el responsable
├── evidencias/      ← salidas de comandos y capturas
└── revisiones/      ← REV-01.md, REV-02.md… (dictamen y retroalimentación)
```

Dominios: `AMB` ambientes · `SEG` directrices de seguridad · `CFG` configuración · `INC` incidencias · `DOC` documentación.
Formato de `historia.md`: skill `hu-taiga` (en la configuración de Claude Code del líder).

## Entregas

| Entrega | Fecha | Módulos | Estado | Carpeta |
|---|---|---|---|---|
| E1 | 2026-10-13 | M01, M09, M02 | entregada | [E1](E1_2026-10-13_M01-M09-M02/) |
| E2 | 2026-11-03 | M03, M04 | en curso | [E2](E2_2026-11-03_M03-M04/) |
| E3 | 2026-11-17 | M05, M06 | por iniciar | [E3](E3_2026-11-17_M05-M06/) |
| E4 | 2026-11-24 | M07, M08 y presentación final | por iniciar | [E4](E4_2026-11-24_M07-M08-final/) |

## Tablero

| ID | Título | Entrega | Taiga | Estado | Responsable | Carpeta |
|---|---|---|---|---|---|---|
| HU-IMP-AMB-01 | Compose base y convención de orquestación | E1 | — | Completada | Juan Esteban Hernández | [AMB-01](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-01_compose-base/) |
| HU-IMP-AMB-02 | Catálogo unificado de variables de entorno | E1 | — | Completada técnicamente | — | [AMB-02](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-02_catalogo-variables/) |
| HU-IMP-AMB-03 | — | E1 | — | Sin documentos en el repositorio | — | — |
| HU-IMP-AMB-04 | Restauración controlada de DBIntegrador | E1 | — | Completada técnicamente (según su reporte, PR pendiente de revisión) | Juan Hernando Perdomo | [AMB-04](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-04_restauracion-dbintegrador/) |
| HU-IMP-AMB-05 | Gateway AIoT y Mosquitto | E1 | — | Parcialmente avanzada | Juan Hernando Perdomo | [AMB-05](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-05_gateway-aiot-mosquitto/) |
| HU-IMP-AMB-06 | Montaje del ambiente DEV | E1 | — | Completada | — | [AMB-06](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-06_ambiente-dev/) |
| HU-IMP-AMB-07 | Montaje del ambiente TEST | E1 | — | — | Juan Sebastián Gutiérrez | [AMB-07](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-07_ambiente-test/) |
| HU-IMP-AMB-08 | Definición y entrega del ambiente PROD | E1 | #1702 | Cerrada | Juan Sebastián Gutiérrez | [AMB-08](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-08_ambiente-prod/) |
| HU-IMP-AMB-09 | Mapa de puertos y protocolos por ambiente | E1 | por crear | Correcciones de REV-02 en `main` (PR #16, 2026-10-23); cierre pendiente del líder | Juan Hernando Perdomo | [AMB-09](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-AMB-09_mapa-puertos-protocolos/) |
| HU-IMP-DOC-01 | Documento de ambiente de trabajo v1.4 → v1.5 | E1 | por crear | Correcciones de REV-02 en `main` (PR #16, 2026-10-23); cierre pendiente del líder | Juan Hernando Perdomo | [DOC-01](E1_2026-10-13_M01-M09-M02/propio/HU-IMP-DOC-01_documento-ambiente-trabajo/) |
| HU-IMP-SEG-01 | Cerrar SEG-CICD-01 (evidencia por rama, `release.yml` y cierre con Análisis) | E1 | por crear | Borrador actualizado al corte 2026-10-13 | Juan Hernando Perdomo | [SEG-01](E1_2026-10-13_M01-M09-M02/issues/BACK-266_SEG-CICD-01/HU-IMP-SEG-01_cierre-seg-cicd-01/) |
| HU-IMP-SEG-02 | Cerrar SEG-FE-02 (evidencia de cabeceras, CSP y cierre; código ya en `main`) | E1 | por crear | Borrador actualizado al corte 2026-10-13 | Juan Hernando Perdomo | [SEG-02](E1_2026-10-13_M01-M09-M02/issues/FRONT-113_SEG-FE-02/HU-IMP-SEG-02_cabeceras-nginx-prod/) |
| HU-IMP-SEG-03 | Activar TLS del broker en TEST y preparar PROD | E1 | por crear | Borrador actualizado al corte 2026-10-13 | Juan Hernando Perdomo | [SEG-03](E1_2026-10-13_M01-M09-M02/prs/BRK-PR19_SEG-BROKER-02-tls/HU-IMP-SEG-03_tls-broker-test-prod/) |

Pendiente: importar a `historia.md` el texto de Taiga de AMB-01 a AMB-07 y completar los números de Taiga.
