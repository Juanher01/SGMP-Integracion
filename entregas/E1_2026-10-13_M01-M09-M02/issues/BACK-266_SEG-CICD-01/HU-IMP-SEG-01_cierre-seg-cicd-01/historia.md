# HU-IMP-SEG-01 — Cerrar SEG-CICD-01: evidencia por rama, justificación de `release.yml` y cierre con Análisis

> Estado: borrador para Taiga · Redactado: 2026-10-12 · Actualizado: 2026-10-13 contra el corte [`registros/entornos/corte-2026-10-13.md`](../../../../../registros/entornos/corte-2026-10-13.md) · Fuente: [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266)

## Para copiar en Taiga — Descripción de la HU

**Rama:** `chore/seg-cicd-01-release-permisos` → PR a `dev` (llega a `main` con el release) · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Directriz de seguridad — [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266) · Código `SEG-CICD-01` · Autor: miguelortiz13 (Análisis) · Abierto: 2026-09-12 · Asignados: Chebaztian, SamuelPR21.

**Situación actual.** Corte del 2026-10-13 (`git fetch --prune` a las 10:59:47 -0500). Hashes: `dev@bd8b6d4f`, `test@81487428`, `main@8a7e6327` (release 1.3.1). El código ya cumple casi toda la directriz en las tres ramas, incluida `main`: los permisos de los workflows llegaron a PROD por promoción y ya no hace falta un PR dirigido. Falta justificar la escritura de `release.yml`, reunir la evidencia y proponer el cierre.

| Criterio del issue | dev `bd8b6d4f` | test `81487428` | main `8a7e6327` | Evidencia (comando contra el hash) |
|---|---|---|---|---|
| `permissions: contents: read` en `_migrate-template.yml`, `migrate-dev.yml`, `validate-migrations.yml` | ✅ | ✅ en los 2 que existen (`migrate-dev.yml` no existe en test) | ✅ | `git merge-base --is-ancestor 402739ec <hash>` → INCLUIDO en los tres; `git show <hash>:.github/workflows/<wf> \| grep -nA1 '^permissions:'` → `contents: read` |
| Comentario que justifica la escritura en `release.yml` | ❌ | No aplica (`release.yml` no corre en `test`) | ❌ | `git show <hash>:.github/workflows/release.yml` l. 18–21: `contents/issues/pull-requests: write` sin comentario que lo justifique |
| `gcc`/`libpq-dev` fuera de la imagen; `useradd --uid 1000` y `USER 1000` | ✅ | ✅ | ✅ | `388c0f01` INCLUIDO en los tres; `Dockerfile` idéntico en las tres ramas (blob `30f8b2b3`), l. 51 y 56 |
| `postgresql-18-cron` con versión fijada | ✅ | ✅ | ✅ | `Dockerfile.postgres` idéntico en las tres (blob `eed755b9`), l. 24: `postgresql-18-cron=1.6.8-1.pgdg13+1` |
| hadolint sin hallazgos | ✅ (2026-10-12) | ✅ | ✅ | hadolint 2.12.0 el 2026-10-12 sobre los mismos blobs; **sin archivo de evidencia** |
| Ejecuciones reales con permisos reducidos | ✅ existen | — | — | `gh run list` (consultado 2026-10-13): `validate-migrations.yml` run `38333126929` (success, 2026-10-13, PR a `dev`); `migrate-dev.yml` run `38332528210` (success, 2026-10-13, push a `dev`). **Sin archivo de evidencia** |
| Imagen arranca y no corre como root | Sin evidencia | — | Sin evidencia | Pendiente (CA-2) |

Dato adicional: los otros workflows del corte (`migrate-prod.yml`, `sast.yml` y, en `test`, `migrate-test.yml`) también declaran `permissions: contents: read`. `main` y `dev` están sincronizadas (`git rev-list --count 8a7e6327..bd8b6d4f` → 1, el merge de `main` en `dev`; `bd8b6d4f..8a7e6327` → 0).

