# REV-02 — Documento de Ambiente de Trabajo de Implementación v1.5 (segunda entrega)

> Estado: dictamen emitido · Fecha: 2026-10-13 · Revisa: Líder de Implementación (con el agente `revisor`) · Autor del trabajo: Juan Hernando Perdomo Mosquera

**Objeto revisado:**
- `entregables/ambiente_de_trabajo_implementacion_v1_5.docx` (13 secciones, 1 imagen incrustada, última modificación por Juan Hernando Perdomo Mosquera).
- `entregables/registro_incidencias_borrador.md` (17 salvedades `SAL-IMP-01…17`, IDs provisionales).

**Sin PR:** no existe la rama `docs/ambiente-trabajo-v1.5` en `origin` y los dos entregables están sin versionar (`git status`: `?? historias/HU-IMP-DOC-01_documento-ambiente-trabajo/entregables/`). Se revisan los archivos locales.

**Contrastado con** (`git fetch` del 2026-10-13):

| Repo | Rama → commit |
|---|---|
| sgpmp-backend | `dev` → `bd8b6d4f` · `test` → `81487428` · `main` → `8a7e6327` |
| SGPMP-FRONT-END-PWA | `dev` → `9e5af40` · `test` → `95fa674` · `main` → `2132c62` |
| BROKER-MQTT-SGPMP | `develop` → `44e29b6` · `test` → `7cbdb3f` · `main` → `cebd430` |
| SGMP-Integracion | `main` → `b1ee7ee` (`decisiones/ADR-001…`, `registros/incidencias/registro.md`, `compose/`) |
| Mapa AMB-09 | `historias/HU-IMP-AMB-09_mapa-puertos-protocolos/entregables/imp_diag_despliegue_puertos_protocolos_v1.5.drawio` y `.png` |

Cuando una afirmación del documento ya era falsa en la fecha de corte que declara (2026-10-12), se indica el commit y la hora en que cambió el código.

## Dictamen global: SOLICITAR CAMBIOS

La v1.5 avanzó mucho. El rol vigente está bien descrito, los autores están unificados, las cabeceras ya se atribuyen al nginx del frontend y C2–C7 están corregidos. Hay trazabilidad, control de cambios y no aparece ningún secreto. Aun así, no se puede aprobar por tres motivos:

1. **El código contradice afirmaciones centrales** sobre PROD: la base de datos de PROD **sí publica** el puerto 5449, el frontend **no tiene** `docker-compose.prod.yml` en `main`, y las cabeceras de SEG-FE-02, la ACL y el soporte TLS del broker **ya están** en `main`.
2. **Los flujos del Camino B no son los de ADR-001**, y la §2.2 atribuye al líder de Implementación la aprobación de PR que corresponde a otros líderes.
3. **Falta el proceso exigido por la HU:** no hay fuente Markdown, el Word se editó a mano, no hay rama ni PR, y el registro de incidencias no se actualizó (solo existe un borrador).

