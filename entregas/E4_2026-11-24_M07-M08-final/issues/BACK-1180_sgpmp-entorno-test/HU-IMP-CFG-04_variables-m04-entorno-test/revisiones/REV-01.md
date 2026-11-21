# REV-01 — HU-IMP-CFG-04 (fase 2: documentación de la HU)

- **Fecha:** 2026-11-20 (America/Bogota)
- **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Objeto:** contenido preparado (`git diff --cached`) de SGMP-Integracion, rama `docs/hu-imp-cfg-04-variables-m04` (desde `origin/main f40300b`), 8 archivos. No hay PR ni subtareas ejecutadas: se revisa la HU, los borradores, el informe EXT-BACK-PR1204 y los registros.
- **Corte reverificado:** sgpmp-backend `origin/dev 6cee5fc4` · `origin/test 12965211` · `origin/main 0abbeeef` · PR #1204 `b8968e68` (padre `135bc318` = merge-base con `test`; OPEN, MERGEABLE, 0 revisiones, 1 archivo, +18). La ref local `origin/pr-1204` no existe; se verificó por el objeto `b8968e68`. #1180 CLOSED (TEX053, creado 2026-11-19, cerrado 2026-11-20). #941 OPEN `dev`→`main`.

## Dictamen global

**APROBAR CON OBSERVACIONES.** La HU cumple el formato `hu-taiga`, refleja las seis decisiones del líder y todas las citas comprobadas son correctas. Hay un defecto en el comando de verificación de CA-4 (no prueba lo que dice el CA) y una imprecisión en el borrador de #1204; conviene corregirlos antes de publicar el borrador y de pasar la HU a Taiga.

## Revisión contra el formato y las decisiones

