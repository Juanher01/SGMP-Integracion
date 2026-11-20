# F6 — Verificación local de la imagen `motor-ia`

> Estado: vigente · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

Imagen construida desde la rama `feat/motor-ia-e2-despliegue` del broker, commit `789eb7b`, sobre el
código del motor de `develop` (`ace799f`). Docker 29.7.2 en Windows (Docker Desktop). Token de prueba
generado al momento y enmascarado en los logs. Salida completa en
[F6-verificacion-local.txt](F6-verificacion-local.txt).

## Resultado por paso

| Paso | Qué se verificó | Resultado | Evidencia |
|---|---|---|---|
| 1 | `hadolint Dockerfile.motor-ia` (2.15.1) | ✅ sin avisos | [hadolint.txt](hadolint.txt) |
| 2 | `docker build` | ✅ imagen `motor-ia:local`, 590 MB | — |
| 3 | `trivy image --severity CRITICAL,HIGH` (0.76.1) | ✅ 0 CRITICAL; 0 en paquetes Python; 44 HIGH del sistema Debian 13 sin corrección publicada (excepciones, abajo) | [trivy.txt](trivy.txt) |
| 4a | Arranque sin `MOTOR_IA_DIR_MODELOS` | ✅ `healthy`, 0 reinicios, `modelos_cargados: 0` | log, «Paso 4a» |
| 4b | `MOTOR_IA_DIR_MODELOS=/data/modelos` con el volumen vacío | ⚠️ esperado: no arranca, `CatalogoInvalidoError`, reinicios en bucle. Confirma H-01 | log, «Paso 4b» |
| 4c | `catalogo.json` = `{"modelos": []}` | ✅ `healthy`, `modelos_cargados: 0` | log, «Paso 4c» |
| 5a | Modelo BOV-001 (fixture del repo) sin `BACKEND_URL` | ⚠️ esperado: no arranca (`RuntimeError`, falta `BACKEND_URL`) | log, «5a» |
| 5b | Modelo BOV-001 con `BACKEND_URL` https | ✅ `healthy`; `modelos_cargados: 1` (SHA-256 verificado al cargar) | log, «5b» |
| 6 | `docker inspect` | ✅ `User=1001`; CPU 1.0; memoria 1 GiB; reserva 256 MiB; healthcheck 30 s/5 s/30 s/3 | log, «Paso 6» |
| 7a | `POST /v1/paquetes` sin token | ✅ 401 `TOKEN_SERVICIO_INVALIDO` | log |
| 7b | `POST` con token y sin modelos | ✅ 503 `MOTOR_SIN_MODELOS` (el backend reintenta; no se pierde el paquete) | log |
| 7c | `POST` con token y BOV-001 cargado (caso SEPTICEMIA del fixture, 105 lecturas) | ✅ el motor infirió: log C3 del activo 885 con temperatura fuera del rango sano. Luego respondió 503 `BACKEND_NO_DISPONIBLE` en 1,25 s porque no hay backend que reciba | log, «Paso 7c» |

## Lo que no se pudo probar en local

- **Entrega del resultado al backend** (`POST {BACKEND_URL}/prediccion/inferencias`): el motor solo
  acepta `https://`, y los hooks de este espacio bloquean generar un certificado de prueba. Esto queda
  cubierto por las pruebas de #50 con `httpx.MockTransport`
  (`tests/test_motor_ia.py::test_infiere_una_vez_por_activo_y_entrega_al_backend`) y se verifica de
  punta a punta en DEV, con el backend real, después del despliegue.
- **Latencia P95 < 2 s** (M6): es tarea de Desarrollo. El dato de 1,25 s es un solo lote e incluye el
  intento de conexión fallido.

## Excepciones de trivy (HIGH del sistema, sin corrección)

Los 44 hallazgos tienen estado `affected` (43) o `fix_deferred` (1) en Debian 13, así que no hay
versión corregida que instalar. Están en paquetes de la imagen base que el motor no invoca: util-linux
(`mount`, `libblkid1`, `libmount1`…), ncurses, `perl-base`, `login`, `libsystemd0`, `libudev1`. Se revisan
al actualizar el digest de `python:3.13-slim`.

Alternativas descartadas:

| Opción | Resultado |
|---|---|
| `python:3.13-slim-bookworm` | 53 hallazgos, 2 de ellos CRITICAL (sqlite CVE-2025-7458, zlib CVE-2023-45853), sin corrección |
| `python:3.13.0-slim-bookworm` (versión inicial del PR #54) | La primera 3.13 de 2024; no se adoptó |

Se eliminaron 5 HIGH corregibles (urllib3, msgpack, setuptools) quitando `pip` de la imagen final,
que tiene copias vendorizadas de esos paquetes.

## Versión inicial del PR #54 (`89654ee`)

No construye: `OSError: Readme file does not exist: README.md`. Hadolint da 3 avisos (DL3008, DL3013 y
DL3025). Ver [pr54-version-inicial.txt](pr54-version-inicial.txt) y la tabla de correcciones en el
[README](../README.md).
