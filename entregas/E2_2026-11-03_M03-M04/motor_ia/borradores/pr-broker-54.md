# Borrador — actualización del PR #54 del broker

> Estado: borrador (no publicado) · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

**Acción propuesta:** push del commit `789eb7b` a `feat/motor-ia-e2-despliegue`. El PR #54 lo toma
solo, porque aún no está mergeado y su versión inicial no construye. Después se reemplaza la
descripción por el texto de abajo y se cambia el título.

**Título:** `feat(motor-ia): despliegue E2 — imagen, compose local y variables`

---

## Descripción

Imagen propia del motor de inferencia M04 (`motor_ia/`, RF-66), que se despliega como servicio aparte
del broker (Applications `motor-ia-dev`, `motor-ia-test` y `motor-ia-main` en Dokploy). No modifica el
código del broker, su `Dockerfile` ni sus `docker-compose*.yml`.

| Archivo | Qué es |
|---|---|
| `Dockerfile.motor-ia` | Multi-etapa sobre `python:3.13-slim` fijada por digest (3.13.18). Instala `".[motor-ia]"` en un venv y la imagen final copia solo el venv. Corre como usuario 1001, escucha en el puerto 8000 y tiene healthcheck sobre `/v1/healthz` |
| `Dockerfile.motor-ia.dockerignore` | Exclusiones propias de esta imagen (BuildKit) |
| `docker-compose.motor-ia.yml` | Solo para desarrollo local: volumen `/data/modelos`, límites de 1 CPU y 1 GB (reserva 256 MB) |
| `.env.motor-ia.example` | `IOT_INFERENCIA_M04_TOKEN`, `BACKEND_URL`, `MOTOR_IA_DIR_MODELOS`, `UVICORN_ROOT_PATH` (sin valores) |

### Correcciones respecto a la versión inicial (`89654ee`)

- La imagen no construía: faltaban `README.md`, `app/` y `motor_ia/` en la etapa de build.
- El puerto pasa de 8100 a 8000, que es al que apuntan los servicios de Dokploy (con 8100, Traefik da 502).
- `MOTOR_IA_DIR_MODELOS` ya no se fija en la imagen: con el volumen vacío el motor no arranca.
- Base actualizada de 3.13.0 a 3.13.18 (trixie), sin `gcc` y sin `pip` en la imagen final.
- `ROOT_PATH` no existe en el código; se reemplaza por `UVICORN_ROOT_PATH`.

## Trazabilidad

- **RF asociado:** RF-66 (motor de inferencia M04)
- **Depende de:** #49, #50 y #51, ya mergeados en `develop`

## Verificación (local)

- `hadolint`: sin avisos.
- `trivy` (CRITICAL/HIGH): 0 CRITICAL, 0 en paquetes Python. Quedan 44 HIGH del sistema Debian 13, sin corrección publicada.
- Sin modelos: el contenedor queda `healthy` y `POST /v1/paquetes` responde 401 sin token y 503 `MOTOR_SIN_MODELOS` con token.
- Con el modelo BOV-001 del fixture: `modelos_cargados: 1` e infiere el caso SEPTICEMIA.
- `docker inspect`: usuario 1001 y límites aplicados.

## Notas para el revisor

- **No definir `IOT_INFERENCIA_M04_URL` en el backend** hasta que el motor del ambiente tenga modelos
  (`/v1/healthz` → `modelos_cargados > 0`). Con un motor sin modelos, los paquetes quedan FALLIDO tras 5 intentos.
- Si `MOTOR_IA_DIR_MODELOS` está definida, la carpeta debe tener `catalogo.json` (mínimo `{"modelos": []}`).
- La entrega del resultado al backend no se probó en local, porque exige HTTPS. La cubren las pruebas
  de #50 y se verifica en DEV.
- El checklist de la plantilla (ruff, pytest, capas) no aplica: el PR no toca código Python.
