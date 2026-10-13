# HU-IMP-AMB-09 — Mapa de puertos y protocolos por ambiente (DEV, TEST, PROD)

> Estado: lista para crear en Taiga · Redactado: 2026-10-12 · Tipo: historia retroactiva. La v1.4 ya existe; las correcciones de la v1.5 salen de [REV-01](revisiones/REV-01.md).

## Para copiar en Taiga — Descripción de la HU

**Rama:** `docs/mapa-puertos-v1.5` en `SGMP-Integracion` → PR a `main` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Trabajo de Implementación para documentar la infraestructura donde corre el SGPMP en Dokploy. Parte del diagrama de despliegue de Diseño (PI3) y le agrega capas por ambiente. La v1.4 está terminada (`Diag_DESP_Ptos_Ptcls_v1.4.drawio`); la revisión REV-01 (2026-10-12) pide una v1.5.

**Situación actual.** La v1.4 tiene una capa base y capas activables para DEV, TEST/Sandbox, PROD, Protocolos, Hallazgos y Detalle de comunicación. Los dominios y la separación entre puertos internos y de host son correctos. Cuatro flechas no reflejan el flujo real:
- los Edge entran por el puerto de host, no por el 1883;
- el backend no habla MQTT;
- falta la conexión Gateway → PostgreSQL;
- falta la conexión Traefik → Gateway.

Además, el estado de seguridad del broker (ACL y TLS) está desactualizado, y no se distingue lo desplegado de la arquitectura objetivo. Con la redefinición del rol, cada puerto y protocolo debe indicar su fuente: Despliegue, AIoT o Desarrollo.

**Descripción.** Mantener un mapa confiable de cómo se comunican los componentes del SGPMP en cada ambiente: qué se publica por dominio y ruta, qué puertos de host existen y qué protocolos se usan internamente. Debe ser la referencia visual de Implementación para el triage de incidencias y para revisar los compose, y debe ser coherente con el documento de ambiente de trabajo.

**Alcance.** Diagrama draw.io (fuente) y su exportación a PNG; versionado en `SGMP-Integracion`; registro de los hallazgos CN-00X. · **Fuera de alcance:** asignar puertos o dominios (Despliegue); definir protocolos (AIoT y Desarrollo); corregir los hallazgos de seguridad (cada directriz tiene su HU SEG).

**Criterios de aceptación.**
1. CA-1 Cada flecha de la capa Protocolos corresponde a una comunicación real y se puede rastrear a un archivo de una rama (compose, `mosquitto.conf`, adaptador del backend) o a una fuente externa nombrada.
2. CA-2 El flujo del broker queda así: Backend → Traefik → Gateway (HTTPS, `/broker-sigab-<env>` → 8000); Gateway ↔ Mosquitto (MQTT 1883 interno); Gateway → PostgreSQL (5432 interno); Edge → Mosquitto por el puerto de host del ambiente (y 8883 al activar TLS).
3. CA-3 El estado de seguridad del broker se muestra por rama: ACL dynamic-security y soporte TLS en develop, test y main; TLS desactivado por defecto en el código de las tres ramas, y su activación en Dokploy la confirma Despliegue.
4. CA-4 Una leyenda "Fuente" indica quién define cada dato (Despliegue: dominios y puertos de host; AIoT: MQTT y TLS; compose: `expose`/`ports`) y la fecha de corte.
5. CA-5 Los elementos no desplegados (segunda instancia del backend, réplica de BD, servidor ML separado, SendGrid, balanceo) se distinguen como "Objetivo (no desplegado)".
6. CA-6 Los puertos de PROD coinciden con los del documento de ambiente de trabajo v1.5 y citan su fuente.
7. CA-7 Los hallazgos CN-001, CN-002 y CN-003 quedan registrados en `registros/incidencias/registro.md` con responsable y estado, y su ID aparece en el diagrama.
8. CA-8 El archivo se versiona en `SGMP-Integracion` como `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio` más su PNG, con un recuadro de control (versión, fecha, autor, cambios).

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | Tabla flecha → fuente en `revisiones/REV-02.md`; contraste con `git show origin/<rama>:<archivo>` | 100 % de las flechas con fuente | Tabla |
| CA-2 | Inspección del diagrama frente a `edge_sincronizacion_mqtt_adapter.py` (backend), `app/config.py` y `docker-compose.yml` (broker) | Las 4 conexiones dibujadas como en el CA | Captura de la capa Protocolos |
| CA-3 | Contraste con `registros/entornos/corte-2026-10-13.md` §2.4–§2.6 (`git merge-base --is-ancestor` de `seg-broker-01/02` y `git grep` de dynamic-security y `MQTT_PUERTO_PUBLICO` en `develop`, `test` y `main`) | Caja de Mosquitto y detalle CN-002/CN-003: ACL y soporte TLS en las tres ramas; TLS desactivado por defecto en el código; activación en Dokploy "por confirmar (Despliegue)" mientras no haya respuesta | Referencia al corte en la leyenda "Fuente" y, si existe, la confirmación de Despliegue en `evidencias/` |
| CA-4 | Inspección | Leyenda presente con fecha | Captura |
| CA-5 | Inspección | Elementos objetivo con estilo diferenciado | Captura |
| CA-6 | Comparación de la capa PROD con la §3.8 del documento v1.5 | Sin diferencias | Nota en REV-02 |
| CA-7 | Lectura del registro de incidencias | 3 filas CN con estado | Commit |
| CA-8 | `git log -- <ruta del drawio>` | Archivo y PNG versionados | Enlace al PR |

