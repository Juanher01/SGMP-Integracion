# F0 — Reconocimiento del motor de inferencia M04 (broker #49, #50, #51)

> Estado: vigente · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

Análisis hecho a mano (mismo alcance que `/impacto`) sobre `SerBy48/BROKER-MQTT-SGPMP` y
`Arekkazu/sgpmp-backend`. Manda el código; las diferencias con el plan y el tablero se listan como hallazgos.

## Estado de las ramas (verificado con `git fetch` y `git merge-base --is-ancestor`)

| Rama del broker | Punta | ¿Incluye #49–#51 (merge `976ec7c`)? |
|---|---|---|
| `develop` | `ace799f` (0.4.0-rc.12) | Sí. #49, #50, #51 y #52 mergeados el 30–31 oct |
| `test` | `dc4daf7` | Sí (PR #53, develop → test) |
| `main` | `cebd430` | **No** |

Backend: `origin/dev` en `4f0d54cd` (1.4.0-rc.26), confirmado con `gh api repos/Arekkazu/sgpmp-backend/commits/dev`.

## Respuestas a las preguntas de F0

| Pregunta | Respuesta | Evidencia |
|---|---|---|
| ¿`/v1/healthz` responde 200 sin modelos? | **Sí**, siempre 200 y sin token: `{"status":"ok","modelos_cargados":N,"backend":...}`. No hay riesgo de bucle *unhealthy* | `motor_ia/main.py` en `ace799f`, función `healthz` |
| Forma de `catalogo.json` | `{"modelos": [{"id_activo_biologico", "id_version_modelo", "onnx", "linea_base", "metadatos"}]}`. Los tres archivos van **en la misma carpeta** que `catalogo.json` (no hay subcarpeta `modelos/`) | Docstring y `cargar_catalogo` de `motor_ia/individual.py`; ejemplo real en `tests/fixtures/et02_bov001/catalogo.json` |
| Variable de `root_path` | **No existe en el código.** El motor no lee ninguna; uvicorn acepta `--root-path` o la variable `UVICORN_ROOT_PATH` (`auto_envvar_prefix="UVICORN"`, uvicorn 0.54.0) | Docstring de `motor_ia/main.py`; `uvicorn/main.py:61` dentro de la imagen |
| Dependencias del extra `motor-ia` | `onnxruntime==1.29.0`, `numpy==2.5.3`, `pandas==3.0.5` (numpy exige Python ≥ 3.12) | `pyproject.toml` en `ace799f`, `[project.optional-dependencies]` |
| ¿`.env.example` del backend tiene las `IOT_INFERENCIA_*`? | Sí, las cuatro (líneas 179–184 de `origin/dev`). **Pero** `.env.prod.example` no las tiene y **ningún compose del backend las pasa al contenedor** | `git show origin/dev:docker-compose.yml` (environment explícito, sin `IOT_INFERENCIA_*`) |
| ¿`IOT_INFERENCIA_M04_URL` es base o ruta completa? | **Las dos sirven.** El cliente agrega `/v1/paquetes` salvo que la URL ya termine así. Forma canónica: la URL base (`https://api.inmero.co/motor-ia-dev`) | `url_paquetes()` en `src/telemetry/infrastructure/adapters/motor_inferencia_http_adapter.py` (`origin/dev`) |

## Hallazgos

| # | Hallazgo | Efecto | Responsable |
|---|---|---|---|
| H-01 | Si `MOTOR_IA_DIR_MODELOS` está definida y la carpeta no tiene `catalogo.json`, el motor **no arranca** (`CatalogoInvalidoError`) | Fijarla en la imagen con un volumen vacío deja el contenedor en bucle de reinicios. Reproducido en F6 paso 4b | Implementación (no se fija en la imagen) |
| H-02 | Con modelos en el catálogo y sin `BACKEND_URL`, el motor no arranca | La variable es obligatoria en cuanto haya catálogo | Despliegue (cargarla) |
| H-03 | `BACKEND_URL` solo acepta `https://` | No se puede probar la entrega contra un backend local sin TLS | — (por diseño) |
| H-04 | El arranque documentado usa `--port 8100`; Dokploy apunta al 8000 | La imagen fija `PORT=8000` | Implementación |
| H-05 | El backend no recibe las `IOT_INFERENCIA_*` aunque se carguen en Dokploy: sus compose declaran `environment:` explícito sin ellas, y `.env.prod.example` no las lista | El backend seguiría usando el stub | Implementación (PR al backend, preparado en local) |
| H-06 | El plan de Desarrollo y el `.env.example` del backend usan `/model-ia[-test]`; Dokploy y el tablero usan `/motor-ia[-test]` | Una URL mal copiada da 404 en Traefik | Desarrollo (plan); el `.env.example` se corrige en el PR al backend |
| H-07 | `ROOT_PATH` (de la versión inicial del `.env.motor-ia.example`) no existe | Sin efecto en las rutas; Swagger arma mal sus enlaces | Implementación (corregido) |
| H-08 | La unicidad de producción en `modulo4.versiones_modelos` agrupa por `(tipo_modelo, componente)` (migración `a9d4d253ac97`, 2026-10-19) y existe un índice único de versión `ACTIVO` por `(tipo_modelo, componente)` (`cf12e716a4ec`) | Solo puede haber una versión activa por tipo de modelo, así que no caben versiones por animal. Confirma el bloqueo de RFC-010. No se pudo confirmar si "DEV-01" se refiere a esto | DBA / Comité (RFC-010) |
| H-09 | `versiones_modelos` no tiene columna de animal ni el estado `SOMBRA` (`enum_estado_version_modelo`: EN_VALIDACION, APROBADO, ACTIVO, DEPRECADO, RECHAZADO); `nombre_version` es `varchar(40)` | El catálogo no se puede derivar solo de la BD: el `id_activo_biologico` se asigna a mano hasta RFC-010 | DBA / Comité |
| H-10 | El enum `tipo_modelo` tiene 6 valores: MODELO_AVES, MODELO_ESPECIES_MEDIANAS, MODELO_ESPECIES_GRANDES, MODELO_RIESGO_CONTAGIO, MODELO_PORCINOS, MODELO_ACUICULTURA | Base de la consulta de referencia de F4 | — |
| H-11 | Los artefactos de BOV-001 (`.onnx`, línea base, metadatos y `catalogo.json`) **están versionados** como fixture de pruebas en `tests/fixtures/et02_bov001/` | La prueba local F6 paso 5 no depende de que Desarrollo entregue los `.onnx`. Para los ambientes sí hacen falta los artefactos validados | — |
| H-12 | La línea base del fixture vence a los 6 meses (feb. 2027), según `tests/test_motor_ia.py` | Después de esa fecha la inferencia con el fixture deja de dar resultado | Desarrollo (informativo) |
| H-13 | `pip install ".[motor-ia]"` también instala las dependencias base del broker (aiomqtt, sqlalchemy, asyncpg) | Imagen más pesada (590 MB). Separar las dependencias es cambio de `pyproject.toml`, de Desarrollo | Desarrollo (opcional) |

## Supuestos del paquete v3 que cambian

| # | Supuesto | Cambio |
|---|---|---|
| 2 | Puerto 8000 | Se mantiene |
| 4 | Los `.onnx` no están en el repo | Solo es cierto para los ambientes; BOV-001 está como fixture (H-11) |
| F1 | `ENV MOTOR_IA_DIR_MODELOS=/data/modelos` en la imagen | Se descarta por H-01 |
| F1 | Base `python:3.13-slim-bookworm` | Se usa `python:3.13-slim` (trixie): bookworm tiene 2 CRITICAL sin corrección |
| F2 | Volumen con subcarpeta `modelos/` | Estructura plana (H-01, forma del catálogo) |
| F2 | Workaround si `healthz` da 503 | No hace falta: siempre da 200 |
| F4 | Catálogos vacíos `[]` | El esquema exige `{"modelos": []}` |

## Directrices SEG aplicables

No hay issues `SEG-*` en el repo del broker para imágenes (`gh issue list -R SerBy48/BROKER-MQTT-SGPMP --search SEG`: sin resultados). Se aplican por analogía los criterios de SEG-CICD-01 (backend): imagen no-root, hadolint limpio, sin compiladores en la imagen final y base fijada. Ver [registro-SEG](../../../../registros/seguridad/registro-SEG.md).
