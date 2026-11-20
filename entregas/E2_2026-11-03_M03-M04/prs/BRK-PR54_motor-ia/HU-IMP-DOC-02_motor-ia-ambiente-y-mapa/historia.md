# HU-IMP-DOC-02 — El documento de ambiente de trabajo y el mapa de puertos (v1.6) incorporan el motor de inferencia M04 (`motor-ia`) tal como está en el código y en los entornos

> Estado: borrador para Taiga · Redactado: 2026-11-02 · Corte: `git fetch --prune` 2026-11-02 13:20 -0500 · Origen: [SerBy48/BROKER-MQTT-SGPMP#54](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/54) (fusionado) e insumos de `../../../motor_ia/` (sin versionar)

## Para copiar en Taiga — Descripción de la HU

**Rama:** `docs/motor-ia-ambiente-mapa-v1.6` en `SGMP-Integracion` (desde `origin/main`) → PR a `main` · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval · **Entrega:** E2 · **Módulos:** M04 (y M03 por el gateway)

**Origen.** PR de otro equipo — [BROKER-MQTT-SGPMP#54](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/54) `feat/motor-ia-e2-despliegue` → `develop`, fusionado el 2026-11-01 (merge `102b2c5`, head `3fe7839`). Autores: Sebastián Sandoval (versión inicial `89654ee` y correcciones `789eb7b`) y Arekkazu, Desarrollo (`06f951b`, `3fe7839`). Continúa con PR #57, #58 y #60 en `develop` (2026-11-01 y 2026-11-02). Documentos de origen: `AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` v1.5 (HU-IMP-DOC-01) y `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio` (HU-IMP-AMB-09), entregados en E1.

**Situación actual.** Corte 2026-11-02 13:20 -0500. Hashes: broker `develop@c5f43ab` (0.4.0-rc.18) · `test@662e096` · `main@cebd430`; backend `dev@6cf3c036` · `test@c4be97a1` · `main@0abbeeef`; frontend `dev@e7a5613a` · `test@298492ed` · `main@95f3e563`; SGMP-Integracion `main@0fa672e`. Los documentos v1.5 (corte 2026-10-13) no mencionan el motor: el mapa solo muestra un "Servidor ML" como **objetivo (no desplegado)**.

| Rama (broker) | Archivos del motor | Puerto | Modelos | Evidencia |
|---|---|---|---|---|
| `develop` (DEV) | ✅ `Dockerfile.motor-ia`, `.dockerignore`, `docker-compose.motor-ia.yml` (solo local), `.env.motor-ia.example`, `motor_ia/`, `docs/MOTOR_IA_MODELOS_DOKPLOY.md` | `PORT=8100`, `EXPOSE 8100`, healthcheck a `127.0.0.1:${PORT}/v1/healthz` | Artefactos de ET-02 (BOV-001, TER-001) **dentro de la imagen** (`COPY artefactos_et02/ /data/modelos/`), `catalogo.json` por File Mount; sincronización del catálogo con el backend (`MOTOR_IA_SINCRONIZACION_S`, `MOTOR_IA_CALIBRACION_HORAS`) | `git show origin/develop:Dockerfile.motor-ia`; commits `d54b4bf` (#57), `fe24f0a` (#58), `6d81179` (#60) |
| `test` (TEST) | ✅ los mismos archivos, en la versión de `3fe7839` | 8100 | Sin artefactos en la imagen; guía de Bind Mount en `/data/modelos`; sin variables de sincronización | `git merge-base --is-ancestor 3fe7839 origin/test` → INCLUIDO; `6d81179` → AUSENTE |
| `main` (PROD) | ❌ ninguno | — | — | `git ls-tree --name-only origin/main` sin `Dockerfile.motor-ia` ni `motor_ia/` |

| Entorno desplegado (curl 2026-11-02 13:20 -0500) | Resultado |
|---|---|
| `https://api.inmero.co/motor-ia-dev/v1/healthz` | **200** `{"status":"ok","modelos_cargados":3,"backend":"https://api.inmero.co/api-sgpmp-dev/prediccion/inferencias","sincronizacion":{…}}` |
| `/model-ia-dev`, `/model-ia-test`, `/model-ia`, `/motor-ia-test`, `/motor-ia` (`/v1/healthz`) | 404 |
| Backend: `/back-sigab-dev/health` · `/back-sigab-test/health` | 404 · 404 |
| Backend: `/api-sgpmp-dev/health` · `/api-sgpmp-test/health` | 200 · 200 |
| Gateway: `/broker-sigab-dev/v1/healthz` · `/broker-sigab-test/v1/healthz` | 404 · 200 |
| Frontend: `https://dev.inmero.co/` · `api.inmero.co/sigab-dev/` · `api.inmero.co/sigab-test/` | 404 · 200 · 200 |

Backend (cliente del motor): `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_M04_TOKEN`, `IOT_INFERENCIA_TLS_MIN` e `IOT_INFERENCIA_CA_FILE` se reenvían en `docker-compose.yml` (l. 84-87) y `docker-compose.prod.yml` (l. 157-160) de `dev` (PR #909, fusionado el 2026-11-01). En `test` están en esos dos archivos, pero **no** en `docker-compose.test.yml`. En `main` no están.

**Descripción.** Publicar la v1.6 del documento de ambiente de trabajo y del mapa de puertos y protocolos con el motor de inferencia M04 como componente nuevo. Hay que mostrar su imagen, sus variables, su puerto, su ruta pública por entorno, sus flujos con el backend y su estado por rama: DEV desplegado, TEST con el código pero sin ruta pública que responda, y PROD sin código en `main`. Cada dato debe citar el código o la fuente de Despliegue con su fecha. Las fuentes de la v1.6 se guardan en la carpeta de la entrega E2. Las de la v1.5 quedan sin cambios en E1, como registro de lo entregado.

**Alcance.** Fuentes v1.6 de los dos documentos en `entregas/E2_2026-11-03_M03-M04/documentos/` y su PNG. La tabla flecha → fuente de la v1.6. Las rutas públicas observadas de backend, frontend y gateway (ST-05). El registro de los hallazgos de comunicación en el registro vivo. El Word generado con `md2docx.ps1`. · **Fuera de alcance:** asignar dominios, rutas, Container Port, tipo de servicio, volúmenes o límites en Dokploy (**Despliegue**). Corregir el prefijo `/model-ia-*` en los comentarios del código del motor y del `.env.example` del backend (**Desarrollo / AIoT**). Agregar las `IOT_INFERENCIA_*` al `docker-compose.test.yml` del backend (Implementación, **otra HU de tipo CFG**). Corregir los insumos de `motor_ia/` (líder). Promover el motor a `main` (AIoT y Despliegue).

**Criterios de aceptación.**
1. CA-1 **Fecha de corte.** La sección "Fuentes y fecha de corte" del documento y la leyenda "Fuente" del mapa citan la fecha del `git fetch --prune` y los hashes de broker `develop`/`test`/`main` y backend `dev`/`test`/`main` (y del frontend si se hace ST-05). El fetch se repite el día del PR: si una rama avanzó, el hash nuevo se anota y se reverifican las afirmaciones sobre esa rama. No se copian los hashes de esta HU sin reverificarlos.
2. CA-2 **Ubicación y nombres.** Existen exactamente `entregas/E2_2026-11-03_M03-M04/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` (`version: "1.6"`), `entregas/E2_2026-11-03_M03-M04/documentos/IMP_Diag_Despliegue_Puertos_Protocolos_v1.6.drawio` y `entregas/E2_2026-11-03_M03-M04/documentos/img/imp_diag_despliegue_puertos_protocolos_v1.6.png`. El `.md` incrusta ese PNG con la ruta relativa `img/…v1.6.png`. Los archivos de `entregas/E1_2026-10-13_M01-M09-M02/documentos/` no cambian.
3. CA-3 **Motor en el documento.** La v1.6 incluye el motor en:
   - §3.1, capas por entorno: una fila con el origen de la imagen y el estado DEV/TEST/PROD.
   - §3.3: `docker-compose.motor-ia.yml` es solo para uso local y en Dokploy el motor no se agrega a los compose del broker.
   - §3.4: un "Grupo F — Motor de inferencia M04" con `IOT_INFERENCIA_M04_TOKEN`, `BACKEND_URL`, `MOTOR_IA_DIR_MODELOS`, `PORT`, `UVICORN_ROOT_PATH`, `OMP_NUM_THREADS`, `MOTOR_IA_SINCRONIZACION_S` y `MOTOR_IA_CALIBRACION_HORAS`, cada una con tipo, sensibilidad y valor o condición por entorno. Las dos últimas se marcan "solo `develop`".
   - Grupo C del backend: las cinco `IOT_INFERENCIA_*` (las cuatro del compose más `IOT_INFERENCIA_REENVIO_SEG`), con su presencia por archivo de compose y rama.
   - §3.8: una fila del motor con puerto interno 8100 y su ruta por entorno.
   - Una §8.4 nueva con los flujos, el healthcheck, el volumen `/data/modelos` y el orden de puesta en marcha (cargar `IOT_INFERENCIA_M04_URL` en el backend al final).
   - §11.1 a §11.3 actualizadas.

   Cada afirmación técnica cita `BRK|BE <rama>@<hash> <archivo>:<líneas>`.
4. CA-4 **Diferencias por rama explícitas.** El documento y el mapa muestran que DEV (`develop`) y TEST (`test`) **no** tienen la misma imagen del motor: en `develop` hay artefactos en la imagen, File Mount de `catalogo.json` y sincronización; en `test`, la guía de Bind Mount y ninguna variable de sincronización. PROD aparece como "no existe en `main` (`cebd430`); por promover (AIoT y Despliegue)".
5. CA-5 **Datos de Despliegue sin inventar.** La ruta pública, el Container Port configurado, el tipo de servicio (Application), los montajes y los límites de CPU y memoria en Dokploy aparecen como "observado (curl, fecha)" o "por confirmar (Despliegue)". La discrepancia entre la ruta desplegada en DEV (`/motor-ia-dev`, 200) y el prefijo que documenta el código (`/model-ia-*` en `.env.motor-ia.example`, `motor_ia/main.py`, `docs/MOTOR_IA_MODELOS_DOKPLOY.md` y `.env.example` del backend) queda escrita con su ID de incidencia. Los límites `cpus 1.0` / `1G` / reserva `256M` se atribuyen solo al compose local.
6. CA-6 **Motor en el mapa.** El mapa v1.6 tiene:
   - un nodo "Motor de inferencia M04 (`motor-ia`)" que reemplaza al "Servidor ML (objetivo)" de la Instancia 1;
   - las flechas Backend → Traefik (HTTPS 443, `POST /v1/paquetes`, Bearer `IOT_INFERENCIA_M04_TOKEN`), Traefik → Motor (HTTP `:8100` interno, Strip Path) y Motor → Traefik → Backend (HTTPS 443, `POST /prediccion/inferencias` y, solo DEV, `GET/POST /prediccion/motor/*`);
   - el estado del motor en las capas DEV, TEST y PROD;
   - el recuadro de control en v1.6.

   Ninguna flecha (`edge="1"`) queda sin `source` o sin `target`. Las flechas de la Backend Instancia 2 hacia el motor siguen como "Objetivo (no desplegado)".
7. CA-7 **Tabla flecha → fuente.** `evidencias/tabla-flechas-fuentes-v1.6.md` lista el 100 % de las flechas del `.drawio` v1.6 (id, rótulo, origen → destino, archivo y `rama@hash`, o "Objetivo" o fuente externa con su fecha). El método es el de HU-IMP-AMB-09.
8. CA-8 **Coherencia documento ↔ mapa.** Puerto, rutas, estado por entorno y flujos del motor coinciden entre el documento y el mapa. Hay una tabla de cotejo en `evidencias/cotejo-doc-mapa-v1.6.md` sin diferencias abiertas.
9. CA-9 **Rutas públicas del resto de componentes (ST-05).** En §3.8, §8.2 y §11.2 del documento y en las capas DEV/TEST del mapa, las rutas de backend, frontend y gateway reflejan lo observado con curl el día del corte y lo comunicado por Despliegue (EXT-BRK-PR35, H-02), con su fecha. Lo que responde 404 o no fue comunicado queda como "por confirmar (Despliegue)".
10. CA-10 **Hallazgos registrados.** `registros/incidencias/registro.md` (registro oficial, sin archivos paralelos) tiene cuatro filas nuevas con el formato y los estados del registro:
    - INC-BE-08: `docker-compose.test.yml` del backend sin `IOT_INFERENCIA_*`.
    - INC-BRK-04: prefijo `/model-ia-*` en el código y `/motor-ia-dev` en el despliegue.
    - INC-BRK-05: el motor de TEST no responde en ninguna ruta pública.
    - INC-BE-09: `IOT_INFERENCIA_REENVIO_SEG` no se reenvía en el compose.

    El documento las cita en §11.4.
11. CA-11 **Publicación.**
    - "Control de cambios" con la fila v1.6 y la tabla de cambios v1.5 → v1.6.
    - Word generado con `herramientas/md2docx.ps1` (no editado a mano).
    - Sin valores de secretos en el `.md`, el `.drawio` ni el `.png`.
    - Fila nueva en "Documentos entregados" de `entregas/E2_2026-11-03_M03-M04/README.md`, con el commit de la fuente.
    - PR a `main` que enlaza esta HU.

**Verificación.**

| CA | Método (comando o prueba) | Resultado esperado | Evidencia a adjuntar |
|---|---|---|---|
| CA-1 | `for r in BROKER-MQTT-SGPMP sgpmp-backend SGPMP-FRONT-END-PWA; do git -C $r fetch --prune origin; done` y luego `git -C BROKER-MQTT-SGPMP log -1 --format='%h %ad' --date=iso origin/develop` (lo mismo para cada rama citada) | Los hashes y la fecha coinciden con la tabla de fuentes del `.md` y con la leyenda del mapa | Salida pegada en `evidencias/corte.md` |
| CA-2 | `git -C SGMP-Integracion diff --name-status origin/main...HEAD` y `grep -n 'version:\|v1.6.png' entregas/E2_2026-11-03_M03-M04/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` | Solo `A` en `entregas/E2_…/documentos/` (3 archivos) y `M`/`A` en evidencias, README y registro; **ningún** cambio en `entregas/E1_…/documentos/`; `version: "1.6"` y la imagen `img/imp_diag_despliegue_puertos_protocolos_v1.6.png` | Salida en el PR |
| CA-3 | `grep -nE 'IOT_INFERENCIA_M04_TOKEN\|BACKEND_URL\|MOTOR_IA_DIR_MODELOS\|UVICORN_ROOT_PATH\|OMP_NUM_THREADS\|MOTOR_IA_SINCRONIZACION_S\|MOTOR_IA_CALIBRACION_HORAS\|IOT_INFERENCIA_REENVIO_SEG\|8100' <md>` y lectura de §3.1, §3.3, §3.4, §3.8, §8.4 y §11.1–11.3. Contraste: `git -C BROKER-MQTT-SGPMP show origin/develop:Dockerfile.motor-ia \| grep -nE 'PORT\|EXPOSE\|HEALTHCHECK\|USER\|COPY'` | Las 8 variables del motor y las 5 del backend aparecen con su cita. El puerto 8100 coincide con `EXPOSE 8100` | Tabla de citas en `evidencias/` o en el PR |
| CA-4 | `git -C BROKER-MQTT-SGPMP diff --stat origin/test origin/develop -- Dockerfile.motor-ia Dockerfile.motor-ia.dockerignore .env.motor-ia.example docs/MOTOR_IA_MODELOS_DOKPLOY.md` y `git -C BROKER-MQTT-SGPMP ls-tree --name-only origin/main \| grep -ci motor` | Diferencias en esos 4 archivos y `0` en `main`. El documento describe las tres diferencias (artefactos, File Mount, sincronización) y "no existe en `main`" | Salida pegada |
| CA-5 | `curl -sS https://api.inmero.co/motor-ia-dev/v1/healthz` y `for p in model-ia-dev motor-ia-test model-ia-test motor-ia model-ia; do curl -sS -o /dev/null -w "$p %{http_code}\n" https://api.inmero.co/$p/v1/healthz; done`; lectura de §3.8 y §8.4 | Las celdas de Dokploy dicen "observado (curl aaaa-mm-dd)" o "por confirmar (Despliegue)". Aparece la discrepancia `/motor-ia-dev` ↔ `/model-ia-*` con su INC | Salida de curl con fecha y hora en `evidencias/curl-<fecha>.md` (el cuerpo de `healthz` no tiene secretos) |
| CA-6 | `F=entregas/E2_2026-11-03_M03-M04/documentos/IMP_Diag_Despliegue_Puertos_Protocolos_v1.6.drawio; grep -o '<mxCell [^>]*edge="1"[^>]*>' "$F" \| grep -vc 'source="'; grep -o '<mxCell [^>]*edge="1"[^>]*>' "$F" \| grep -vc 'target="'` (el `.drawio` se guarda **sin comprimir**: *Archivo → Propiedades → Comprimido* desmarcado) | `0` y `0`. Aparecen el nodo del motor y sus 3 flechas desplegadas, con rótulos como en el CA | Captura de la capa Protocolos y de cada capa de ambiente en `evidencias/` |
| CA-7 | `grep -o '<mxCell [^>]*edge="1"[^>]*>' "$F" \| grep -c .` comparado con el número de filas de `evidencias/tabla-flechas-fuentes-v1.6.md` | Mismo número | La tabla |
| CA-8 | Lectura cruzada con `evidencias/cotejo-doc-mapa-v1.6.md` (filas: puerto, ruta por entorno, estado por entorno, cada flujo) | Todas las filas "coincide" | El archivo |
| CA-9 | `for u in api-sgpmp-dev/health api-sgpmp-test/health back-sigab-dev/health back-sigab-test/health broker-sigab-dev/v1/healthz broker-sigab-test/v1/healthz sigab-dev/ sigab-test/; do curl -sS -o /dev/null -w "$u %{http_code}\n" https://api.inmero.co/$u; done; curl -sS -o /dev/null -w "dev.inmero.co %{http_code}\n" https://dev.inmero.co/` | Cada ruta que da 200 está en el documento y en el mapa con "observado (fecha)". Cada ruta que da 404 no aparece como vigente | Salida en `evidencias/curl-<fecha>.md` |
| CA-10 | `grep -nE 'INC-BE-08\|INC-BE-09\|INC-BRK-04\|INC-BRK-05' registros/incidencias/registro.md` y `grep -n 'INC-B' <md>` | 4 filas con fecha, entorno, capa, responsable, estado (`detectado`/`diagnosticado`) y enlace a esta HU. El documento las cita en §11.4 | Diff del PR |
| CA-11 | `powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregas/E2_2026-11-03_M03-M04/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`, y luego `grep -inE 'password\|secret\|://[^ /]*:[^ @]*@' <md> <drawio>` | `.docx` en `salida/` con portada, índice y el Diagrama 1 v1.6. El grep sin resultados (los nombres `*_TOKEN` sin valor están permitidos). README de E2 con la fila del documento y su commit | `.docx` adjunto en Taiga (no se versiona); enlace al PR |

**Definición de terminado.**
- [ ] CA-1 a CA-11 verificados, con la evidencia en `evidencias/` de esta HU.
- [ ] PR en `SGMP-Integracion` hacia `main`, con una descripción que enlaza esta HU y el PR #54 del broker.
- [ ] PR aprobado y fusionado por el Líder de Implementación.
- [ ] `registros/incidencias/registro.md` actualizado (CA-10).
- [ ] Word v1.6 subido a Drive (`G-Implementacion/entrega_2`) y enlazado en el README de E2.

**Dependencias y aprobaciones.**
- Aprueba el PR: Líder de Implementación (`SGMP-Integracion`).
- Antes de ST-03, el líder pone a disposición de Juan Hernando los insumos de `motor_ia/` (hoy no versionados).
- Despliegue: confirmar la ruta pública del motor en TEST y PROD, el Container Port, el tipo de servicio, los montajes y los límites, y las rutas nuevas de backend, frontend y gateway. Sin respuesta, quedan "por confirmar (Despliegue)" y la HU no se bloquea.
- Desarrollo / AIoT: corregir el prefijo documentado en el código (INC-BRK-04). No bloquea esta HU.

**Riesgos.**
- `develop` del broker cambia a diario (rc.15 a rc.18 entre el 2026-11-01 y el 2026-11-02): el documento puede quedar viejo antes del PR. Mitigación: CA-1 (corte reverificado el día del PR) y citar hashes, no ramas.
- Copiar al documento los datos de los insumos de `motor_ia/` (puerto 8000, `/motor-ia-*`, volumen nombrado) que el código ya cambió. Mitigación: manda el código; los insumos son contexto (ver la tabla de discrepancias en las notas).
- Editar el `.docx` a mano lo desalinea del `.md`. Mitigación: CA-11.
- Un `.drawio` comprimido impide verificar CA-6 y CA-7. Mitigación: guardarlo sin comprimir.

**Referencias.**
- PR [BROKER-MQTT-SGPMP#54](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/54), con #57, #58 y #60.
- PR [sgpmp-backend#909](https://github.com/Arekkazu/sgpmp-backend/pull/909).
- Broker `docs/MOTOR_IA_MODELOS_DOKPLOY.md`.
- HU-IMP-DOC-01 y HU-IMP-AMB-09 (E1), con REV-02 y `evidencias/tabla-flechas-fuentes.md` de AMB-09.
- `entregas/E2_2026-11-03_M03-M04/prs/BRK-PR35_compose-prod-broker/plan.md` (H-02, dominios nuevos).
- ADR-002.

## Para copiar en Taiga — Subtareas

### ST-01 preparar la rama, copiar las fuentes a E2 como v1.6 y fijar el corte
**Objetivo.** Dejar la rama y las tres fuentes v1.6 en la carpeta de E2, con la tabla de corte actualizada.
**Pasos.**
1. `git -C SGMP-Integracion fetch origin && git -C SGMP-Integracion switch -c docs/motor-ia-ambiente-mapa-v1.6 origin/main`.
2. Copiar (no mover) estos tres archivos desde `entregas/E1_2026-10-13_M01-M09-M02/documentos/` hacia `entregas/E2_2026-11-03_M03-M04/documentos/`:
   - `AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`, con el mismo nombre;
   - `IMP_Diag_Despliegue_Puertos_Protocolos_v1.5.drawio`, que pasa a llamarse `…_v1.6.drawio`;
   - `img/imp_diag_despliegue_puertos_protocolos_v1.5.png`, que pasa a llamarse `img/…_v1.6.png` (provisional hasta ST-04).
3. En el `.md`, poner `version: "1.6"`. Actualizar "Control del documento": Fuente → nueva ruta; Rama de trabajo → la de esta HU; HU → HU-IMP-DOC-01 y HU-IMP-DOC-02. Cambiar la imagen del Diagrama 1 a `img/imp_diag_despliegue_puertos_protocolos_v1.6.png`.
4. Hacer `git fetch --prune` en broker, backend y frontend y anotar `git log -1 --format='%h %ad' --date=iso origin/<rama>` de las 9 ramas. Con eso, reescribir la tabla "Fuentes y fecha de corte" y guardar la salida en `evidencias/corte.md`.
5. Primer commit: `docs(entregas): copia a E2 las fuentes v1.6 del ambiente de trabajo y del mapa`.
**Entregable.** Rama con las tres fuentes v1.6 y `evidencias/corte.md`.
**Verificación.** `git diff --name-status origin/main...HEAD` → solo `A` en `entregas/E2_…/documentos/` (CA-1, CA-2).
**Estimación.** 2 h

### ST-02 incorporar el motor `motor-ia` al documento de ambiente de trabajo
**Objetivo.** Cumplir CA-3, CA-4 y CA-5 en el `.md`.
**Pasos.**
1. Leer en el broker, con el hash del corte:
   - `git show origin/develop:Dockerfile.motor-ia` y `git show origin/test:Dockerfile.motor-ia`;
   - `git show origin/develop:docker-compose.motor-ia.yml`;
   - la plantilla de variables del motor en las dos ramas: `MSYS_NO_PATHCONV=1 git show "origin/develop:.env.motor-ia.example"`. En Git Bash, sin `MSYS_NO_PATHCONV=1`, la ruta que empieza por punto se rompe;
   - `git show origin/develop:docs/MOTOR_IA_MODELOS_DOKPLOY.md`.

   En el backend: `git show origin/<rama>:docker-compose.yml | grep -n IOT_INFERENCIA` en `dev`, `test` y `main`, y lo mismo con `docker-compose.test.yml` y `docker-compose.prod.yml`.
2. §3.1, capas por entorno: fila "Motor de inferencia M04" con la imagen `Dockerfile.motor-ia` (python 3.13-slim por digest, `USER 1001`, `EXPOSE 8100`) y las columnas DEV `develop` · TEST `test` · PROD "no existe en `main`".
3. §3.3: fila del broker con `docker-compose.motor-ia.yml` "solo local; en Dokploy, Application aparte (comentario del archivo, l. 4-6; tipo por confirmar con Despliegue)". Agregar una tabla corta con las diferencias entre `develop` y `test` (CA-4).
4. §3.4: crear el "Grupo F — Motor de inferencia M04" con las 8 variables (CA-3): tipo, sensibilidad, DEV/TEST/PROD y cita de línea. Sin valores de secretos. En el Grupo C, agregar las 5 `IOT_INFERENCIA_*` del backend con su presencia por archivo y rama. Anotar que no están en `docker-compose.test.yml` y la regla "cargar `IOT_INFERENCIA_M04_URL` al final".
5. §3.8: fila del motor con puerto interno 8100 y ruta por entorno:
   - DEV: `https://api.inmero.co/motor-ia-dev`, observado (curl de la fecha);
   - TEST: por confirmar (Despliegue);
   - PROD: no existe.

   Agregar la nota de la discrepancia con `/model-ia-*` (INC-BRK-04).
6. Crear la §8.4 "Motor de inferencia M04 (`motor-ia`)":
   - flujos backend → motor (`POST /v1/paquetes`) y motor → backend (`POST /prediccion/inferencias`; `/prediccion/motor/*` solo en `develop`);
   - healthcheck (`/v1/healthz` sin token, 30 s/5 s/30 s/3; `modelos_cargados`);
   - volumen `/data/modelos` (dueño 1001; cómo llegan los modelos en `develop` y en `test`);
   - orden de puesta en marcha.

   Indicar que el motor no usa MQTT ni conecta a la BD (no hay variable de BD en `motor_ia/`).
7. §11.1 (el broker contiene `motor_ia/`), §11.2 (arranque local con `docker-compose.motor-ia.yml`, puerto de host 8100, `./modelos` solo lectura; el compose de `SGMP-Integracion/compose/` no incluye el motor) y §11.3.
**Entregable.** `.md` con las secciones nuevas o cambiadas.
**Verificación.** Comandos de CA-3, CA-4 y CA-5.
**Estimación.** 5 h

### ST-03 dibujar el motor en el mapa de puertos v1.6 y armar la tabla flecha → fuente
**Objetivo.** Cumplir CA-6 y CA-7.
**Pasos.**
1. Abrir `…_v1.6.drawio` en draw.io y confirmar que se guarda **sin comprimir**.
2. Capa Base: convertir el nodo "Servidor ML (objetivo)" de la Instancia 1 en "Motor de inferencia M04 (`motor-ia`) · Python 3.13 · onnxruntime · HTTP 8100 (TLS en Traefik) · `/data/modelos`", con estilo sólido. Las flechas de la Instancia 2 siguen punteadas, como "Objetivo".
3. Capa Protocolos: reemplazar las flechas Backend ↔ ML por estas, arrastrando cada extremo hasta que la caja se resalte en azul:
   - Backend → Traefik: "HTTPS 443 · POST /v1/paquetes · Bearer (IOT_INFERENCIA_M04_TOKEN)";
   - Traefik → Motor: "HTTP :8100 interno (Strip Path)";
   - Motor → Traefik: "HTTPS 443 · POST /prediccion/inferencias · /prediccion/motor/* (solo DEV)".

   La entrada Traefik → Backend ya existe: no se duplica.
4. Capas DEV, TEST y PROD:
   - DEV: "motor-ia-dev · `/motor-ia-dev` (observado aaaa-mm-dd) · imagen `develop@<hash>`";
   - TEST: "motor-ia-test · código en `test@<hash>` · ruta por confirmar (Despliegue)";
   - PROD: "motor: no existe en `main`".
5. Leyenda "Fuente" con la nueva fecha de corte y los hashes. Recuadro de control: versión 1.6, fecha, autor y cambios.
6. Crear `evidencias/tabla-flechas-fuentes-v1.6.md`, copiando la estructura de `entregas/E1_…/propio/HU-IMP-AMB-09_mapa-puertos-protocolos/evidencias/tabla-flechas-fuentes.md`, con una fila por flecha.
**Entregable.** `.drawio` v1.6 y la tabla.
**Verificación.** Comandos de CA-6 y CA-7: `0`/`0` sin anclar y el mismo número de flechas que de filas.
**Estimación.** 4 h

### ST-04 exportar el PNG, cotejar documento y mapa y registrar los hallazgos
**Objetivo.** Cumplir CA-8 y CA-10, y dejar el PNG final.
**Pasos.**
1. Exportar `img/imp_diag_despliegue_puertos_protocolos_v1.6.png` con las capas Base y Protocolos y las de ambiente que use el Diagrama 1. Revisar que ningún rótulo tape una caja.
2. Crear `evidencias/cotejo-doc-mapa-v1.6.md` con una fila por dato del motor (puerto, ruta por entorno, estado por entorno y cada flujo). Columnas: documento (§) · mapa (id) · código · ¿coincide? Corregir hasta que todas coincidan.
3. Agregar a `registros/incidencias/registro.md` las filas INC-BE-08, INC-BE-09, INC-BRK-04 e INC-BRK-05 (texto propuesto en "Notas para el líder" → "Filas para el registro"), con el formato y los estados del registro y el enlace a esta HU. Citarlas en la §11.4 del documento.
**Entregable.** PNG, cotejo y registro actualizados.
**Verificación.** CA-8 y CA-10.
**Estimación.** 2,5 h

### ST-05 actualizar las rutas públicas observadas de backend, frontend y gateway
**Objetivo.** Cumplir CA-9: que la v1.6 no presente como vigentes rutas que hoy responden 404.
**Pasos.**
1. Ejecutar el comando de CA-9 y guardar la salida con fecha y hora en `evidencias/curl-<fecha>.md`.
2. Con esa salida y la tabla de dominios comunicados por Despliegue (`entregas/E2_…/prs/BRK-PR35_compose-prod-broker/plan.md`, H-02), actualizar §3.8 (servicios web), §8.2 (endpoint del gateway), §11.2 B y las capas DEV y TEST del mapa:
   - lo que da 200 → "observado (fecha) · comunicado por Despliegue";
   - lo que da 404 sin reemplazo conocido (gateway DEV) → "por confirmar (Despliegue)".
3. Agregar la fila correspondiente en la tabla de cambios v1.5 → v1.6.
**Entregable.** Documento y mapa con las rutas observadas.
**Verificación.** CA-9.
**Estimación.** 2,5 h

### ST-06 cerrar el control de cambios, generar el Word y abrir el PR
**Objetivo.** Cumplir CA-1 (reverificación), CA-2 y CA-11.
**Pasos.**
1. En "13. Control de cambios", agregar la fila v1.6 (fecha, autores, descripción) y la tabla "Cambios de la versión 1.5 a la 1.6" (sección · cambio · origen).
2. Repetir el `fetch` de ST-01. Si alguna rama avanzó, actualizar el hash y reverificar lo que se dice de ella (CA-1).
3. Ejecutar `powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregas/E2_2026-11-03_M03-M04/documentos/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`. Abrir `salida/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.docx`, actualizar el índice y revisar tablas e imagen.
4. Ejecutar el grep de secretos de CA-11.
5. En `entregas/E2_2026-11-03_M03-M04/README.md` → "Documentos entregados", agregar dos filas (documento y mapa, versión 1.6, commit). El enlace de Drive lo completa el líder.
6. Abrir el PR hacia `main` con el título `docs(entregas): ambiente de trabajo y mapa de puertos v1.6 con el motor de inferencia M04`. En la descripción, enlazar la HU, el PR #54 del broker y la lista de evidencias. Adjuntar el `.docx` en Taiga.
**Entregable.** PR abierto y Word adjunto.
**Verificación.** CA-2 y CA-11.
**Estimación.** 2 h

**Total:** 18 h (unos 2,5 días de trabajo de una persona).

## Notas para el líder (no copiar a Taiga)

### Plazo
- **No es realista terminar todo para la entrega de mañana (2026-11-03).** Son 18 h, más tu revisión.
- **Plazo sugerido:** 2026-11-05 a las 18:00 para el PR completo. Si el docente exige algo el 2026-11-03, hay una entrega mínima: ST-01 + ST-02 + ST-06, solo con el documento (unas 9 h y un día completo de Juan Hernando), en un PR propio antes de las 18:00. El mapa v1.6 (ST-03, ST-04) y las rutas (ST-05) irían en un segundo PR hasta el 2026-11-05. En ese caso, deja en el documento la nota del Diagrama 1 "v1.6 en preparación; manda el texto", como se hizo en la v1.5.
- **Por qué una sola HU y no dos:** los dos documentos se citan entre sí (CA-6 de DOC-01 y la nota D9 de REV-02 de AMB-09). Separarlos repitió en E1 la corrección de N1 y N2 en los dos documentos. Si prefieres dos HU, el corte natural es DOC-02 = ST-01, ST-02 y ST-06 (documento) y DOC-03 = ST-03, ST-04 y ST-05 (mapa y rutas), con CA-8 en DOC-03.

### Preguntas abiertas
1. **Versión y ubicación.** Propongo v1.6 para los dos documentos, con las fuentes **copiadas** (no movidas) a `entregas/E2_2026-11-03_M03-M04/documentos/` y las de E1 sin cambios, que son lo que se entregó en E1. Esto sigue ADR-002 ("la fuente de lo entregado vive en `entregas/<E>/documentos/`") y su consecuencia de que lo histórico conserva su ruta. ¿Lo confirmas? La alternativa es `git mv` a E2, que deja a E1 sin su fuente.
2. **ST-05 (rutas nuevas de backend, frontend y gateway).** No es del motor, pero el curl de hoy muestra que la v1.5 tiene rutas que dan 404: `back-sigab-dev`, `back-sigab-test`, `broker-sigab-dev` y `dev.inmero.co`. Además, el propio motor de DEV ya entrega a `api-sgpmp-dev`. Recomiendo incluirla. Si no la apruebas, borra ST-05 y CA-9 antes de copiar a Taiga y deja la nota en el documento.
3. **Insumos sin versionar.** `entregas/E2_2026-11-03_M03-M04/motor_ia/` y `prs/` existen solo en tu copia (`git status`: `??`), así que Juan Hernando no los tiene. Esta HU también queda sin versionar hasta que la subas. ¿Los versionas antes de asignarla? Sugiero mover `motor_ia/` dentro de `prs/BRK-PR54_motor-ia/` para seguir ADR-002: carpeta del origen, con el análisis junto a su HU.
4. **Numeración.** Usé `DOC-02` (DOC-01 es el documento de ambiente). Ya están reservadas CFG-01 y AMB-10 en el plan de BRK-PR35. Cámbiala si en Taiga hay otra.
5. **IDs de incidencia.** INC-BE-08, INC-BE-09, INC-BRK-04 e INC-BRK-05 son los siguientes libres al 2026-11-02. ¿Los asigna Juan Hernando en ST-04 o prefieres registrarlos tú con `triage` antes?
6. **HU CFG aparte.** INC-BE-08 (el backend de TEST, si se despliega con `docker-compose.test.yml`, no recibe `IOT_INFERENCIA_*`) es trabajo de Implementación en el compose. ¿La planifico como HU-IMP-CFG-02 (PR a `test`, o a `dev` con promoción)?

### Discrepancias código ↔ insumos de `motor_ia/` (manda el código)

| # | Tema | Insumo (`motor_ia/`) | Código al corte | Clasificación |
|---|---|---|---|---|
| D-01 | Puerto del contenedor | 8000 (README C-03; `docs/variables.md`; `docs/volumen-limites.md`, "Valores para Dokploy"; F6 sobre `789eb7b`) | **8100**: `PORT=8100`, `EXPOSE 8100`, healthcheck con valor por defecto 8100 y compose local `8100:8100` (`3fe7839`, Arekkazu, en `develop` y `test`) | Insumo desactualizado: `3fe7839` revirtió C-03 |
| D-02 | Prefijo público | `/motor-ia-dev`, `/motor-ia-test`, `/motor-ia` (README C-10; `variables.md`; `volumen-limites.md`) | `/model-ia-*` en `.env.motor-ia.example`, el docstring de `motor_ia/main.py`, `docs/MOTOR_IA_MODELOS_DOKPLOY.md` y el `.env.example` del backend (dev l. 179) y `.env.prod.example` (l. 198) | Insumo desactualizado frente al código, **pero** el despliegue real de DEV responde en `/motor-ia-dev` (200) y no en `/model-ia-dev` (404): el código y el despliegue no coinciden → INC-BRK-04 (Desarrollo/AIoT con Despliegue) |
| D-03 | Volumen | Volumen nombrado `motor-ia-data` (C-09); "Valores para Dokploy": volumen en `/data/modelos` | `test`: Bind Mount `./modelos:/data/modelos:ro` en local y guía de Bind Mount en Dokploy. `develop`: artefactos ET-02 copiados en la imagen y `catalogo.json` por File Mount (provisional, `d54b4bf`) | Insumo desactualizado |
| D-04 | Variables del motor | 6 variables (`variables.md`) | `develop` agrega `MOTOR_IA_SINCRONIZACION_S` y `MOTOR_IA_CALIBRACION_HORAS` (`6d81179`); `test` no las tiene | Insumo incompleto |
| D-05 | `.dockerignore` | Excluye `*.onnx` | `develop`: `**/*.onnx` con la excepción `!artefactos_et02/*.onnx` | Insumo desactualizado |
| D-06 | H-05 (backend sin `IOT_INFERENCIA_*`) | "Hoy los compose del backend no pasan estas variables" | Corregido en `dev` (PR #909, 2026-11-01) y presente en `test` en `docker-compose.yml` y `docker-compose.prod.yml`; **falta** en `docker-compose.test.yml` de `test` y en todo `main` | Parcialmente resuelto → INC-BE-08 |
| D-07 | Composición del PR #54 | README F1: "`89654ee` + `789eb7b`" | Head `3fe7839`; incluye además `06f951b` y `3fe7839` de Arekkazu | Insumo desactualizado; la verificación F6 es de una imagen que ya no es la de `develop` ni la de `test` |
| D-08 | Guía del broker | — | `docs/MOTOR_IA_MODELOS_DOKPLOY.md` (`develop`) dice "por qué no van en git ni en la imagen" y a continuación documenta la excepción `artefactos_et02/` en la imagen | Incoherencia interna del broker (Desarrollo); solo informativa |
| D-09 | Motor de TEST | Paso a paso con `https://api.inmero.co/model-ia-test` | `/motor-ia-test` y `/model-ia-test` → 404: TEST no está publicado o tiene otra ruta | INC-BRK-05 (Despliegue) |
| D-10 | Límites CPU y memoria | "Valores para Dokploy": 1.0 / 1 GB / 256 MB | Solo en `docker-compose.motor-ia.yml` (local). En una Application de Dokploy no aplican salvo que Despliegue los configure | Por confirmar (Despliegue) |

Te sugiero corregir `motor_ia/README.md` (C-03, C-10 y F1), `docs/variables.md` y `docs/volumen-limites.md` antes de entregar E2, o marcarlos "superados por `3fe7839`". Están a tu nombre y fuera del alcance de Juan Hernando.

### Filas para el registro (texto propuesto para ST-04)
- **INC-BE-08** · 2026-11-02 · TEST · Si TEST se despliega con `docker-compose.test.yml`, el backend no recibe `IOT_INFERENCIA_M04_URL/TOKEN/TLS_MIN/CA_FILE` y no puede enviar paquetes al motor ni validar sus resultados · Compose del backend · Implementación · diagnosticado.
- **INC-BE-09** · 2026-11-02 · DEV, TEST, PROD · `IOT_INFERENCIA_REENVIO_SEG` se lee en `reenvio_inferencia_worker.py:45`, pero ningún compose la reenvía (se usa el valor por defecto, 5 s) · Compose del backend · Implementación · detectado.
- **INC-BRK-04** · 2026-11-02 · DEV, TEST, PROD · El motor desplegado en DEV responde en `/motor-ia-dev`. El código y la plantilla del backend documentan `/model-ia-*`, así que una URL copiada de la plantilla da 404 en Traefik · Motor (documentación del código) y Traefik · Desarrollo/AIoT con Despliegue · detectado.
- **INC-BRK-05** · 2026-11-02 · TEST · El código del motor está en `test` (`662e096`), pero ni `/motor-ia-test` ni `/model-ia-test` responden · Traefik / Dokploy · Despliegue · detectado.

### Puntos de atención para la revisión
- Que no se copien al documento el puerto 8000 ni la ruta `/motor-ia-*` "de diseño" desde los insumos: el puerto es 8100 por código, y la ruta de DEV se cita como observada.
- Que DEV y TEST no aparezcan como si tuvieran la misma imagen (CA-4).
- Las flechas nuevas, ancladas (error de E1, N4 de REV-02).
- Que la leyenda "Fuente" atribuya el Dockerfile y el compose del motor a **Implementación** (vienen de PR #54, aunque luego los modificó Desarrollo) y la ruta y el Container Port a Despliegue (error de E1, N6).
- Hashes reverificados el día del PR, no los de esta HU (error recurrente, regla fija de `hu-taiga`).

### Otros pendientes que salen del corte (no son de esta HU)
- La tabla "Infraestructura" de `CLAUDE.md` todavía muestra `dev.inmero.co`, `/back-sigab-*` y `/broker-sigab-dev`, que hoy dan 404. Conviene actualizarla cuando Despliegue confirme las rutas.
- El gateway de DEV no responde en `/broker-sigab-dev`. Si el backend de DEV usa esa URL en `MQTT_BROKER_URL`, los comandos a dispositivos fallarían. Conviene hacer un `/triage`.

### Borrador de mensaje a Despliegue
> Hola. Para documentar el motor de inferencia M04 (`motor-ia`) en el ambiente de trabajo de Implementación necesitamos confirmar lo siguiente. (1) La ruta pública del motor en cada entorno: en DEV responde `https://api.inmero.co/motor-ia-dev`; en TEST no responde ni `/motor-ia-test` ni `/model-ia-test`. (2) El Container Port configurado en cada Application (la imagen escucha en 8100). (3) El tipo de servicio (Application o Compose), los montajes de `/data/modelos` y si hay límites de CPU y memoria. (4) Las rutas vigentes de backend, frontend y gateway en DEV y TEST: `/back-sigab-*` y `/broker-sigab-dev` dan 404 y `/api-sgpmp-*` y `/sigab-*` dan 200. Gracias.

---
**Metadatos.** Redactado el 2026-11-02 por el planificador.

Fuentes, con `git fetch --prune` el 2026-11-02 a las 13:20 -0500:
- BROKER-MQTT-SGPMP: `develop@c5f43ab`, `test@662e096`, `main@cebd430`. Commits revisados: `89654ee`, `789eb7b`, `06f951b`, `3fe7839`, merge `102b2c5` (#54), `d54b4bf`/`b6a0239` (#57), `fe24f0a` (#58), `6d81179` (#60). `git diff 789eb7b 3fe7839`; `git diff origin/test origin/develop` sobre los archivos del motor.
- sgpmp-backend: `dev@6cf3c036`, `test@c4be97a1`, `main@0abbeeef`. PR #909 fusionado el 2026-11-01T05:03Z (`gh pr view`).
- SGPMP-FRONT-END-PWA: `dev@e7a5613a`, `test@298492ed`, `main@95f3e563`.
- SGMP-Integracion: `main@0fa672e`.
- curl a `api.inmero.co` y `dev.inmero.co` el 2026-11-02 a las 13:20 -0500 (tabla de la situación actual).
- Insumos: `motor_ia/README.md`, `IMP-M04_paquete_instrucciones_motor-ia_v3.md`, `plan_motor_ia_modelos.md`, `docs/variables.md`, `docs/volumen-limites.md`, `evidencias/F0-hallazgos.md` y `evidencias/F6-verificacion-local.md`.
- HU-IMP-AMB-09 (historia, REV-02, tabla flecha → fuente), HU-IMP-DOC-01 (historia), ADR-002 y `prs/BRK-PR35_compose-prod-broker/plan.md`.
