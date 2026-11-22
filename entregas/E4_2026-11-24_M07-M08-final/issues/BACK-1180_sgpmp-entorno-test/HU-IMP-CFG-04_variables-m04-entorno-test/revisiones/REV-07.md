# REV-07 — HU-IMP-CFG-04: ampliación de ST-04c (redacción, antes del commit)

- **Fecha:** 2026-11-22 (America/Bogota) · **Revisor:** agente `revisor` (dictamen; decide el líder)
- **Objeto:** `historia.md` en la rama local `docs/cfg-04-st04c-volumenes-test` de SGMP-Integracion, **sin commit**
  (`git diff origin/main -- historia.md`, base `origin/main b372c82`). En la misma rama y solo en lo que se cruza con la HU:
  `prs/BACK-PR1223_volumen-modelos-uid1000/analisis.md`, INC-BE-02 e INC-BE-10 de `registros/incidencias/registro.md` y
  la fila nueva del README de E4.
- **Contra qué:** skill `hu-taiga` (CA verificables, comandos que funcionan en Git Bash, coherencia interna, numeración y totales)
  y lo que pidió el líder el 2026-11-22.
- **No se editó** `historia.md` ni se hizo commit.

## 1. Reverificación del corte (git fetch del 2026-11-22)

Todo coincide con lo que dice la HU (l. 9) y con los hechos que trae el líder.

