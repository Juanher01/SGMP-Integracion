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
| E3 | 2026-11-17 | M05, M06 | entregada (2026-11-17) | [E3](E3_2026-11-17_M05-M06/) |
| E4 | 2026-11-24 | M07, M08 y presentación final | en curso | [E4](E4_2026-11-24_M07-M08-final/) |

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
| HU-IMP-DOC-02 | Ambiente de trabajo y mapa de puertos v1.6 con el motor de inferencia M04 (`motor-ia`) | E2 | por crear | Borrador (corte 2026-11-02) | Juan Hernando Perdomo | [DOC-02](E2_2026-11-03_M03-M04/prs/BRK-PR54_motor-ia/HU-IMP-DOC-02_motor-ia-ambiente-y-mapa/) |
| HU-IMP-CFG-03 | El backend monta la clave pública del SSO de AgroFusion y la imagen no incluye claves | E3 | por crear | Fase 2 (verificación de documentación) en el PR #18; REV-03 aprobado con observaciones (2026-11-20). Montaje en `dev` y `test` (`0dbe294`, PR #1130); faltan `main` (release #941), `SGPMP_ENTORNO` en TEST (PR #1204), ST-05 y el envío de la ficha a Despliegue | Juan Hernando Perdomo | [CFG-03](E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-03_agrofusion-sso/) |
| HU-IMP-CFG-04 | TEST recibe y documenta las variables de M04/M07 (`SGPMP_ENTORNO=TEST`) sin romper el respaldo de auditoría IoT | E4 | en Taiga | En ejecución (2026-11-22): ST-01 a ST-04b, ST-05 y ST-07 hechas; PR #1216 (`test`) y #1217 (`dev`) fusionados el 2026-11-21; PR #1220 (`test`, tabla de cabecera) abierto; ST-04c ampliada el 2026-11-22 (volúmenes de TEST y Dockerfile de #1224; absorbe HU-IMP-AMB-10) y ST-04d nueva; ST-04c, ST-04d y ST-06 esperan la fusión de PR #1204 (BE) y el Deploy; ficha entregada a Despliegue, respuesta pendiente | Juan Hernando Perdomo | [CFG-04](E4_2026-11-24_M07-M08-final/issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/) |
| HU-IMP-AMB-11 | El catálogo de variables y las plantillas locales reflejan el contrato real del gateway del broker (`MQTT_TLS=false`, sin `GATEWAY_API_TOKEN`, variables de BRK-10) | E4 | por crear | En ejecución (2026-11-22): HU en `main` (PR #25); ST-01 a ST-04 hechas en `docs/amb-11-ejecucion-catalogo-broker`; el PR de la ejecución queda abierto hasta comparar con las variables de Dokploy | Sebastián Sandoval | [AMB-11](E4_2026-11-24_M07-M08-final/prs/BRK-PR35_compose-prod-broker/HU-IMP-AMB-11_catalogo-broker-mqtt-tls/) |

Pendiente: importar a `historia.md` el texto de Taiga de AMB-01 a AMB-07 y completar los números de Taiga.