**Descripción.** Completar SEG-CICD-01: documentar en `release.yml` por qué necesita escritura, reunir en un solo archivo la evidencia por rama que pide el issue y proponer el cierre a Análisis con las dos desviaciones explicadas. El comentario de `release.yml` entra por `dev` y llega a `main` con el próximo release (estrategia A), porque `dev` y `main` están al día y los releases salen a diario.

**Alcance.** Comentario en `.github/workflows/release.yml` de sgpmp-backend; evidencia de `Dockerfile`, `Dockerfile.postgres` y de los workflows; borrador del comentario de cierre en #266; registro SEG. · **Fuera de alcance:** cambios funcionales en los workflows (Desarrollo); esquema y extensión `pg_cron` en la base (DBA); promover `dev → main` (Despliegue).

**Criterios de aceptación.**
1. CA-1 `hadolint` no reporta hallazgos en `Dockerfile` ni en `Dockerfile.postgres` en `dev`, `test` y `main` (hashes del corte vigente).
2. CA-2 La imagen del backend construida desde `main` corre como `uid=1000` y no contiene compilador (`gcc`/`cc`).
3. CA-3 `Dockerfile.postgres` instala `postgresql-18-cron` con versión fijada en `dev`, `test` y `main`.
4. CA-4 `_migrate-template.yml`, `migrate-dev.yml` y `validate-migrations.yml` declaran `permissions: contents: read` en `dev` y `main`, y los dos que existen en `test` también. *(Cumplido en código al corte; falta el archivo de evidencia.)*
5. CA-5 `release.yml` tiene, junto a su bloque `permissions:`, un comentario que justifica cada permiso de escritura, en `dev` (PR fusionado) y en `main` (tras el siguiente release). El commit es de tipo `ci:` para no generar una versión por sí mismo.
6. CA-6 La evidencia incluye al menos una ejecución exitosa de `validate-migrations.yml` y una de `migrate-dev.yml` posteriores al 2026-09-14 (fecha de `402739ec`).
7. CA-7 Las desviaciones (UID 1000 en vez de 10001; eliminar `gcc`/`libpq-dev` en lugar de una etapa multi-stage) quedan explicadas en #266 con su evidencia, dentro del comentario de cierre.
8. CA-8 `registros/seguridad/registro-SEG.md` refleja SEG-CICD-01 como "Lista para cierre" (o "Cerrada por Análisis") con los enlaces de evidencia.
9. CA-9 La HU y su evidencia citan la fecha de corte (`git fetch --prune` 2026-10-13 10:59:47 -0500) y los hashes `dev@bd8b6d4f`, `test@81487428`, `main@8a7e6327`; antes de abrir el PR y antes de entregar el cierre se repite el `fetch` y, si alguna rama avanzó, se rehacen CA-1, CA-3 y CA-4 sobre el hash nuevo y se anota.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | `for h in bd8b6d4f 81487428 8a7e6327; do for f in Dockerfile Dockerfile.postgres; do echo "== $h $f"; git -C sgpmp-backend show $h:$f \| docker run --rm -i hadolint/hadolint; done; done` | Solo los encabezados `==`, sin hallazgos | Salida con fecha en `evidencias/ca1-ca4-ca6.md` |
| CA-2 | `git -C sgpmp-backend archive 8a7e6327 \| docker build -t sgpmp-backend:verif -`; `docker run --rm --entrypoint id sgpmp-backend:verif`; `docker run --rm --entrypoint sh sgpmp-backend:verif -c 'command -v gcc cc \|\| echo sin-compilador'` | `uid=1000(appuser)` y `sin-compilador` | Salidas pegadas |
| CA-3 | `git -C sgpmp-backend show <hash>:Dockerfile.postgres \| grep -n 'postgresql-18-cron='` en los tres hashes | `24: postgresql-18-cron=1.6.8-1.pgdg13+1` en cada uno | Salida |
| CA-4 | `git -C sgpmp-backend show <hash>:.github/workflows/<wf> \| grep -nA1 '^permissions:'` para cada workflow y hash | `contents: read` en los tres de `dev` y `main` y en los dos de `test` | Salida |
| CA-5 | Antes del PR: `git -C sgpmp-backend log --format='%s' origin/dev..chore/seg-cicd-01-release-permisos`. Tras el merge y tras el release: `git -C sgpmp-backend show origin/<dev\|main>:.github/workflows/release.yml \| sed -n '/permissions:/,+4p'` junto con las líneas de comentario previas | Un commit `ci(release): …`; comentario presente en `dev` y luego en `main` | Salidas + enlace al PR |
| CA-6 | `gh run list -R Arekkazu/sgpmp-backend --workflow validate-migrations.yml --limit 5` y lo mismo con `migrate-dev.yml` | Al menos un `success` de cada uno con fecha > 2026-09-14 (al corte: `38333126929` y `38332528210`) | Enlaces a las ejecuciones |
| CA-7 | Revisión del comentario publicado en #266 | Tabla criterio × rama + desviaciones con motivo | Enlace al comentario |
| CA-8 | Lectura de `registros/seguridad/registro-SEG.md` | Estado y enlaces actualizados | Commit en SGMP-Integracion |
| CA-9 | `git -C sgpmp-backend fetch --prune origin && git -C sgpmp-backend rev-parse --short origin/dev origin/test origin/main` | Coinciden con `bd8b6d4f`, `81487428`, `8a7e6327`, o la diferencia queda anotada y reverificada | Salida con fecha y hora en la evidencia |