| Aspecto | Veredicto | Evidencia |
|---|---|---|
| Secciones `hu-taiga` (Rama, Origen, Situación con tabla, Descripción, Alcance/Fuera, CA, Verificación, DoD, Dependencias, Riesgos, Referencias, Subtareas, Notas, Metadatos) | CUMPLE | `historia.md` completo; subtareas con Objetivo/Pasos/Entregable/Verificación/Estimación; total 21 h = suma de ST |
| CA verificables con comando | CUMPLE (salvo CA-4, ver M-01) | Tabla de Verificación, un método por CA |
| CA de corte y criterios fijos (registro vivo, rama propia y PR) | CUMPLE | CA-1, CA-7 (registro vivo, sin paralelo), ST-02/ST-07 por PR |
| Decisión 1 (líder publica; sin reabrir #1180; lista sin repetir `docker-compose.yml`; @soymoroo; frase final) | CUMPLE | Borradores §1 («`docker-compose*.yml`, `.env*.example` o el `Dockerfile`») y §2 (mención y frase final literales) |
| Decisión 2 (`:?` en PROD no) | CUMPLE | Fuera de alcance y Notas 2 |
| Decisión 3 (AMB-10 en borrador, después, prioridad auditoría PROD) | CUMPLE | Fuera de alcance y Notas 3 |
| Decisión 4 (ST-04a / ST-04b) | CUMPLE | ST-04a sin dependencia; ST-04b espera `MERGED` |
| Decisión 5 (carpetas) | CUMPLE | Rutas de los archivos preparados |
| Decisión 6 (INC-BE-09; INC-BE-08 = CORS; seguimiento) | CUMPLE | `registro.md` fila y nota INC-BE-09; CA-9, ST-06 |
| Secretos | CUMPLE | Sin valores en el diff; las líneas de `.env.test.example` se verificaron con los valores redactados |
| Atribución a herramientas | CUMPLE | `grep -iE 'claude\|co-authored\|generated with'` sobre el diff: solo la línea de contexto preexistente de `entregas/README.md` (no es atribución) |

## Citas comprobadas (muestra)

| Cita | Resultado |
|---|---|
| `docker-compose.test.yml:82@b8968e68` `IOT_AUDITORIA_RESPALDO_PATH: ${…:-var/auditoria_iot/fallas.sqlite3}` | Correcta |
| `:71@b8968e68` `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}`; 11 variables (l. 71-86) | Correcta |
| `AGROFUSION_HUB_*` l. 67-68@b8968e68 y l. 66-67@12965211 | Correctas (la tabla de situación usa bien las de `test`) |
| `Dockerfile@12965211` l. 55-56 (mkdir/chown 1000), l. 61 (`ENV`), l. 62 (`USER 1000`), `WORKDIR /app` l. 6 | Correctas |
| `.dockerignore:19@12965211` `var/auditoria_iot/` | Correcta |
| `configuracion.py:18@12965211` `os.getenv("SGPMP_ENTORNO", "DEV")` | Correcta |
| `.env.test.example` l. 54-55 `AGROFUSION_HUB_*` | Correcta |
| Lectura relativa: `respaldo_auditoria_iot_sqlite_adapter.py:18` (`Path(... 'var/auditoria_iot/...')`) | Confirma que resuelve contra `/app` |
| `AGROFUSION_HUB_CLIENT` en `*.py` de `dev` y `test` | 0 archivos: correcto «ya no lo lee» |
| `docker-compose.prod.yml@6cee5fc4` l. 154 (`:-PROD`), l. 167-169 (`OTA_URL_*`); `.env.prod.example@6cee5fc4` sin `OTA_URL_*` | Correctas |
| `b2b9097b`, `d417c0c6`, `5e87d61e`, `098f635a` | Los 4 INCLUIDOS en `dev` y `test`, AUSENTES en `main` |
| `main@0abbeeef` sin `SGPMP_ENTORNO` | Correcta (sin coincidencias) |
| #1161 = SEG-M04-01 | Correcta |
| `VARIABLES-ENTORNO.md` l. 92 y l. 340; `registro.md` INC-BE-02 (l. 15), INC-BE-04 (l. 17), INC-BE-08 CORS | Correctas |

## Hallazgos

### Mayores (no bloqueantes para preparar la rama; corregir antes de Taiga)

| ID | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|
| M-01 | `historia.md`, Verificación CA-4 | El comando hace `grep -q IOT_AUDITORIA_RESPALDO_PATH && echo "-e IOT_AUDITORIA_RESPALDO_PATH=/app/storage/…"`: si el compose conserva la l. 82 relativa, inyecta la ruta **absoluta** y la prueba da `ESCRIBIBLE`. No usa «el valor que entrega el compose de TEST», que es lo que exige el CA. CA-3 atenúa el riesgo, pero CA-4 queda como falso positivo posible. | Extraer el valor por defecto real del compose y pasarlo tal cual, p. ej. `V=$(sed -n 's/.*IOT_AUDITORIA_RESPALDO_PATH: \${IOT_AUDITORIA_RESPALDO_PATH:-\(.*\)}$/\1/p' docker-compose.test.yml)` y `docker run --rm ${V:+-e IOT_AUDITORIA_RESPALDO_PATH=$V} --entrypoint sh sgpmp-back:cfg04 -c '…; mkdir -p "$(dirname "$IOT_AUDITORIA_RESPALDO_PATH")" && touch …/.w && echo ESCRIBIBLE'` (sin `--env-file` real). |

### Menores

| ID | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|
| m-01 | `borradores-comentarios.md` §1, propuesta de la l. 82 | Dice «usar `${IOT_AUDITORIA_RESPALDO_PATH:-/app/storage/…}`, como DEV». En `dev@6cee5fc4` `docker-compose.yml:92` es literal: `IOT_AUDITORIA_RESPALDO_PATH: /app/storage/auditoria_iot/fallas.sqlite3`. `analisis.md` lo dice bien. | «o fijarla a `/app/storage/auditoria_iot/fallas.sqlite3`, como DEV (l. 92)». |
| m-02 | `borradores-comentarios.md` §1, primer párrafo | «la misma forma `${VAR:-}`» no es exacta: `LOGOS_STORAGE_PATH` tiene default `/tmp/sgpmp_logos` en el PR y `/app/storage/modelos/logos` en DEV; `IOT_AUDITORIA_RESPALDO_PATH` difiere. | Matizar («con `${VAR:-…}`, salvo los defaults de rutas») o no afirmar igualdad. |
| m-03 | `borradores-comentarios.md` §1 vs CA-2 | CA-2 pide que el comentario explique la desviación frente a lo pedido en #1180 («definir» `M04_FIRMA_MODELOS_KEY`). El texto lo cubre de forma implícita, sin referir la petición. | Añadir «Sobre lo que se pidió en #1180 de definir la clave en TEST: …» para que CA-2 se verifique sin interpretación. |
| m-04 | `historia.md`, campo **Rama** | Lista `cfg-04/test-plantilla-variables` y `cfg-04/dev-plantilla-prod-ota`, pero no `cfg-04/test-retiro-hub` (ST-04b). | Añadirla al encabezado. |
| m-05 | Corte entregado por el líder | `origin/pr-1204` no existe como ref local; el hash `b8968e68` sí. | Sin cambio en la HU; para reverificar usar `git fetch origin pull/1204/head:refs/remotes/origin/pr-1204` o el hash. |
| m-06 | `historia.md`, celdas con `\|` en comandos (CA-5, CA-7, CA-9) | Escape necesario en la tabla Markdown; al copiar a terminal hay que quitarlo. | Opcional: nota «quitar `\` antes de `\|` al copiar». |

## Borrador de retroalimentación (para el autor de la HU)

La HU está bien armada: la situación actual se apoya en hashes y líneas que comprobé una por una, refleja las seis decisiones del 2026-11-20 y separa con claridad lo que hace Desarrollo (#1204), Despliegue (Deploy y valores) y Pruebas (re-prueba). El registro INC-BE-09, las filas de los README y la nota de traslado en CFG-03 son coherentes con la historia.

Antes de pasarla a Taiga y publicar los borradores:
1. **CA-4:** el comando inyecta la ruta absoluta cuando el compose trae la variable, así que la prueba pasaría aunque la l. 82 siguiera relativa. Toma el valor del compose y pásalo tal cual (propuesta en M-01).
2. **Borrador de #1204:** DEV fija `IOT_AUDITORIA_RESPALDO_PATH` como literal en `docker-compose.yml:92`, no con `${…:-}`; y los defaults de rutas no son iguales a DEV. Ajusta esas dos frases (m-01, m-02).
3. **CA-2:** menciona explícitamente en el comentario de #1204 la petición de #1180 de «definir» la clave, para que la desviación quede explícita (m-03).
4. Añade `cfg-04/test-retiro-hub` al campo Rama (m-04).
