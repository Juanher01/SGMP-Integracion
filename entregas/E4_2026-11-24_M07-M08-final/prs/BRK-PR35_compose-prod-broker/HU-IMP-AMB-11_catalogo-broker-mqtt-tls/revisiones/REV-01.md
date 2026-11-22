# REV-01 — HU-IMP-AMB-11 (revisión de redacción, antes de Taiga)

- **Fecha:** 2026-11-21 (America/Bogota), después de las 22:51.
- **Revisado:** `historia.md` en la rama local `docs/hu-imp-amb-11-catalogo-broker` (commit `26f5792` + cambios sin commit), base `origin/main b372c82`. Filas nuevas en `entregas/README.md` y `entregas/E4_2026-11-24_M07-M08-final/README.md`.
- **Tipo:** segunda revisión de la redacción. Responsable y revisor son la misma persona (Sebastián Sandoval). No hay ejecución, PR ni evidencias todavía.
- **Corte propio:** `git fetch --prune` del 2026-11-21 en los tres repos. Broker `develop 2f8ea54` · `test 662e096` · `main 2181993`. Backend `dev 5115b83d` · `test c698c656` · `main 9655f389`. SGMP-Integracion `main b372c82`. **Coinciden con el corte de la HU.**

## Dictamen global: SOLICITAR CAMBIOS (de redacción, no de fondo)

El contenido técnico es correcto y aplica las nueve decisiones del líder. Antes de copiarla a Taiga hay que corregir dos cosas:

1. Una afirmación de verificación falsa: «`test` igual que `develop`».
2. Los comandos de verificación con `|` dentro de la tabla Markdown. Tal como están escritos dan falsos positivos, y CA-9 no se puede cumplir porque su lista de archivos excluye los README que la propia DoD exige actualizar.

Son seis cambios pequeños, todos en `historia.md`.

## Dictamen por punto

| # | Punto | Veredicto | Evidencia |
|---|---|---|---|
| 1 | Formato hu-taiga | **CUMPLE** con observaciones | Están todas las secciones, en orden: cabecera, origen con autor y fecha, situación actual con tabla por rama, descripción, alcance y fuera de alcance, 10 CA (CA-1 de corte), tabla de verificación, DoD, dependencias, riesgos, referencias, 5 subtareas con Objetivo/Pasos/Entregable/Verificación/Estimación, notas y metadatos. La suma de las estimaciones da 13 h, igual a las notas. Observaciones: ST-01 estima 1,5 h (la skill pide de 2 a 6 h; nota n-03). ST-02 declara CA-2 completo, pero §4 se corrige en ST-03 (m-05). |
| 2 | Citas en el corte | **OBSERVACIÓN** | Verificadas: catálogo `@b372c82` l. 118, 119–120, 123, 185 y §4 l. 190–202 (`MQTT_HOST`/`MQTT_PORT` en l. 198–199). Entre `a910760` y `b372c82` el diff del catálogo solo toca l. 87–107 y 357–367: las citas `@a910760` siguen valiendo. `env/` y `compose/` sin cambios. Broker `develop`: `config.py:27,48,65,77–79`; `docker-compose.prod.yml:68–69, 92–93, 99, 203–204, 209–217, 232–248`; `.env.prod.example:244–246`; `client.py:41–47,56`; `dependencies.py:18–31`; `mosquitto-entrypoint.sh:88–94`; `docker-compose.yml:20–21, 47–48`. Backend `broker_auth.py:61` y `Dockerfile:64,74` en `dev`, `test` y `main`. `compose/docker-compose.yml:109` es `backend:`. `env/*.example` l. 78/80/88 y overrides l. 43/31/30 correctos. PR #35/#64/#67 coinciden en estado, autor y fecha. **Falla:** `develop` y `test` **no** son iguales en los archivos citados (M-01). |
| 3 | Decisiones del líder | **CUMPLE** | (a) `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT` solo en la nota: CA-4 con 7 filas y el `grep -c` espera `0`; ST-02 paso 4. (b) `BACKEND_URL=http://backend:8000` en dev y test, vacía en prod: Alcance, CA-7, ST-04 paso 3. (c) `MQTT_HOST`/`MQTT_PORT` en ST-03, CA-10 (+0,5 h). (d) Dependencia de cierre, no de inicio, y riesgo: Dependencias l. 95–96, Riesgos l. 100, DoD l. 89–90. (e) Nota SEG-BROKER-02 / HU-IMP-SEG-03 fuera de alcance: l. 56. (f) Responsable y revisor Sebastián Sandoval, sin reparto, `/revisar` como segunda revisión: cabecera, l. 113, riesgo l. 105. (g) El aviso a Despliegue lo da el líder: Fuera de alcance y Notas 4. (h) Riesgo 0.4.x en `main`: l. 104. (i) Las preguntas quedaron cerradas en «Decisiones del líder». |
| 4 | Coherencia, comandos, secretos, afirmaciones viejas | **NO CUMPLE** | CA-9 no se puede cumplir tal como está escrito (M-02). Los comandos con `\|` en la tabla dan falsos positivos: probados en Git Bash sobre `main` de hoy (M-03). No promete valores de secretos, puertos de host ni dominios: los `1885`/`9002` aparecen solo como citas del compose de TEST, y CA-5 los prohíbe en la nota. No quedan «#941», «main sin compose PROD», `cebd430` como estado vigente ni Juan Hernando como responsable. |
| 5 | README | **CUMPLE** | `git diff origin/main` en los dos README: una sola línea `+` en cada uno (la fila de AMB-11) y ninguna `-`. |

