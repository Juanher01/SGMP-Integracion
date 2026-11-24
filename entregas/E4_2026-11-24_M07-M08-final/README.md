# Entrega 4 — 2026-11-24 — Módulos M07, M08 y presentación final
> Estado: en curso · Actualizado: 2026-11-22 · Responsable: Líder de Implementación

## Alcance
Módulos M07, M08 y presentación final. [PENDIENTE: alcance exacto según el tablero del docente]

## Trabajo
| Origen | Tipo | HU | Módulos | Estado | Carpeta |
|---|---|---|---|---|---|
| [BACK #1180](https://github.com/Arekkazu/sgpmp-backend/issues/1180) (`SGPMP_ENTORNO` en TEST) | Issue externo | HU-IMP-CFG-04 | M07, M04 | en ejecución (2026-11-22): PR #1216 y #1217 fusionados (21-11); PR #1220 abierto (m-04); ST-04c ampliada con los volúmenes de TEST y el Dockerfile de #1224 (absorbe HU-IMP-AMB-10) y ST-04d nueva · INC-BE-09, INC-BE-02, INC-BE-10 | [issues/BACK-1180_sgpmp-entorno-test/](issues/BACK-1180_sgpmp-entorno-test/HU-IMP-CFG-04_variables-m04-entorno-test/) |
| [BACK PR #1204](https://github.com/Arekkazu/sgpmp-backend/pull/1204) (compose de TEST: entorno y M04) | PR externo | HU-IMP-CFG-04 | M07, M04 | analizado · commit de Implementación `097f6d80` (ST-04b) · abierto al 2026-11-21 | [prs/BACK-PR1204_compose-test-entorno-m04/](prs/BACK-PR1204_compose-test-entorno-m04/) |
| [BROKER PR #35](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/35) (compose PROD del broker; plan en E2) | PR externo | HU-IMP-AMB-11 | M03/M04 (gateway) | en ejecución (2026-11-23): HU en `main` (PR #25); ST-01 a ST-04 hechas; ST-05 en el PR #27: comparación con Dokploy del backend hecha, REV-03 aprobar con observaciones; pendiente gateway y Mosquitto (AIoT), no bloquea la fusión | [prs/BRK-PR35_compose-prod-broker/](prs/BRK-PR35_compose-prod-broker/HU-IMP-AMB-11_catalogo-broker-mqtt-tls/) |
| [BACK PR #1223](https://github.com/Arekkazu/sgpmp-backend/pull/1223) / [#1224](https://github.com/Arekkazu/sgpmp-backend/pull/1224) (carpeta de modelos del UID 1000 en el Dockerfile) y commit `e2ec9ed5` (volumen de auditoría IoT en PROD) | PR externo | HU-IMP-CFG-04 (ST-04c) | M04, M03 | en seguimiento: falta el Dockerfile en `test` (cherry-pick en CFG-04 ST-04c) y que Desarrollo registre BOV-001 y TER-001 en PROD tras el redespliegue · INC-BE-10 | [prs/BACK-PR1223_volumen-modelos-uid1000/](prs/BACK-PR1223_volumen-modelos-uid1000/) |
| Hallazgos de E4 (curl 2026-11-23, HU-IMP-AMB-11, HU-IMP-CFG-04, Taiga #5478) | Propio | HU-IMP-DOC-03 | Transversal | en revisión final: REV-02 aprobada con observaciones; PR #32 y PR de la ST-04 por fusionar · Taiga #6071 | [propio/HU-IMP-DOC-03_ambiente-v1.7/](propio/HU-IMP-DOC-03_ambiente-v1.7/) |

## Estado por módulo
| Módulo | DEV | TEST | PROD | Notas |
|---|---|---|---|---|

## Documentos entregados
| Documento | Versión | Fuente (commit) | Enlace Drive |
|---|---|---|---|
| Documento de Ambiente de Trabajo y mapa de puertos (`documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`, `documentos/IMP_Diag_Despliegue_Puertos_Protocolos_v1.7.drawio`) | 1.7 | `5de6495` (rama `docs/ambiente-v1.7-final`, PR #33) | Por agregar |

## Pendientes que pasan a la siguiente entrega
