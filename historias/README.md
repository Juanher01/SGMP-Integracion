# Historias de usuario de Implementación

> Estado: vigente · Actualizado: 2026-10-13 · Responsable: Líder de Implementación

Una carpeta por historia de Taiga: `HU-IMP-<DOM>-<NN>_<slug>/`.

```
HU-IMP-XXX-NN_slug/
├── historia.md      ← texto de la HU y sus subtareas (lo que se copia a Taiga)
├── entregables/     ← lo que produce el responsable
├── evidencias/      ← salidas de comandos y capturas
└── revisiones/      ← REV-01.md, REV-02.md… (dictamen y retroalimentación)
```

Dominios: `AMB` ambientes · `SEG` directrices de seguridad · `CFG` configuración · `INC` incidencias · `DOC` documentación.
Formato de `historia.md`: skill `hu-taiga` (en la configuración de Claude Code del líder).

## Tablero

| ID | Título | Taiga | Estado | Responsable | Carpeta |
|---|---|---|---|---|---|
| HU-IMP-AMB-01 | Compose base y convención de orquestación | — | Completada | Juan Esteban Hernández | [AMB-01](HU-IMP-AMB-01_compose-base/) |
| HU-IMP-AMB-02 | Catálogo unificado de variables de entorno | — | Completada técnicamente | — | [AMB-02](HU-IMP-AMB-02_catalogo-variables/) |
| HU-IMP-AMB-04 | Restauración controlada de DBIntegrador | — | Completada técnicamente (según su reporte, PR pendiente de revisión) | Juan Hernando Perdomo | [AMB-04](HU-IMP-AMB-04_restauracion-dbintegrador/) |
| HU-IMP-AMB-05 | Gateway AIoT y Mosquitto | — | Parcialmente avanzada | Juan Hernando Perdomo | [AMB-05](HU-IMP-AMB-05_gateway-aiot-mosquitto/) |
| HU-IMP-AMB-06 | Montaje del ambiente DEV | — | Completada | — | [AMB-06](HU-IMP-AMB-06_ambiente-dev/) |
| HU-IMP-AMB-07 | Montaje del ambiente TEST | — | — | Juan Sebastián Gutiérrez | [AMB-07](HU-IMP-AMB-07_ambiente-test/) |
| HU-IMP-AMB-08 | Definición y entrega del ambiente PROD | #1702 | Cerrada | Juan Sebastián Gutiérrez | [AMB-08](HU-IMP-AMB-08_ambiente-prod/) |
| HU-IMP-AMB-09 | Mapa de puertos y protocolos por ambiente | por crear | Revisión REV-01: solicitar cambios | Juan Hernando Perdomo | [AMB-09](HU-IMP-AMB-09_mapa-puertos-protocolos/) |
| HU-IMP-DOC-01 | Documento de ambiente de trabajo v1.4 → v1.5 | por crear | Revisión REV-01: solicitar cambios | Juan Hernando Perdomo | [DOC-01](HU-IMP-DOC-01_documento-ambiente-trabajo/) |
| HU-IMP-SEG-01 | Cerrar SEG-CICD-01 (evidencia por rama, `release.yml` y cierre con Análisis) | por crear | Borrador actualizado al corte 2026-10-13 | Juan Hernando Perdomo | [SEG-01](HU-IMP-SEG-01_cierre-seg-cicd-01/) |
| HU-IMP-SEG-02 | Cerrar SEG-FE-02 (evidencia de cabeceras, CSP y cierre; código ya en `main`) | por crear | Borrador actualizado al corte 2026-10-13 | Juan Hernando Perdomo | [SEG-02](HU-IMP-SEG-02_cabeceras-nginx-prod/) |
| HU-IMP-SEG-03 | Activar TLS del broker en TEST y preparar PROD | por crear | Borrador actualizado al corte 2026-10-13 | Juan Hernando Perdomo | [SEG-03](HU-IMP-SEG-03_tls-broker-test-prod/) |

Pendiente: importar a `historia.md` el texto de Taiga de AMB-01 a AMB-07 y completar los números de Taiga. La AMB-03 no tiene documentos en el repositorio.
