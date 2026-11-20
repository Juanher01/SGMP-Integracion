# Plan — Motor de inferencia M04 (`motor-ia`) con los modelos entregados

30 de octubre de 2026 · Propuesta para revisión · Insumos en `anotaciones/M04-M03 MODELOS/`

## Resumen

Los modelos individual (ET-02 v5) y de contagio (ET-03 v5) corren en un **servicio nuevo,
`motor-ia`**: contenedor propio, código en el repo del broker, publicado por Dokploy en
`api.inmero.co/model-ia[-test|-dev]`. El backend ya sabe enviarle paquetes (`IOT_INFERENCIA_M04_URL`).
Falta el camino de vuelta (resultados) y el contrato de entrada. YOLO (poblacionales V4) va al
nodo con cámara, no al servidor. Todo arranca en **modo sombra**: calcula y registra, no alerta.

## Insumos

| Modelo | Entrada ONNX | Estado |
|---|---|---|
| Individual ET-02 v5 (XGBoost, uno por animal, 7 clases) | `features [n,14]` desde ventana de 10 min (36 lecturas FC/temp/actividad) + línea base del animal | 2 de 6 con `.onnx` (BOV-001, TER-001). Ninguno registrable en RF-69 sin RFC-010. Sintético → sombra |
| Contagio ET-03 v5 (GNN) | `x [nodos,12]`, `edge_index`, `edge_type`, `edge_weight` | Apto para sombra. Necesita topología real (áreas + vías) que M09 no tiene |
| Poblacionales V4 (YOLOv8n aves/porcinos/acuicultura) | imagen `[1,3,320,320]`, clase única `animal` | Solo el detector; faltan seguimiento, métricas y anomalías. Licencia AGPL-3.0 |

## Arquitectura

```
Edge ─MQTT─> Broker ─HTTP─> Backend (RF-56 consolida paquete)
                               │  POST https://api.inmero.co/model-ia/v1/paquetes  (Bearer)
                               ▼
                           motor-ia  (onnxruntime; descarga modelos activos de RF-69)
                               │  POST /prediccion/inferencias            (Bearer)
                               ▼
                           Backend → modulo4.resultados_inferencia → RF-67 / RF-72 / RF-57*
                                                    * RF-57 solo si el modelo no está en SOMBRA
Cámara (Edge) ─ YOLO + cascada ─> vector D4 ─> /iot/telemetria/vision  (ya existe)
```

Por qué un servicio aparte y no dentro del broker: el broker es asíncrono (aiomqtt) y una
inferencia en CPU bloquea la recepción MQTT; las dependencias de ML inflan su imagen; el motor
se reinicia y escala sin tocar la ingesta. RF-66 pide a futuro inferencia en el Edge: el
individual se lleva allí por OTA (RF-70) cuando el firmware lo soporte; el servidor cubre el modo HÍBRIDO.

## Fase 0 — Decisiones (bloquean)

| # | Decisión | Propuesta | Decide | Bloquea |
|---|---|---|---|---|
| D-A | Dónde corre RF-66 | Servicio `motor-ia` (cierra Q2 de INC-M04-195-G024) | Producto / arquitectura | Todo |
| D-B | Contrato IA-1 (INC-M03-115-G58) | El motor acumula la ventana por animal con los paquetes que recibe; alternativa: el backend envía la ventana completa | Desarrollo + AIoT | F2 |
| D-C | RFC-010: llave de versión por animal | Aprobar el borrador de `ESCALAMIENTO_C1-C8_ET02_v5.md` §C1 | Comité de cambios | Registrar modelos individuales |
| D-D | Licencia AGPL de YOLO | Revisar con el líder antes de distribuir | Líder | F3 |
| D-E | Topología de vías entre áreas en M09 | Modelarla o aplazar la GNN | Análisis + DBA | Contagio en sombra |

## Fase 1 — Backend

| # | Tarea | Notas |
|---|---|---|
| B1 ✅ PR #890 | `POST /prediccion/inferencias` | Token `IOT_INFERENCIA_M04_TOKEN`, idempotente por `id_resultado_inferencia` (lo genera el motor). Columna `modo_sombra` (migración 785022cc8ef9, DBA pendiente). Por ahora solo acepta resultados en sombra (422 si son vinculantes) |
| B2 | Entrega de artefactos activos al motor | `GET` interno con versión activa por `(tipo_modelo, componente[, id_animal])` y binario + `hash_artefacto_modelo`. Hoy solo existe `/prediccion/ota/artefactos/{id_despliegue_ota}`, pensado para nodos |
| B3 | RF-69 con llave por animal y estado SOMBRA | Tras D-C. Migración Alembic → autorización DBA |
| B4 | Sacar el envío a M04 de la petición del evento Edge | T2 del plan de reenvío: hoy espera a M04 dentro del request con 10 s de timeout |
| B5 ✅ PR #892 | Contrato IA-1 v1 | D-B decidida: el backend manda `id_activo_biologico` + 2 h de lecturas del activo. Además: URL base en cualquier dominio, `codigo_patologia_rf64`, worker con motor real y lock FOR NO KEY UPDATE |

## Fase 2 — Servicio `motor-ia`

