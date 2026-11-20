# Paquete de instrucciones — Implementación `motor-ia` (E2) · v3

**Fecha:** domingo, 1 de noviembre de 2026  
**Entregable objetivo:** Imagen `motor-ia` funcional, Dockerfile, compose local, catálogo por ambiente, procedimiento RF-69 y PR a `develop` del broker.  
**Rama de trabajo:** Rama derivada de `develop` del broker (ej. `feat/motor-ia-e2-despliegue`), abierta solo después de que los PRs #49, #50 y #51 estén mergeados.  
**Regla de oro de repositorios:** Solo el `Dockerfile.motor-ia`, `Dockerfile.motor-ia.dockerignore`, `docker-compose.motor-ia.yml` y `.env.motor-ia.example` van al repo del broker. Toda la documentación, scripts de referencia y evidencias van a la carpeta `E2` de `SGMP-Integracion`.  
**Carpeta `E2`:** en este documento, `SGMP-Integracion/E2/` es la carpeta de la entrega vigente según la convención del repo (`entregas/E2_<fecha>_M03-M04/` si el lote F ya está aplicado).

---

## 0. Supuestos tomados (resuelven las dudas sin bloquear)

Mientras no haya respuesta formal, el equipo avanza con estos supuestos. Si alguno cambia, la corrección es localizada y no invalida el trabajo.

| # | Duda | Supuesto | Justificación | Costo de corregir si cambia |
|---|---|---|---|---|
| 1 | Tipo de servicio en Dokploy | **Application** (Dockerfile). El `docker-compose` del broker se usa para despliegue, pero el motor se configurará como App independiente para no levantar dos motores. | Despliegue creó tres servicios aparte (`motor-ia-dev/-test/-main`), separados del stack del broker. Es un supuesto: **se confirma con Despliegue** (no está verificado qué tipo usan los demás servicios). | Bajo: si es Compose, se adapta el `docker-compose.motor-ia.yml` local ya escrito. |
| 2 | Puerto del Dockerfile | **8000**. | Dokploy ya apunta al 8000. El motor debe alinearse a esto para evitar error 502 de Traefik. | Nulo: el `CMD` usa variable `PORT` con default 8000. |
| 3 | Registro RF-69 | **Bloqueado por RFC-010**. Se documenta y se notifica a Desarrollo para que marque la tarea en el tablero. | El plan lo dice explícitamente (H2 + D-C). No hay forma de saltarlo sin la migración del DBA. | Nulo: el procedimiento F5 queda escrito y listo para ejecutar. |
| 4 | Ubicación de artefactos (`.onnx`) | **No están en el repo** (no van a git). Se deben solicitar formalmente a Desarrollo. Despliegue los copiará al volumen del servidor. | Coherente con la regla de no subir binarios a git y con el plan original. | Bajo: solo cambia la fuente de obtención para la prueba local F6. |

---

## 1. Fases y tareas

