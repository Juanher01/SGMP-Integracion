# HU-IMP-SEG-01 — Cerrar SEG-CICD-01: permisos mínimos de workflows en PROD y evidencia de hadolint

> Estado: borrador para Taiga · Redactado: 2026-10-12 · Fuente: [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266)

## Para copiar en Taiga — Descripción de la HU

**Rama:** `fix/seg-cicd-01-main` → PR a `main` (y `chore/seg-cicd-01-release-permisos` → PR a `dev`) · **Plazo:** por definir (líder) · **Responsable:** Juan Hernando Perdomo · **Revisa:** Sebastián Sandoval

**Origen.** Directriz de seguridad — [sgpmp-backend#266](https://github.com/Arekkazu/sgpmp-backend/issues/266) · Código `SEG-CICD-01` · Autor: miguelortiz13 (Análisis) · Abierto: 2026-09-12 · Asignados: Chebaztian, SamuelPR21.

**Situación actual.** Verificado con git el 2026-10-12. Los hallazgos de los Dockerfiles ya están resueltos en las tres ramas; falta llevar los permisos de los workflows a `main`, documentar `release.yml` y reunir la evidencia para el cierre.

| Rama | Dockerfiles (hadolint 2.12.0) | `permissions:` en los 3 workflows | Comentario en `release.yml` |
|---|---|---|---|
| dev | ✅ sin hallazgos (`388c0f01`) | ✅ (`402739ec`) | ❌ falta |
| test | ✅ sin hallazgos | ✅ en los 2 que existen (`migrate-dev.yml` no existe en test) | ❌ falta |
| main | ✅ sin hallazgos | ❌ ninguno de los 3 lo declara | ❌ falta |

**Descripción.** Completar la directriz SEG-CICD-01 en el ambiente de producción. Se lleva a `main` el commit `402739ec` (bloques `permissions: contents: read`) mediante un PR dirigido, porque `main` está a 644 commits de `dev` y la directriz no debe esperar al próximo release. Además, se documenta en `release.yml` por qué necesita permisos de escritura, se reúne la evidencia exigida por el issue y se propone el cierre a Análisis, explicando las dos desviaciones respecto a lo sugerido.

**Alcance.** Workflows `_migrate-template.yml`, `migrate-dev.yml`, `validate-migrations.yml` y `release.yml` de sgpmp-backend; evidencia de `Dockerfile` y `Dockerfile.postgres`; comentario de cierre en el issue. · **Fuera de alcance:** cambios funcionales en los workflows (Desarrollo); esquema y extensión `pg_cron` en la base (DBA).

**Criterios de aceptación.**
1. CA-1 `hadolint` no reporta hallazgos en `Dockerfile` ni en `Dockerfile.postgres` en `dev`, `test` y `main`.
2. CA-2 La imagen del backend construida desde `main` corre como `uid=1000` y no contiene compilador (`gcc`/`cc`).
3. CA-3 `postgresql-18-cron` está instalado con versión fijada en `Dockerfile.postgres` en las tres ramas.
4. CA-4 `_migrate-template.yml`, `migrate-dev.yml` y `validate-migrations.yml` declaran `permissions: contents: read` en `main` (y se mantienen en `dev` y `test`).
5. CA-5 `release.yml` contiene un comentario junto a su bloque `permissions:` que justifica la escritura (crear tags, releases, comentar issues y PRs) en `dev` y en `main`.
6. CA-6 Existe al menos una ejecución exitosa de `validate-migrations.yml` (en un PR) y una de `migrate-dev.yml`, ambas posteriores al 2026-09-14 (fecha de `402739ec`).
7. CA-7 El PR a `main` no provoca un release no deseado: los commits usan tipos que no generan versión (`ci:`/`chore:`), o el Líder de Despliegue acepta explícitamente la versión resultante.
8. CA-8 Las desviaciones (UID 1000 en vez de 10001; eliminar `gcc`/`libpq-dev` en lugar de una etapa multi-stage) quedan explicadas en el issue #266 con su evidencia.
9. CA-9 `registros/seguridad/registro-SEG.md` refleja SEG-CICD-01 como "Lista para cierre" (o "Cerrada por Análisis") con los enlaces de evidencia.

**Verificación.**

| CA | Método | Resultado esperado | Evidencia |
|---|---|---|---|
| CA-1 | `for b in dev test main; do for f in Dockerfile Dockerfile.postgres; do git show origin/$b:$f \| docker run --rm -i hadolint/hadolint; done; done` | Sin salida | Salida del comando con fecha |
| CA-2 | `git switch --detach origin/main && docker build -t sgpmp-backend:verif .` y luego `docker run --rm --entrypoint id sgpmp-backend:verif` y `docker run --rm --entrypoint sh sgpmp-backend:verif -c 'command -v gcc cc \|\| echo sin-compilador'` | `uid=1000(appuser)` y `sin-compilador` | Salidas pegadas |
| CA-3 | `git show origin/<rama>:Dockerfile.postgres \| grep -n 'postgresql-18-cron='` | Una línea con `=1.6.8-1.pgdg13+1` (o la versión vigente) por rama | Salida |
| CA-4 | `git show origin/main:.github/workflows/<wf> \| grep -nA1 '^permissions:'` para los 3 workflows (tras el merge) | `contents: read` en los tres | Salida + enlace al PR fusionado |
| CA-5 | `git show origin/<rama>:.github/workflows/release.yml \| sed -n '/^permissions:/,+6p'` y las líneas de comentario previas | Comentario que explica cada permiso de escritura | Salida |
| CA-6 | `gh run list -R Arekkazu/sgpmp-backend --workflow validate-migrations.yml --limit 10` y lo mismo con `migrate-dev.yml` | Una ejecución `success` de cada uno con fecha > 2026-09-14 | Enlaces a las ejecuciones |
| CA-7 | `git log --format='%s' origin/main..fix/seg-cicd-01-main` antes del PR; tras el merge, `gh run list --workflow release.yml --branch main --limit 1` | Tipos `ci:`/`chore:`; el run de release no publica versión, o lo aprobó Despliegue | Salida + comentario en el PR |
| CA-8 | Revisión del comentario publicado en #266 | Tabla de criterios + desviaciones con motivo | Enlace al comentario |
| CA-9 | Lectura de `registros/seguridad/registro-SEG.md` | Estado y enlaces actualizados | Commit en SGMP-Integracion |

**Definición de terminado.**
- [ ] Todos los CA verificados con evidencia adjunta en la HU.
- [ ] PR a `dev` (comentario de `release.yml`) aprobado por el Líder de Desarrollo y fusionado.
- [ ] PR a `main` (cherry-pick de `402739ec` + comentario) aprobado por el Líder de Despliegue y fusionado.
- [ ] Comentario de cierre publicado en #266 (lo publica el líder).
- [ ] Registro SEG actualizado en SGMP-Integracion.

**Dependencias y aprobaciones.** PR a `dev`: Líder de Desarrollo. PR a `main`: Líder de Despliegue. Cierre del issue: Análisis (Miguel). Avisar a SamuelPR21 (co-asignado, autor de `402739ec`).

**Riesgos.** (1) Un push a `main` dispara `release.yml`; un commit con tipo `fix:`/`feat:` generaría una versión estable no planificada → usar `ci:`/`chore:` (CA-7). (2) Cuando llegue el release `dev → main`, git puede marcar un conflicto trivial en los workflows: se avisa en el PR. (3) El tag `postgresql-18-cron` fijado puede desaparecer del repositorio PGDG; el build fallaría de forma visible (procedimiento en el propio `Dockerfile.postgres`).

**Referencias.** Issue #266 · commits `388c0f01` (hadolint), `402739ec` (permisos) · skill `promocion-entornos` (estrategia B).

## Para copiar en Taiga — Subtareas

### ST-01 reunir evidencia de hadolint y de la imagen del backend
**Objetivo.** Dejar documentados CA-1, CA-2 y CA-3 en las tres ramas.
**Pasos.**
1. `git -C sgpmp-backend fetch --prune origin`.
2. Ejecutar el lint de CA-1 sobre las tres ramas.
3. Construir la imagen desde `origin/main` y ejecutar las pruebas de `id` y de compilador (CA-2).
4. Ejecutar el `grep` de `postgresql-18-cron=` en las tres ramas (CA-3).
5. Guardar las salidas en `historias/HU-IMP-SEG-01_cierre-seg-cicd-01/evidencias/ca1-ca3.md` con fecha y commit de cada rama.
**Entregable.** Archivo de evidencias.
**Verificación.** Las tres salidas coinciden con lo esperado en la tabla de verificación (CA-1, CA-2, CA-3).
**Estimación.** 2 h

### ST-02 documentar los permisos de escritura de release.yml (PR a dev)
**Objetivo.** Cumplir CA-5 en `dev`.
**Pasos.**
1. `git switch -c chore/seg-cicd-01-release-permisos origin/dev`.
2. Sobre el bloque `permissions:` de `.github/workflows/release.yml`, agregar un comentario: *"Escritura requerida por diseño (SEG-CICD-01, #266): `contents` para crear tags y releases, `issues` y `pull-requests` para que semantic-release comente en ellos. Los demás workflows usan `contents: read`."*
3. Commit con el mensaje `ci(release): documentar permisos de escritura requeridos (SEG-CICD-01, #266)`.
4. Abrir el PR a `dev` enlazando #266 y esta HU.
**Entregable.** PR a `dev`.
**Verificación.** CA-5 sobre `origin/dev` tras el merge.
**Estimación.** 1 h

### ST-03 preparar el PR dirigido a main con los permisos de los workflows
**Objetivo.** Cumplir CA-4, CA-5 y CA-7 en `main`.
**Pasos.**
1. `git switch -c fix/seg-cicd-01-main origin/main`.
2. `git cherry-pick -x 402739ec` (aplica limpio: solo agrega los tres bloques `permissions:`).
3. `git cherry-pick -x <commit de ST-02>` (o repetir el mismo comentario con el mismo mensaje `ci(release): …`).
4. Verificar con `git log --format='%s' origin/main..HEAD` que ningún commit sea de tipo `feat:`/`fix:`. El de `402739ec` no sigue la convención y no genera release, pero hay que confirmarlo en el PR.
5. Push y PR a `main`. En la descripción: qué trae, por qué no espera el release (main a 644 commits de dev), que no genera versión, posible conflicto trivial en el próximo release, y enlaces a #266 y la HU.
**Entregable.** PR a `main`.
**Verificación.** CA-4 y CA-5 sobre la rama del PR (`git show HEAD:.github/workflows/<wf>`); CA-7 con el log de commits.
**Estimación.** 2 h

### ST-04 seguimiento de aprobaciones y verificación en main
**Objetivo.** Lograr que los dos PR se fusionen y verificar el resultado.
**Pasos.**
1. Avisar al Líder de Desarrollo (PR a `dev`) y al Líder de Despliegue (PR a `main`), con el enlace y un resumen de una línea.
2. Tras cada merge, `git fetch` y repetir CA-4/CA-5 sobre `origin/main` y `origin/dev`.
3. Revisar el run de `release.yml` en `main` (CA-7).
**Entregable.** Evidencia en `historias/HU-IMP-SEG-01_cierre-seg-cicd-01/evidencias/ca4-ca7.md`.
**Verificación.** CA-4, CA-5 y CA-7 sobre las ramas fusionadas.
**Estimación.** 2 h (repartidas según la disponibilidad de los aprobadores)

### ST-05 evidenciar las ejecuciones reales de los workflows
**Objetivo.** Cumplir CA-6.
**Pasos.**
1. `gh run list -R Arekkazu/sgpmp-backend --workflow validate-migrations.yml --limit 10` y lo mismo con `migrate-dev.yml`.
2. Si no hay ejecuciones exitosas posteriores al 2026-09-14: pedir al Líder de Desarrollo que lance `migrate-dev.yml` manualmente (`workflow_dispatch`), y para `validate-migrations.yml` esperar el próximo PR que toque `alembic/versions/**`.
3. Registrar los enlaces de las ejecuciones.
**Entregable.** Enlaces en `historias/HU-IMP-SEG-01_cierre-seg-cicd-01/evidencias/ca6.md`.
**Verificación.** CA-6.
**Estimación.** 1 h

### ST-06 redactar el cierre para Análisis y actualizar el registro
**Objetivo.** Cumplir CA-8 y CA-9.
**Pasos.**
1. Redactar el comentario de cierre con la plantilla de la skill `seguridad-analisis`: criterio × rama × evidencia, más las desviaciones (UID 1000 por los volúmenes existentes; paquetes eliminados en lugar de multi-stage, lo que deja igualmente el compilador fuera de la imagen final).
2. Entregarlo al líder para que lo publique en #266, mencionando a @miguelortiz13 y a @SamuelPR21.
3. Actualizar `registros/seguridad/registro-SEG.md`.
**Entregable.** Borrador del comentario y registro actualizado.
**Verificación.** CA-8 y CA-9.
**Estimación.** 1,5 h

## Notas para el líder (no copiar a Taiga)

- **Plazo sugerido:** 3 días hábiles, condicionado a la disponibilidad de los aprobadores. El trabajo de Juan Hernando suma unas 9,5 h.
- **Preguntas abiertas:**
  1. ¿El Líder de Despliegue acepta un PR dirigido a `main` fuera del ciclo de release? Si prefiere esperar el release, ST-03 se reduce a verificar después del merge `dev → main`.
  2. ¿Análisis aceptará UID 1000 en vez de 10001? El motivo es sólido (los volúmenes de los tres entornos ya pertenecen a 1000), pero conviene anticiparlo con Miguel.
- **Puntos de atención en la revisión:** que el PR a `main` contenga solo los workflows (nada de `dev` arrastrado), el tipo de los commits (CA-7) y que la evidencia de CA-6 sea posterior al cambio.
- **Mensaje sugerido al Líder de Despliegue:** "Hola, abrimos un PR a `main` del backend que solo agrega `permissions: contents: read` a tres workflows (directriz SEG-CICD-01 de Análisis). No cambia código ni genera versión. ¿Lo puedes revisar?"

---
Fuentes consultadas (2026-10-12): `origin/dev@492c19f2`, `origin/test@5d770da7`, `origin/main@66805718` de sgpmp-backend; hadolint 2.12.0; issue #266.