| # | Tarea | Notas |
|---|---|---|
| M1 ✅ broker #49 | Esqueleto FastAPI: `POST /v1/paquetes`, `GET /v1/healthz` | `root_path` por variable para el prefijo de Traefik. Rechaza sin `Bearer`; no arranca si `IOT_INFERENCIA_M04_TOKEN` está vacía |
| M2 ✅ broker #50 | Pipeline de inferencia individual | Extraer de `modelos_individuales_ET02_v5.py` solo `validar_lecturas`, `regularizar_y_rellenar`, `construir_ventanas`, `calcular_features`, `LineaBase`. Sin xgboost/sklearn/matplotlib en runtime |
| M3 | Carga de modelos desde B2 | Caché en volumen, verifica SHA-256 antes de usar, recarga al cambiar la versión activa |
| M4 ✅ broker #50 | Salida contrato RF-66 → B1 | Formato de `salidas_ET02_v5/contrato_ejemplo_rf66.json`, con `modo_sombra` |
| M5 | Contagio en sombra | Solo si D-E. La fórmula RF-68 del backend sigue siendo la lógica vigente |
| M6 | Pruebas | Paridad contra las salidas de referencia; latencia P95 < 2 s (RF-66) |

## Fase 3 — IoT (visión)

| # | Tarea | Notas |
|---|---|---|
| V1 | Cascada en el nodo con cámara: YOLO → seguimiento → métricas → anomalías | Publica el sobre D4 `VECTOR_COMPORTAMIENTO`; el backend ya lo acepta. Hoy ningún firmware publica visión (T6 del plan de reenvío) |
| V2 | Latencia en el hardware real | Los modelos están a 320 px para un equipo modesto; medir en el gateway |

## Implementación (Docker)

- `Dockerfile` de `motor-ia`: Python 3.13, `onnxruntime==1.29.0`, `numpy==2.5.3`, `pandas==3.0.5`, uvicorn.
- Servicio `motor-ia` en `docker-compose.yml` y `docker-compose.prod.yml` del broker.
- Escucha HTTP en su puerto, sin certificados: el HTTPS lo pone Dokploy (Let's Encrypt).
- Volumen para la caché de modelos. Los `.onnx`/`.pt` no van a git (53 MB solo los poblacionales).
- Healthcheck sobre `/v1/healthz` y límites de CPU/memoria.

## Despliegue (Dokploy)

| Ambiente | Dominio + Path (Strip Path activado) | Backend que lo llama |
|---|---|---|
| PROD | `api.inmero.co` `/model-ia` | `/sigab` |
| TEST | `api.inmero.co` `/model-ia-test` | `/api-sgpmp-test` |
| DEV | `api.inmero.co` `/model-ia-dev` | `/api-sgpmp-dev` |

Un motor por ambiente: cada uno descarga los modelos activos del RF-69 de su propia BD.

Variables del backend en cada ambiente:

```env
IOT_INFERENCIA_M04_URL=https://api.inmero.co/model-ia-test/v1/paquetes   # prefijo del ambiente
IOT_INFERENCIA_M04_TOKEN=<mismo valor que en el motor>
IOT_INFERENCIA_TLS_MIN=1.3
IOT_INFERENCIA_CA_FILE=                                                  # vacía: CA del sistema
```

- La URL debe coincidir **exacta** con la ruta del motor: el cliente no sigue redirecciones
  (`follow_redirects=False`), así que un 307 por barra final se toma como fallo.
- Opcional: middleware de lista de IPs en ese router de Traefik para que solo responda al backend.
- Orden: backend (B1, B2, migración con visto bueno del DBA) → motor → cargar versiones SOMBRA en
  RF-69 desde `*_metadatos_rf69.json` → por último poner `IOT_INFERENCIA_M04_URL`. Con la URL vacía
  los paquetes quedan pendientes y nada se rompe.
- **No poner la URL antes de M2**: el esqueleto responde 503, y el backend marca FALLIDO un paquete
  tras 5 envíos fallidos (~2 min). Vacía, no gasta intentos.
- Confirmar desde qué rama sale cada ambiente (D4 del plan de reenvío): `main` va muy atrás de `dev`.

## Orden sugerido

1. Ya: D-A a D-E en paralelo; B1 y M1 (no dependen de decisiones).
2. Tras D-B: B5, M2, M4.
3. Tras D-C: B3, B2, M3.
4. Tras D-E: M5. Tras D-D: V1, V2.
5. Implementación + despliegue en DEV → pruebas E2E en TEST → PROD.

## Riesgos

- Los modelos individuales son **por animal sintético**: aplicarlos a un activo real exige calibrar
  su línea base (`calibrar_animal`) y, en rigor, entrenar por animal. Hasta entonces, solo sombra.
- El motor comparte dominio público con el backend: el token es la única barrera si no se pone
  la lista de IPs.
- Latencia sin medir en el Pi 3 (C4 de ET-02); importa cuando el individual pase al Edge.

## Hallazgos de M2 (PR #892 / broker #50)

- H1: `ACTIVIDAD` está en m/s² (0–200); ET-02 espera índice 0–1 → con datos reales se descarta (AIoT).
- H2: `version_modelo` de ET-02 (46 caracteres) no cabe en `nombre_version varchar(40)` (DBA, con RFC-010).
- H3: nivel_riesgo derivado de la clase predicha (S4) mientras Análisis no defina la proyección.
- H4: las 8 patologías base son datos, no las siembra Alembic.
