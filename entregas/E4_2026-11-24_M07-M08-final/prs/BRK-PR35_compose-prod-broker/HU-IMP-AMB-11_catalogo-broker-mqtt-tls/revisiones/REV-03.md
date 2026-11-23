# REV-03 — HU-IMP-AMB-11 (tercera revisión, `/revisar`)

- **Fecha:** 2026-11-23, 08:00 (America/Bogota)
- **Revisado:** rama local `docs/amb-11-ejecucion-catalogo-broker` @ `e71dc30`, sobre `origin/main 9a099e4`. Commits: `78ad93f` (ST-01 a ST-04), `9763e04` (`BACKEND_URL` pública en TEST y PROD), `7bc8ff9` (ST-05, comparación con Dokploy) y `e71dc30` (decisión 9, CA-7 ajustado y evidencias regeneradas).
- **PR:** [#27](https://github.com/Juanher01/SGMP-Integracion/pull/27), `OPEN`, `main` ← `docs/amb-11-ejecucion-catalogo-broker`. En GitHub la cabeza es `78ad93f`: los tres últimos commits **no están pusheados**. La descripción del PR es del 2026-11-22 y no tiene comentarios.
- **Criterio aplicado a CA-7:** el texto nuevo (decisión 9, 2026-11-23): en prod, un placeholder de URL pública en `BACKEND_URL`.
- **Revisiones previas:** REV-01 (2026-11-21) y REV-02 (2026-11-22). Ambas pedían cambios.
- **Evidencia de CA-7 y CA-8:** por regla de esta revisión, el revisor no ejecutó comandos que nombran las plantillas `env/`. Usó la salida que el líder corrió hoy en Git Bash (`scratchpad/ca7_ca8.txt`, la misma que `evidencias/CA-7_CA-8_plantillas.md`) y el `config --no-interpolate`, que el revisor sí repitió.

## Dictamen global: APROBAR CON OBSERVACIONES

Los diez CA cumplen. Ninguno queda PARCIAL ni NO CUMPLE. No hay secretos, IP ni archivos fuera de la lista del CA-9. Tampoco se toca lógica de aplicación, y la rama destino es la correcta (`main`).

Antes de fusionar hay que hacer dos cosas de proceso: pushear `9763e04..e71dc30` y actualizar en la HU y en la descripción del PR el corte del 2026-11-23 y lo que cambió con la decisión 9 (m-01, m-02). Las demás observaciones no bloquean. Conviene resolverlas en este PR, porque tocan archivos que el PR ya modifica.

## Dictamen por criterio

| CA | Veredicto | Evidencia (propia, 2026-11-23) |
|---|---|---|
| CA-1 Corte | **CUMPLE con observación** | `git fetch --prune` de los tres repos (rc 0). Broker sin cambios: `develop 2f8ea54`, `test 662e096`, `main 2181993`, iguales al corte, así que el diff de `app/`, `docker-compose*.yml`, `docker/` y plantillas sale vacío por construcción. SGMP-Integracion `main 9a099e4`, sin cambios. **El backend avanzó:** `dev e0c5c0e4 → 77e0d772` (1.4.4-rc.1), `test c698c656 → 1ee56516` y `main bcc3cd17 → e3b07ae6` (1.4.4). En `dev` y `main`, `git diff --stat` del corte a hoy sale vacío en `Dockerfile`, `docker-compose*.yml`, `.dockerignore` y `src/shared/broker_auth.py`. En `test` cambian `Dockerfile` (crea `/app/storage/modelos`) **y `docker-compose.prod.yml`** (`IOT_AUDITORIA_RESPALDO_PATH` y el volumen `sgpmp_auditoria_iot_prod`). La HU no cita ninguno de los dos cambios. Las citas siguen valiendo en las tres ramas: `broker_auth.py:61`, y `Dockerfile:69` (`EXPOSE 8000`) y `:79` (`--port 8000`). Falta registrar el corte del día en la HU, la evidencia y el PR (m-01). |
| CA-2 `MQTT_TLS` | **CUMPLE** | El primer `awk` de la HU no da salida, y `grep -cx 'MQTT_TLS=false'` en §4 da `3`. La fila l. 122 tiene Componente `Gateway AIoT` y dice «**`false` en DEV, TEST y PROD.**». Remite a la nota «Dos tramos MQTT» y cita `docker-compose.prod.yml:217@2181993`, que el revisor verificó: `${MQTT_TLS:-false}`. |
| CA-3 `GATEWAY_API_TOKEN` | **CUMPLE** | El primer `awk` no da salida. El conteo en §6 da `2` (l. 278 y 281, con el motivo y la cita `.env.prod.example:244–246@2181993`). Fuera de §6 solo aparece en la entrada de §8 de esta HU (l. 368), que el CA admite. |
| CA-4 Filas nuevas | **CUMPLE** | Hay `1` fila para cada una de las 7 variables y `0` para `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT`. `BROKER_SERVICE_TOKEN` es `**Secreta**` (l. 133). Cada fila dice en qué ramas existe. La fila de `BACKEND_URL` (l. 132) incorpora la decisión 9, y su base técnica se verifica en `client.py@2181993`: `httpx.AsyncClient(base_url=settings.backend_url.rstrip("/"))` y `post(ruta)`, que conservan el prefijo de ruta. |
| CA-5 Nota «Dos tramos MQTT» | **CUMPLE** | La nota (l. 138) cubre los dos tramos. Por entorno dice: DEV en claro; TEST en claro, sin `MQTT_PUERTO_PUBLICO`, con incumplimiento de SEG-BROKER-02 y pendiente de HU-IMP-SEG-03; PROD 8883/9002 con `./docker/certs`. También dice que `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT` son `:?` y que su valor lo define Despliegue. El párrafo nuevo «Servidores» no trae valores: el grep de dominios, IP y puertos de host da `0`. |
| CA-6 §8 | **CUMPLE** | La entrada «Actualización 2026-11-22 (HU-IMP-AMB-11; corte …)» (l. 366) trae H-01, D1 (con el criterio resuelto el 2026-11-23 y el pendiente del Dokploy de AIoT), H-01 ampliado, el tramo gateway → PostgreSQL (fuera de alcance), el TLS de TEST y las variables de H-04 que quedaron fuera. El encabezado conserva los hashes del backend del 2026-11-22 (m-01). |
| CA-7 Plantillas (texto de la decisión 9) | **CUMPLE con observación** | Salida del líder (2026-11-23): `PARIDAD`; ningún `GATEWAY_API_TOKEN`; `MQTT_TLS=false` en las tres; `BROKER_SERVICE_TOKEN=` sin nada después en las tres; `BACKEND_URL=http://backend:8000` en dev (l. 102) y test (l. 100); en prod (l. 103), `BACKEND_URL=https://<dominio-publico-del-backend>/<prefijo>`, que es un placeholder con la forma `https://<…>/<…>` y sin valor real. `grep API_TOKEN compose/*.yml` no da salida. El compose base tiene las 6 líneas: l. 89–93 en el gateway y l. 126 en el backend, con los defaults `:-false`, `:-resultado` y `:-10`. Observación: la salida no muestra `MQTT_ACK_REQUIERE_ID_COMANDO`, `MQTT_TOPIC_RESULTADO` ni `BACKEND_TIMEOUT_SECONDS` en las plantillas (m-03). |
| CA-8 Compose local | **CUMPLE** | Salida del líder: `exit=0` en dev, test y prod, también en prod con el placeholder. El revisor repitió el `config --no-interpolate` de los tres entornos, sin `--env-file`. En cada uno hay 0 `API_TOKEN`, las 5 variables en `gateway` y `BROKER_SERVICE_TOKEN` en `backend` (l. 21 en dev y l. 14 en test y prod), igual que la evidencia. |
| CA-9 Archivos y secretos | **CUMPLE** | `git diff --name-only origin/main...HEAD` da 20 archivos, todos en la lista del CA-9: el catálogo, las 3 plantillas, los 4 compose, los 2 README, `CONTRATO-PROD.md`, `CONTRATO-TEST.md`, el runbook, `incidencias/registro.md` y 6 archivos de la carpeta de la HU. La búsqueda de `TOKEN|PASSWORD|SECRET|KEY` con valor en `compose/ registros/ entregas/` solo encuentra referencias `${…:-}` y comentarios; la versión estricta de la HU sobre `compose/` no da salida. En todo el diff no hay IP de servidores ni dominios de los servidores del broker (n-01). Tampoco aparece ninguno de los roles de `DBIntegrador/backup_roles.sql` (n-02). |
| CA-10 `MQTT_HOST`/`MQTT_PORT` | **CUMPLE** | Las filas l. 118 y 119 dicen `mosquitto` y `1883` en los tres entornos, sin «sujeto a configuración TLS». `MQTT_PORT` aclara que no es `MQTT_HOST_PORT`. El segundo comando de la HU sale con rc=1. La cita `docker-compose.prod.yml:203–204@2181993` se verificó: `MQTT_HOST: mosquitto` y `MQTT_PORT: "1883"`. |

**DoD:**
- Hecho: todos los CA tienen evidencia; el registro vivo es el entregable y no hay catálogo paralelo; la segunda revisión está en `revisiones/`.
- Pendiente: el push; la constancia de la reunión con el Líder de Despliegue (m-05); los README (m-04); la aprobación y la fusión.

**Lógica de aplicación:** no se toca. **Rama destino:** `main`, correcta.

## Hallazgos

### Mayores

Ninguno.

### Menores

**m-01. El corte del 2026-11-23 no está registrado y quedan dos cortes mezclados.**
- Hoy el backend está en `dev 77e0d772`, `test 1ee56516` y `main e3b07ae6`.
- La HU (l. 6, 51, Referencias), `evidencias/CA-1_corte.md`, la fila de `BROKER_SERVICE_TOKEN` (catálogo l. 133), el encabezado de §8 (l. 366) y la descripción del PR siguen con `e0c5c0e4`, `c698c656` y `bcc3cd17`.
- `evidencias/ST-05_comparacion-dokploy.md` ya cita `test@1ee56516`.

Las líneas citadas no se movieron, así que no hay error de contenido. Pero CA-1 pide los hashes «reverificados el día del PR», y el PR recibe hoy tres commits.

Corrección:
1. Agregar a `CA-1_corte.md` una sección del 2026-11-23 con la salida de este revisor:
   - broker sin cambios;
   - backend con los hashes nuevos;
   - `dev`/`main` sin diff en `Dockerfile`, compose y `broker_auth.py`;
   - en `test`, `Dockerfile` y `docker-compose.prod.yml` cambiados por el PR #1223 y por INC-M03-125-G12, sin efecto en las citas.
2. Actualizar los hashes en la HU (l. 6), en la fila l. 133 y en el encabezado de §8.

Nota para el líder: la premisa «solo Dockerfile cambió en `test` desde `c698c656`» no es exacta. También cambió `docker-compose.prod.yml` de la rama `test`, aunque no afecta a ninguna cita.

**m-02. La descripción del PR y su cabeza no reflejan lo que se revisa.**
- GitHub muestra `78ad93f` y la descripción del 2026-11-22.
- No menciona la decisión 9 (`BACKEND_URL` pública en TEST y PROD, el placeholder de prod y la fila nueva en `CONTRATO-PROD.md`), ni la comparación de ST-05, ni el pendiente del Dokploy de AIoT.
- «Antes de fusionar» sigue pidiendo una comparación que ya se hizo para el backend.
- La DoD pide que la descripción **enlace** la HU, el PR #35 del broker y `plan.md` §2.2. Hoy solo los nombra en texto.

Corrección: pushear y editar la descripción. Agregar una sección «Cambios del 2026-11-23» con `9763e04`, `7bc8ff9` y `e71dc30`, el corte nuevo (m-01) y los tres enlaces. CA-7 en la descripción debe decir «placeholder de URL pública en prod».

**m-03. La evidencia de CA-7 no muestra 3 de las 5 variables de BRK-10.**
- El `grep -n` de la HU solo busca `GATEWAY_API_TOKEN`, `MQTT_TLS`, `BROKER_SERVICE_TOKEN` y `BACKEND_URL`.
- `PARIDAD` prueba que los tres archivos tienen el mismo conjunto de nombres, pero no que estén `MQTT_ACK_REQUIERE_ID_COMANDO`, `MQTT_TOPIC_RESULTADO` y `BACKEND_TIMEOUT_SECONDS`.
- REV-02 las vio el 2026-11-22, y `9763e04` solo cambia 6 líneas de la plantilla de prod. Por eso es muy probable que sigan allí, pero hoy no hay salida que lo muestre.

Este revisor no ejecutó el comando porque nombra las plantillas. **Comando que debe correr el líder**, desde `SGMP-Integracion`:
```bash
for e in dev test prod; do printf '%s ' $e; grep -cE '^(MQTT_ACK_REQUIERE_ID_COMANDO|MQTT_TOPIC_RESULTADO|BACKEND_TIMEOUT_SECONDS|MQTT_HOST|MQTT_PORT)=' env/.env.$e.example; done
grep -nE '^(MQTT_HOST|MQTT_PORT)=' env/.env.prod.example
```
Resultado esperado: `5` en cada entorno, y en prod `MQTT_HOST=mosquitto` y `MQTT_PORT=1883` (REV-02 m-05, marcado como aplicado y no verificable por este revisor). La salida va en `CA-7_CA-8_plantillas.md`.

**m-04. Los registros vivos no reflejan del todo la decisión 9 ni CA-10** (error recurrente 14).
- La decisión 9 vale para **TEST y PROD**, pero solo `CONTRATO-PROD.md` ganó la fila de `BACKEND_URL` (l. 93). `CONTRATO-TEST.md` no la tiene.
- En el mismo `CONTRATO-PROD.md` §5.2, la fila siguiente (l. 94) sigue pidiendo `MQTT_HOST` y `MQTT_PORT` como configuración externa que carga «Despliegue / AIoT». Eso contradice CA-10: el compose PROD del broker los fija y el catálogo ya no los trata como externos.
- La misma tabla tampoco lista `BROKER_SERVICE_TOKEN`, secreta y obligatoria (`:?`) en el gateway de PROD.
- `CONTRATO-TEST.md:53` sigue justificando `MQTT_TLS=false` con «TLS obligatorio solo en PROD». REV-02 M-01 ya lo había señalado: la frase confunde el TLS de los dispositivos con el del gateway.
- `CONTRATO-PROD.md` l. 31 y 67 (red `sgpmp-network`, `DB_HOST` `database`) describen el stack local y ahora conviven con la afirmación de l. 93 de que el broker está en otro servidor.

Corrección mínima:
- En `CONTRATO-PROD.md`, quitar `MQTT_HOST`/`MQTT_PORT` de §5.2, con remisión al catálogo, y agregar `BROKER_SERVICE_TOKEN` (mismo valor que el backend).
- En `CONTRATO-TEST.md`, agregar la fila de `BACKEND_URL` y cambiar l. 53 por la remisión a la nota «Dos tramos MQTT».
- Lo de la red y `DB_HOST` es de HU-IMP-CFG-05 (#5478): basta dejarlo nombrado en ese pendiente.

**m-05. La constancia de la reunión con Despliegue (DoD y ST-05 paso 5) no está escrita como tal.**
- La HU dice que Despliegue compartió la lista de Dokploy del backend el 2026-11-23, pero no dice si eso fue la reunión con el Líder de Despliegue, ni con qué resultado («sin cambios» o qué cambió).
- Las filas de AMB-11 en `entregas/README.md:63` y `E4/README.md:12` siguen con el estado del 2026-11-22 («PR de la ejecución abierto hasta comparar con Dokploy»).

Corrección:
- Una línea en el Estado de la HU: «Reunión con el Líder de Despliegue: aaaa-mm-dd; resultado: decisión 9; pendiente del Dokploy de AIoT».
- Actualizar las dos filas: «comparación con Dokploy del backend hecha (2026-11-23); pendiente gateway (AIoT), no bloquea».

### Notas

- **n-01.** La evidencia de CA-5 (`CA-2_a_CA-6_CA-10_catalogo.md`, «Regenerado el 2026-11-23») citaba el patrón de búsqueda con fragmentos de dominios. No era un valor, pero por decisión del líder (2026-11-23) se reescribió sin ellos: ningún fragmento de IP ni de dominio de servidores en el repositorio, ni siquiera como patrón.
- **n-02.** Para «nombre del rol de base de datos», el revisor buscó en el diff los roles de `DBIntegrador/backup_roles.sql`, listando solo los nombres (`dba`, `postgres`, `role_dba`, `grp_*`, `member_*`). No hay coincidencias añadidas. Si el rol que preocupa es otro (p. ej. el `POSTGRES_USER` de Dokploy que menciona ST-05 l. 208), este revisor no lo conoce ni debe buscarlo. El líder puede correr `git diff origin/main...HEAD | grep -c '<rol>'` y esperar `0`.
- **n-03.** `ST-05_comparacion-dokploy.md` dice en la cabecera «nunca valores», pero pega valores no sensibles de Dokploy: `ALLOWED_ORIGINS=https://inmero.co`, `MODELOS_STORAGE_PATH` = `/tmp` y dominios de TEST, DEV y PROD en «Hallazgos fuera de alcance». No son secretos y el catálogo admite valores no sensibles, pero la frase y el contenido se contradicen (error recurrente 13). Corrección: «nunca valores sensibles».
- **n-04.** Hallazgos de ST-05 que conviene llevar a su dueño, porque no son de esta HU:
  - `ALLOWED_ORIGINS=https://api.inmero.co` en el frontend de TEST, cuando la regla es el origen del frontend (`https://inmero.co`).
  - El dominio del motor de TEST mal escrito.
  - La tabla de dominios de `PI4/CLAUDE.md` desactualizada para el frontend de TEST.
- **n-05.** La fila de `BACKEND_URL` (l. 132) y §8 dicen «en DEV local (`compose/`), `http://backend:8000`», pero la plantilla local de **test** también lo usa (decisión 9: «DEV y TEST locales»). Además, no dice nada de DEV **desplegado**, cuyo gateway sigue «por confirmar». Sugerencia: «En los stacks locales de DEV y TEST (`compose/`), `http://backend:8000`; DEV desplegado, por confirmar con AIoT».
- **n-06.** «Sin `/` final» es buena práctica, pero el código tolera la barra: `client.py:45` hace `rstrip("/")`. Si se quiere precisión, puede quedar como «sin `/` final (el cliente la recorta)». No cambia el dictamen.
- **n-07.** En el stack local de PROD (`compose/compose.prod.yml` sobre el compose base), gateway y backend comparten red. Con el placeholder copiado tal cual, el gateway intentará reenviar a un host inexistente y registrará un error; antes, con la variable vacía, no reenviaba. Es coherente con la decisión 9, porque la plantilla de prod modela el entorno desplegado. Conviene que el comentario de l. 100–102 diga que, para probar en local, se use `http://backend:8000`.

## Respuesta a las preguntas del líder

- **¿Avanzó alguna rama?** El broker y SGMP-Integracion `main`, no. El backend, sí, en las tres ramas (m-01). En los archivos citados no cambia nada: `broker_auth.py:61`, `Dockerfile:69,79` y los compose de `dev`/`main`. En `test` cambian `Dockerfile` y `docker-compose.prod.yml`, ninguno citado.
- **Descripción del PR desactualizada:** sí (m-02). No se editó.
- **Comandos bloqueados por hooks:** ninguno.

## Resolución del líder (2026-11-23)

- **m-01** aplicado: corte del 2026-11-23 en `historia.md`, `evidencias/CA-1_corte.md`, la fila de `BROKER_SERVICE_TOKEN` y el encabezado de §8 del catálogo.
- **m-02** se aplica después del push: descripción del PR #27 nueva, aprobada por el líder y publicada con `gh pr edit` (decisión 9, ST-05, enlaces de la DoD; pendiente del gateway en la primera línea).
- **m-03** aplicado: salida ejecutada por el líder en Git Bash (`dev 5`, `test 5`, `prod 5`; en prod `MQTT_HOST=mosquitto` y `MQTT_PORT=1883`), pegada en `evidencias/CA-7_CA-8_plantillas.md`. CA-7 queda sin observación.
- **m-04** aplicado en parte: `CONTRATO-PROD.md` §5.2 con `MQTT_HOST`/`MQTT_PORT` como fijas del compose (no las carga Despliegue) y con `BROKER_SERVICE_TOKEN` (Secreta, sin valor); `CONTRATO-TEST.md` §4.1 con una fila de `BACKEND_URL` (local `http://backend:8000`; en TEST desplegado, URL pública, decisión 9). **Pendiente:** `CONTRATO-TEST.md:53` («TLS obligatorio solo en PROD») no se toca en esta HU; se resuelve con HU-IMP-SEG-03 (SEG-BROKER-02).
- **m-05** aplicado: no hubo reunión con el Líder de Despliegue; la constancia es la lista de variables de Dokploy que compartió Despliegue el 2026-11-23, no versionada porque contenía valores. README actualizados al 2026-11-23.
- **n-03** aplicado: la cabecera de ST-05 distingue la columna (solo «con valor / vacía / no cargada») del resto del archivo (nunca valores sensibles).
- **n-07** no se aplica: queda como nota. La plantilla de prod modela el entorno desplegado; para probar en local se usa `http://backend:8000`.
- **n-01** aplicado: sin fragmentos de IP ni de dominios como patrón de búsqueda en el repositorio.
- n-02 (el rol de Dokploy da `0` en el diff de la rama, comprobado el 2026-11-23), n-04 (hallazgos para sus dueños, ya en ST-05), n-05 y n-06: sin cambios.

## Borrador de comentario para el PR (lo publica el líder, después del push)

> **Tercera revisión (REV-03) — HU-IMP-AMB-11** · rama `docs/amb-11-ejecucion-catalogo-broker` @ `e71dc30`
>
> **Dictamen: aprobar con observaciones.** CA-1 a CA-10 cumplen; CA-1 y CA-7 tienen observaciones. Sin secretos, sin IP y sin archivos fuera del CA-9. El catálogo ya refleja el código del broker (`2f8ea54`, `662e096`, `2181993`, sin cambios hoy) y la decisión 9: `BACKEND_URL` del gateway = URL pública del backend en TEST y PROD, porque el broker corre en otro servidor. La base técnica se verificó en `app/backend/client.py:45@2181993` (`base_url` conserva el prefijo).
>
> Antes de fusionar:
> 1. **Corte del 2026-11-23** (m-01). El backend avanzó a `dev 77e0d772`, `test 1ee56516` y `main e3b07ae6`; `broker_auth.py:61` y `Dockerfile:69,79` no se movieron. Hay que actualizar `CA-1_corte.md`, la HU (l. 6), la fila de `BROKER_SERVICE_TOKEN` y el encabezado de §8.
> 2. **Esta descripción** (m-02): agregar los commits `9763e04`, `7bc8ff9` y `e71dc30`, el texto nuevo de CA-7 (placeholder en prod) y los enlaces a la HU, al PR #35 del broker y a `plan.md` §2.2.
> 3. **Evidencia de CA-7** (m-03): pegar el conteo de `MQTT_ACK_REQUIERE_ID_COMANDO`, `MQTT_TOPIC_RESULTADO` y `BACKEND_TIMEOUT_SECONDS` (y `MQTT_HOST`/`MQTT_PORT` en prod) en las tres plantillas.
>
> Recomendado en este mismo PR:
> 4. **Contratos** (m-04): `CONTRATO-PROD.md` §5.2 sin `MQTT_HOST`/`MQTT_PORT` como externas y con `BROKER_SERVICE_TOKEN`; `CONTRATO-TEST.md` con `BACKEND_URL` (URL pública) y l. 53 remitiendo a la nota «Dos tramos MQTT».
> 5. **Constancia de la reunión con Despliegue y README** (m-05).
>
> Pendiente registrado y no bloqueante: la lista de variables del gateway y de Mosquitto en el Dokploy de AIoT (§8 del catálogo).