**Definición de terminado.**
- [ ] Todos los CA verificados con evidencia adjunta en la HU.
- [ ] PR a `dev` (comentario de `release.yml`) aprobado por el Líder de Desarrollo y fusionado; comentario visible en `main` tras el siguiente release.
- [ ] Comentario de cierre publicado en #266 (lo publica el líder).
- [ ] Registro SEG actualizado en SGMP-Integracion.

**Dependencias y aprobaciones.** PR a `dev`: Líder de Desarrollo. Llegada a `main`: release `dev → main` que fusiona el Líder de Despliegue (no se pide un PR aparte). Cierre del issue: Análisis (Miguel). Avisar a SamuelPR21 (co-asignado, autor de `402739ec`).

**Riesgos.** (1) Si el siguiente release a `main` tarda, CA-5 en `main` queda pendiente: se registra como "en `dev`, pendiente de release" y se decide con el líder si se pide el cierre igual. (2) El tag `postgresql-18-cron` fijado puede desaparecer del repositorio PGDG; el build fallaría de forma visible (procedimiento en el propio `Dockerfile.postgres`). (3) Una rama avanza entre el corte y el PR: lo detecta CA-9.

**Referencias.** Issue #266 · commits `388c0f01` (Dockerfiles), `402739ec` (permisos) · corte `registros/entornos/corte-2026-10-13.md` · skill `promocion-entornos` (estrategia A).

## Para copiar en Taiga — Subtareas

### ST-01 reunir la evidencia por rama del código ya cumplido
**Objetivo.** Dejar documentados CA-1, CA-2, CA-3, CA-4 y CA-6 contra los hashes del corte.
**Pasos.**
1. Ejecutar el lint de CA-1 sobre `bd8b6d4f`, `81487428` y `8a7e6327`.
2. Construir la imagen desde `8a7e6327` con `git archive` y ejecutar las pruebas de `id` y de compilador (CA-2).
3. Ejecutar el `grep` de CA-3 y el de CA-4 sobre los tres hashes.
4. Ejecutar los dos `gh run list` de CA-6 y copiar el enlace de una ejecución exitosa de cada workflow.
5. Guardar todo en `entregas/E1_2026-10-13_M01-M09-M02/issues/BACK-266_SEG-CICD-01/HU-IMP-SEG-01_cierre-seg-cicd-01/evidencias/ca1-ca4-ca6.md` con fecha, hora y hash de cada rama (formato de la skill `verificacion` §9).
**Entregable.** Archivo de evidencias.
**Verificación.** Salidas iguales a las esperadas en la tabla (CA-1, CA-2, CA-3, CA-4, CA-6).
**Estimación.** 2,5 h