| Dato | HU | Reverificado |
|---|---|---|
| BE `origin/dev` | `4c65796e` | `4c65796e` (2026-11-22); `885f39de` INCLUIDO |
| BE `origin/test` | `c698c656` | `c698c656` (2026-11-21); `885f39de`, `21ab30e5` y `e2ec9ed5` AUSENTES |
| BE `origin/main` | `239909e0` | `239909e0` (2026-11-22); `21ab30e5` y `e2ec9ed5` INCLUIDOS |
| PR #1204 | `097f6d80` OPEN | `097f6d80` OPEN, base `test` |
| PR #1220 | OPEN | OPEN, cabeza `184112a1`, base `test` |
| SGMP-Integracion `origin/main` | `b372c82` | `b372c82` |
| Volumen de modelos de PROD | desde `00dbf946` (2026-09-11, PR #268) | `00dbf946` de chebaztian, 2026-09-11 14:50 -05; ya monta `sgpmp_modelos_prod:/app/storage/modelos` (l. 150@00dbf946); PR #268 fusionado el 2026-09-12 14:04 UTC (merge `aab39ca3`, contiene `00dbf946`) |
| `e2ec9ed5` | solo el volumen de auditoría | +6 líneas en `docker-compose.prod.yml`: `IOT_AUDITORIA_RESPALDO_PATH` literal, montaje y declaración de `sgpmp_auditoria_iot_prod`. No toca el de modelos |
| Compose de TEST @`097f6d80` | l. 63 y 75 en `/tmp`, `AGROFUSION_HUB_*` l. 67-68, solo `pgdata` | Igual; l. 74 es el comentario de RF-26; `volumes:` del backend en l. 97 (solo la clave del SSO); nivel superior l. 111-112 |
| `.env.test.example`@`c698c656` | l. 46 y 101 en `/tmp` | Igual |
| PROD @`239909e0` | compose l. 147, 151, 169, 181-183, 254-257; plantilla l. 138 y 141 | Igual |
| Dockerfile de `test` | sin `/app/storage/modelos` | `mkdir -p /app/storage/auditoria_iot` solamente; idéntico al de `9655f389` y al padre de `885f39de` (`git diff --stat` vacío) |
| Dockerfile de `dev` y `main` | carpeta creada | l. 60: `mkdir -p /app/storage/auditoria_iot /app/storage/modelos` |

**Prueba del cherry-pick propuesto** (worktree temporal desechable, sin push): `git cherry-pick -x 885f39de` sobre
`origin/test@c698c656` aplica **sin conflicto** (solo `Dockerfile`, +7 −2), y después se puede fusionar `097f6d80` (#1204)
sin conflicto. El commit resultante lleva **dos** líneas de procedencia: `885f39de` ya era un cherry-pick de `21ab30e5`.

## 2. Comandos nuevos probados

| CA | Comando (resumen) | Resultado hoy | Valoración |
|---|---|---|---|
| CA-3 ampliación | grep de montajes y rutas (ver m-01) | Con `_prod` en lugar de `_test` sobre `main`: **7** líneas (incluye el comentario l. 148). Copiado crudo del `.md` (con `\|`): **0** | Funciona solo renderizado; recuento esperado impreciso |
| CA-3 `/tmp` | `grep -c /tmp/sgpmp_` sobre `097f6d80` | `2` | Control negativo válido |
| CA-4 (a) `sed` | sobre la l. 169 literal de PROD | `/app/storage/auditoria_iot/fallas.sqlite3` | Sirve para el formato que pide ST-04c paso 3 |
| CA-5 (c) | `grep -nE '^(MODELOS\|LOGOS)_STORAGE_PATH='` sobre `origin/test` | l. 46 y 101 en `/tmp` | Control negativo válido (renderizado) |
| CA-12 (1) | `merge-base … 885f39de origin/test && echo PROMOVIDO \|\| … grep mkdir` | En `test`: sin salida, exit 1. En `dev`: `PROMOVIDO`. Tras el cherry-pick: l. 60 | Correcto |
| CA-12 (2) | `git log --format='%h %s' -3 origin/test -- Dockerfile docker-compose.test.yml` | Tras el cherry-pick: `68bd42eb fix(rf69-mod4): …` **sin** la línea «cherry picked from» | No muestra lo que pide el resultado esperado (M-02) |
| (Situación / análisis) | `git log -S'/app/storage/modelos' origin/main -- Dockerfile` | **Vacío** sin `MSYS_NO_PATHCONV=1`; con el prefijo: `21ab30e5` | Falso negativo en Git Bash (n-04) |

## 3. Dictamen por criterio (redacción)

| CA | Veredicto de redacción | Justificación |
|---|---|---|
| CA-3 | CUMPLE con observación | Condiciones claras y copiadas de PROD; el comando nuevo tiene `\|` en tabla y un recuento ambiguo (m-01) |
| CA-4 (b) | CUMPLE | Volúmenes nuevos, dueño `appuser`, creación de `logos`, control negativo con imagen de Dockerfile idéntico (`9655f389` = `c698c656`, verificado) y `MSYS_NO_PATHCONV=1` en el `docker run` |
| CA-5 | CUMPLE con observación | Rutas iguales a PROD; «ninguna `/tmp/sgpmp_`» no tiene comando (m-02) |
| CA-9 | NO CUMPLE (redacción) | La cláusula «no hay `MODELOS_STORAGE_PATH` ni `LOGOS_STORAGE_PATH` en `/tmp`» no tiene método ni resultado esperado; `[ -w ]` no la detecta (M-03) |
| CA-11 | CUMPLE en la HU; NO CUMPLE en el registro de la rama | El texto del CA es correcto, pero INC-BE-02 en la rama sigue diciendo «fuera de alcance; HU-IMP-AMB-10» y `diagnosticado` (M-01) |
| CA-12 | NO CUMPLE (redacción) | La rama del cherry-pick (la que la HU propone) no se puede evidenciar con el comando escrito (M-02) |
| Resto (CA-1, 2, 6, 7, 8, 10) | Sin cambios en esta ampliación | CA-1: el corte nuevo (l. 9) trae fecha y todos los hashes; reverificados |

Numeración y totales: CA-1 a CA-12 correlativos; subtareas ST-01…ST-07 sin huecos; total 2+4+3+2+1+5+2+2+3 = **24 h**, correcto.
ST-04c (5 h) dentro de 2-6 h. No quedan menciones de `e2ec9ed5` como origen del volumen de modelos (grep en todo el repo).

## 4. Fortalezas

| # | Dónde | Qué está bien |
|---|---|---|
| F-1 | Situación actual, decisión 9 | Origen del volumen de modelos corregido y trazado (`00dbf946`, PR #268, fechas exactas), separado de `e2ec9ed5` |
| F-2 | ST-04c pasos 2-4 | Copia línea a línea de PROD con número de línea y hash; `IOT_AUDITORIA_RESPALDO_PATH` literal «para que funcione el sed de CA-4»: anticipa la verificación |
| F-3 | CA-12 + riesgo + punto de atención | Orden Dockerfile → volúmenes explícito y con control negativo real (prueba del 2026-11-22) |
| F-4 | Riesgos | Cubre los casos no obvios: variable de Dokploy con `/tmp` que gana al default, volumen reutilizado con archivos de root, prefijo de Dokploy en el nombre |
| F-5 | ST-04c paso 1 | Espera también al #1220 (mismo archivo) |
| F-6 | Decisión 9 | Las cuatro razones del cherry-pick son verificables; el cherry-pick aplica limpio (probado) |

## 5. Hallazgos

### Mayores

| ID | Dónde | Evidencia | Corrección propuesta |
|---|---|---|---|
| M-01 | `registros/incidencias/registro.md` l. 15 (INC-BE-02), en esta misma rama | Columna de referencia: «historia.md (fuera de alcance; HU-IMP-AMB-10)»; estado sigue `diagnosticado` y la frase «Los volúmenes van en HU-IMP-AMB-10 (borrador; depende de…)» queda sin cierre. Es una mención vigente a AMB-10 como HU independiente y contradice CA-11 («enlazada a esta HU, ST-04c») | Estado → `en HU (HU-IMP-CFG-04)`; referencia → `…/historia.md (ST-04c; absorbe HU-IMP-AMB-10)`; en la frase antigua, «(sustituido el 2026-11-22: ver abajo)» o equivalente |
| M-02 | CA-12, Verificación (2.º comando) | `git log --format='%h %s'` solo imprime el asunto: tras el cherry-pick sale `68bd42eb fix(rf69-mod4): …` sin «cherry picked from commit 885f39de», que es justo lo que pide el resultado esperado. Si el PR se fusiona con squash, tampoco queda un commit propio | Sustituir por `git -C sgpmp-backend log --grep='cherry picked from commit 885f39de' --format='%h %ad %s' --date=iso origin/test` (o `--format='%h %s%n%b'`) y, como prueba por contenido que sobrevive al squash, `git -C sgpmp-backend cherry -v origin/test 885f39de 885f39de^` → línea con `-`. Mantener el `log … -- Dockerfile docker-compose.test.yml` solo para el orden |
| M-03 | CA-9 (texto) y su fila de Verificación | El CA exige que Despliegue confirme que en TEST no hay `MODELOS_STORAGE_PATH`/`LOGOS_STORAGE_PATH` en `/tmp`, y el riesgo l. 104 se apoya en eso, pero no hay comando ni resultado esperado. `[ -w /app/storage/…]` da `escribible` aunque la app esté usando `/tmp` | Agregar a lo que ejecuta Despliegue: `docker exec <backend-test> sh -c 'printenv MODELOS_STORAGE_PATH LOGOS_STORAGE_PATH'` → `/app/storage/modelos` y `/app/storage/modelos/logos` (variables no sensibles, tipo Comportamiento en el catálogo). Resultado esperado y evidencia en la misma fila |

### Menores

| ID | Dónde | Evidencia | Corrección propuesta |
|---|---|---|---|
| m-01 | CA-3, ampliación del comando | (a) Con `\|` dentro de la tabla, el comando copiado del `.md` da **0** coincidencias (error recurrente n.º 6 de la memoria del revisor). (b) «2 montajes, 2 declaraciones y las 2 rutas» = 6, pero el grep también toma comentarios: sobre PROD devuelve 7 (l. 148). Si ST-04c copia el comentario de RF-26 con `sgpmp_modelos_test`, el resultado no coincide | Bloque de código fuera de la tabla y filtro de comentarios: `git -C sgpmp-backend show origin/test:docker-compose.test.yml \| grep -v '^\s*#' \| grep -nE 'sgpmp_(modelos\|auditoria_iot)_test\|STORAGE_PATH'` (pipes sin escapar en el bloque) → exactamente 6 líneas, listadas |
| m-02 | CA-5 (texto «ninguna `/tmp/sgpmp_`») | Sin comando. Hoy `git show origin/test:.env.test.example \| grep -c /tmp/sgpmp_` → `2` (control negativo listo) | Añadir a (c): ese comando → `0` tras ST-04c |
| m-03 | ST-04c paso 8 | Un PR a SGMP-Integracion (aprueba el Líder de Implementación) dentro de una subtarea cuyo PR va a `test` de BE (aprueba el Líder de Pruebas). `hu-taiga` §5: «una subtarea por PR» con aprobadores distintos | Mover el paso 8 a ST-07 (reabrirla con «Pendiente: ST-04c») o a una ST-04d de 1-2 h; ST-04c baja a ~4 h y el total no cambia si se reparte |
| m-04 | ST-04c paso 8 (cobertura) | En `main` del catálogo quedan menciones a AMB-10 que el paso no cubre: nota de `VARIABLES-ENTORNO.md:365` («Volúmenes… HU-IMP-AMB-10 (borrador; depende de Desarrollo)») y la fila de `IOT_AUDITORIA_RESPALDO_PATH` (l. 101) | Añadir al paso: l. 365 y fila de `IOT_AUDITORIA_RESPALDO_PATH` (TEST con volumen y ruta literal, como PROD) |
| m-05 | Decisión 3 (l. 252), ST-07 paso 1 (l. 229) y fila ST-07 del estado (l. 23) | La decisión 3 sigue diciendo que AMB-10 «queda en borrador, va después de esta HU» sin remitir a la decisión 9; ST-07 paso 1 sigue mandando a «INC-BE-02 (HU-IMP-AMB-10)» | Al final de la decisión 3: «Sustituida por la decisión 9 (2026-11-22).»; en ST-07 paso 1: «INC-BE-02 (ST-04c; antes HU-IMP-AMB-10)». La fila del estado puede quedar como histórico si se marca la fecha |
| m-06 | **Descripción** (l. 44) | No menciona la persistencia de TEST ni el Dockerfile: Alcance, CA y ST sí. Un lector de Taiga no ve el nuevo objetivo en el párrafo que lo define | Una frase: «…y que TEST guarde modelos, logos y el respaldo de auditoría en volúmenes, como PROD, con el Dockerfile de #1224 (ST-04c; absorbe HU-IMP-AMB-10)» |
| m-07 | INC-BE-10 (registro, en esta rama) | Responsable solo «Desarrollo · Despliegue» y la referencia solo al análisis, aunque la HU decide llevar el Dockerfile a `test` por ST-04c (Implementación) | Responsable: añadir «Implementación (llevarlo a `test`, HU-IMP-CFG-04 ST-04c)»; referencia: añadir la ruta de la HU |

### Notas

| ID | Dónde | Observación |
|---|---|---|
| n-01 | Encabezado | «Estado: en ejecución (2026-11-21, tarde)» y «Estado por subtarea (corte 2026-11-21, 17:55)» ya contienen hechos del 21 noche y del 22. Actualizar fecha de ambos. El tablero `entregas/README.md` (l. 62) y la fila de #1180 del README de E4 no reflejan la ampliación (`hu-taiga` §6) |
| n-02 | `analisis.md` §6 y §7.3 | El análisis presenta la estrategia A (esperar la promoción) como la de defecto y deja abierta la pregunta; la HU propone B. No hay contradicción de criterios (CA-12 acepta las dos), pero cuando el líder decida, cerrar §7.3 y ajustar §6 |
| n-03 | CA-12 | `885f39de` ya trae «(cherry picked from commit 21ab30e5…)»; con `-x` quedan dos líneas. El grep por `885f39de` funciona; conviene decirlo en la descripción del PR para que el Líder de Pruebas no lo lea como error |
| n-04 | Situación actual (evidencia «`git log -S`») y `analisis.md` §2 | En Git Bash, `git log -S'/app/storage/modelos' … -- Dockerfile` devuelve vacío **también en `main`**, donde sí está: MSYS convierte el argumento. La conclusión («la imagen nunca creó la carpeta») es correcta (comprobado con `MSYS_NO_PATHCONV=1`: en `test` vacío; en `main` solo `21ab30e5`), pero la evidencia debe citar el comando con el prefijo. La nota de la l. 63 de la HU solo lo pide para `git show` |
| n-05 | Dependencias (l. 89) vs ST-04c paso 1 | Dependencias: «la rama se crea después de su fusión» (#1220); paso 1: «fusión … o su cierre». Unificar |
| n-06 | ST-04c paso 6 | Aviso de cortesía a Desarrollo (Arekkazu/Alex) en el PR: su hotfix entra a `test` por un PR de Implementación antes de la promoción |

## 6. Dictamen global

**SOLICITAR CAMBIOS** (de redacción, antes del commit). La ampliación es correcta en fondo: los hechos están verificados,
el cherry-pick aplica limpio y la secuencia Dockerfile → volúmenes está bien protegida. Bloquean el commit M-01 (mención
vigente a AMB-10 en el registro, contra lo pedido y contra CA-11), M-02 (CA-12 no se puede evidenciar por la vía que la propia HU
propone) y M-03 (cláusula de CA-9 sin método, que es la única detección de una falla silenciosa). Los menores se corrigen en el
mismo pase.

**Sugerencia al líder:** la n-04 y la m-01 son variantes de errores ya registrados (conversión MSYS y `\|` en tablas). Conviene que el
`planificador` ponga los comandos con `|` o rutas `/…` en bloques de código fuera de la tabla, con el prefijo `MSYS_NO_PATHCONV=1`
para todo `git`/`docker` que reciba una ruta absoluta.

## 7. Borrador de retroalimentación (para el autor de la redacción)

> La ampliación de ST-04c queda sólida: el origen del volumen de modelos está bien corregido y trazado (`00dbf946`, PR #268),
> los pasos copian PROD línea a línea con hash, y los riesgos cubren los casos que de verdad fallan en silencio (variable de Dokploy
> con `/tmp`, volumen reutilizado con archivos de root). Probé el cherry-pick de `885f39de` sobre `test@c698c656`: aplica sin
> conflicto, y #1204 se fusiona encima sin conflicto.
>
> Antes del commit, tres cambios:
> 1. **INC-BE-02** (registro, misma rama): la columna de referencia aún dice «fuera de alcance; HU-IMP-AMB-10» y el estado es
>    `diagnosticado`. Pasarlo a `en HU (HU-IMP-CFG-04)` con referencia a ST-04c.
> 2. **CA-12**: `git log --format='%h %s'` no muestra la línea «cherry picked from». Usar
>    `git log --grep='cherry picked from commit 885f39de' origin/test` y, para el caso de squash,
>    `git cherry -v origin/test 885f39de 885f39de^` (espera `-`).
> 3. **CA-9**: la cláusula de «sin rutas en `/tmp`» necesita comando: `printenv MODELOS_STORAGE_PATH LOGOS_STORAGE_PATH` dentro del
>    contenedor (no son sensibles), con resultado esperado.
>
> En el mismo pase: grep de CA-3 fuera de la tabla y sin comentarios (6 líneas exactas), `grep -c /tmp/sgpmp_` → `0` en CA-5,
> el paso 8 de ST-04c a ST-07 o a una subtarea propia (otro repo, otro aprobador) cubriendo también `VARIABLES-ENTORNO.md:365` y la
> fila de `IOT_AUDITORIA_RESPALDO_PATH`, la decisión 3 marcada como sustituida por la 9, la Descripción con el objetivo nuevo e
> INC-BE-10 con Implementación y la HU.
