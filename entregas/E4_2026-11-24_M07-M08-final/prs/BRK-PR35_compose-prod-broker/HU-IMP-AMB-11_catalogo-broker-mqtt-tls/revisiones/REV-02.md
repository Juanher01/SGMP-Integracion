# REV-02 — HU-IMP-AMB-11 (ejecución ST-01 a ST-04, antes del commit)

- **Fecha:** 2026-11-22, 12:18 (America/Bogota).
- **Revisado:** rama local `docs/amb-11-ejecucion-catalogo-broker` de SGMP-Integracion, sobre `origin/main 9a099e4`. Son cambios sin commit: 9 archivos modificados (`git diff --stat`: +88/−44) y 3 evidencias sin seguimiento en `evidencias/`. Todavía no hay PR.
- **Tipo:** segunda revisión de la ejecución. Responsable y revisor son la misma persona (Sebastián Sandoval).
- **Corte propio:** `git fetch --prune` del 2026-11-22, 12:18, en los tres repos.
  - Broker: `develop 2f8ea54` · `test 662e096` · `main 2181993`. Coinciden con la HU.
  - Backend: `dev e0c5c0e4` (1.4.0-rc.89, PR #1228) · `test c698c656` · `main bcc3cd17` (release 1.4.3, PR #1227). **Avanzó** desde el corte de la ejecución (`c54dc754`, `3a8cfcb7`). `src/shared/broker_auth.py:61` sigue igual en los cinco hashes.
  - SGMP-Integracion: `main 9a099e4`.

## Dictamen global: SOLICITAR CAMBIOS (de trazabilidad y coherencia; el contenido técnico es correcto)

Lo que llega a Despliegue está bien. El catálogo §3–§6 y §8, las plantillas `env/` y el compose local reflejan el código del broker en las tres ramas. Todas las citas `archivo:línea@hash` que comprobé coinciden. CA-2 a CA-8 y CA-10 se reproducen con los comandos exactos de la HU, y fallan sobre `main` como deben. No hay secretos.

Antes del commit y del PR hay que corregir tres cosas:

1. La evidencia de CA-1 se contradice con la HU y con su propia salida (M-02). Además, el backend volvió a avanzar.
2. Hay registros vivos del repo que siguen diciendo `MQTT_TLS=true` y `GATEWAY_API_TOKEN`, y quedarían contradiciendo al catálogo (M-01).
3. La HU declara cumplidos CA que todavía no se pueden verificar (m-01), y el nombre de la rama no coincide (m-02).

## Dictamen por criterio

| CA | Veredicto | Evidencia (propia, 2026-11-22) |
|---|---|---|
| CA-1 Corte | **NO CUMPLE** (por ahora) | Broker igual que la HU: diff de `app/`, `docker-compose*.yml`, `.env*.example` y `docker/` vacío entre `2f8ea54` y `origin/main`. El backend avanzó a `dev e0c5c0e4` y `main bcc3cd17`, aunque `broker_auth.py:61` sigue en la misma línea. `CA-1_corte.md` dice `origin/main 468b051` (PR #25), mientras la HU y la rama están en `9a099e4`. También afirma que el release 1.4.2 «no toca Dockerfile», y su propia salida muestra `Dockerfile | 9 +++++++--` (M-02). Además, CA-1 exige el corte en la descripción del PR, que todavía no existe. |
| CA-2 `MQTT_TLS` | **CUMPLE** | El primer `awk` no da salida (sobre `main` da l. 123 y 185). `grep -cx 'MQTT_TLS=false'` en §4 da `3` (`2` en `main`). La fila tiene Componente `Gateway AIoT`, dice «`false` en DEV, TEST y PROD» y remite a la nota. |
| CA-3 `GATEWAY_API_TOKEN` | **CUMPLE** | El primer `awk` no da salida (sobre `main` da l. 118, 213 y 219). El conteo en §6 da `2`. El motivo cita `.env.prod.example:244–246@2181993`, que verifiqué: es el comentario «ESE DISENO QUEDO SUPERADO». §5 ya no tiene `API_TOKEN`. |
| CA-4 Filas nuevas | **CUMPLE** | El conteo da `1` en las 7 filas y `0` en `MQTT_HOST_PORT` y `MQTT_WS_HOST_PORT`. `BROKER_SERVICE_TOKEN` está como `**Secreta**`. Comprobé en `origin/main 2181993` `config.py:27,48,65,77,78,79`, `client.py:41–56`, `main.py:35`, `publisher.py:30` e `ingest.py:312`; en `test` es l. 302. En `docker-compose.prod.yml`, l. 68–69, 92–93, 203–204, 217, 232, 234 y 246–248. También `docker-compose.yml:20–21@2f8ea54` y `mosquitto-entrypoint.sh:88–94`. Tipo y Sensibilidad salen del vocabulario de §1. Las filas dicen en qué ramas existe cada variable. La tabla de citas está dentro de `CA-2_a_CA-6_CA-10_catalogo.md` y no en el `CA-4_filas.md` que pide la tabla de Verificación (n-01). |
| CA-5 Nota «Dos tramos MQTT» | **CUMPLE** con observación | La nota cubre los dos tramos. Por entorno dice: DEV en claro; TEST en claro, sin `MQTT_PUERTO_PUBLICO`, incumple SEG-BROKER-02 y queda pendiente de HU-IMP-SEG-03; PROD 8883/9002 con `./docker/certs` (`docker-compose.prod.yml:99`). Dice que PROD exige `MQTT_HOST_PORT`/`MQTT_WS_HOST_PORT` con `:?` y que su valor lo define Despliegue. No trae puertos de host ni dominios: 8883/9002 son puertos de contenedor, que el CA exige. No da por hecho el TLS de TEST. Observación: nombra la red `broker-interna` como si fuera de los tres entornos, y solo existe en PROD (m-03). |
| CA-6 §8 | **CUMPLE** | La entrada «Actualización 2026-11-22 (HU-IMP-AMB-11; corte …)» trae H-01, D1, TLS de TEST y las variables de H-04 que quedaron fuera. Los hashes del backend del corte habrá que actualizarlos (M-02). |
| CA-7 Plantillas | **CUMPLE** | `PARIDAD`. No queda `GATEWAY_API_TOKEN`. `MQTT_TLS=false` en las tres. `BROKER_SERVICE_TOKEN=` sin nada después en las tres. `BACKEND_URL=http://backend:8000` en dev y test, y `BACKEND_URL=` en prod. `grep API_TOKEN compose/*.yml` sale con rc=1. El compose base tiene las 6 líneas: l. 89–93 en el gateway y l. 126 en el backend. |
| CA-8 Compose local | **CUMPLE** | Con imágenes ficticias, `config --quiet` da `exit=0` en dev, test y prod (Docker Compose 5.7.0). En los tres entornos, `config --no-interpolate` muestra las 5 variables en el gateway y `BROKER_SERVICE_TOKEN` en `backend`, y ningún `API_TOKEN`. Ningún servicio usa `env_file`, así que el `--no-interpolate` no vuelca valores. |
| CA-9 Archivos y secretos | **NO VERIFICABLE AÚN** | No hay commit ni PR. Hoy el `git status` toca solo archivos permitidos. Ninguna variable `*TOKEN*\|*PASSWORD*\|*SECRET*\|*KEY*` de las tres plantillas tiene valor. Los README no cambiaron: la DoD sí exige actualizar la fila de AMB-11 (m-04). |
| CA-10 `MQTT_HOST`/`MQTT_PORT` | **CUMPLE** con observación | Las dos filas dicen `mosquitto`/`1883` en los tres entornos, sin «sujeto a configuración TLS». El segundo comando de la HU sale con rc=1 (en `main` da `MQTT_HOST` y `MQTT_PORT`). La evidencia usa comandos distintos a los de la HU (n-02). Observación: la plantilla de prod sigue con `MQTT_HOST=` y `MQTT_PORT=` vacíos, y §4 PROD ya no las nombra en ningún lado (m-05). |

**DoD:** la mayoría de los puntos son posteriores (PR, reunión con Despliegue, fusión). Lo que se puede revisar hoy: el registro vivo es el entregable y está actualizado; no hay catálogo paralelo. Faltan los README (m-04).

**Lógica de aplicación:** no se toca. **Rama destino:** `main` (cuando se abra el PR).

## Hallazgos

### Mayores

**M-01. Hay registros vivos que contradicen el catálogo corregido, y la ejecución no los registra.**
- `registros/entornos/CONTRATO-PROD.md`:
  - l. 52, 75 y 115 dicen `MQTT_TLS=true` («TLS Obligatorio», «✅ Entregado»).
  - l. 54 y 93 piden `GATEWAY_API_TOKEN`.
- `registros/entornos/CONTRATO-TEST.md`:
  - l. 91, 96, 135 y 151 piden `GATEWAY_API_TOKEN`.
  - l. 53 dice «TLS obligatorio solo en PROD», refiriéndose a `MQTT_TLS`.
- `runbooks/RUNBOOK-LEVANTAMIENTO-VALIDACION-SGPMP.md`: l. 465 pide llenar `GATEWAY_API_TOKEN=<valor local seguro>`, y l. 915, 978 y 1046 también lo nombran.
- `registros/incidencias/registro.md`: INC-IMP-05 (l. 35 y 62) es justo el `API_TOKEN` del compose local que esta HU retira, y sigue en «detectado».

Por qué importa: el objetivo de la HU es que Despliegue no cargue `MQTT_TLS=true` ni `GATEWAY_API_TOKEN`, y `CONTRATO-PROD.md` es el contrato de frontera con Despliegue. CA-9 no deja tocar esos archivos en este PR, así que no es un incumplimiento de la ejecución: es un hueco del alcance. Pero si se fusiona sin dejarlo escrito, el repo queda con dos fuentes que se contradicen.

Corrección propuesta (decide el líder):
- (a) Mínimo, dentro de CA-9: en la entrada de §8 de esta HU, agregar un pendiente que nombre `CONTRATO-PROD.md` (l. 52, 54, 75, 93, 115), `CONTRATO-TEST.md`, el runbook (l. 465) e INC-IMP-05 como desactualizados por esta corrección, con la HU de seguimiento o «sin HU».
- (b) Preferible para `CONTRATO-PROD.md` e INC-IMP-05: ampliar CA-9 en la HU para incluirlos (y el texto del CA, no solo una nota; ver el error recurrente 4). Así se corrigen en el mismo PR: `MQTT_TLS=false` con remisión al catálogo, retirar `GATEWAY_API_TOKEN` y pasar INC-IMP-05 a «resuelto (HU-IMP-AMB-11)».

**M-02. La evidencia de CA-1 se contradice, y el corte del backend ya quedó viejo.**
- `evidencias/CA-1_corte.md` dice que la rama se creó desde `origin/main 468b051` y que SGMP-Integracion `main` es `468b051`. La HU (l. 3, 6 y 293) y la rama real están en `9a099e4` (PR #26 fusionado después del #25). Hoy `git diff --stat 468b051 9a099e4` sale vacío en catálogo, `env/` y `compose/`, así que las líneas siguen valiendo, pero la evidencia tiene que mostrar el hash real.
- La misma evidencia y la HU (l. 6) afirman que el release 1.4.2 «no toca Dockerfile, compose ni plantillas». La salida que se pega justo debajo es `Dockerfile | 9 +++++++--`. El cambio crea `/app/storage/modelos` y mueve `EXPOSE 8000` y `--port 8000` de l. 64,74 a **l. 69,79** (verificado en `origin/dev` y `origin/main`). La HU sigue citando `Dockerfile:64,74` en Situación actual (l. 34) y en Metadatos (l. 292).
- El backend avanzó otra vez: `dev e0c5c0e4` y `main bcc3cd17` (release 1.4.3). Ninguno toca `broker_auth.py`, compose ni plantillas (`git diff --stat` vacío).

Corrección: repetir CA-1 el día del PR (ST-05 paso 1) con el `main` real. Reemplazar «no toca Dockerfile» por «toca Dockerfile (crea `/app/storage/modelos`; el puerto 8000 pasa a l. 69,79); no toca compose ni plantillas». Actualizar `Dockerfile:64,74` → `:69,79@<hash>` en la HU. Poner los hashes nuevos del backend en la HU (l. 6, 51, Referencias, Metadatos) y en la fila de `BROKER_SERVICE_TOKEN` y la entrada de §8 del catálogo.

### Menores

**m-01. La HU da por cumplidos CA que todavía no se pueden verificar.** Metadatos l. 293: «CA-1 a CA-10 cumplidos en local». CA-1 exige el corte en la descripción del PR, y CA-9 se mide sobre `git diff origin/main...HEAD` del PR. Corrección: «CA-2 a CA-8 y CA-10 cumplidos en local; CA-1 y CA-9 se cierran con el PR».

**m-02. El nombre de la rama no coincide.** La cabecera de Taiga (l. 22), ST-01 paso 1 y ST-05 paso 3 (`git push -u origin docs/hu-imp-amb-11-catalogo-broker`) usan la rama de la redacción, que ya se fusionó con el PR #25. La ejecución va en `docs/amb-11-ejecucion-catalogo-broker`. Corrección: actualizar el campo **Rama** y el comando de ST-05, o dejar escrita la desviación en el Estado. Si no, el `git push` de ST-05 empuja a una rama equivocada.

**m-03. La nota «Dos tramos MQTT» atribuye la red `broker-interna` a los tres entornos.** Esa red solo existe en `docker-compose.prod.yml@2181993` (l. 327). DEV (`docker-compose.yml`) y TEST (`docker-compose.test.yml`) usan la red por defecto del proyecto. Corrección: «por la red interna del stack (`broker-interna` en PROD; red por defecto del compose en DEV y TEST)».

**m-04. Los README (DoD).** Pregunta del líder: sí, la HU exige tocarlos. CA-9 los permite y la DoD («Fila de AMB-11 actualizada en `entregas/README.md` y en el README de E4») los exige. Hoy dicen «por crear / Lista para Taiga» (`entregas/README.md:63`, `E4/README.md:12`), y eso ya es falso. Corrección: en este mismo PR, cambiar el estado a «en ejecución (PR #n abierto; se fusiona después de la reunión con Despliegue)» en las dos filas, y a «terminada» al fusionar.

**m-05. `MQTT_HOST`/`MQTT_PORT` de PROD quedan sin valor en ningún sitio.** El catálogo ahora dice «`mosquitto`/`1883` en DEV, TEST y PROD». El bloque §4 PROD no las incluye, y ya no están en la lista de configuración externa. `env/.env.prod.example:78–79` sigue con `MQTT_HOST=` y `MQTT_PORT=` vacíos. Con esa plantilla, el gateway local de prod recibe `MQTT_HOST` vacío (`compose/docker-compose.yml`, `MQTT_HOST: ${MQTT_HOST}`). Ningún CA lo cubre, pero ST-03 busca que «el resto del catálogo no contradiga la nueva §3». Corrección: agregar `MQTT_HOST=mosquitto` y `MQTT_PORT=1883` al bloque §4 PROD y a `env/.env.prod.example` (la paridad de nombres no cambia). La otra opción es dejar escrita la razón para mantenerlas vacías. Como dato: los compose del broker de DEV (`docker-compose.yml:77,83`) y TEST (`docker-compose.test.yml:43,46`) también las fijan, no solo PROD. Las filas podrían decir «los tres compose del broker las fijan».

### Notas

- **n-01.** La tabla de Verificación pide `evidencias/CA-4_filas.md`, y la tabla de citas está dentro de `CA-2_a_CA-6_CA-10_catalogo.md`. Es aceptable (la DoD permite «un `.md` por CA o uno por HU»). Para que coincida: renombrar o ajustar la columna de la HU.
- **n-02.** Las evidencias de CA-5 y CA-10 usan comandos distintos a los del bloque de la HU. CA-10 usa `grep` BRE con `\|` y otro `awk`, justo el patrón del error recurrente 6 (aquí da el resultado correcto). Reejecuté los comandos exactos de la HU y salen igual. Conviene pegar la salida del comando de la HU, tal cual.
- **n-03.** `app/api/dependencies.py:18–31` (§6 y HU): la función termina en l. 32 (`raise HTTPException`). Cambiar a `18–32`. No afecta al sentido.
- **n-04.** Varias citas por fila llevan `@hash` solo en la primera mención (p. ej. `docker-compose.prod.yml:232` sin hash). Se entiende por contexto. Si se quiere la regla estricta de CA-4, poner `@2181993` en cada cita de compose.
- **n-05.** Los comentarios nuevos de plantillas y compose van sin tildes («reenvio», «catalogo», «envia»), mientras el catálogo sí las usa. Es cosmético.
- **n-06.** `registros/entornos/corte-2026-10-13.md:102` (`MQTT_TLS=false`) y `registro-SEG.md:79` son coherentes con lo nuevo; no requieren cambio.

## Borrador de comentario para el PR (cuando se abra)

> **Segunda revisión (REV-02) — HU-IMP-AMB-11**
>
> El catálogo y las plantillas quedaron bien. `MQTT_TLS` está en `false` en los tres entornos. `GATEWAY_API_TOKEN` pasó a §6 con su motivo. Las 7 filas nuevas tienen citas que verifiqué una por una contra `develop@2f8ea54`, `test@662e096` y `main@2181993`. La nota «Dos tramos MQTT» no da por hecho el TLS de TEST. `BROKER_SERVICE_TOKEN` llega al gateway y al backend del compose local. CA-2 a CA-8 y CA-10 se reproducen con los comandos de la HU, y fallan sobre `main` como deben.
>
> Antes de fusionar:
> 1. **CA-1:** rehacer `evidencias/CA-1_corte.md` con el `main` real (`9a099e4`, no `468b051`) y el backend del día (al 2026-11-22, 12:18: `dev e0c5c0e4`, `main bcc3cd17`). Corregir «no toca Dockerfile»: el release mueve `EXPOSE 8000` a l. 69 y `--port 8000` a l. 79. Actualizar `Dockerfile:64,74` en la HU y los hashes del backend en el catálogo (§3 `BROKER_SERVICE_TOKEN` y §8).
> 2. **Registros que contradicen el catálogo:** `registros/entornos/CONTRATO-PROD.md` (l. 52, 54, 75, 93, 115), `CONTRATO-TEST.md`, `runbooks/RUNBOOK-LEVANTAMIENTO-VALIDACION-SGPMP.md:465` e INC-IMP-05. O se corrigen aquí, ampliando CA-9, o se dejan como pendiente en §8.
> 3. **README:** actualizar la fila de AMB-11 en `entregas/README.md` y en el README de E4 (lo exige la DoD).
> 4. Menores: rama `docs/amb-11-ejecucion-catalogo-broker` en la HU y en ST-05; «CA-1 a CA-10 cumplidos» → solo los locales; red `broker-interna` solo en PROD; `MQTT_HOST`/`MQTT_PORT` de PROD en §4 y en `env/.env.prod.example`.
>
> Verificación: los comandos del bloque de Verificación de la HU, en Git Bash con `MSYS_NO_PATHCONV=1`, más `git diff --stat origin/main...HEAD` para CA-9.

## Comandos ejecutados (resumen)

- `git -C <repo> fetch --prune -q origin` en broker, backend y SGMP-Integracion; `git log -1` por rama.
- Backend: `git show <hash>:src/shared/broker_auth.py` en `c54dc754`, `e0c5c0e4`, `c698c656`, `3a8cfcb7` y `bcc3cd17`. `git diff 9655f389 3a8cfcb7 -- Dockerfile`. `git diff --stat` de `c54dc754..e0c5c0e4` y `3a8cfcb7..bcc3cd17` en Dockerfile, compose, plantillas y `broker_auth.py` (vacío).
- Broker: `git show origin/main:<archivo> | sed -n` en cada cita, `ingest.py` en `test`, redes y montaje de certificados en los tres compose, y `git diff --stat 2f8ea54 origin/main` en configuración (vacío).
- Bloque de Verificación de la HU, CA-2 a CA-8 y CA-10, sobre la rama y (CA-2, CA-3, CA-10) sobre `origin/main` para confirmar que fallan.
- Grep en `registros/`, `compose/`, `env/*.example`, `runbooks/`, `scripts/`, `dockerfiles/` y `decisiones/` buscando `MQTT_TLS|API_TOKEN`. No se abrieron `.env` reales.
