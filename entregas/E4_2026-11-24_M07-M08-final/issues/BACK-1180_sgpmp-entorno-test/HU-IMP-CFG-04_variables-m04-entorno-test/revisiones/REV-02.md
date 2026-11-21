# REV-02 — HU-IMP-CFG-04 (fase 2: verificación de correcciones de REV-01)

- **Fecha:** 2026-11-20 18:30 (America/Bogota)
- **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Objeto:** contenido preparado (`git diff --cached`) de SGMP-Integracion, rama `docs/hu-imp-cfg-04-variables-m04` (desde `origin/main f40300b`), 9 archivos (los 8 de REV-01 + `revisiones/REV-01.md`). Sin cambios sin preparar en el árbol de trabajo.
- **Corte reverificado** (`git fetch origin` sin `--prune` y `git fetch origin pull/1204/head:refs/remotes/origin/pr-1204`): sgpmp-backend `origin/dev 6cee5fc4` · `origin/test 12965211` · `origin/main 0abbeeef` · `origin/pr-1204 b8968e68`. Sin cambios respecto de REV-01.
- **Alcance:** confirmar M-01, m-01, m-02, m-03 y m-04 de REV-01 y buscar regresiones. m-05 y m-06 no tocan archivos. Por decisión del líder, la lista «`docker-compose*.yml`, `.env*.example` o el `Dockerfile`» del borrador de #1204 no es hallazgo.

## Dictamen global

**APROBAR CON OBSERVACIONES.** Las cinco correcciones están aplicadas y se comprobaron. La prueba de CA-4 se ejecutó con una imagen construida desde `b8968e68`. Con la l. 82 relativa, la prueba falla como dice la HU, así que ya no se cumple sola. Quedan dos observaciones menores nuevas sobre el comando de CA-4 (n-01, n-02), que no bloquean.

## Verificación de las correcciones