### ST-02 documentar los permisos de escritura de release.yml (PR a dev)
**Objetivo.** Cumplir CA-5 en `dev`.
**Pasos.**
1. Reverificar el corte (comando de CA-9). Luego `git -C sgpmp-backend switch -c chore/seg-cicd-01-release-permisos origin/dev`.
2. Sobre el bloque `permissions:` de `.github/workflows/release.yml`, agregar un comentario: *"Escritura requerida por diseño (SEG-CICD-01, #266): `contents` para crear tags y releases, `issues` y `pull-requests` para que semantic-release comente en ellos. Los demás workflows usan `contents: read`."*
3. Commit con el mensaje `ci(release): documentar permisos de escritura requeridos (SEG-CICD-01, #266)`.
4. Abrir el PR a `dev` enlazando #266 y esta HU; en la descripción, indicar que llega a `main` con el próximo release y que el tipo `ci:` no genera versión.
**Entregable.** PR a `dev`.
**Verificación.** CA-5 (parte `dev`) y CA-9.
**Estimación.** 1 h

### ST-03 llevar los permisos de los workflows a main — ✅ cerrar
**Objetivo.** `permissions: contents: read` en los tres workflows de `main`.
**Entregable.** Ninguno de Implementación: el cambio llegó a `main` por promoción (release 1.3.1). No se hizo cherry-pick.
**Verificación.** Corte 2026-10-13: `git -C sgpmp-backend merge-base --is-ancestor 402739ec 8a7e6327` → INCLUIDO; `git show 8a7e6327:.github/workflows/<wf>` → `contents: read` en los tres (CA-4).
**Estado.** Se crea como cerrada.

### ST-04 verificar la llegada del comentario de release.yml a main
**Objetivo.** Cumplir CA-5 en `main`.
**Pasos.**
1. Tras el merge del PR de ST-02, avisar al Líder de Desarrollo y dar seguimiento.
2. Cuando Despliegue fusione el siguiente release `dev → main`, ejecutar `git -C sgpmp-backend fetch --prune origin` y el comando de CA-5 sobre `origin/main`.
3. Anotar el hash de `main` en que aparece el comentario en `evidencias/ca5.md`.
**Entregable.** `entregas/E1_2026-10-13_M01-M09-M02/issues/BACK-266_SEG-CICD-01/HU-IMP-SEG-01_cierre-seg-cicd-01/evidencias/ca5.md`.
**Verificación.** CA-5 sobre `origin/dev` y `origin/main`.
**Estimación.** 1 h (repartida según la fecha del release)

### ST-05 redactar el cierre para Análisis y actualizar el registro
**Objetivo.** Cumplir CA-7, CA-8 y CA-9.
**Pasos.**
1. Reverificar el corte (CA-9) y anotar los hashes finales.
2. Redactar el comentario de cierre con la plantilla de la skill `seguridad-analisis`: criterio × rama × evidencia (enlaces a ST-01 y ST-04), más las desviaciones (UID 1000 por los volúmenes existentes; paquetes eliminados en lugar de multi-stage, lo que deja igualmente el compilador fuera de la imagen final).
3. Entregarlo al líder para que lo publique en #266, mencionando a @miguelortiz13 y a @SamuelPR21.
4. Actualizar SEG-CICD-01 en `registros/seguridad/registro-SEG.md`.
**Entregable.** Borrador del comentario y registro actualizado.
**Verificación.** CA-7, CA-8 y CA-9.
**Estimación.** 1,5 h

