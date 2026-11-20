# EXT-BACK-PR1130 — Montaje de la clave pública del SSO de AgroFusion en `docker-compose.test.yml`

> Análisis de cambio externo (Camino B, flujo 4) · Analista: Implementación · Fecha: 2026-11-17 · Entrega: E3
> Implementación no es revisor asignado: este informe no aprueba ni rechaza el cambio.

## 1. Ficha

| Campo | Valor |
|---|---|
| Repo | `Arekkazu/sgpmp-backend` |
| PR | #1130 `chore/test-compose-clave-sso-agrofusion` → `test` · **MERGED** 2026-11-14 05:10 UTC por Arekkazu · 0 reviews · 0 comentarios |
| Commits | `9a52ad5cc2337b07e23ef1379b04d8f0c0629950` (`9a52ad5c`) · merge `64c691237e59b8008044aa972c8883eb1a746805` (`64c69123`) |
| Autor / equipo | Arekkazu (Desarrollo). Implementación no participó |
| Relacionado | #1129 (dev, ver `commits/BACK-9ff4d38_sso-issuer-codigos-proyecto/analisis.md`) · nuestra HU-IMP-CFG-03 (`0dbe294`, PR #1051) |
| Corte (fetch del líder, 2026-11-17) | `origin/dev` `2b9ee221` · `origin/test` `5697ebbe` · `origin/main` `0abbeeef` |

## 2. Qué se hizo

`docker-compose.test.yml` existe solo en `test`. Pasaba las variables del SSO pero el `backend` no montaba el
`.pem`, así que con `AGROFUSION_SSO_PUBLIC_KEY_PATH` cargada el SSO de TEST daría 500
`AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE`. El PR crea el bloque `volumes:` del `backend`
(`docker-compose.test.yml:80-86` en `origin/test`) con un único montaje:

```yaml
- ../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro
```

más un comentario que explica el *File Mount* de Dokploy y una fila en la tabla de cambios (línea 4).
Descripción y diff coinciden (1 archivo, +8). La descripción indica para TEST `AGROFUSION_PROJECT_CODE=SIGAB-TEST`
(no sensible).

## 3. Estado por rama