## A. Criterios de aceptación

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-1 Los 10 puntos de REV-01 A corregidos; cada afirmación cita rama y archivo o fuente con fecha | **NO CUMPLE** | 7 de 10 corregidos (ver §B). C1, C8 y C9 siguen en contradicción con el código. Casi ninguna afirmación técnica cita rama y archivo: solo `ce0a3a4` y "REV-01" de forma genérica. Hay contradicciones nuevas (N-01 a N-04) |
| CA-2 Secciones 1, 2, 4–8 y 11.3 con el rol vigente | **PARCIAL** | §1, §2.1, §2.3, §2.4, §4, §6, §8 y §11.3 bien. §2.2 dice que el líder de Implementación "aprueba todo Pull Request de Implementación", lo que contradice `CLAUDE.md` (dev → Líder de Desarrollo, test → Líder de Pruebas, main → Líder de Despliegue) y la propia §5, paso 4 (N-06). La §5 no usa los tres flujos de ADR-001 (N-05). La §3.5 conserva "E3 y E5" |
| CA-3 Dominios y puertos como información recibida de Despliegue, con fuente y fecha | **PARCIAL** | La §3.8 lo cumple ("Fuente: … recibida de Despliegue (corte 2026-10-12)"). Pero el puerto MQTT de PROD se atribuye a AIoT en §3.4 (`MQTT_HOST_PORT`, `MQTT_HOST / MQTT_PORT`: "Por asignar con AIoT"), en §3.8 (tabla de Mosquitto) y en el Diagrama 3, y a "Despliegue y AIoT" en §8.2 |
| CA-4 Tabla de trazabilidad E1→E7, DOC-01…04 y FR-IMP-CE-04 con justificación | **PARCIAL** | La §12 cubre todos los elementos y justifica cada fila. Pero lleva a los "Flujo 1/2/3" inventados en la §5, no a los de ADR-001, y se presenta como "propuesta que el líder debe validar". ADR-001 está en el repositorio y la tabla debe alinearse con él |
| CA-5 Salvedades migradas a `registros/incidencias/registro.md`; el documento conserva el resumen con enlaces | **NO CUMPLE** | `registro.md` sin cambios (último commit `935ad6d`; contiene solo INC-FE-01, INC-FE-02 e INC-BE-01). Hay un borrador aparte con otro formato de columnas, IDs provisionales y duplicados (SAL-IMP-06 = INC-BE-01; SAL-IMP-14 = INC-FE-01). El borrador tiene 17 filas y la §11.4 tiene 16 (falta SAL-IMP-17) (N-08) |
| CA-6 Puertos y flujos coinciden con el mapa v1.5 (AMB-09) | **NO CUMPLE** | 5 incoherencias (§D) |
| CA-7 Fuente `entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`, Word con `md2docx.ps1`, portada y autores correctos | **NO CUMPLE** | No existe el `.md` (`ls SGMP-Integracion/entregables/` → `Ambiente-Trabajo-Implementacion.md`, `FLUJO-GIT.md`). `docProps/app.xml`: `Application=Microsoft Office Word`, `Template=Normal.dotm` (no es la salida de `md2docx`). Portada y autores: correctos |
| CA-8 Control de cambios v1.4 → v1.5 | **CUMPLE** | La §13 tiene 15 filas con su origen en REV-01. Se ajustará cuando se corrijan los hallazgos (p. ej., la fila de C9) |

**DoD:** sin PR, sin rama remota, entregables sin versionar → incompleta.

## B. Estado de los hallazgos de REV-01

### B.1 Sección A (contradicciones con el código)