## Notas para el líder (no copiar a Taiga)

- **Plazo sugerido:** 2 días hábiles para ST-01, ST-02 y ST-05 (unas 5 h); ST-04 depende de la fecha del siguiente release (hoy salen a diario: 1.2.0 el 2026-10-12; 1.3.0 y 1.3.1 el 2026-10-13).
- **Preguntas abiertas:**
  1. ¿Se pide el cierre a Análisis cuando el comentario de `release.yml` esté en `dev`, o se espera a verlo en `main`? Recomiendo esperar a `main`, porque el issue apunta a PROD; si el release se demora, la alternativa es un PR dirigido a `main` solo con ese commit (estrategia B), que ya no recomiendo porque `dev` y `main` están sincronizadas.
  2. ¿Análisis aceptará UID 1000 en vez de 10001? El motivo es sólido (los volúmenes de los tres entornos ya pertenecen a 1000), pero conviene anticiparlo con Miguel.
- **Puntos de atención en la revisión:** que la evidencia cite hashes, no nombres de rama; que el commit de ST-02 sea de tipo `ci:`; que las ejecuciones de CA-6 sean posteriores al 2026-09-14.
- **Hallazgo menor:** `test` (`81487428`) está a 574 commits de `main` y tiene `migrate-test.yml` en lugar de `migrate-dev.yml`; ya está registrado como divergencia en INC-BE-01. No afecta a esta directriz.

### Cambios respecto a la versión anterior (2026-10-12)

- **Título:** antes "permisos mínimos de workflows en PROD y evidencia de hadolint". Los permisos ya están en PROD; el resultado pendiente es la evidencia, `release.yml` y el cierre.
- **Situación actual:** rehecha con los hashes del corte. `main` pasa de ❌ a ✅ en los permisos (`402739ec` ancestro de `8a7e6327`). Se agregan los blobs idénticos de los Dockerfiles en las tres ramas y las ejecuciones reales encontradas.
- **Rama y estrategia:** se quita la rama `fix/seg-cicd-01-main` y el PR dirigido a `main`. El comentario de `release.yml` va solo por `dev` y viaja con el release (A), porque `main` ya no está a 644 commits de `dev`: está sincronizada.
- **CA:** el CA-4 anterior (permisos en `main` tras el merge) queda cumplido en código y solo pide evidencia. Se elimina el CA-7 anterior (que el PR a `main` no disparara un release): sin PR a `main` ya no aplica; lo que queda (tipo `ci:`) se integró en CA-5. Se renumeran: antiguos CA-8 y CA-9 → CA-7 y CA-8. Nuevo CA-9 de fecha de corte.
- **Subtareas:** ST-03 (cherry-pick de `402739ec` y PR a `main`) se marca cerrada sin ejecutar, porque el cambio llegó por promoción. ST-04 pasa de "seguir dos PR" a "verificar la llegada a `main`". La antigua ST-05 (ejecuciones reales) se integra en ST-01 porque las ejecuciones ya existen. Trabajo pendiente: de 9,5 h a 6 h.

---
Redactado: 2026-10-12 · Actualizado: 2026-10-13.
Fuentes consultadas (2026-10-13, sin nuevo fetch): corte `registros/entornos/corte-2026-10-13.md`; sgpmp-backend `dev@bd8b6d4f`, `test@81487428`, `main@8a7e6327` (`git show`, `git merge-base --is-ancestor 402739ec|388c0f01 <hash>`, `git rev-parse <hash>:Dockerfile*`, `git rev-list --count`); `gh run list` de `validate-migrations.yml` y `migrate-dev.yml` (2026-10-13); `registros/seguridad/registro-SEG.md`; issue #266. Versión anterior: `dev@492c19f2`, `test@5d770da7`, `main@66805718` (2026-10-12).