## Hallazgos

### Mayores

| ID | Dónde | Evidencia | Corrección propuesta |
|---|---|---|---|
| M-01 | Tabla «Código del broker», fila `test` (l. 30); cabecera, «las citas `@6a7f2e4` valen para las tres ramas» (l. 5); fila `MQTT_ACK_REQUIERE_ID_COMANDO` (l. 37) | `git diff --stat origin/develop origin/test` muestra diferencias en `app/services/ingest.py` (en `test` la lectura de `mqtt_ack_requiere_id_comando` está en l. **302**, no en l. 312) y en `docker-compose.test.yml`, que **solo existe en `test`** (`git cat-file -e` falla en `develop` y en `main`). La HU comparó `6a7f2e4..develop` y `develop..main`, pero nunca `develop..test`. | Fila `test`: «Igual que `develop` en `config.py`, compose PROD, `.env*.example` y entrypoint; `ingest.py` difiere (l. 302) y `docker-compose.test.yml` solo existe en `test`». En l. 37: «`ingest.py:312` (`develop`/`main`), l. 302 (`test`)». En l. 5: limitar «tres ramas» a los archivos que de verdad son iguales. CA-4 exige `archivo:línea@hash` por rama, así que esto entra en las filas. |
| M-02 | CA-9 (l. 67) y la verificación de ST-05 (l. 172) | La lista cerrada de archivos no incluye `entregas/README.md` ni `entregas/E4_…/README.md`. La DoD (l. 92) exige actualizarlos y el commit `26f5792` de la rama ya los modifica: `git diff --stat origin/main...HEAD` va a mostrar 3 archivos que el CA no admite. | Agregar los dos README a la lista de CA-9 y de ST-05. |
| M-03 | Tabla de verificación: CA-7, CA-8, CA-9 y CA-10 (l. 80–83); CA-4 (l. 77) | Dentro de una tabla Markdown el `\|` se escribe con escape, y el comando cambia según desde dónde se copie. Probado sobre `main` de hoy con el texto **crudo** del `.md`: el `grep -nE '^MQTT_(HOST\|PORT)$'` de CA-10 **no da salida aunque el error sigue ahí** (`MQTT_HOST`/`MQTT_PORT` están en §4 l. 198–199). Es un falso positivo, porque el resultado esperado es «sin salida». En ERE, `\|` es un pipe literal, y lo mismo pasa con el `grep -E` de CA-8 (`API_TOKEN\|…`: «ningún `API_TOKEN`» siempre pasa) y el de CA-9 (el filtro de secretos nunca encuentra nada). Copiado de la vista **renderizada** (GitHub y Taiga muestran el escape como un pipe simple), el primer comando de CA-10 coincide con las 367 líneas, porque el `^|` del inicio pasa a ser una alternancia vacía. Los `grep` BRE de CA-3 y CA-7 pierden la alternancia: en BRE el pipe simple es literal y no encuentran nada. Además, en CA-4 y CA-10 las comillas invertidas escapadas (`` \` ``) cortan el código en línea, y la celda se ve rota. | Dejar en la tabla solo «ver bloque CA-n» y poner los comandos en un bloque de código debajo de la tabla, sin escapes. Para los `grep` usar `-e A -e B` en vez de alternancia, y `[|]` para el pipe literal del inicio de fila: `grep -nE '^[|] .MQTT_(HOST|PORT). [|]' "$F"`. Probarlos una vez contra `main` de hoy: CA-2, CA-3 y CA-10 deben **fallar** antes del cambio. |

### Menores

| ID | Dónde | Evidencia | Corrección propuesta |
|---|---|---|---|
| m-01 | CA-2 y CA-3 frente a CA-6 | CA-6 pide en §8 una entrada con el corte y los pendientes. Lo natural es que esa entrada diga «`MQTT_TLS=true` → `false`» y «se retira `GATEWAY_API_TOKEN`», y entonces los `grep` de CA-2 (ningún `true`) y CA-3 (solo en §6) fallan. | Escribir en CA-2 y CA-3 «salvo la entrada de §8 de esta HU», o fijar que esa entrada no repita los literales. |
| m-02 | ST-04 / CA-7 (alcance D3) | `compose/docker-compose.yml` y `compose.dev.yml:47–75` no pasan `BROKER_SERVICE_TOKEN` al servicio `backend`. Con `BACKEND_URL=http://backend:8000` en dev y test, si alguien llena el token, el gateway reenvía y el backend lo rechaza, porque `broker_auth.py:61` exige la misma variable. La fila del catálogo dice «Gateway AIoT y Backend». | Agregar `BROKER_SERVICE_TOKEN: ${BROKER_SERVICE_TOKEN:-}` al `environment:` del `backend` en el compose local (y sumarlo a CA-7 y CA-8), o dejar escrito en Fuera de alcance que el reenvío local no queda operativo de punta a punta. |
| m-03 | CA-1 (l. 74) | El `diff --stat` de CA-1 cubre `app/config.py`, compose, `.env*.example` y el entrypoint, pero CA-4 también cita `client.py`, `main.py`, `publisher.py`, `ingest.py` y `dependencies.py`. | Usar `-- app 'docker-compose*.yml' '.env*.example' docker` como pathspec. |
| m-04 | ST-02 paso 3 (l. 131) | Ese paso toma las filas del plan §2.2 (l. 124–128). La de `BACKEND_URL` dice «sin ella el reenvío falla en silencio», pero el código registra un error (`client.py:56`) y un aviso al arrancar (`main.py:35`), como dice la propia tabla de la HU (l. 39). | Indicar que se reemplace esa frase por «no reenvía y registra un error». |
| m-05 | ST-02 «Verificación» (l. 135) | ST-02 lista CA-2 completo, pero §4 PROD (`MQTT_TLS=false`) se corrige en ST-03, así que CA-2 falla al cerrar ST-02. | Poner «CA-2 (parte §3)», igual que ya está CA-3. |
| m-06 | CA-4 (l. 62) y ST-02 paso 4 | CA-4 pide «Componente, Tipo y Sensibilidad del vocabulario del catálogo (§1)», pero §1 solo define Tipo y Sensibilidad. ST-02 introduce el componente `Mosquitto`, cuando las filas actuales usan `Gateway / Mosquitto`. Para `MQTT_*_PUERTO_PUBLICO` elige Tipo `Autenticación / Seguridad`, y §1 clasifica los puertos como «Conexión». | Decidir el componente (`Gateway / Mosquitto` o uno nuevo, justificado) y el tipo, y escribirlo igual en CA-4 y en ST-02. |
| m-07 | Cabecera (l. 5) frente a metadatos (l. 217) y Notas 1 (l. 182) | La cabecera dice «`git fetch` del 2026-11-21, 22:30» y cita `b372c82`, que es el merge del PR #24 de las 22:51 (America/Bogota). Los metadatos y la nota 1 siguen diciendo SGMP-Integracion `main a910760`. | Poner la hora real del fetch que vio `b372c82` y llevar ese hash a los metadatos y a la nota 1. |

### Notas

| ID | Dónde | Comentario |
|---|---|---|
| n-01 | Fuera de alcance, CA-6 | HU-IMP-CFG-01 no está en el índice `entregas/README.md`: solo existe como propuesta en `plan.md` §2.3. Conviene escribir «propuesta, por crear». |
| n-02 | CA-7 / CA-9 | `<scratch>` no es un comando que se pueda pegar: proponer `T=$(mktemp -d)`. El filtro de secretos `(TOKEN\|PASSWORD\|SECRET)=` no detecta `SECRET_KEY=valor`. Mejor `'^\+[A-Z0-9_]*(TOKEN\|PASSWORD\|SECRET\|KEY)[A-Z0-9_]*=.+'`, en el bloque de código. |
| n-03 | ST-01 | 1,5 h queda por debajo del mínimo de 2 h de la skill. Se acepta porque hay un solo responsable; también se puede unir con el paso 1 de ST-05 o subirla a 2 h. |
| n-04 | Verificación previa | CA-8 de base, ejecutado hoy sobre `main`: `exit=0` en dev, test y prod con `*_IMAGE` ficticias, y `--no-interpolate` en dev muestra `API_TOKEN=${GATEWAY_API_TOKEN}`. El método funciona. |

## Borrador de retroalimentación (para el autor, que es el propio líder)

> La HU está bien armada. El corte coincide con el fetch de hoy en los siete hashes. Las citas del catálogo, del broker y del backend son correctas, y las nueve decisiones están aplicadas sin contradicciones: 7 filas en CA-4, `BACKEND_URL` local, CA-10, dependencia de cierre, aviso del líder y riesgo de PROD. Los README solo agregan la fila de AMB-11.
>
> Antes de pasarla a Taiga, corregir en este orden:
> 1. **M-03.** Sacar los comandos de la tabla de verificación a bloques de código y quitar la alternancia con `\|`. El segundo comando de CA-10, copiado tal cual, da «sin salida» hoy mismo, con el error todavía en §4. Comprobar que CA-2, CA-3 y CA-10 fallan sobre `main` antes del cambio.
> 2. **M-02.** Agregar los dos README a la lista de CA-9 y de ST-05.
> 3. **M-01.** `test` del broker no es igual a `develop`: `ingest.py` (l. 302) y `docker-compose.test.yml`, que solo existe en `test`. Corregir la fila `test`, la cabecera y la cita de `MQTT_ACK_REQUIERE_ID_COMANDO`.
> 4. Menores m-01 a m-07, sobre todo m-02 (token del backend en el compose local) y m-01 (excepción de §8 en CA-2 y CA-3).
