# Motor M04 — volumen, healthcheck, límites y valores para Dokploy

> Estado: vigente · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

Fuente: `Dockerfile.motor-ia` y `docker-compose.motor-ia.yml` de la rama
`feat/motor-ia-e2-despliegue` del broker (commit `789eb7b`), y el código del motor en `develop` (`ace799f`).

## Estructura del volumen

El motor lee todo de una sola carpeta (`motor_ia/individual.py`, `cargar_catalogo`). Los nombres de
archivo son los que entrega ET-02 por animal:

```text
/data/modelos/                     ← MOTOR_IA_DIR_MODELOS
├── catalogo.json                  ← {"modelos": [ ... ]}; mínimo {"modelos": []}
├── BOV-001.onnx
├── BOV-001_linea_base.json
└── BOV-001_metadatos_rf69.json    ← trae hash_artefacto_modelo (SHA-256 del .onnx)
```

Reglas que impone el código:

- Si `MOTOR_IA_DIR_MODELOS` está definida, `catalogo.json` **tiene que existir**; si falta, el motor no arranca.
- Si el SHA-256 del `.onnx` no coincide con `hash_artefacto_modelo` de los metadatos, el motor no arranca.
- Si el catálogo trae modelos y falta `BACKEND_URL`, el motor no arranca.
- Un mismo `id_activo_biologico` no puede aparecer dos veces en el catálogo.
- El catálogo se lee **solo al arrancar**: después de cambiar archivos hay que reiniciar el contenedor.

## Healthcheck

Está definido en la imagen. En Dokploy el motor es una Application, no un compose:

| Parámetro | Valor |
|---|---|
| Prueba | `GET http://127.0.0.1:${PORT}/v1/healthz` (Python `urllib`, sin curl) |
| Intervalo / timeout / start-period / reintentos | 30 s / 5 s / 30 s / 3 |

`/v1/healthz` responde 200 sin token y sin modelos. Para saber si el motor tiene modelos se lee el
campo `modelos_cargados` del cuerpo; el estado `healthy` no lo indica.

## Valores para Dokploy (entrega a Despliegue)

| Parámetro | DEV | TEST | PROD |
|---|---|---|---|
| Servicio | `motor-ia-dev` | `motor-ia-test` | `motor-ia-main` |
| Tipo | Application (Dockerfile) — **por confirmar con Despliegue** | ídem | ídem |
| Repositorio / rama de build | broker / `develop` | broker / `test` | broker / `main` (hoy **no** tiene el código del motor) |
| Dockerfile / contexto | `Dockerfile.motor-ia` / raíz del repo | ídem | ídem |
| Dominio y path | `api.inmero.co` `/motor-ia-dev` | `api.inmero.co` `/motor-ia-test` (revisar la `/` inicial) | `api.inmero.co` `/motor-ia` |
| Strip Path | Activo | Activo | Activo |
| Puerto del contenedor | 8000 | 8000 | 8000 |
| Volumen | montado en `/data/modelos` | ídem | ídem |
| CPU | límite 1.0, sin reserva | ídem | ídem |
| Memoria | límite 1 GB, reserva 256 MB | ídem | ídem |
| `OMP_NUM_THREADS` | ya fijado en la imagen (1) | ídem | ídem |

- Si el volumen es un bind mount, la carpeta del servidor debe pertenecer al UID 1001 (el usuario de la
  imagen). Un volumen nombrado nuevo hereda el dueño de `/data/modelos` de la imagen.
- Los límites son provisionales: se recalculan con la prueba de latencia M6 (P95 < 2 s, RF-66). En la
  prueba local el primer lote con BOV-001 tardó 1,25 s, incluido el intento fallido de entrega al backend.
- Las variables y su orden de carga están en [variables.md](variables.md).

### Orden de puesta en marcha por ambiente

1. Desplegar con `IOT_INFERENCIA_M04_TOKEN` y **sin** `MOTOR_IA_DIR_MODELOS`. Comprobar
   `https://api.inmero.co/motor-ia-dev/v1/healthz` → `modelos_cargados: 0`.
2. Cuando haya catálogo ([procedimiento-rf69.md](procedimiento-rf69.md)): copiar los archivos al
   volumen, definir `MOTOR_IA_DIR_MODELOS=/data/modelos` y `BACKEND_URL`, y redesplegar. Comprobar
   `modelos_cargados > 0`.
3. Recién entonces, cargar `IOT_INFERENCIA_M04_URL` en el backend de ese ambiente.

DEV primero; TEST y PROD después de revisar `healthz` en DEV.