| Rama | `9a52ad5c` / `64c69123` | Evidencia |
|---|---|---|
| `dev` `2b9ee221` | AUSENTE (esperado) | `docker-compose.test.yml` no existe en `dev` (`git ls-tree origin/dev`) |
| `test` `5697ebbe` | INCLUIDO | `git merge-base --is-ancestor`; montaje en `docker-compose.test.yml:86`; `docker compose -f docker-compose.test.yml config --no-interpolate --quiet` → `TEST-OK`; el bind resuelve a `target: /app/secrets/agrofusion_sso_public.pem`, `read_only: true`, solo en `backend` |
| `main` `0abbeeef` | AUSENTE (esperado) | El archivo no existe en `main`. PROD usa `docker-compose.prod.yml`, que en `main` **aún no** monta el `.pem` (llega con `0dbe294` en el release #941) |

## 4. Archivos de Implementación tocados y conformidad

Cambio de otro equipo en archivo de Implementación: `docker-compose.test.yml`.

**¿Es correcto desde infraestructura?** Sí.

| Regla / punto | Veredicto | Evidencia |
|---|---|---|
| Igual al montaje de `0dbe294` en `dev` | **Idéntico** en origen, destino y modo: `../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro` (`dev:docker-compose.yml:109`, `dev:docker-compose.prod.yml:189`, `test:docker-compose.test.yml:86`). Solo difiere el comentario (sin "Mecanismo A") | `git show 0dbe294` vs `git show 9a52ad5c` |
| Patrón *File Mount* de Dokploy (`../files/`) | Conforme | Mismo patrón que `firebase.json` en DEV/PROD |
| `compose-entornos` 1 (sin `ports:`) | Conforme | Solo `expose: "8000"` |
| `compose-entornos` 11 (comentarios del porqué) | Conforme | Comentario en español |
| Alcance "solo el `.pem`" (decisión del líder 2026-11-07 para CFG-03) | Conforme | No agrega `firebase.json` ni `sgpmp_modelos`; eso sigue pendiente para el PR de alineación de compose |
| Validez | Conforme | `TEST-OK` (2026-11-17) |
| Riesgo heredado (carpeta creada si falta el archivo) | Igual que en DEV/PROD | Mitigación en la ficha de ST-04 de CFG-03 |

**Observación de proceso (no de infraestructura):** el aprobador de `test` es el Líder de Pruebas; el PR se fusionó
sin reviews por su propio autor, 9 minutos después de abrirse.

## 5. Impacto

| Punto | Resultado | Evidencia |
|---|---|---|
| Choque con CFG-03 | **No hay conflicto de contenido**: es exactamente el montaje que pedía CA-4. Pero **duplica** el paso 3.1 de `brief-02-pr-test.md` y parte de ST-02: si Juan Hernando ejecuta el brief tal como está, su rama desde `origin/test` ya trae el bloque `volumes:` y el paso crearía un segundo montaje o un conflicto | `test:docker-compose.test.yml:80-86` |
| `brief-02` | **Obsoleto en parte.** Sigue vigente: quitar `AGROFUSION_HUB_*` (pasos 2, 3.2, 4.2), comentar las variables en `.env.test.example` (4.1). Obsoleto: 3.1 (montaje). Nuevo: pasar `SGPMP_ENTORNO` (ver abajo) | — |
| `AGROFUSION_HUB_CLIENT_ID/SECRET` en TEST | Siguen en `docker-compose.test.yml:66-67` y `.env.test.example:54-55`. El código de `test` y de `dev` **no las lee** (`git grep AGROFUSION_HUB origin/{dev,test} -- '*.py'` vacío). PDF §3 correcto | — |
| `AGROFUSION_HUB_*` en `main` | Siguen en `docker-compose.yml:73-74`, `docker-compose.prod.yml:149-150`, `.env.example:132-133`, `.env.prod.example:216-217`. **El código de `main` todavía las lee**: `main.py:671`, `src/shared/agrofusion_auth.py:19-20`. Quitarlas hoy de `main` rompería la integración M2M de PROD | `git grep -n AGROFUSION_HUB origin/main` |
| `SGPMP_ENTORNO` en TEST | **No se pasa**: no aparece en `docker-compose.test.yml` ni en `.env.test.example`. El código lee `os.getenv("SGPMP_ENTORNO", "DEV")` (`src/accounting_integration/infrastructure/configuracion.py:18`), así que TEST se identifica como `DEV` en `SourceSystem.Environment` (M07/AAEF). PDF §3 correcto. En `dev`: `docker-compose.yml:79` `:-DEV`, `docker-compose.prod.yml:153` `:-PROD` | — |
| `SGPMP_ENTORNO` en `main` | El código de `main` no la lee (`git grep` vacío); llega con el release junto a `dev:docker-compose.prod.yml:153` | — |
| `AGROFUSION_ISSUER` en TEST | Ya con default: `docker-compose.test.yml:65` | — |
| Variables nuevas | No | — |
| Puertos, redes, healthcheck | Sin cambios. El `backend` de TEST sigue sin healthcheck propio y sin volumen de modelos (`MODELOS_STORAGE_PATH` por defecto `/tmp/sgpmp_modelos`, contra `compose-entornos` 9). Hallazgo previo, fuera de este PR | `docker-compose.test.yml:62` |
| `.dockerignore` (`**/*.pem`) en `test` | Llegó con el merge de `dev` (`0dbe294` INCLUIDO en `test`) | `--is-ancestor` |
| Orígenes externos / CSP / workflows / temporales | No aplica | — |
| Secretos | Ninguno en el diff ni en la descripción | — |

## 6. Trabajo derivado

| Tipo | Rama | Trabajo | Estrategia |
|---|---|---|---|
| Sin acción | `test` | Montaje del `.pem`: hecho por #1130. CA-4 (parte montaje) se da por cumplido con evidencia ajena: registrar en `HU-IMP-CFG-03/evidencias/` la salida `TEST-OK` y la línea 86 | — |
| Implementación (CFG, rehacer ST-02) | `test` | PR desde `origin/test` que solo toca `docker-compose.test.yml` y `.env.test.example`: (1) quitar `AGROFUSION_HUB_CLIENT_ID/SECRET` (líneas 66-67 y 54-55); (2) agregar `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}` en el `environment:` del `backend` y `SGPMP_ENTORNO=TEST` comentado en la plantilla; (3) comentar las variables del SSO en `.env.test.example` con `SIGAB-TEST`. **No** volver a agregar el montaje | B (PR a `test`; el archivo solo existe ahí) |
| Implementación (verificar) | `main` | `AGROFUSION_HUB_*` y el montaje de PROD llegan con el release #941 (código y compose de `dev` viajan juntos). **No** PR dirigido para quitar las HUB: el código de `main` las usa | A; verificar `--is-ancestor 0dbe294 origin/main` y `git grep AGROFUSION_HUB origin/main` vacío tras el release |
| Implementación (documental) | SGMP-Integracion | Actualizar `brief-02-pr-test.md` (quitar paso 3.1, agregar `SGPMP_ENTORNO`) y la tabla de estado de `historia.md` de CFG-03 (fila `test`) | — |
| Despliegue | TEST | *File Mount* `agrofusion_sso_public.pem` antes del despliegue, `AGROFUSION_SSO_PUBLIC_KEY_PATH=/app/secrets/agrofusion_sso_public.pem`, `AGROFUSION_PROJECT_CODE=SIGAB-TEST`, permisos `644`, `test -r` posterior. Cuando el PR de ST-02 se fusione: `SGPMP_ENTORNO=TEST` (opcional por el default) y borrar `AGROFUSION_HUB_*` de Dokploy TEST | Ficha de ST-04 |
| Equipo autor | — | Borrador opcional (el líder decide): "Gracias por #1130: el montaje es idéntico al de #1051 en dev. Implementación completa el resto de TEST (quitar `AGROFUSION_HUB_*`, pasar `SGPMP_ENTORNO`) en un PR aparte. Para evitar trabajo duplicado, ¿nos avisan cuando toquen compose o plantillas?" | — |

**Resumen para `/planificar`:** reescribir ST-02 de HU-IMP-CFG-03 sin el montaje y con `SGPMP_ENTORNO`; dominio CFG.
Si se prefiere separar `SGPMP_ENTORNO` (no es del SSO), HU CFG nueva.

## 7. Preguntas abiertas para el líder

1. ¿`SGPMP_ENTORNO` entra en ST-02 de CFG-03 o en HU aparte? ¿Default `:-TEST` o guarda `:?` (afecta la validez de contratos M07 en TEST)?
2. ¿Se acuerda con Desarrollo avisar a Implementación antes de editar compose o plantillas? (#1129 y #1130 se fusionaron sin reviews el mismo día.)
3. Índice: falta la fila de este origen en `entregas/E3_2026-11-17_M05-M06/README.md` (estado sugerido `en planificación`); no se editó por instrucción del líder.

> **Actualización 2026-11-17** (anotada el 2026-11-20). La ficha (`registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md` §2) reemplaza el `test -r` de la fila de Despliegue por `test -f && test -r` e incluye los permisos `644`. CA-4 pide `SGPMP_ENTORNO=TEST` activa en `.env.test.example`, no comentada. La pregunta 1 (`:-TEST` o `:?`) sigue pendiente (`historia.md`, Notas). La fila de este origen ya está en el README de E3 (pregunta 3). Detalle: `propio/HU-IMP-CFG-03_agrofusion-sso/revisiones/VERIF-DOC-agrofusion.md` §5 y §8.