### F0 · Reconocimiento (solo lectura) — 1 agente, 1 h
**Entrada:** Acceso de lectura a `SerBy48/BROKER-MQTT-SGPMP` (ramas `develop`, PRs #49, #50, #51) y backend (rama `dev`).  
**Salida:** `SGMP-Integracion/E2/evidencias/F0-hallazgos.md`

**Tareas:**
1. Ejecutar `/impacto` sobre los PRs #49, #50 y #51. Revisar si hay issues `SEG-*` del broker aplicables a una imagen nueva.
2. Inspeccionar el código del motor y responder:
   - ¿`/v1/healthz` responde 200 sin modelos cargados? Si responde 503, documentar el riesgo (contenedor en bucle *unhealthy*).
   - Forma esperada de `catalogo.json` y estructura de volumen según el código del PR #50.
   - Nombre exacto de la variable de `root_path`.
   - Lista de dependencias del extra `motor-ia` en `pyproject.toml` (para no hardcodear versiones en el Dockerfile).
3. Revisar `.env.example` del backend en rama `dev`. Confirmar si existen `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_M04_TOKEN`, `IOT_INFERENCIA_TLS_MIN`, `IOT_INFERENCIA_CA_FILE`. Si faltan, preparar un PR al backend para agregarlas.
4. Confirmar en el código del backend (cliente HTTP del PR #892) si `IOT_INFERENCIA_M04_URL` espera la URL base o la ruta completa con `/v1/paquetes`. (El tablero sugiere URL base).

---

### F1 · Imagen — 1 agente, 2 h
**Entrada:** Resultados de F0; `pyproject.toml` del broker.  
**Salida:** Archivos para el repo del broker.

**Artefactos a crear:**
1. `Dockerfile.motor-ia` multi-stage sobre `python:3.13-slim-bookworm` con el **último parche 3.13** disponible, fijado por digest. No usar `3.13.0`: es la primera versión de 3.13 (2024) y trivy la marcaría con vulnerabilidades HIGH.
   - Stage `builder`: `python -m venv /opt/venv` y `/opt/venv/bin/pip install --no-cache-dir ".[motor-ia]"` (las versiones salen de `pyproject.toml`).
   - Stage final: copia **todo `/opt/venv`** y `ENV PATH="/opt/venv/bin:$PATH"`. Si solo se copia `site-packages`, el ejecutable `uvicorn` no llega a la imagen y el `CMD` falla con "not found".
   - `WORKDIR /app`.
   - Permisos del volumen, **antes** de `USER`: `RUN mkdir -p /data/modelos && chown 1001:1001 /data/modelos`.
   - Usuario no-root: `USER 1001:1001`.
   - `ENV PORT=8000`, `ENV MOTOR_IA_DIR_MODELOS=/data/modelos`, `ENV OMP_NUM_THREADS=1`.
   - `EXPOSE 8000`.
   - `CMD ["sh", "-c", "exec uvicorn motor_ia.main:crear_app --factory --host 0.0.0.0 --port ${PORT}"]` (el `exec` asegura que uvicorn reciba la señal de apagado).
   - `HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:${PORT}/v1/healthz', timeout=4)"` (`urlopen` lanza una excepción ante un error, y eso da el código de salida 1). Ajustar si F0 muestra que `healthz` exige token.
2. `Dockerfile.motor-ia.dockerignore` (no tocar el del broker):
   ```text
   .git
   .env*
   anotaciones/
   evidencias/
   *.onnx
   *.pt
   *.pkl
   *.pyc
   __pycache__
   .pytest_cache
   .mypy_cache
   ```
3. `docker-compose.motor-ia.yml` (solo para desarrollo local):
   - Servicio `motor-ia` construido con `Dockerfile.motor-ia`.
   - Puerto `8000:8000`.
   - Volumen `motor-ia-data:/data/modelos`.
   - Variables con `env_file: .env.motor-ia`: una copia local del `.example` con valores de prueba, que **no se versiona** (verificar que el `.gitignore` del broker la cubra). Si se usa el `.example`, que no trae valores, el motor no arranca, porque sin `IOT_INFERENCIA_M04_TOKEN` se detiene al iniciar.
   - Límites: `deploy.resources.limits.cpus: '1.0'`, `deploy.resources.limits.memory: 1G`, `deploy.resources.reservations.memory: 256M`.
4. `.env.motor-ia.example` con las variables del motor sin valores.

**Criterio de cierre:** `docker build` exitoso, hadolint sin warnings críticos, `docker compose config` valida.

---

### F2 · Volumen, healthcheck y límites — 1 agente, 1 h
**Entrada:** Resultados de F0 (estructura de volumen del PR #50).  
**Salida:** `SGMP-Integracion/E2/docs/volumen-limites.md`

**Tareas:**
1. Documentar la estructura del volumen acordada con el código de #50:
   ```text
   /data/modelos/
   ├── catalogo.json
   └── modelos/
       └── <estructura definida en PR #50>
   ```
2. Sección **"Valores para Dokploy"**, para entregar formalmente a Despliegue (se configuran en la UI de Dokploy):
   - Build: `Dockerfile.motor-ia`, contexto la raíz del broker, y la rama de la que construye cada servicio.
   - Puerto 8000, Strip Path activo y path de TEST con `/` inicial.
   - Volumen montado en `/data/modelos`. Si es bind mount, la carpeta del servidor debe pertenecer al UID 1001.
   - CPU: 1.0 límite, sin reserva. Memoria: 1 GB límite, 256 MB reserva. Son valores provisionales, que se recalculan con la prueba M6 (P95 < 2 s).
   - `OMP_NUM_THREADS=1` (ya incluido en el Dockerfile).
   - Healthcheck: intervalo 30 s, timeout 5 s, start-period 30 s, retries 3 sobre `/v1/healthz`.
3. Si F0 confirmó que `/v1/healthz` responde 503 sin modelos: documentarlo y pedir a Desarrollo la decisión (que `healthz` indique solo que el proceso está vivo, o un endpoint alternativo). Mientras tanto, la verificación usa el catálogo de prueba de F4. **No se cambia el código del motor.** La opción "cargar un modelo SOMBRA" no existe todavía, porque SOMBRA llega con RFC-010.

---

### F3 · Variables de entorno — 1 agente, 1 h
**Entrada:** Hallazgos de F0 sobre `.env.example` del backend.  
**Salida:** `SGMP-Integracion/E2/docs/variables.md` y PR al backend si faltan variables.

**Tareas:**
1. Crear la tabla completa de variables (motor y backend).
2. Nota explícita en la documentación: **No definir `IOT_INFERENCIA_M04_URL` en el backend hasta que el motor tenga modelos cargados** (verificado en el log o en `healthz`), como dice el tablero. Si F0 muestra que el motor necesita IDs de RF-69 para cargar un modelo, la condición pasa a ser "versiones registradas en RF-69". Con la URL vacía los paquetes quedan pendientes; con la URL apuntando a un motor sin modelos, el backend marca FALLIDO tras ~5 reintentos (~2 min).
3. Si F0 detectó que faltan las variables `IOT_INFERENCIA_*` en el `.env.example` del backend, abrir un PR al repo del backend para agregarlas.

---

### F4 · Catálogo — 1 agente, 1 h
**Entrada:** Forma de `catalogo.json` desde F0.  
**Salida:** Plantilla y consulta de referencia en `SGMP-Integracion/E2/docs/`.

**Tareas:**
1. Plantilla `catalogo.template.json` con la estructura mínima (según F0).
2. Tres archivos `catalogo.dev.json`, `catalogo.test.json`, `catalogo.prod.json` **vacíos** (array `[]` o objeto vacío según el esquema). Se llenan con los IDs de la BD de cada ambiente cuando haya versiones registradas en RF-69.
3. `catalogo.prueba.json`, solo para F6: una entrada con BOV-001 o TER-001, si el esquema permite cargar un modelo sin ID de RF-69. Si no lo permite, se anota como bloqueado y F6 (paso 5) queda pendiente.
4. Documento `consulta_catalogo_referencia.sql`: **no inventar esquema**. La consulta se escribe contra el esquema real (`modulo4.versiones_modelos` y columnas verificadas en el repo de DBA, solo lectura) y la ejecuta quien tenga acceso a la BD de cada ambiente. Hoy filtra por `estado = 'ACTIVO'` y por los valores reales de `tipo_modelo` (enum de 6). **El estado SOMBRA no existe todavía**: se agrega a la consulta cuando B3 / RFC-010 lo cree.

---

### F5 · Procedimiento RF-69 — 1 agente, 30 min
**Entrada:** Plan original y hallazgos del análisis.  
**Salida:** `SGMP-Integracion/E2/docs/procedimiento-rf69.md`

**Tarea:** Crear el checklist corregido:
```text
Checklist para cargar versiones SOMBRA en RF-69
[ ] RFC-010 aprobado por el Comité de cambios.
[ ] Migración Alembic de nombre_version (varchar 40 → 60) aplicada por DBA.
[ ] DEV-01 (corrección del trigger de unicidad) aplicado.
[ ] Especies del modelo individual creadas en el ambiente (hoy DEV solo tiene acuicultura).
[ ] Umbrales de RF-17 configurados y validados.
[ ] B3 completado (RF-69 con llave por animal y estado SOMBRA).
[ ] Archivos .onnx y metadatos solicitados a Desarrollo y validados con SHA-256.
[ ] Ejecutado por quien tenga la llave interna de RF-71.
[ ] catalogo.json armado con consulta_catalogo_referencia.sql sobre la BD de ese ambiente y copiado al volumen.
[ ] Solo después: IOT_INFERENCIA_M04_URL cargada en el backend (Despliegue).
[ ] Healthcheck del motor verificado tras la carga.
Ambiente: [ ] DEV  [ ] TEST  [ ] PROD
Fecha:
Ejecutor:
```
**Criterio de cierre:** Documento con el checklist completo y nota de "No ejecutar hasta RFC-010".

---

### F6 · Verificación local — 1 agente, 2 h
**Entrada:** Artefactos de F1 a F4; archivos `.onnx` solicitados a Desarrollo.  
**Salida:** Evidencias en `SGMP-Integracion/E2/evidencias/`.

**Tareas:**
1. `hadolint Dockerfile.motor-ia` → sin errores. Guardar log.
2. `docker build` → imagen construida.
3. Escaneo con `trivy image motor-ia:local` → sin vulnerabilidades CRITICAL/HIGH (o con excepciones documentadas). Guardar log.
4. Arrancar con `docker compose -f docker-compose.motor-ia.yml up` y `catalogo.json` vacío → verificar `healthy` tras el `start-period`. Si no queda `healthy`, registrar en `F6-healthcheck-vacio.md` y aplicar el workaround de F2.
5. Copiar un `.onnx` de prueba al volumen con `catalogo.prueba.json` (F4) → reiniciar el contenedor → verificar `healthy` y que el modelo aparezca cargado.
6. `docker inspect` → confirmar los límites de CPU y memoria aplicados y que el usuario sea 1001.
7. `curl -X POST http://localhost:8000/v1/paquetes -H "Authorization: Bearer <token-prueba>" -H "Content-Type: application/json" -d @paquete-ejemplo.json`. El paquete de ejemplo se toma de los tests o fixtures de #50. `BACKEND_URL` apunta a un backend `dev` local o a un stub que acepte `POST /prediccion/inferencias`, porque el motor entrega ahí el resultado. Se anota la respuesta real sin suponer el código. Guardar request y response en `F6-prueba-post.md`.

---

### F7 · PR, Evidencia y Entrega Formal — 1 agente, 1 h
**Entrada:** Todos los artefactos anteriores; confirmación de que #49, #50 y #51 están en `develop`.  
**Salida:** PRs abiertos y entregables en `SGMP-Integracion/E2`.

**Tareas:**
1. Abrir PR a `develop` del broker con título `feat(motor-ia): despliegue E2 — imagen, compose local y variables`.
   - Descripción: Resumen de supuestos, lista de archivos nuevos, nota de que **no se define `IOT_INFERENCIA_M04_URL` en el backend** hasta que el motor tenga modelos cargados (ver F3).
   - Dependencia: Requiere #49, #50 y #51 mergeados.
2. (Si aplica) Abrir PR al backend para agregar las variables `IOT_INFERENCIA_*` al `.env.example`.
3. Carpeta `SGMP-Integracion/E2/evidencias/` con: `F0-hallazgos.md`, `F6-healthcheck-vacio.md` (si aplica), `F6-prueba-post.md`, `hadolint.log` (hoy `.txt`), `trivy.log` (hoy `.txt`).
4. **Entrega formal:** Enviar a Despliegue el documento "Valores para Dokploy" (F2). Enviar a Desarrollo el aviso sobre: actualización del tablero (bloqueado por RFC-010), corrección del path `/model-ia` en su plan, y solicitud de los archivos `.onnx`.
5. Dejar listo el borrador de PR de promoción a `test` y `main` usando la plantilla `promocion-entornos`, **sin mergear** hasta que Desarrollo lleve los PRs #49 a #51 a esas ramas del broker.

---

## 2. Manejo de bloqueantes

| Bloqueante | Acción | Responsable |
|---|---|---|
| RFC-010 no aprobado | Se avanza con supuestos; F5 deja el procedimiento escrito. Desarrollo actualiza el tablero marcando tareas como "Bloqueado por RFC-010". | Desarrollo + Comité |
| PRs #49-#51 no mergeados en `develop` | F1 a F3 se trabajan en local sobre la rama del PR más avanzado. F7 se abre solo tras el merge. | Desarrollo |
| Falta confirmación de `IOT_INFERENCIA_M04_URL` (ruta completa vs. base) | F0 lo aclara; F3 documenta la forma canónica. Si no se confirma antes de F7, se deja como "pendiente de confirmación" en el PR. | Desarrollo backend |
| Despliegue no confirma tipo de servicio en Dokploy | Se asume Application. Si es Compose, el `docker-compose.motor-ia.yml` local ya escrito se adapta en <30 min. | Despliegue |
| Falta de archivos `.onnx` para prueba local | Se solicitan formalmente a Desarrollo. La prueba F6 se documenta como "pendiente de artefactos" si no llegan a tiempo, sin bloquear el resto del entregable. | Desarrollo |

---

## 3. Correcciones posteriores al entregable

Una vez resueltas las dudas, se aplican en PRs pequeños y localizados:
* Si Dokploy resulta ser Compose: crear `docker-compose.motor-ia.<entorno>.yml` (dev, test, prod) a partir del compose local, con volumen, healthcheck, límites y `dokploy-network`. **No meter el motor en los compose del broker**: el broker y el motor son servicios distintos en Dokploy y quedarían dos motores.
* Si `IOT_INFERENCIA_M04_URL` no es la URL base: actualizar `variables.md` y los `.env.example` del backend.
* Cuando RFC-010 se apruebe: ejecutar F5 en DEV primero, luego TEST, luego PROD, en ese orden.

---

## 4. Checklist final del entregable E2

* [ ] `Dockerfile.motor-ia` + `Dockerfile.motor-ia.dockerignore` (en repo broker)
* [ ] `docker-compose.motor-ia.yml` local (en repo broker)
* [ ] `.env.motor-ia.example` (en repo broker)
* [ ] `SGMP-Integracion/E2/docs/volumen-limites.md`
* [ ] `SGMP-Integracion/E2/docs/variables.md`
* [ ] `SGMP-Integracion/E2/docs/catalogo.template.json` + tres catálogos vacíos + `catalogo.prueba.json` (si el esquema lo permite)
* [ ] `SGMP-Integracion/E2/docs/consulta_catalogo_referencia.sql` (o script adaptado al esquema real)
* [ ] `SGMP-Integracion/E2/docs/procedimiento-rf69.md`
* [ ] Carpeta `SGMP-Integracion/E2/evidencias/` con F0 y F6
* [ ] PR abierto a `develop` del broker
* [ ] PR abierto al backend (si faltaban variables en `.env.example`)
* [ ] Entrega formal de "Valores para Dokploy" a Despliegue y avisos a Desarrollo
* [ ] Informe copiado a `SGMP-Integracion/E2`
* [ ] Supuestos y correcciones posteriores documentados

---

**Nota para los agentes:** Cada fase es autocontenida y puede ejecutarse en paralelo salvo las dependencias explícitas (F1 depende de F0; F6 depende de F1–F4; F7 depende de F6 y del merge de #49–#51). El entregable se considera completo cuando el checklist final esté marcado, aunque queden correcciones menores pendientes de confirmación.