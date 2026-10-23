# Entrega 1 — 2026-10-13 — Módulos M01, M09, M02
> Estado: entregada · Actualizado: 2026-10-23 · Responsable: Líder de Implementación

## Alcance
Ambientes DEV, TEST y PROD del SGPMP para los módulos M01, M09 y M02, el documento de ambiente de trabajo
de Implementación y el mapa de puertos y protocolos. [PENDIENTE: alcance exacto según el tablero del docente]

## Trabajo
| Origen | Tipo | HU | Módulos | Estado | Carpeta |
|---|---|---|---|---|---|
| Propio | Ambientes | HU-IMP-AMB-01 | Transversal | Completada | [propio/HU-IMP-AMB-01](propio/HU-IMP-AMB-01_compose-base/) |
| Propio | Ambientes | HU-IMP-AMB-02 | Transversal | Completada técnicamente | [propio/HU-IMP-AMB-02](propio/HU-IMP-AMB-02_catalogo-variables/) |
| Propio | Ambientes | HU-IMP-AMB-04 | Transversal | Completada técnicamente | [propio/HU-IMP-AMB-04](propio/HU-IMP-AMB-04_restauracion-dbintegrador/) |
| Propio | Ambientes | HU-IMP-AMB-05 | Transversal | Parcialmente avanzada | [propio/HU-IMP-AMB-05](propio/HU-IMP-AMB-05_gateway-aiot-mosquitto/) |
| Propio | Ambientes | HU-IMP-AMB-06 | Transversal | Completada | [propio/HU-IMP-AMB-06](propio/HU-IMP-AMB-06_ambiente-dev/) |
| Propio | Ambientes | HU-IMP-AMB-07 | Transversal | — | [propio/HU-IMP-AMB-07](propio/HU-IMP-AMB-07_ambiente-test/) |
| Propio | Ambientes | HU-IMP-AMB-08 | Transversal | Cerrada | [propio/HU-IMP-AMB-08](propio/HU-IMP-AMB-08_ambiente-prod/) |
| Propio | Ambientes | HU-IMP-AMB-09 | Transversal | Correcciones de REV-02 en `main`; cierre pendiente | [propio/HU-IMP-AMB-09](propio/HU-IMP-AMB-09_mapa-puertos-protocolos/) |
| Propio | Documentación | HU-IMP-DOC-01 | Transversal | Correcciones de REV-02 en `main`; cierre pendiente | [propio/HU-IMP-DOC-01](propio/HU-IMP-DOC-01_documento-ambiente-trabajo/) |
| [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266) | Directriz SEG-CICD-01 | HU-IMP-SEG-01 | Transversal | Borrador | [issues/BACK-266_SEG-CICD-01](issues/BACK-266_SEG-CICD-01/) |
| [SGPMP-FRONT-END-PWA#113](https://github.com/Arekkazu/SGPMP-FRONT-END-PWA/issues/113) | Directriz SEG-FE-02 | HU-IMP-SEG-02 | Transversal | Borrador | [issues/FRONT-113_SEG-FE-02](issues/FRONT-113_SEG-FE-02/) |
| [BROKER-MQTT-SGPMP PR #19](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/19) | Directriz SEG-BROKER-02 | HU-IMP-SEG-03 | Transversal | Borrador | [prs/BRK-PR19_SEG-BROKER-02-tls](prs/BRK-PR19_SEG-BROKER-02-tls/) |

## Estado por módulo
| Módulo | DEV | TEST | PROD | Notas |
|---|---|---|---|---|
| M01 | por verificar | por verificar | por verificar | Pendiente del próximo corte (`/auditar-seg` y registros de `registros/entornos/`) |
| M09 | por verificar | por verificar | por verificar | Ídem |
| M02 | por verificar | por verificar | por verificar | Ídem |

## Documentos entregados
| Documento | Versión | Fuente (commit) | Enlace Drive |
|---|---|---|---|
| [Ambiente de trabajo de Implementación](documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md) | v1.5 | `458d2b2` (2026-10-13) | [PENDIENTE: enlace Drive] |
| [Mapa de despliegue, puertos y protocolos](documentos/IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio) | v1.5 | `458d2b2` (2026-10-13); reacomodo de etiquetas en `90f000f` (2026-10-23) | [PENDIENTE: enlace Drive] |
| [Flujo Git](documentos/FLUJO-GIT.md) | — | `935ad6d` (2026-10-12) | [PENDIENTE: enlace Drive] |

Los commits citados son anteriores a la reorganización por entregas: en ellos los archivos están en
`historias/HU-IMP-DOC-01_documento-ambiente-trabajo/entregables/`, `historias/HU-IMP-AMB-09_mapa-puertos-protocolos/entregables/`
y `entregables/`. Las exportaciones (`.docx`, `.pdf`) están en Drive; la imagen que incrusta el documento de ambiente está en `documentos/img/`.

## Pendientes que pasan a la siguiente entrega
- [HU-IMP-SEG-01](issues/BACK-266_SEG-CICD-01/HU-IMP-SEG-01_cierre-seg-cicd-01/) — cerrar SEG-CICD-01.
- [HU-IMP-SEG-02](issues/FRONT-113_SEG-FE-02/HU-IMP-SEG-02_cabeceras-nginx-prod/) — cerrar SEG-FE-02.
- [HU-IMP-SEG-03](prs/BRK-PR19_SEG-BROKER-02-tls/HU-IMP-SEG-03_tls-broker-test-prod/) — TLS del broker en TEST y PROD.