| ID | Estado | Evidencia (2026-10-13) |
|---|---|---|
| C1 Cabeceras | **Parcialmente corregido** | Bien: emisor nginx, HSTS sin `includeSubDomains`, `geolocation=()` y CSP Report-Only sin `unsafe-inline` en scripts (`nginx.conf` L34-49, idéntico en las tres ramas). Mal: dice "todavía no en main", pero `ce0a3a4` está en `origin/main` (merge `956347c`, 2026-10-12 20:49 -0500, ya dentro del corte declarado). La tabla omite `X-Frame-Options: DENY` y `payment=(), usb=()` de `Permissions-Policy` |
| C2 Compose de TEST | **Corregido** | `origin/test:docker-compose.test.yml` L59-60 `MQTT_BROKER_URL`/`MQTT_BROKER_TOKEN` con `:?`; L52 `MODELOS_STORAGE_PATH:-/tmp/sgpmp_modelos`; sin `LOGOS_STORAGE_PATH` |
| C3 Sandbox | **Corregido** | L61-62 reenvía ambas variables; `src/shared/rollback` existe solo en `test` (4 archivos; 0 en `dev` y `main`); `ENABLE_TEST_SANDBOX` solo se lee en `test` |
| C4 `API_TOKEN` | **Corregido** | `API_TOKEN` no aparece en el código de `develop`, `test` ni `main`; el gateway valida contra `modulo1.credenciales_servicio` (`app/db/repositories/credenciales.py`) |
| C5 Variables TLS/ACK | **Corregido** (con observación N-10) | Están las cuatro que pedía REV-01. Faltan otras que el broker ya declara (N-10) |
| C6 `VITE_AGROFUSION_LOGIN_URL` | **Corregido** | Leída en `src/auth/config/sso.ts` en las tres ramas; 0 `ARG` en el `Dockerfile` de las tres ramas; sin `build.args` en `docker-compose.test.yml` |
| C7 Variables del backend | **Corregido** (mejorable) | Agregadas. Se puede reemplazar "por confirmar" por lo que dice el código: `AUDITORIA_M02_EVENTOS_POR_SEGUNDO` vale 100 por defecto (`_registrar_evento_bitacora.py:87`); `ALEMBIC_DATABASE_URL` es opcional y cae a `DATABASE_URL` (`alembic/env.py:40`) |
| C8 TLS y ACL del broker | **Parcialmente corregido** | "Implementado, sin activar" está bien para `develop` y `test`. Pero `main` **ya tiene** dynamic-security (`docker/mosquitto-entrypoint.sh`, SEG-BROKER-03) y el soporte TLS (merge `1b5fd84`, PR #30, 2026-10-12 17:33 -0500; release `cebd430`). La §7, la §8.1, la §8.3 y SAL-IMP-16 dicen lo contrario |
| C9 Compose del frontend por rama | **No resuelto: la corrección es falsa en el código** | `git cat-file -e origin/main:docker-compose.prod.yml` en el frontend → no existe (tampoco al corte). Lo eliminó la sincronización `c143fe5` (PR #365). `main` despliega con `docker-compose.yml`. **Nota: el error viene de REV-01**, que propuso esa corrección sin verificar `main` del frontend |
| C10 Autores | **Corregido** | Portada y control con dos autores |

### B.2 Sección B (redefinición del rol)

| Sección | Estado | Nota |
|---|---|---|
| §1 | Corregido | — |
| §2.1 | Corregido (menor) | Las ramas `docs/` del documento nacen de `main` de SGMP-Integracion, no de una "rama de entorno destino". Remite a la "skill promocion-entornos", que es una herramienta interna del líder: conviene citar la tabla de aprobadores |
| §2.2 | **Parcial** | Dos roles, bien; aprobación de PR, mal (N-06) |
| §2.3 / §2.4 | Corregido | Entradas y salidas invertidas. Rutas `docs/CONTRATO-*.md` desactualizadas (N-14) |
| §3.8 | Corregido | Fuente y fecha presentes |
| §4–§7 | **Parcial** | Flujos que no son los de ADR-001 (N-05); falta SEG-CICD-01 en la §7 (N-19) |
| §8.2 | Corregido | — |
| §11.3 | Corregido | Ítems 4 y 5 separados |
| §11.4 | **Parcial** | Resumen con enlaces, pero el registro no se actualizó (CA-5) |

### B.3 Sección C (coherencia con AMB-09)

| Punto | Estado |
|---|---|
| Puertos MQTT/WS de PROD | **Sin corregir**: el documento dice "por asignar con AIoT" y AMB-09 dice "por asignar (Despliegue)" |
| Flujo backend–gateway | **Corregido**: los dos describen HTTPS 443 por Traefik, `POST /v1/commands` y `/broker-sigab-*` con Strip Path hacia `:8000` |

## C. Hallazgos nuevos

### Fortalezas

| Aspecto | Detalle |
|---|---|
| Rol y fronteras | §1, §2.3, §2.4 y §10 describen bien el alcance vigente y el principio "manda el código" |
| Sandbox | §3.9 precisa y verificable: guarda de `TEST_DATABASE_URL` (`tests/integration/conftest.py:31`, `{"pruebas","pruebas-integrador"}`) y riesgo de rama |
| Salvedades técnicas verificadas | SAL-IMP-11 (979 `OWNER TO postgres` en `alembic/baseline/esquema_baseline.sql`, confirmado), SAL-IMP-13 y SAL-IMP-07 se sostienen en el código |
| Seguridad del documento | Sin valores de secretos; los sensibles aparecen como "valor propio" |
| Trazabilidad y control de cambios | Completos en cobertura (§12, §13) |

### Hallazgos

| ID | Sev. | Dónde | Evidencia | Corrección esperada |
|---|---|---|---|---|
| N-01 | **Mayor** | §3.1 (tabla de capas), §3.3 (tabla del compose: "Ninguno"), §3.4 (`DB_PORT` PROD "No existe"), §3.8 (tabla y "PROD no publica ningún puerto… túnel SSH"), §11.3 ítem 5, SAL-IMP-09 "Aclarado", Diagrama 3 | `origin/main:docker-compose.prod.yml` L67-68 `ports: "${DB_PORT:-5449}:5432"`, commit `c68775af` (2026-10-12 15:19, antes del corte). El comentario dice: "el equipo no tiene acceso SSH… restringirse por firewall a IPs conocidas" | PROD publica 5449 para el DBA y Despliegue, restringido por firewall. Quitar "túnel SSH" y reabrir SAL-IMP-09 como riesgo (exposición de la BD de PROD) |
| N-02 | **Mayor** | §3.3 (Nivel 2: "main → docker-compose.prod.yml… tanto en sgpmp-backend como en SGPMP-FRONT-END-PWA"), §2.4 | El frontend no tiene `docker-compose.prod.yml` en `main` (eliminado en `c143fe5`); `main` usa `docker-compose.yml`, sin guardas `:?` y con `restart: unless-stopped` | Corregir la tabla por repo y rama. Registrar la ausencia del compose de PROD del frontend como salvedad o incidencia (es de Implementación) |
| N-03 | **Mayor** | §3.8 ("todavía no en main"), §7 | `git merge-base --is-ancestor ce0a3a4 origin/main` → INCLUIDO (merge `956347c`, 2026-10-12 20:49) | SEG-FE-02 en dev, test y main (el despliegue en PROD está por verificar) |
| N-04 | **Mayor** | §7, §8.1 ("main: sin dynamic-security ni TLS"), §8.3, SAL-IMP-16 | `origin/main` (BROKER) contiene `docker/mosquitto-entrypoint.sh` con dynamic-security (SEG-BROKER-03) y las variables TLS (`MQTT_TLS`, `TLS_CERT`, `TLS_KEY`) (merge `1b5fd84`) | Actualizar: ACL y soporte TLS en las tres ramas; TLS sin activar en ningún entorno |
| N-05 | **Mayor** | §5 y §12 | ADR-001 define: **Cambio de configuración**, **Directriz de seguridad** e **Incidencia de comunicación**. El documento usa "Imágenes y entornos / Configuración y seguridad / Incidencias" y lo deja "por validar" | Copiar los tres flujos de ADR-001 con sus pasos y rehacer la columna "Equivalente" de la §12 |
| N-06 | **Mayor** | §2.2 (tabla de roles) | `CLAUDE.md`: PR a dev → Líder de Desarrollo; a test → Líder de Pruebas; a main → Líder de Despliegue; SGMP-Integracion → Líder de Implementación. La §5, paso 4, ya lo dice bien | El líder de Implementación revisa y aprueba la HU y los PR de SGMP-Integracion; no aprueba PR de los repos de código |
| N-07 | **Mayor** | Proceso (CA-7, DoD) | No existe `entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`; el `.docx` lo generó Word; no hay rama ni PR | Crear el `.md` como fuente, generar el Word con `herramientas/md2docx.ps1`, abrir la rama `docs/ambiente-trabajo-v1.5` y el PR a `main` |
| N-08 | **Mayor** | CA-5, §11.4, `registro_incidencias_borrador.md` | `registro.md` sin cambios; borrador con otras columnas; duplicados con INC-BE-01 e INC-FE-01; 17 filas frente a 16 | Migrar al `registro.md` real con sus columnas (ID, Fecha, Entorno, Síntoma, Capa, Responsable, Estado, Enlace), reutilizar los ID existentes y que la §11.4 enlace los ID definitivos. Preguntar al líder si las salvedades que no son de comunicación (GHCR, credenciales, plantillas) van a `registros/entornos/` |
| N-09 | **Mayor** | §3.4 Grupo C: `MQTT_HOST / MQTT_PORT`, `MQTT_USER / MQTT_PASSWORD` | El backend no las lee: `git grep` de `os.getenv`/`os.environ.get` en `dev` y `main` no las encuentra, y ningún compose del backend las reenvía (en `test` solo aparecen en scripts de `tests/Test_Testing/…`). Son del gateway (`MQTT_USERNAME`/`MQTT_PASSWORD`, Grupo E) | Retirarlas del Grupo C |
| N-10 | Menor | §3.4 Grupo E | `.env.example` y `docker-compose.yml` del broker (`develop`, `test`, `main`) declaran también `MQTT_TLS`, `MQTT_TLS_HOST_PORT`, `MQTT_WSS_HOST_PORT`, `TLS_CERT`, `TLS_KEY` y `MQTT_ACK_TIMEOUT_SECONDS` (30). La rama `test` del broker tiene además `docker-compose.test.yml` (1885, 9002→9001, sin montaje de certificados) | Agregarlas. Preguntar a AIoT y Despliegue qué compose usa TEST |
| N-11 | Menor | §3.3 "Automatización existente" | Faltan `migrate-prod.yml` (push a `main`), `migrate-test.yml` (rama `test`) y `sast.yml` (PR). `validate-migrations.yml` se dispara en PR a `dev`, `test` **y `main`** | Completar la tabla |
| N-12 | Menor | §3.3 Frontend, §3.8 cabeceras | `/assets/*` lleva `public, immutable` (map) **y** `expires 7d` (location), es decir, doble `Cache-Control` (hallazgo conocido); faltan `X-Frame-Options` y `payment=(), usb=()` | Describir la caché como está y completar la tabla |
| N-13 | Menor | §8 ("persiste… por la red interna") | Contradice la §3.8, SAL-IMP-01 y AMB-09: hoy el gateway usa host:puerto publicado y el rol `dba` | "Diseño: red interna; hoy: host y puerto publicado (SAL-IMP-01)" |
| N-14 | Menor | §2.4, §3.1, §3.3, §11.2, §11.3 | `docs/CONTRATO-TEST.md` y `docs/CONTRATO-PROD.md` → hoy `registros/entornos/CONTRATO-*.md`; `evidencias/hu06/` y `SGPMP_IMPL_Proceso_Ejecucion.drawio` no existen en `origin/main`; los Diagramas 1 y 2 tienen leyenda sin imagen (el `.docx` tiene una sola imagen) | Actualizar rutas, incluir los diagramas o quitar sus leyendas |
| N-15 | Menor | SAL-IMP-03 | `origin/main:compose/compose.test.yml` L23 monta `../../BROKER-MQTT-SGPMP/docker/mosquitto.conf` (ya no `-develop`) | Cerrar como resuelta |
| N-16 | Menor | §3.5, §2.1 | "E3 y E5" (pipeline retirado); referencias a skills internas | Redactar sin el pipeline anterior |
| N-17 | Menor | §3.4 Grupo D, `VITE_FIREBASE_API_KEY` | La columna PROD dice "Proyecto Firebase propio de **TEST**" | Revisar el desplazamiento de columnas |
| N-18 | Menor | Todo el documento (CA-1) | Sin citas de rama, archivo y commit; las ramas avanzaron después del corte | Agregar una tabla de fuentes (repo, rama, commit) y una cita por afirmación técnica; fijar un nuevo corte y reverificar antes del PR |
| N-19 | Menor | §7 | Omite SEG-CICD-01 (HU-IMP-SEG-01) | Agregar su estado por rama |
| N-20 | Menor | SAL-IMP-13 | `.env.test.example` sí trae `JWT_EXPIRE_HOURS` y `REFRESH_TOKEN_EXPIRE_DAYS`; omite `JWT_LEEWAY_SECONDS`, `COOKIE_*` y `MQTT_BROKER_*` | Precisar |

**Secretos:** ninguno. Búsqueda de patrones (cadenas de conexión con credenciales, llaves API, bloques PEM, cadenas largas) sobre el `.docx` y el borrador: sin coincidencias. Las descripciones de `DATABASE_URL` del gateway no incluyen credenciales.

## D. Coherencia con el mapa de puertos AMB-09

| # | Tema | Documento v1.5 | AMB-09 v1.5 | Código | Quién corrige |
|---|---|---|---|---|---|
| D-1 | Puerto MQTT/WS de PROD | "Por asignar con AIoT" (§3.4, §3.8, Diagrama 3); "Despliegue y AIoT" (§8.2); "Despliegue" (§3.1, `MQTT_WS_*`) | "host por asignar (Despliegue)" | — (`CLAUDE.md`: puertos de host → Despliegue) | Documento: "Despliegue" en todas las menciones |
| D-2 | BD de PROD | "sin puerto publicado; 5449 reservado; túnel SSH" | "5449 reservado — NO publicado" | **Publica** `${DB_PORT:-5449}:5432` (`c68775af`) | **Ambos** (abrir el ajuste en AMB-09) |
| D-3 | ACL y TLS en `main` del broker | "main sin dynamic-security ni TLS" | "ACL: DEV/TEST sí · PROD no"; fuente `main@b6e8e28` | `main@cebd430` con dynamic-security y soporte TLS | **Ambos** |
| D-4 | Flujo backend → gateway en el Diagrama 3 del documento | El texto (§8) está bien, pero el Diagrama 3 incrustado **no es** el mapa AMB-09: no dibuja backend → Traefik → gateway (`POST /v1/commands`), gateway → PostgreSQL, Edge → Mosquitto ni WS/TLS, y dice "Mosquitto PROD: host por asignar con AIoT". La leyenda afirma "Fuente: … mapa de puertos v1.5" | Dibuja backend → Traefik (HTTPS 443, `/broker-sigab-*`) → gateway `:8000` (Strip Path), gateway → BD TCP 5432 y Edge → Mosquitto `1884/1885 → 1883` | — | Documento: incrustar el PNG de AMB-09 o corregir el diagrama propio |
| D-5 | Gateway → BD | §8: "por la red interna" | "diseño: red interna; hoy host:puerto publicado y rol `dba`" | — | Documento |

Coinciden: dominios y prefijos DEV/TEST, puertos internos (80, 8000, 5432, 1883, 9001), host 5447/5448, MQTT 1884/1885, WS 9001 (DEV) y 9002→9001 (TEST), y la dirección y el protocolo backend → gateway en el texto de la §8.

Observaciones para AMB-09 (no bloquean esta HU):
- Su capa "Hallazgos" dice "Sandbox: reenvío en compose por verificar", y ya está verificado (C3).
- El compose de `develop` del broker advierte que el host 9002 ya lo usa el WS de TEST, por lo que el WSS de TEST no podrá ir a 9002 en el host. Afecta a los dos documentos ("TLS → 9002").

## E. Notas para el líder (no se envían)

- **Error propio de REV-01 (C9):** propuso `main → docker-compose.prod.yml` para el frontend sin verificar `main`. Conviene reconocerlo en la retroalimentación.
- **`registros/seguridad/registro-SEG.md` está desactualizado:** SEG-FE-02 aparece ❌ en `main` y ya está; SEG-BROKER-03 (ACL) no figura, y la ACL y el soporte TLS ya están en `main` del broker. Pásalo al `auditor-seguridad`.
- **AMB-09** necesita una revisión menor por D-2 y D-3 (BD de PROD publicada y ACL en `main`).
- **Riesgo nuevo, fuera de esta HU:** la BD de PROD publicada en 5449 depende de que el firewall esté restringido. Conviene confirmarlo con Despliegue. Además, el frontend despliega PROD con un compose sin guardas (N-02). Las dos cosas valen una HU `CFG`/`AMB`.
- **Para el planificador** (CA explícitos en las HU de documentos): (1) "cada afirmación sobre `main` se verifica con `git show origin/main:…` en la fecha de corte"; (2) "el `.docx` se genera con `md2docx.ps1`; se adjunta la salida del comando".

## F. Retroalimentación para Juan Hernando (lista para enviar)

> Juan Hernando, revisé la v1.5 del documento de ambiente de trabajo. Primero lo bueno: el rol nuevo quedó bien explicado (introducción, fronteras con los demás equipos, entradas y salidas), los autores están corregidos, las cabeceras ya se atribuyen al nginx del frontend con los valores correctos, y C2 a C7 de REV-01 están resueltos. La Sandbox, la trazabilidad y el control de cambios también están bien, y no hay ningún secreto en el documento. Buen avance.
>
> Todavía no lo puedo aprobar. Te dejo lo que hay que corregir, en orden de prioridad:
>
> **1. Afirmaciones que el código contradice (lo más importante)**
> - **BD de PROD:** `docker-compose.prod.yml` en `main` del backend **sí publica** el puerto: `"${DB_PORT:-5449}:5432"` (commit `c68775af`, 12 de octubre). El comentario del archivo explica que es para el DBA y Despliegue porque **no hay acceso SSH**, y que debe restringirse por firewall. Corrige la §3.1, la §3.3, la §3.4 (`DB_PORT`), la §3.8, el ítem 5 de la §11.3, SAL-IMP-09 y el Diagrama 3. Quita "túnel SSH".
>   Verifícalo con: `git -C sgpmp-backend show origin/main:docker-compose.prod.yml | grep -n DB_PORT`
> - **Frontend en `main`:** no existe `docker-compose.prod.yml`; `main` usa `docker-compose.yml`. Esto lo propuse mal yo en REV-01 (C9), disculpa. Corrige la §3.3 y la §2.4, y regístralo como salvedad.
>   Verifícalo con: `git -C SGPMP-FRONT-END-PWA ls-tree --name-only origin/main | grep compose`
> - **SEG-FE-02 ya está en `main`** (`ce0a3a4`, que entró con el release del 12 de octubre). Corrige la §3.8 y la §7. Agrega a la tabla `X-Frame-Options: DENY` y `payment=(), usb=()` en `Permissions-Policy`.
> - **Broker en `main`:** ya tiene dynamic-security y el soporte TLS (PR #30). Corrige la §7, la §8.1, la §8.3 y SAL-IMP-16: "ACL y soporte TLS en las tres ramas; TLS sin activar en ningún entorno".
> - **Grupo C:** `MQTT_HOST`, `MQTT_PORT`, `MQTT_USER` y `MQTT_PASSWORD` no las lee el backend; son del gateway. Sácalas del Grupo C.
>
> **2. Rol y flujos**
> - **§5 y §12:** usa los tres flujos tal como están en `decisiones/ADR-001-flujos-por-tipo-de-trabajo.md`: *Cambio de configuración*, *Directriz de seguridad* e *Incidencia de comunicación*, con sus pasos. Después rehaz la columna "Equivalente" de la §12. Quita el "debe validarse contra ADR-001": el ADR ya está aprobado.
> - **§2.2:** yo no apruebo los PR de los repos de código. A `dev` los aprueba el Líder de Desarrollo, a `test` el de Pruebas y a `main` el de Despliegue. Yo reviso tu trabajo y apruebo los PR de SGMP-Integracion y el cierre de las HU.
> - **Puertos de PROD del broker:** en todas partes es "por asignar (Despliegue)", no "con AIoT" (§3.4, §3.8, §8.2 y el diagrama).
>
> **3. Proceso de la HU (CA-5 y CA-7)**
> - Crea `entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md` como fuente y genera el Word con `powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregables/AMBIENTE-DE-TRABAJO-IMPLEMENTACION.md`. No edites el Word a mano.
> - Pasa las salvedades al `registros/incidencias/registro.md` real, con sus columnas (ID, Fecha, Entorno, Síntoma, Capa, Responsable, Estado, Enlace). No dupliques: SAL-IMP-06 ya es INC-BE-01 y SAL-IMP-14 ya es INC-FE-01. SAL-IMP-03 ya está resuelta en `compose/compose.test.yml`. Revisa que la §11.4 y el registro tengan las mismas filas (hoy son 16 y 17).
> - Trabaja en la rama `docs/ambiente-trabajo-v1.5` y abre el PR a `main` de SGMP-Integracion enlazando la HU.
>
> **4. Ajustes menores**
> - **Fuentes:** agrega una tabla con repo, rama y commit, y cita rama y archivo en cada afirmación técnica (es lo que pide CA-1). Las ramas avanzaron después del 12 de octubre: fija un nuevo corte y reverifica antes del PR.
> - **Grupo E:** agrega `MQTT_TLS`, `MQTT_TLS_HOST_PORT`, `MQTT_WSS_HOST_PORT`, `TLS_CERT`, `TLS_KEY` y `MQTT_ACK_TIMEOUT_SECONDS`. La rama `test` del broker tiene también `docker-compose.test.yml`: anota cuál usa TEST (pregúntalo a AIoT).
> - **CI/CD (§3.3):** faltan `migrate-prod.yml`, `migrate-test.yml` y `sast.yml`. `validate-migrations` también corre en PR a `main`.
> - **§8:** el gateway hoy llega a la BD por host y puerto publicado con el rol `dba`, no por la red interna (como dice tu propia SAL-IMP-01).
> - **Diagrama 3:** incrusta el PNG de AMB-09 o corrige el tuyo. Hoy no muestra backend → Traefik → gateway, gateway → BD ni Edge → Mosquitto. Los Diagramas 1 y 2 tienen leyenda pero no imagen.
> - **Rutas:** los contratos están en `registros/entornos/CONTRATO-TEST.md` y `CONTRATO-PROD.md`. `evidencias/hu06/` no existe en `main`.
> - **Otros:** en la §3.5 quita "E3 y E5". En el Grupo D, la columna PROD de `VITE_FIREBASE_API_KEY` dice "propio de TEST". Agrega SEG-CICD-01 a la §7. En C7 puedes poner el valor por defecto 100 de `AUDITORIA_M02_EVENTOS_POR_SEGUNDO` y que `ALEMBIC_DATABASE_URL` cae a `DATABASE_URL`.
>
> El detalle con la evidencia de cada punto está en `historias/HU-IMP-DOC-01_documento-ambiente-trabajo/revisiones/REV-02.md`. Cuando abras el PR, hago la REV-03.

## Criterios para la próxima revisión (REV-03)

Los CA de `historia.md`, con PR abierto, `.md` fuente y `registro.md` actualizado. Se reverificarán N-01 a N-04 en la nueva fecha de corte.