**Definición de terminado.**
- [ ] CA-1 a CA-8 con evidencia.
- [ ] PR en `SGMP-Integracion` aprobado por el líder.
- [ ] REV-02 con dictamen APROBAR.

**Dependencias y aprobaciones.** Confirmar con Despliegue los puertos de PROD (MQTT y WS) y 5449 publicado y restringido por firewall: confirmar las reglas con Despliegue. Confirmar con AIoT la fecha de activación de TLS (HU-IMP-SEG-03). Aprueba: Líder de Implementación.

**Riesgos.** El diagrama se desactualiza con cada promoción entre ramas: se mitiga con la fecha de corte (CA-4) y con la tabla de fuentes (CA-1), que permite reverificarlo rápido.

**Referencias.** [REV-01](revisiones/REV-01.md) · `registros/seguridad/registro-SEG.md` · HU-IMP-SEG-03 · HU-IMP-DOC-01.

## Para copiar en Taiga — Subtareas

### ST-01 construir la capa base a partir del diagrama de despliegue de Diseño — ✅ cerrar
**Objetivo.** Partir del diagrama de despliegue de PI3 como capa fija.
**Entregable.** Capa Base de la v1.4.
**Verificación.** Revisada en REV-01 (fortalezas).
**Estado.** Hecha en la v1.4: se crea como cerrada.

### ST-02 documentar los dominios y puertos de host por ambiente — ✅ cerrar
**Objetivo.** Capas DEV, TEST/Sandbox y PROD con dominios, rutas y puertos.
**Entregable.** Tres capas de la v1.4.
**Verificación.** Los dominios coinciden con los informados por Despliegue (REV-01).
**Estado.** Hecha en la v1.4: se crea como cerrada.

### ST-03 documentar los protocolos internos, los hallazgos y el detalle de comunicación — ✅ cerrar (sus correcciones van en ST-04)
**Objetivo.** Capas Protocolos, Hallazgos y Detalle.
**Entregable.** Tres capas de la v1.4.
**Verificación.** REV-01: CN-001 confirmado; las flechas del broker requieren corrección.
**Estado.** Hecha en la v1.4: se crea como cerrada; sus correcciones van en ST-04 y ST-05.

### ST-04 corregir los flujos del broker y del gateway
**Objetivo.** Cumplir CA-1 y CA-2 (hallazgos M1–M4).
**Pasos.**
1. Edge → Mosquitto por el puerto de host del ambiente (1884/1885), con la nota de TLS (8883).
2. Reemplazar las flechas Broker → Backend por Backend → Traefik → Gateway (HTTPS) y Gateway ↔ Mosquitto (MQTT 1883).
3. Agregar Gateway → PostgreSQL (5432 interno) y Traefik → Gateway (8000).
4. Armar la tabla flecha → fuente.
**Entregable.** Diagrama con la capa Protocolos corregida y la tabla de fuentes.
**Verificación.** CA-1 y CA-2.
**Estimación.** 3 h

### ST-05 actualizar el estado de seguridad del broker por rama
**Objetivo.** Cumplir CA-3 (hallazgo M5).
**Pasos.** Verificar con `git merge-base` las ramas `seg-broker-01/02` en `develop`, `test` y `main`, y actualizar la caja de Mosquitto y el detalle CN-002/CN-003.
**Entregable.** Capa Base y capa Detalle actualizadas.
**Verificación.** CA-3.
**Estimación.** 1,5 h

### ST-06 agregar la leyenda de fuentes y separar lo desplegado de lo objetivo
**Objetivo.** Cumplir CA-4 y CA-5 (hallazgos A1 y A2).
**Pasos.**
1. Leyenda "Fuente" con la fecha de corte.
2. Estilo punteado y rótulo "Objetivo (no desplegado)" en los elementos que aún no existen.
**Entregable.** Diagrama actualizado.
**Verificación.** CA-4 y CA-5.
**Estimación.** 2 h

### ST-07 unificar PROD, registrar los hallazgos y publicar la v1.5
**Objetivo.** Cumplir CA-6, CA-7 y CA-8 (hallazgos m1–m5).
**Pasos.**
1. Confirmar con Despliegue los puertos de PROD y alinearlos con el documento v1.5.
2. Registrar CN-001…003 en `registros/incidencias/registro.md`.
3. Aclarar el WS 9002 de TEST y anotar el firewall de 5447/5448.
4. Renombrar el archivo, agregar el recuadro de control, exportar a PNG y abrir el PR.
**Entregable.** PR con el `.drawio` y el `.png` de la v1.5.
**Verificación.** CA-6, CA-7 y CA-8.
**Estimación.** 2,5 h

## Notas para el líder (no copiar a Taiga)

- **Numeración:** se propone **AMB-09** porque continúa la serie de ambientes (la última conocida es AMB-08). Cámbiala si en Taiga ya existe una AMB-09.
- **Subtareas cerradas:** ST-01 a ST-03 documentan lo ya hecho; créalas con estado *Closed* para que el tablero refleje el esfuerzo real.
- **Plazo sugerido:** 2 a 3 días hábiles (9 h de trabajo pendiente).
- **Pregunta abierta:** ¿confirmas que Juan Hernando es el autor de la v1.4? El archivo no lo registra.

---
Fuentes (2026-10-12): `Diag_DESP_Ptos_Ptcls_v1.4.drawio`; ramas citadas en REV-01.
