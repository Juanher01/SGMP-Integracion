# IMP-M04 — Imagen del motor de inferencia M04 (`motor-ia`)

> Estado: borrador (punto de control 2) · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

Ejecución de [IMP-M04_paquete_instrucciones_motor-ia_v3.md](IMP-M04_paquete_instrucciones_motor-ia_v3.md)
con los insumos [plan_motor_ia_modelos.md](plan_motor_ia_modelos.md) y el tablero de Desarrollo
(`Motor M04 — tablero de estado.pdf`, corte 31-10; Drive: [PENDIENTE: enlace]).

## Estado por fase

| Fase | Estado | Resultado |
|---|---|---|
| F0 Reconocimiento | ✅ | [evidencias/F0-hallazgos.md](evidencias/F0-hallazgos.md) |
| F1 Imagen | ✅ | PR [#54](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/54): `89654ee` (versión inicial) + `789eb7b` (correcciones) |
| F2 Volumen y límites | ✅ | [docs/volumen-limites.md](docs/volumen-limites.md), con los «Valores para Dokploy» |
| F3 Variables | ✅ | [docs/variables.md](docs/variables.md). PR al backend: [#909](https://github.com/Arekkazu/sgpmp-backend/pull/909) |
| F4 Catálogo | ✅ | `docs/catalogo.*.json`, [docs/consulta_catalogo_referencia.sql](docs/consulta_catalogo_referencia.sql) |
| F5 Procedimiento RF-69 | ✅ escrito · ⛔ bloqueado por RFC-010 | [docs/procedimiento-rf69.md](docs/procedimiento-rf69.md) |
| F6 Verificación local | ✅ (la entrega al backend no se probó: exige HTTPS) | [evidencias/F6-verificacion-local.md](evidencias/F6-verificacion-local.md) |
| F7 PR y entrega formal | ⏸ espera aprobación del líder | [borradores/](borradores/) |

## Correcciones a la versión inicial publicada (PR #54, `89654ee`)

La versión inicial se publicó para que el equipo tuviera una base. Al verificarla salieron estos errores,
corregidos en `789eb7b`:

| # | Archivo | Error encontrado | Corrección |
|---|---|---|---|
| C-01 | `Dockerfile.motor-ia` | No construye: solo copia `pyproject.toml`; hatchling necesita `README.md`, `app/` y `motor_ia/` | El builder copia los cuatro e instala en `/opt/venv` |
| C-02 | `Dockerfile.motor-ia` | Aunque construyera, el código del motor no llegaba a la imagen (`COPY motor_ia` comentado) | El paquete queda instalado en el venv |
| C-03 | `Dockerfile.motor-ia`, compose, `.env` | Puerto 8100; Dokploy apunta al 8000, así que Traefik daría 502 | `PORT=8000` y `EXPOSE 8000` |
| C-04 | `Dockerfile.motor-ia`, `.env` | `MOTOR_IA_DIR_MODELOS=/data/modelos` fijo: con el volumen vacío, bucle de reinicios (H-01) | Sin valor por defecto; se define cuando hay `catalogo.json` |
| C-05 | `Dockerfile.motor-ia` | `python:3.13.0-slim-bookworm` sin digest | `python:3.13-slim` 3.13.18 por digest: 0 CRITICAL |
| C-06 | `Dockerfile.motor-ia` | `gcc` instalado sin necesidad y `pip --upgrade` sin versión (DL3008, DL3013) | Sin apt ni gcc; `pip` desinstalado de la imagen final |
| C-07 | `Dockerfile.motor-ia` | Copia `site-packages` y `/usr/local/bin` del builder encima de la imagen final | Copia solo `/opt/venv` |
| C-08 | `Dockerfile.motor-ia` | HEALTHCHECK en forma shell (DL3025), sin timeout | Forma JSON, `timeout=4`, puerto desde `PORT` |
| C-09 | `docker-compose.motor-ia.yml` | `version:` obsoleto; healthcheck duplicado con el puerto 8100 fijo; `env_file` obligatorio que hace fallar el compose si no existe | Interpolación con `${IOT_INFERENCIA_M04_TOKEN:?}` y `--env-file`; healthcheck heredado de la imagen |
| C-10 | `.env.motor-ia.example` | `ROOT_PATH=/model-ia-dev`: la variable no existe y el path es otro | `UVICORN_ROOT_PATH`, paths `/motor-ia-*` |

Evidencia de la versión inicial: [evidencias/pr54-version-inicial.txt](evidencias/pr54-version-inicial.txt).

## Checklist del entregable E2 (paquete §4)

- [x] `Dockerfile.motor-ia` + `Dockerfile.motor-ia.dockerignore` (broker, local)
- [x] `docker-compose.motor-ia.yml` local (broker, local)
- [x] `.env.motor-ia.example` (broker, local)
- [x] `docs/volumen-limites.md`
- [x] `docs/variables.md`
- [x] `docs/catalogo.template.json` + tres catálogos vacíos + `catalogo.prueba.json`
- [x] `docs/consulta_catalogo_referencia.sql`
- [x] `docs/procedimiento-rf69.md`
- [x] `evidencias/` con F0 y F6 (`hadolint.txt`, `trivy.txt`, `F6-verificacion-local.*`)
- [x] PR a `develop` del broker: [#54](https://github.com/SerBy48/BROKER-MQTT-SGPMP/pull/54) con las correcciones (`789eb7b`, push 2026-10-31), pendiente de aprobación de AIoT
- [x] PR al backend (variables): [#909](https://github.com/Arekkazu/sgpmp-backend/pull/909) a `dev` (`5e87d61e`), pendiente de aprobación del Líder de Desarrollo
- [ ] Entrega formal a Despliegue y avisos a Desarrollo: [borradores/](borradores/)
- [x] Supuestos y correcciones posteriores documentados (F0 y esta tabla)
