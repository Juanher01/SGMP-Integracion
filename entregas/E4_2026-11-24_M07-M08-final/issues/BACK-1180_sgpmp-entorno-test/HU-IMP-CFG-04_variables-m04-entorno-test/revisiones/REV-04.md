# REV-04 — HU-IMP-CFG-04 (ajuste del 2026-11-21: nueva ST-04b, renumeración a ST-04c y aplicación de REV-03)

- **Fecha:** 2026-11-21 (America/Bogota)
- **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Objeto:** `historia.md` en el árbol de trabajo de SGMP-Integracion, rama `docs/hu-imp-cfg-04-variables-m04` (PR #21, abierto), frente a HEAD `ad617b6` (`git diff HEAD -- historia.md`: una parte preparada y otra no; se revisó el total). Es un documento: no hay PR de Juan Hernando que revisar.
- **Cambios revisados:** (1) retiro de `AGROFUSION_HUB_*` de la plantilla en ST-04a; «Sensible» → «Secreta» en CA-7, CA-8 y ST-02. (2) Nueva ST-04b, commit en la rama de #1204. (3) La ST-04b anterior pasa a ST-04c. (4) Tabla de verificación, dependencias, riesgos, total, decisión 8 y estado. (5) M-01 y m-04 de REV-03 aplicados en CA-5.
- **Estado real reverificado hoy** (`git fetch origin` en sgpmp-backend y `gh`):
  - `origin/dev 684af9e4` (avanzó desde `6cee5fc4`; `git diff --stat 6cee5fc4 origin/dev` sobre compose ×3, `.env.example`, `.env.prod.example`, `Dockerfile` y `.dockerignore`: vacío).
  - `origin/test 918806ec` (avanzó desde `12965211`; `git diff --name-only 12965211 origin/test` solo toca `tests/`). Compose de `test`: sin `SGPMP_ENTORNO` ni `IOT_AUDITORIA_RESPALDO_PATH`, y con `AGROFUSION_HUB_*` en l. 66-67.
  - `origin/main 0abbeeef`.
  - #1204: `OPEN`, `MERGEABLE`, cabeza `b8968e68`, `headRefName fix/compose-test-entorno-m04-1180`, `isCrossRepository: false` (la rama está en el mismo repo), `maintainerCanModify: false` (no aplica: no es un fork). l. 82: `IOT_AUDITORIA_RESPALDO_PATH: ${IOT_AUDITORIA_RESPALDO_PATH:-var/auditoria_iot/fallas.sqlite3}`, sin corregir.
  - Rama `fix/compose-test-entorno-m04-1180`: `protected: false`; reglas de ruleset aplicables: 0.
  - Permisos en `Arekkazu/sgpmp-backend` (`gh api …/collaborators/<u>/permission`): `chebaz-117 read` · `chebaztian write` · `Juanher01 write`. La sesión de `gh` es `Chebaztian`.
  - Comentarios publicados hoy: #1204, [comentario de revisión](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7066376147) (17:18Z) y [aviso de ST-04b](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7066889566) (17:57Z). Respuesta de Arekkazu: «Vosotros» ([18:13Z](https://github.com/Arekkazu/sgpmp-backend/pull/1204#issuecomment-7067098039)). #1180: [respuesta](https://github.com/Arekkazu/sgpmp-backend/issues/1180#issuecomment-7066432077) (17:22Z).

## Dictamen global

**APROBAR CON OBSERVACIONES**, condicionado a corregir M-01 (comprobación de permiso con la cuenta equivocada) en `historia.md` y en la ST-04b de Taiga **antes** de que Juan Hernando ejecute ST-04b.

M-01 y m-04 de REV-03 quedan resueltos. La numeración ST-04a/b/c es coherente en todas las secciones. El total suma 21 h. No hay secretos ni atribución a herramientas. CA-4 se puede verificar por sus tres caminos.

## Comprobaciones pedidas

| Comprobación | Veredicto | Evidencia |
|---|---|---|
| REV-03 M-01 (resultado esperado de CA-5) | **Resuelto** | En la fila CA-5 (l. 51) las comprobaciones quedan separadas: (a) `grep -c AGROFUSION_HUB_` en la plantilla → `0`; (b) `diff` evaluado **después de** #1204, con dos excepciones (`IOT_AUDITORIA_RESPALDO_PATH` «mientras siga en el compose» y `AGROFUSION_HUB_*` como solo-compose «hasta ST-04c»); (c) secretos sin valor. La renumeración ST-04b → ST-04c está aplicada. Con la nueva ST-04b la excepción de `IOT_AUDITORIA_RESPALDO_PATH` desaparece sola: simulé el compose de `b8968e68` sin la l. 82, y `grep -oE '\$\{[A-Z0-9_]+'` devuelve 0 coincidencias de esa variable. En la plantilla va como comentario y no la toma `^[A-Z0-9_]+=`. El resultado esperado vale en cualquier orden de fusión (ST-04a antes o después de #1204 y de ST-04c). |
| REV-03 m-04 (condicional de CA-5) | **Resuelto** | CA-5 (l. 35): «`IOT_AUDITORIA_RESPALDO_PATH` como comentario "la fija la imagen"», sin condicional. Coincide con el paso 2 de ST-04a (l. 127). |
| «Sensible» → «Secreta» | **CUMPLE** | CA-7 (l. 53), CA-8 (l. 54) y ST-02 paso 2 (l. 105). No quedan «Sensible» en CA ni subtareas. Los comentarios de la plantilla siguen diciendo «sensible: la carga Despliegue» (ST-04a), y es correcto: es el texto de la plantilla, no del catálogo. |
| Numeración ST-04a/b/c | **CUMPLE** | Campo Rama (l. 11): las tres ramas con su destino. Descripción (l. 25): ST-04b. Alcance (l. 27): l. 82 en la rama de #1204 o por PR hacia ella; si no, en el PR del compose. CA-3: ST-04c. CA-4: tres caminos ST-04b / PR hacia la rama / ST-04c. CA-5: ST-04a y «hasta ST-04c». Dependencias (l. 68), riesgos (l. 77, l. 82), plazo (l. 196), decisión 4 (texto histórico con nota de renumeración) y decisión 8: todo coherente. La única aparición de «ST-04» a secas es la decisión 4, que es histórica. No quedan «ST-04b» con el significado antiguo fuera de esa nota. |
| Total de horas | **CUMPLE** | 2 + 4 + 3 + 2 + 1 + 2 + 2 + 2 + 3 = 21 h (ST-01 … ST-07). |
| ST-04b ejecutable | **Con observaciones** (M-01, m-01, m-02) | La rama de #1204 está en el mismo repo, sin protección ni rulesets: el push sin force es posible. Simulé el paso 3 (borrar la l. 82) y `docker compose config --no-interpolate` da OK. El `sed` de CA-4 devuelve vacío, la prueba usa entonces el `ENV` de la imagen (`Dockerfile:61@b8968e68`, carpeta `chown 1000` en l. 55-56) y no hace falta `-e`. La ruta alternativa por PR está bien descrita. Problema: el permiso se comprueba sobre `chebaz-117`, que tiene `read` (M-01). |
| CA-4 verificable en sus tres caminos | **CUMPLE** | (1) Commit en la rama de #1204. (2) PR hacia esa rama. (3) ST-04c si #1204 se fusiona sin la corrección. En (1) y (2) el compose queda sin la línea y la prueba usa el `ENV` de la imagen. En (3) ST-04c borra la línea o la fija sin comillas y con valor por defecto (REV-02 n-02), y el `sed` cubre ambas formas. La prueba sigue fallando si se deja la l. 82 relativa (`sed` sobre `b8968e68` → `var/auditoria_iot/fallas.sqlite3`). No se autocumple. |
| Secretos y atribución | **CUMPLE** | `grep -nE '(SECRET\|KEY\|TOKEN\|PASSWORD)[A-Z_]*=[^ <\`]'`: sin salida. `grep -niE 'co-authored\|claude\|generated with'`: sin salida. |
| Estado real citado por el líder | **Confirmado** | #1204 OPEN en `b8968e68` con la l. 82 sin corregir. `origin/test 918806ec` no toca compose, plantilla, `Dockerfile` ni `.dockerignore`. Comentarios de ST-01 publicados el 2026-11-21 en #1204 y #1180. Además: `origin/dev` avanzó a `684af9e4` sin tocar los archivos de la HU. |
| Menciones externas | **CUMPLE** (con m-04) | `HU-IMP-CFG-03/historia.md:77` y `entregas/README.md:62` dicen ST-04c. REV-03 tiene nota final de renumeración y no cambia su dictamen. |

## Criterios de la HU tocados por el ajuste

| CA | Veredicto sobre el texto | Justificación |
|---|---|---|
| CA-3 | Coherente | Su tercera condición la cubre ST-04b (tras la fusión) o ST-04c. El comando no cambia. |
| CA-4 | Coherente | Tres caminos explícitos. El comando no inyecta el valor esperado. |
| CA-5 | Coherente | M-01 y m-04 de REV-03 aplicados (ver arriba). |
| CA-7, CA-8 | Coherente | Vocabulario «Secreta» igual en el CA y en el comando. |
| CA-2 | Verificable ya | Los comandos de la tabla encuentran coincidencias en los comentarios publicados: `IOT_AUDITORIA_RESPALDO_PATH` en #1204; `Deploy` y `1204` en #1180. La HU todavía no enlaza las URLs (m-03). |

## Hallazgos

### Mayores

| ID | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|
| M-01 | ST-04b paso 1 (l. 137) | El paso comprueba `gh api repos/Arekkazu/sgpmp-backend/collaborators/chebaz-117/permission`. Hoy `chebaz-117` tiene **`read`**. `Juanher01` (quien ejecuta ST-04b) y `chebaztian` (la cuenta que publicó el aviso en #1204) tienen `write`. Si se sigue el paso al pie de la letra, sale «sin permiso» y se toma la ruta alternativa por PR. Eso no es lo que se le avisó a Arekkazu, que respondió «Vosotros» a «vamos a subir un commit a esta rama». La decisión entre las dos rutas se apoya en un hecho mal verificado. | Comprobar la cuenta que hace el push: `U=$(gh api user --jq .login); gh api repos/Arekkazu/sgpmp-backend/collaborators/$U/permission --jq .permission`. Resultado esperado: `write`, `maintain` o `admin`. Corregirlo también en la ST-04b de Taiga. |

### Menores

| ID | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|
| m-01 | ST-04b pasos 1, 3 y 5 | «Que la rama no tiene protección que impida el push» no trae comando. El paso 3 dice «una rama local que la siga» sin el comando, y el paso 5 depende de ese seguimiento para que `git push` llegue a la rama correcta. | Añadir `gh api repos/Arekkazu/sgpmp-backend/branches/fix/compose-test-entorno-m04-1180 --jq .protected` (esperado `false`, hoy `false`) y `git switch -c fix/compose-test-entorno-m04-1180 --track origin/fix/compose-test-entorno-m04-1180`. Push explícito: `git push origin HEAD:fix/compose-test-entorno-m04-1180` (sin `--force` ni `--force-with-lease`). |
| m-02 | ST-04b paso 1 | Exige que la cabeza sea `b8968e68`, pero no dice qué hacer si cambió (p. ej., si Arekkazu sube otro commit). | Añadir: «si la cabeza cambió, `git show origin/pr-1204:docker-compose.test.yml \| grep -n IOT_AUDITORIA_RESPALDO_PATH`; si la línea ya no está o es absoluta, ST-04b se cierra sin commit, con esa salida como evidencia». |
| m-03 | ST-01 y CA-2 (l. 32, 96-97) | Los comentarios ya están publicados (URLs arriba), pero la HU no los enlaza. Tampoco registra la respuesta de Arekkazu («Vosotros»), que deja hecho el paso 2 de ST-04b y es el consentimiento para el commit. El paso 3 de ST-01 («anotar si corrige la l. 82 sí/no») quedó resuelto con esa respuesta. | Pegar las cuatro URLs en la HU (o en `evidencias/CA-02_comunicacion.md`) y marcar el paso 2 de ST-04b como hecho, con el enlace al aviso. |
| m-04 | Corte (l. 5), Metadatos (l. 218-219), `entregas/README.md:62` y `entregas/E4_…/README.md:10` | El corte y los metadatos siguen en el 2026-11-20 (`test 12965211`, `dev 6cee5fc4`) aunque el estado dice «creada en Taiga 2026-11-21». Los dos README siguen diciendo «por crear» / «lista para Taiga». | Añadir en Metadatos el ajuste del 2026-11-21 con la reverificación (`test 918806ec`, `dev 684af9e4`, sin cambios en los archivos de la HU) y actualizar el estado en los dos README. CA-1 sigue exigiendo un corte nuevo al abrir cada PR. |
| m-05 | Fila CA-4 de la tabla de verificación (l. 50) | «En la rama del PR» es ambiguo ahora que hay tres caminos. El texto de CA-4 sí los distingue. | «En la rama de ST-04b (la de #1204, o la del PR hacia ella) o, si aplica, en la de ST-04c». |

### Observación (no es hallazgo)

- ST-04b se estima en 1 h, por debajo del rango de 2 a 6 h de `hu-taiga` §3. Es una decisión explícita del líder (decisión 8) y el cambio es de una línea. Se puede dejar así.

## Borrador de retroalimentación (para el autor del ajuste)

> El ajuste del 2026-11-21 está bien resuelto. La nueva ST-04b es concreta y prevé las dos rutas (commit en la rama o PR hacia ella), no reescribe el commit de Arekkazu y deja la fusión al Líder de Pruebas. La renumeración a ST-04c es coherente en toda la HU, el total sigue en 21 h y CA-5 ya incorpora M-01 y m-04 de REV-03: su resultado esperado vale en cualquier orden de fusión.
>
> Un cambio antes de ejecutar ST-04b:
> 1. **(M-01)** El paso 1 comprueba el permiso de `chebaz-117`, que hoy tiene `read`. Hay que comprobar la cuenta que hace el push: `gh api repos/Arekkazu/sgpmp-backend/collaborators/$(gh api user --jq .login)/permission --jq .permission` → `write`. Corregirlo también en Taiga.
>
> Mejoras menores: comandos explícitos para la protección de la rama, el seguimiento y el push sin force (m-01); qué hacer si la cabeza de #1204 cambió (m-02); enlazar en la HU los comentarios ya publicados y la respuesta «Vosotros» de Arekkazu (m-03); actualizar corte, metadatos y README (m-04); precisar la rama en la fila CA-4 (m-05).
