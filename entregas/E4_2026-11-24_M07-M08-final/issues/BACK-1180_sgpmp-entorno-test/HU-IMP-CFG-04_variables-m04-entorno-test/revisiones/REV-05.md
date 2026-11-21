# REV-05 — HU-IMP-CFG-04 (correcciones de REV-04 del 2026-11-21)

- **Fecha:** 2026-11-21 (America/Bogota)
- **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Objeto:** árbol de trabajo de SGMP-Integracion, rama `docs/hu-imp-cfg-04-variables-m04`, frente a HEAD `ad617b6` (`git diff HEAD`: una parte preparada y otra no; se revisó el total). El PR #21 ya se fusionó en `main` (`e11893c`), así que estos cambios necesitan un PR nuevo. Archivos: `historia.md`, `revisiones/REV-03.md` (nota final), `revisiones/REV-04.md`, `entregas/README.md` l. 62, `entregas/E4_2026-11-24_M07-M08-final/README.md` l. 10 y `entregas/E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-03_agrofusion-sso/historia.md` l. 77. Es un documento: no hay PR de Juan Hernando que revisar. ST-04b se ejecuta en paralelo en otro worktree y no se revisó.
- **Estado real reverificado hoy**, en solo lectura (`git ls-remote` y `gh`; no se hizo `fetch` en sgpmp-backend para no interferir con ese worktree):
  - BE `dev 8d4981f6` · `test 918806ec` · `main 0abbeeef` · rama `fix/compose-test-entorno-m04-1180` en `b8968e68`. SGMP-Integracion `main e11893c`.
  - `gh api …/compare/6cee5fc4...8d4981f6` (36 archivos) y `…/compare/12965211...918806ec` (176 archivos): ninguno es `docker-compose*.yml`, `.env*.example`, `Dockerfile` ni `.dockerignore`.
  - #1204: `OPEN`, `MERGEABLE`, 1 commit, cabeza `b8968e68`.
  - Permisos: `Juanher01 write` · `chebaztian write` · `chebaz-117 read`. Sesión de `gh`: `Chebaztian`. `branches/fix/compose-test-entorno-m04-1180 .protected` → `false`.
  - Comentarios (`gh api repos/Arekkazu/sgpmp-backend/issues/{1204,1180}/comments`): `7066376147` (Chebaztian, 17:18Z), `7066889566` (Chebaztian, 17:57Z, «vamos a subir un commit a esta rama…»), `7067098039` (Arekkazu, 18:13Z, «Vosotros») en #1204; `7066432077` (Chebaztian, 17:22Z) en #1180.

## Dictamen global

**APROBAR CON OBSERVACIONES.** No hay hallazgos Mayores ni Bloqueantes.

M-01 y m-01 a m-05 de REV-04 quedan resueltos. La numeración ST-04a/b/c es coherente, el total suma 21 h y CA-3, CA-4 y CA-5 no se contradicen entre sí. No hay secretos ni atribución a herramientas. Quedan una observación menor (la ruta sin permiso de escritura no puede hacer push al repo) y dos detalles de redacción. Ninguno impide ejecutar ST-04b por la ruta principal, que es la que corresponde hoy.

## Comprobaciones pedidas

