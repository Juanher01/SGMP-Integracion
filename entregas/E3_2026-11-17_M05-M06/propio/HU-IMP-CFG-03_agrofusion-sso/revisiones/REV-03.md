# REV-03 — HU-IMP-CFG-03 (fase 2: documentación del SSO de AgroFusion, segunda revisión del contenido preparado)

- **Fecha:** 2026-11-20 (tarde, -05) · **Revisa:** Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)
- **Qué se revisó:** `git diff --cached` de `Juanher01/SGMP-Integracion`, rama `docs/hu-imp-cfg-03-agrofusion-sso` (HEAD `95b16b9`, PR #18 abierto hacia `main`).
  - 14 archivos, +945/−42. `git diff --cached --check` no reporta problemas.
  - Fuera de la revisión: `.claude/`, `entregas/E2_*/motor_ia/`, `entregas/E2_*/prs/` y el stash `e2-readmes`.
- **Corte reverificado (`git fetch`):** BE `dev@6cee5fc4` · `test@135bc318` · `main@0abbeeef`. Son los mismos hashes de REV-02.
- **Objetivo:** confirmar que se corrigió lo que pidió REV-02 (C-1 a C-4, N-1 a N-6).

## 1. Dictamen global

**APROBAR CON OBSERVACIONES.**

- Están corregidos C-1, C-2, C-3, C-4, N-1, N-2, N-3 y N-4.
- Las citas de código nuevas se comprobaron en las tres ramas y son correctas.
- Lo preparado no contiene la clave pública ni secretos.
- No quedan PDF en el index ni rutas a ellos fuera de los textos históricos.
- Quedan pendientes que no bloquean y están marcados:
  - N-5 se resuelve en otra rama o lo resuelve el líder.
  - La decisión P4 está marcada como `[PENDIENTE]`.
  - El enlace de Drive está marcado como `[PENDIENTE]`.
  - Falta enviar la ficha a Despliegue.

## 2. Criterios de aceptación

| CA | Veredicto | Evidencia |
|---|---|---|
| CA-1 | CUMPLE | Sin cambios desde REV-02. Montaje en `origin/dev:docker-compose.yml:111` y `docker-compose.prod.yml:191`. `historia.md` (Notas, «Reverificado 2026-11-20») registra el desplazamiento de una línea. |
| CA-2 | CUMPLE | `origin/dev:.dockerignore:23-24`. |
| CA-3 | CUMPLE con observación | `.env.prod.example:236@6cee5fc4` sigue diciendo `SGPMP-DEV`. Lo corrige ST-05, que ya tiene el aviso «NO se aplica hoy» y su verificación cita CA-3 (`historia.md`, ST-05). |
| CA-4 | NO VERIFICABLE AÚN (diferido por el líder) | `docker-compose.test.yml@135bc318` no cambió. La decisión P4 está marcada `[PENDIENTE: confirmación del líder]` en las Notas. |
| CA-5 | NO VERIFICABLE AÚN | `0dbe294`, `9ff4d38` y `9a52ad5c` no están en `main`. El PR #941 sigue abierto. |
| CA-6 | Parte documental CUMPLE · envío SIN EVIDENCIA · DEV CUMPLE · TEST y PROD NO VERIFICABLE AÚN | Detalle debajo de la tabla. |
| CA-7 | CUMPLE | Catálogo, l.87-100. `VITE_BASE_PATH` ya remite a «T5 de `VERIF-DOC-agrofusion.md` §6, sin HU». |
| CA-8 | CUMPLE | Hashes reverificados el 2026-11-20 y anotados en `historia.md` (Notas) con el efecto de `d417c0c6`. |
| DoD (registro) | CUMPLE | `registro.md`: estados dentro del vocabulario y filas en orden BE-06, BE-07, BE-08 (l.19-21). |

Detalle de CA-6:
- Ficha l.25: «con permisos `644` (legible por UID 1000…)».
- `historia.md:36` y `:48` y ficha l.50 usan la misma orden y la misma cadena: `test -f … && test -r … && echo ARCHIVO-LEGIBLE`.
- La historia y la ficha l.45 y l.86 usan `error_code`.
- El envío a Despliegue sigue pendiente: README de E3, «envío a Despliegue pendiente».
- Curl de hoy: DEV 401, TEST 503, PROD 503.

## 3. Comprobación de las citas de C-2

Hecha con `git show <hash>:<archivo> | grep -n`.

| Cita | dev `6cee5fc4` | test `135bc318` | main `0abbeeef` | Resultado |
|---|---|---|---|---|
| `src/shared/error_handlers.py` `"error_code": code` | l.65 | l.65 | l.54 | Correcta |
| `agrofusion_sso_adapter.py` `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE` | l.53 | l.53 | l.53 | Correcta («iguales en las tres ramas») |
| `agrofusion_sso_adapter.py` `SSO_TOKEN_INVALIDO` | l.71, 79 | l.71, 79 | l.71, 79 | Correcta |
| `sesiones_routers.py` `SSO_NO_CONFIGURADO` | l.174 | l.174 | l.168 | Correcta |

## 4. Estado de los hallazgos de REV-02

| ID | Estado | Evidencia |
|---|---|---|
| C-1 | Corregido | `git grep --cached -n 644` → ficha l.25. |
| C-2 | Corregido | `ARCHIVO-LEGIBLE` en `historia.md:36` y `:48` y en la ficha l.50. `error_code` en `historia.md:36` y `:48` y en la ficha l.45 y l.86. No queda «`code`» suelto. |
| C-3 | Corregido | `historia.md`, Notas: plazo, «Brief 2» y «Pendiente sobre ST-01», cada uno con la marca «(Histórico, 2026-11-09 …)». |
| C-4 | Corregido | Ver el detalle debajo de la tabla. |
| N-1 · O-4 | Corregido | Ficha l.15: «No, cuando el compose de TEST la pase con `${SGPMP_ENTORNO:-TEST}`…». P4 queda `[PENDIENTE]` en las Notas. |
| N-1 · O-5 | Corregido | `historia.md:23` y catálogo l.338: «sin variables SSO en el contenedor (503); File Mount por confirmar con Despliegue». |
| N-1 · O-6 | Corregido | ST-05 tiene el aviso «NO se aplica hoy» y su verificación cita CA-3. |
| N-1 · O-7 | Corregido | Catálogo l.99: «T5 de `VERIF-DOC-agrofusion.md` §6, sin HU». |
| N-1 · O-8 | Corregido | INC-FE-01: «derivado (Desarrollo) — sin impacto». INC-BE-06: «en HU (HU-IMP-CFG-03) · derivado (Despliegue)», entorno «DEV, TEST, PROD». Orden 06, 07, 08. |
| N-1 · O-9 | Corregido | Línea «Actualización 2026-11-17 (anotada el 2026-11-20)» en los dos informes: `BACK-9ff4d38…/analisis.md:108` y `BACK-PR1130…/analisis.md:96`. El análisis original se conserva. |
| N-1 · O-10 | Corregido | `brief-01-pr-dev.md:5` amplía la corrección a la frase de `AGROFUSION_ISSUER`. La l.13 se conserva como texto histórico; la nota de la l.5 la desmiente explícitamente. |
| N-1 · O-11 | Corregido | README de E3: «ficha ST-04 redactada; envío a Despliegue pendiente». |
| N-2 | Corregido | `historia.md`, Notas «Reverificado 2026-11-20». ST-05 cita la línea a reemplazar por su contenido (l.236@6cee5fc4). |
| N-3 | Corregido | `brief-02-pr-test.md:3` → `brief-01-pr-dev.md`. |
| N-4 | Corregido | REV-01 l.3 y REV-02 l.3: «Revisa: Líder de Implementación (con el agente `revisor`; dictamen, no aprobación)». |
| N-5 | No aplicado; no bloquea | `entregas/README.md:60` sigue desactualizado en el index (la corrección está en el stash `e2-readmes`, para otra rama). La descripción del PR #18 la actualiza el líder. Pendiente antes de fusionar el PR #18 o en el PR de la otra rama. |
| N-6 | Sin cambio (informativo) | `d417c0c6` (`M04_FIRMA_MODELOS_KEY`) no está en el catálogo. Corresponde un `/impacto` aparte; queda fuera de CFG-03. |

Detalle de C-4:
- `git ls-files -s | grep -c '\.pdf$'` → 0.
- `evidencias/` solo contiene `01` a `04-*.txt`.
- VERIF-DOC §1: «Drive: [PENDIENTE: enlace]», conserva los cuatro SHA-256 y da el motivo (la clave del doc. 05 §4.1, brief-03 l.85, ADR-002). La decisión está fechada (2026-11-20, REV-02 C-4).
- Ficha l.5: «No se versiona en el repositorio».
- VERIF §9 l.169: «fuentes en Drive, §1».

## 5. Comprobaciones adicionales

- **Clave pública y secretos:**
  - `git grep --cached -E 'BEGIN (PUBLIC|PRIVATE)|MIIB|password=[^ \`<]|secret=[^ \`<]'` sobre la HU, `commits/`, `prs/` y `registros/` no encuentra nada en los archivos preparados, aparte de las propias REV, que solo citan el patrón de búsqueda.
  - La huella aparece truncada (`9d99cf66b629bbf7…`) junto con su origen (`a50cc0b`).
  - El mismo grep encontró un posible valor literal de credencial en un archivo ajeno a este commit (N-7).
- **Rutas a los PDF:**
  - `fuentes-desarrollo` solo aparece en REV-01, REV-02 y brief-03 l.16, que son textos históricos.
  - Los nombres de archivo `.pdf` aparecen en VERIF §1 (tabla de huellas) y en la ficha l.5, como referencia y sin ruta.
- **Enlaces relativos:** los 4 enlaces Markdown del README de E3 existen.
- **Atribución:** no hay `Co-Authored-By`, «Generated with», enlaces de sesión ni emojis. Los títulos «Brief para Claude Code» (brief-01/02/03) y la instrucción histórica de brief-03 l.16 se mantienen. No bloquean: nombran el destinatario del brief y no atribuyen la autoría.

## 6. Observaciones vigentes (no bloqueantes)

| ID | Sev. | Dónde | Qué falta |
|---|---|---|---|
| N-5 | Menor | `entregas/README.md:60` y descripción del PR #18 | Actualizar el estado de CFG-03 y el contenido del PR antes de fusionar. |
| N-6 | Info | BE `d417c0c6` | `/impacto` y fila `M04_FIRMA_MODELOS_KEY` en el catálogo, en un trabajo aparte. |
| N-7 | Info, fuera de alcance | `registros/contenedores/REPORTE-dockerfile-backend.md:99` (commit `935ad6d`; no está en este diff) | Contiene un valor literal de contraseña en un ejemplo. Conviene confirmar si es una credencial real de DEV (relacionado con INC-IMP-04) y, si lo es, sustituirla por un marcador en otro PR y pedir la rotación a Despliegue. **Resuelto:** valor no real (confirmado por el líder, 2026-11-20). Se reemplaza por un marcador. |
| P-1 | Info | VERIF §1, ficha l.5 | Completar «Drive: [PENDIENTE: enlace]». |
| P-2 | Info | `historia.md`, Notas (P4) | Registrar la decisión del líder, con fecha. |
| P-3 | Info | CA-6 | Enviar la ficha a Despliegue y archivar la respuesta en `evidencias/`. |

## 7. Borrador de comentario para el PR #18

En `comentario-PR18_2026-11-20.md` (borrador; lo publica el líder).