| ID REV-01 | Veredicto | Evidencia |
|---|---|---|
| M-01 (CA-4 se cumplía solo) | CORREGIDO | `historia.md` l. 50. El `sed` de la HU, aplicado a `origin/pr-1204:docker-compose.test.yml`, da `var/auditoria_iot/fallas.sqlite3`; a `origin/test:docker-compose.test.yml`, vacío; a `origin/dev:docker-compose.yml`, `/app/storage/auditoria_iot/fallas.sqlite3`. Ninguno tiene `\r` final (`od -c`). La fila tiene 4 columnas (5 `\|` sin escapar). Ver la ejecución abajo. |
| m-01 (DEV literal) | CORREGIDO | Borrador §1: «quitar la línea (vale el `ENV` del Dockerfile) o usar la ruta absoluta … que es la que DEV pone como valor literal (`docker-compose.yml:92`)». Coincide con `dev@6cee5fc4` l. 92. |
| m-02 (defaults de rutas) | CORREGIDO | Borrador §1: «con la forma `${VAR:-…}` (los valores por defecto de las rutas difieren de DEV porque TEST no monta sus volúmenes)». Coincide con `b8968e68` l. 63, l. 74-75 (`/tmp/sgpmp_*` y el comentario «TEST no monta los volúmenes de dev») y con `dev` l. 73, 76 y 97-99. |
| m-03 (desviación frente a #1180) | CORREGIDO | Borrador §1: «Sobre lo que se pidió en #1180 a Implementación (definir `M04_FIRMA_MODELOS_KEY` en TEST y revisar el `.env` de TEST …)». Explica que no se leen ni definen valores y que la carga es de Despliegue. Con esto, CA-2 se verifica sin interpretación. |
| m-04 (campo Rama) | CORREGIDO | `historia.md` l. 11: «BE `cfg-04/test-retiro-hub` → PR a `test` (ST-04b)». |

### Ejecución de CA-4 (comando de la HU, sin `--env-file`)

Imagen construida desde `git archive origin/pr-1204` (`b8968e68`). Docker 29.9.3. Etiqueta temporal, borrada después.

| Caso | `V` | Salida | Resultado |
|---|---|---|---|
| Compose de #1204 tal cual | `var/auditoria_iot/fallas.sqlite3` | `1000` · `var/auditoria_iot/fallas.sqlite3` · `mkdir: cannot create directory 'var': Permission denied` | Falla (exit 1), como dice la HU |
| Sin línea (estado de `test`) | vacío | `1000` · `/app/storage/auditoria_iot/fallas.sqlite3` · `ESCRIBIBLE` | Pasa |
| Ruta absoluta, con `MSYS_NO_PATHCONV=1` | `/app/storage/auditoria_iot/fallas.sqlite3` | `1000` · `/app/storage/…` · `ESCRIBIBLE` | Pasa |
| Ruta absoluta, Git Bash **sin** `MSYS_NO_PATHCONV` | ídem | `C:/Program Files/Git/app/storage/…` · `mkdir: cannot create directory 'C:'` | Falso negativo (n-01) |

## Regresiones

| Aspecto | Resultado |
|---|---|
| Secretos en el diff | Ninguno (no hay `*_SECRET/KEY/TOKEN/PASSWORD=` con valor) |
| Atribución a herramientas | Ninguna. Las coincidencias de «claude» son el texto de REV-01 y una línea de contexto preexistente de `entregas/README.md` |
| Coherencia | `analisis.md`, Riesgos (l. 77) y Notas (l. 94) siguen alineados con CA-4 y ST-04b. El total de 21 h no cambia |
| Archivos fuera del alcance | Ninguno nuevo. Los 9 archivos son los esperados |

## Hallazgos

### Bloqueantes

Ninguno.

### No bloqueantes

| ID | Severidad | Dónde | Evidencia | Corrección sugerida |
|---|---|---|---|---|
| n-01 | Menor | `historia.md` l. 50, CA-4 | En Git Bash (Windows), `-e IOT_AUDITORIA_RESPALDO_PATH=/app/…` se convierte a `C:/Program Files/Git/app/…`. Con el compose ya corregido (ruta absoluta), la prueba falla. Es un falso negativo, no positivo, pero puede confundir a Juan Hernando. | Anteponer `MSYS_NO_PATHCONV=1` al `docker run`, o añadir la nota «en Git Bash: `export MSYS_NO_PATHCONV=1`». |
| n-02 | Menor (opcional) | `historia.md` l. 50, `sed` | El `sed` no cubre `${IOT_AUDITORIA_RESPALDO_PATH}` sin valor por defecto (deja `V` vacío y la prueba usa el `ENV` de la imagen). Tampoco quita comillas (`"…"`) si ST-04b escribe el valor entre comillas. Ninguno de los dos casos se da en las ramas actuales. | Mantener en ST-04b el formato sin comillas, o mencionarlo en «Puntos de atención». |
| m-05, m-06 | — | De REV-01 | Sin cambios, como se esperaba (no tocan archivos). | — |

## Borrador de retroalimentación (para el autor de la HU)

Las cinco correcciones de REV-01 están bien hechas. El `sed` de CA-4 extrae el valor correcto en las tres ramas. Construí la imagen de #1204 y la prueba falla con la l. 82 relativa y pasa sin la línea o con la ruta absoluta: CA-4 ya mide lo que pide el criterio. Los borradores de #1204 citan bien la l. 92 de DEV, matizan los valores por defecto y explican la desviación frente a #1180. El campo Rama ya incluye ST-04b.

Dos ajustes opcionales antes de Taiga:
1. **CA-4:** añade `MSYS_NO_PATHCONV=1` (o una nota para Git Bash). Sin eso, en Windows la ruta `/app/…` llega convertida y la prueba falla aunque el compose esté bien (n-01).
2. **ST-04b:** escribe el valor de la ruta sin comillas para que el `sed` lo extraiga tal cual (n-02).