| Comprobación | Veredicto | Evidencia |
|---|---|---|
| REV-04 M-01 (permiso de la cuenta que hace el push) | **Resuelto** | ST-04b paso 1 (l. 140): `gh api repos/Arekkazu/sgpmp-backend/collaborators/$(gh api user --jq .login)/permission --jq .permission` → `write` o `admin`. Con las cuentas de hoy da `write` para `Juanher01` y para `chebaztian`, así que se toma la ruta principal, que es la que se avisó a Arekkazu. Detalle: falta `maintain` entre los resultados válidos (n-02). |
| REV-04 m-01 (protección, `--track`, push sin force) | **Resuelto** | Paso 1: `…/branches/fix/compose-test-entorno-m04-1180 --jq .protected` → `false` (hoy `false`). Paso 3: `git switch --track -c … origin/…` y la variante `git worktree add --track -b …`. Probé las dos sintaxis en un repositorio de prueba y las dos dejan el upstream en `origin/fix/x`. Paso 5: push explícito, sin `--force` ni `--force-with-lease`, y detenerse si no es fast-forward. Detalle: el push usa el nombre de la rama local (n-01). |
| REV-04 m-02 (la cabeza cambia) | **Resuelto** | Paso 1: «Si la cabeza ya no es `b8968e68`… detenerse y avisar al líder: revisar si el commit nuevo ya corrige la l. 82 o cambia su número de línea antes de seguir». Es más conservador que lo propuesto en REV-04 y es válido. Hoy la cabeza sigue en `b8968e68`. |
| REV-04 m-03 (URLs y respuesta de Arekkazu) | **Resuelto** | ST-01 «Hecho (2026-11-21)» (l. 99): las cuatro URLs, con hora UTC y autor. Las comprobé contra la API: los ids, las horas y los autores coinciden. La respuesta «Vosotros» está anotada y se interpreta como «no corrige la l. 82; la corrige Implementación». ST-04b paso 2 (l. 141) queda marcado como hecho, con el aviso y la respuesta enlazados. CA-2 ya tiene sus dos URLs en la HU. |
| REV-04 m-04 (corte y README) | **Resuelto** (con n-03) | l. 6: «Reverificado el 2026-11-21: BE `origin/dev 8d4981f6` · `origin/test 918806ec` · `origin/main 0abbeeef` · PR #1204 `b8968e68` (abierto) · SGMP-Integracion `main e11893c`». Los cinco hashes coinciden con `ls-remote`/`gh`, y la frase de que `dev`/`test` no tocan los archivos de la HU se confirma con `compare`. `entregas/README.md:62` dice «en Taiga» / «En Taiga (2026-11-21)… ST-04c y ST-06». `E4…/README.md:10` dice «en Taiga (2026-11-21)». La sección Metadatos (l. 221-222) no menciona el ajuste del 2026-11-21 (n-03). |
| REV-04 m-05 (fila CA-4) | **Resuelto** | l. 51: «En la rama que lleva la corrección (la de #1204 con el commit de ST-04b; o la del PR de ST-04b hacia ella; o la de ST-04c)». Ya no es ambiguo y coincide con el texto de CA-4 (l. 35). |
| Numeración ST-04a/b/c | **CUMPLE** | La única aparición de «ST-04» a secas es la decisión 4 (l. 205), un texto histórico con nota de renumeración. Rama (l. 12), descripción, alcance, CA-3/4/5, dependencias (l. 69), riesgos (l. 78, 83), plazo (l. 199) y decisión 8 usan ST-04b = commit en la rama de #1204 y ST-04c = retiro de `AGROFUSION_HUB_*` del compose. Las menciones externas (CFG-03 l. 77, `entregas/README.md:62`, nota final de REV-03) usan la numeración nueva. |
| Total de horas | **CUMPLE** | 2 + 4 + 3 + 2 + 1 + 2 + 2 + 2 + 3 = 21 h (l. 193). ST-04b en 1 h: excepción decidida por el líder, anotada en l. 148. No es hallazgo. |
| CA-3 / CA-4 / CA-5 | **Coherentes** | CA-3: la tercera condición la cumple ST-04b tras la fusión, o ST-04c. CA-4: los tres caminos están igual en el CA, en la fila de verificación y en ST-04b/ST-04c. CA-5: no cambió desde REV-04. Su excepción para `IOT_AUDITORIA_RESPALDO_PATH` desaparece sola cuando ST-04b quita la línea. |
| Secretos y atribución | **CUMPLE** | `grep -nE '(SECRET\|KEY\|TOKEN\|PASSWORD)[A-Z_]*=[^ <\`]'` sobre los archivos del diff: una sola coincidencia, en `historia.md:53`, que es el patrón `'^OTA_URL_SECRET=.+'` de CA-6 y no un valor (falso positivo). `grep -niE 'co-authored\|claude\|generated with\|anthropic'`: aparece solo el texto del comando dentro de REV-04 l. 33 y `entregas/README.md:32`, que es una línea anterior a este diff y no se tocó. |

## Hallazgos

### Mayores

Ninguno.

### Menores

| ID | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|
| m-01 | ST-04b paso 1, ruta alternativa (l. 140); decisión 8 y dependencias (l. 69) | «Si no hay permiso de escritura… push a una rama propia, p. ej. `cfg-04/pr1204-ruta-respaldo`, y PR con base `fix/compose-test-entorno-m04-1180`». Sin permiso de escritura no se puede subir **ninguna** rama a `Arekkazu/sgpmp-backend`. Esa ruta solo funciona desde un fork (o si la causa es la protección de la rama y la cuenta sí tiene `write`). REV-04 la dio por buena: se me pasó en esa revisión. Hoy no aplica, porque `Juanher01` y `chebaztian` tienen `write` y la rama no está protegida. | Distinguir los dos casos. **Rama protegida con `write`:** `git push origin HEAD:cfg-04/pr1204-ruta-respaldo` y PR con `--base fix/compose-test-entorno-m04-1180`. **Sin `write`:** `gh repo fork Arekkazu/sgpmp-backend --remote=false`, push al fork y `gh pr create -R Arekkazu/sgpmp-backend --base fix/compose-test-entorno-m04-1180 --head <usuario>:cfg-04/pr1204-ruta-respaldo`. |

### Detalles de redacción (no bloquean)

| ID | Dónde | Evidencia | Corrección sugerida |
|---|---|---|---|
| n-01 | ST-04b paso 5 (l. 144) | `git push origin fix/compose-test-entorno-m04-1180` empuja la rama **local** con ese nombre. Si en la variante `git worktree add --track -b … ` se usa otro nombre local, el push no sube el commit del worktree. | `git push origin HEAD:fix/compose-test-entorno-m04-1180` (como proponía REV-04 m-01), o dejar explícito que el nombre local debe ser el mismo. |
| n-02 | ST-04b paso 1 (l. 140) | El resultado esperado es «`write` o `admin`». El rol `maintain` también permite el push. | «`write`, `maintain` o `admin`». |
| n-03 | Metadatos (l. 221-222) | Solo registran el 2026-11-20. El ajuste y la reverificación del 2026-11-21 están en el encabezado (l. 3 y 6), pero no en Metadatos. | Añadir una línea: «Ajustado el 2026-11-21 (nueva ST-04b, REV-04, REV-05); reverificación en l. 6». |

### Observación (no es hallazgo)

- ST-04b ya está en ejecución. m-01, n-01 y n-02 no la afectan mientras la cuenta sea `Juanher01` o `chebaztian` (`write`), la rama siga sin protección y el worktree use el mismo nombre de rama local. Si hay que corregir el texto, conviene hacerlo también en la ST-04b de Taiga.
- El PR #21 ya está fusionado, así que estos cambios (`historia.md`, REV-03, REV-04, REV-05 y los README) necesitan un PR nuevo a `main` de SGMP-Integracion, desde la rama actual rebasada sobre `e11893c` o desde una rama nueva.

## Borrador de retroalimentación (para el autor del ajuste)

> Las correcciones de REV-04 están bien aplicadas. ST-04b ahora comprueba el permiso de la cuenta que hace el push, la protección de la rama y el seguimiento con comandos exactos. Prohíbe el force push y dice qué hacer si la cabeza de #1204 cambia. Las cuatro URLs de los comentarios están enlazadas y coinciden con la API de GitHub. La respuesta «Vosotros» de Arekkazu está anotada como consentimiento. El corte reverificado del 2026-11-21 es correcto: lo comprobé hash por hash, y `dev` y `test` avanzaron sin tocar compose, plantillas, `Dockerfile` ni `.dockerignore`. La fila de CA-4 ya no es ambigua.
>
> Un ajuste menor, sin urgencia porque hoy no aplica:
> 1. **(m-01)** La ruta alternativa «sin permiso de escritura» propone subir una rama propia al repositorio de Arekkazu. Sin `write` eso no es posible: hace falta un fork (`gh repo fork` + `gh pr create --head <usuario>:<rama> --base fix/compose-test-entorno-m04-1180`). Si la causa es solo la protección de la rama, el push a una rama propia sí funciona.
>
> Detalles de redacción: `git push origin HEAD:<rama>` en el paso 5 (n-01), aceptar `maintain` como permiso válido (n-02) y una línea del 2026-11-21 en Metadatos (n-03).
