# Motor M04 — catálogo de variables (motor y backend)

> Estado: vigente · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

Sin valores reales: los carga Despliegue en Dokploy. Fuentes: `motor_ia/main.py` y `motor_ia/backend.py`
del broker en `develop` (`ace799f`); `.env.motor-ia.example` en `789eb7b`; `motor_inferencia_http_adapter.py`
del backend en `dev` (`4f0d54cd`).

## Motor (`motor-ia-dev` / `-test` / `-main`)

| Variable | Obligatoria | Sensible | DEV | TEST | PROD | Notas |
|---|---|---|---|---|---|---|
| `IOT_INFERENCIA_M04_TOKEN` | Sí | **Sí** | valor propio (Dokploy) | valor propio (Dokploy) | valor propio (Dokploy) | Igual al del backend del mismo ambiente; distinto entre ambientes. Vacía: el motor no arranca |
| `BACKEND_URL` | Si hay modelos | No | `https://api.inmero.co/api-sgpmp-dev` | `https://api.inmero.co/api-sgpmp-test` | `https://api.inmero.co/sigab` | Solo `https://`, sin barra final. El motor agrega `/prediccion/inferencias` |
| `MOTOR_IA_DIR_MODELOS` | No | No | `/data/modelos` cuando haya catálogo | ídem | ídem | Vacía: sin modelos. Definida sin `catalogo.json`: no arranca |
| `PORT` | No | No | 8000 (imagen) | 8000 | 8000 | No cambiar: Dokploy apunta al 8000 |
| `UVICORN_ROOT_PATH` | No | No | `/motor-ia-dev` | `/motor-ia-test` | `/motor-ia` | Solo para los enlaces de Swagger |
| `OMP_NUM_THREADS` | No | No | 1 (imagen) | 1 | 1 | Ya fijada en la imagen |

`MOTOR_IA_TOKEN`, `ENVIRONMENT` y `ROOT_PATH` **no existen** en el código.

## Backend (`sgpmp-backend`, cada ambiente)

| Variable | Obligatoria | Sensible | DEV | TEST | PROD | Notas |
|---|---|---|---|---|---|---|
| `IOT_INFERENCIA_M04_URL` | No (vacía = pendientes) | No | `https://api.inmero.co/motor-ia-dev` | `https://api.inmero.co/motor-ia-test` | `https://api.inmero.co/motor-ia` | URL base, sin barra final. **Se carga al final** (ver abajo) |
| `IOT_INFERENCIA_M04_TOKEN` | Sí, para recibir resultados | **Sí** | valor propio (Dokploy) | valor propio (Dokploy) | valor propio (Dokploy) | El mismo valor que en el motor. Vacía: `POST /prediccion/inferencias` responde 503 |
| `IOT_INFERENCIA_TLS_MIN` | No | No | 1.3 | 1.3 | 1.3 | Default 1.3 |
| `IOT_INFERENCIA_CA_FILE` | No | No | vacía | vacía | vacía | Vacía: CA del sistema (Let's Encrypt) |

**Hallazgo H-05:** hoy los compose del backend no pasan estas cuatro variables al contenedor. Se
corrigen en el PR `fix/imp-m04-variables-motor-ia` (Arekkazu/sgpmp-backend#909, commit `5e87d61e`). Hasta que ese
PR llegue a cada rama, cargarlas en Dokploy no tiene efecto si el backend se despliega como Compose.

## Cuándo cargar `IOT_INFERENCIA_M04_URL`

**No definirla en el backend hasta que el motor de ese ambiente tenga modelos cargados**
(`/v1/healthz` → `modelos_cargados > 0`).

- Con la URL vacía, los paquetes quedan pendientes y no se pierde nada.
- Con la URL apuntando a un motor sin modelos, el motor responde 503 `MOTOR_SIN_MODELOS` y el backend
  marca el paquete FALLIDO tras 5 intentos (~2 min).

El motor necesita el `id_version_modelo` registrado en RF-69 para armar su catálogo. Por eso, en la
práctica, la condición es: **versiones registradas en RF-69 del ambiente + catálogo copiado + `healthz` con modelos**.
