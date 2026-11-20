# Borrador — PR al backend: variables del motor M04 en los compose

> Estado: borrador (no publicado) · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

**Rama:** `fix/imp-m04-variables-motor-ia`, desde `origin/dev` (`4f0d54cd`). Commit local `5e87d61e`, sin push.
**Base del PR:** `dev` (lo aprueba el Líder de Desarrollo).

**Título:** `fix(rf-66): pasar las variables del motor de inferencia M04 al contenedor del backend`

---

## Descripción

Los compose del backend declaran `environment:` explícito y no incluían las variables del cliente
hacia el motor de inferencia M04. Si se cargan en Dokploy, no llegan al contenedor, y el backend
sigue usando el stub (`MotorInferenciaStubAdapter`).

| Archivo | Cambio |
|---|---|
| `docker-compose.yml` | Agrega `IOT_INFERENCIA_M04_URL`, `IOT_INFERENCIA_M04_TOKEN`, `IOT_INFERENCIA_CA_FILE` (default vacío) e `IOT_INFERENCIA_TLS_MIN` (default 1.3) |
| `docker-compose.prod.yml` | Ídem |
| `.env.prod.example` | Agrega las cuatro, sin valores, con el orden de carga |
| `.env.example` | El ejemplo de URL pasa de `/model-ia-test/v1/paquetes` a la URL base `/motor-ia-*` (path real en Dokploy) |

No toca código de aplicación. Con los defaults vacíos, el comportamiento actual no cambia.

## Verificación

- `docker compose config --no-interpolate` valida los dos archivos y muestra las cuatro variables en el servicio del backend.
- En DEV, después del merge: `docker exec <backend> env | grep -c '^IOT_INFERENCIA_'` cuenta 4 (cuenta las variables, sin mostrar valores).

## Nota

`IOT_INFERENCIA_M04_URL` se carga **al final**, cuando el motor del ambiente tenga modelos.
