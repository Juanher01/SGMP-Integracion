# EXT-BACK-PR1223 — Carpeta de modelos del usuario 1000 en la imagen del backend (incluye EXT-BACK-PR1224 y EXT-BACK-e2ec9ed)

## 1. Ficha

| Campo | Valor |
|---|---|
| Repo | Arekkazu/sgpmp-backend |
| Cambio 1 | PR #1223 `hotfix/rf69-volumen-modelos-usuario-1000` → `main`, commit `21ab30e5` (2026-11-22 09:02 -05), merge `4ba92994` (2026-11-22 14:18 UTC), release 1.4.1 `239909e0` |
| Cambio 1 (gemelo) | PR #1224 `hotfix/rf69-volumen-modelos-usuario-1000-dev` → `dev`, commit `885f39de`, merge `b5cb998b` (2026-11-22 14:18 UTC). `git diff 21ab30e5 885f39de -- Dockerfile` vacío |
| Cambio 2 | Commit `e2ec9ed5` (2026-11-21 19:30 -05) en `docker-compose.prod.yml`; a `dev` por PR #1218, a `main` por el release PR #1219 (1.4.0, `9655f389`) |
| Autor / equipo | Arekkazu (Líder de Desarrollo) / Desarrollo |
| Corte | `git fetch` del 2026-11-22 · `origin/dev 4c65796e` · `origin/test c698c656` · `origin/main 239909e0` |
| Entrega | E4 (2026-11-24) |
| Dictamen del líder | Cambio 1 correcto |

## 2. Qué se hizo

**Cambio 1 — Dockerfile (+7 −2).** El `RUN` que crea el usuario 1000 ahora crea también `/app/storage/modelos` y le da dueño
1000, junto a `/app/storage/auditoria_iot` (`Dockerfile@21ab30e5` l. 59-61, comentario l. 55-58, fila de cabecera l. 4).
Problema que resuelve (verificado por el líder): `docker-compose.prod.yml` monta `sgpmp_modelos_prod` en `/app/storage/modelos`
desde `00dbf946` (2026-09-11, a `main` por #268), pero la imagen nunca creó esa carpeta (`MSYS_NO_PATHCONV=1 git log --format=%h -S'/app/storage/modelos' origin/main -- Dockerfile` → solo `21ab30e5`; sin el prefijo, Git Bash convierte la ruta y la salida sale vacía). Un volumen nuevo
copia el dueño de la carpeta de la imagen; sin carpeta queda `root:root` y el proceso (UID 1000) recibe `Permission denied`:
registro de modelos (RF-69) y logotipos (RF-26) no podían escribir en PROD desde el primer despliegue. La descripción y el diff
coinciden.

**Cambio 2 — `docker-compose.prod.yml` (+6).** Fija `IOT_AUDITORIA_RESPALDO_PATH: /app/storage/auditoria_iot/fallas.sqlite3`
(literal, igual al `ENV` de la imagen) y monta el volumen nuevo `sgpmp_auditoria_iot_prod` en `/app/storage/auditoria_iot`
(`@e2ec9ed5` l. 167-169, 183, 257). Resuelve INC-M03-125-G12 en PROD: los respaldos de auditoría IoT pendientes se perdían en
cada redespliegue. No toca el volumen de modelos.

## 3. Estado por rama

| Cambio | dev `4c65796e` | test `c698c656` | main `239909e0` |
|---|---|---|---|
| `21ab30e5` (#1223) | AUSENTE (llega el gemelo) | AUSENTE | INCLUIDO |
| `885f39de` (#1224) | INCLUIDO | AUSENTE | AUSENTE (llega el gemelo) |
| Contenido (carpeta de modelos en la imagen) | Sí | **No** (`Dockerfile` l. 55-56 solo `auditoria_iot`) | Sí |
| `e2ec9ed5` | INCLUIDO | AUSENTE (no aplica: solo toca el compose de PROD) | INCLUIDO desde 1.4.0 |

Evidencia: `git merge-base --is-ancestor <commit> origin/<rama>`; `git show origin/test:Dockerfile | sed -n 50,62p`.
Cuando el release `dev → main` vuelva a pasar, git verá dos commits con el mismo cambio: conflicto nulo o trivial.

## 4. Archivos de Implementación tocados y conformidad

Cambio de otro equipo en archivo de Implementación: `Dockerfile` (#1223, #1224) y `docker-compose.prod.yml` (`e2ec9ed5`).

| Regla (skill) | Resultado |
|---|---|
| Usuario no root numérico, UID 1000 sin cambiar (dockerfile 3 y decisiones del backend) | Conforme: refuerza la decisión |
| Comentario que explica el porqué (dockerfile 10) | Conforme (incluye el límite: un volumen con archivos conserva su dueño) |
| Volúmenes con nombre por entorno, rutas persistentes (compose-entornos 9) | Conforme en PROD (`sgpmp_auditoria_iot_prod`) |
| Paridad (compose-entornos) | DEV y PROD con los dos volúmenes; **TEST sin ninguno** (modelos y logos en `/tmp`, INC-BE-02) |
| Plantilla y catálogo | No aplica: la variable es literal y ya existía en el `ENV` de la imagen |

## 5. Impacto

| Punto | Resultado |
|---|---|
| Variables | No: `IOT_AUDITORIA_RESPALDO_PATH` en PROD solo hace explícito el valor de la imagen |
| Paridad | Sí: TEST queda como único entorno sin volúmenes ni carpeta de modelos en la imagen |
| Imagen, usuario, etapa | Sí (cambio 1): una carpeta más con dueño 1000; sin paquetes ni cambio de base |
| Volúmenes | Sí: `sgpmp_auditoria_iot_prod` nuevo (cambio 2); `sgpmp_modelos_prod` pasa a ser escribible si estaba vacío |
| Puertos, redes, healthchecks, CSP, CORS, workflows | No |
| Temporal | No |
| Secretos | Ninguno en los diffs |
| Riesgo residual (prueba local del líder, casos A/B/C) | Si `sgpmp_modelos_prod` ya tiene algún archivo de root, sigue sin poder escribirse: el hotfix no lo arregla. Se verifica con el uso: Desarrollo registra BOV-001 y TER-001 en PROD tras el redespliegue |

## 6. Trabajo derivado

| Tipo | Trabajo |
|---|---|
| Implementación (CFG) | HU-IMP-CFG-04 ST-04c (se amplía aparte): compose de TEST como PROD, dos volúmenes en `/app/storage/...`. Depende de que el Dockerfile de #1224 llegue a `test`. Absorbe HU-IMP-AMB-10. No hay HU del Dockerfile (lo resolvió Desarrollo) |
| Promoción | PR dirigido (estrategia B, decisión del líder, 2026-11-22): `cherry-pick -x 885f39de` como primer commit del PR de HU-IMP-CFG-04 ST-04c; se omite si la promoción `dev → test` de Pruebas llega antes. Sin `/promover` aparte |
| Despliegue | Nada por ahora sobre el volumen de PROD (ver abajo). La pregunta sobre `MODELOS_STORAGE_PATH` y `LOGOS_STORAGE_PATH` en TEST va por CFG-04 ST-04c |
| Equipo autor | Sin acción técnica |
| Seguimiento | Registro de BOV-001 y TER-001 en PROD por Desarrollo tras el redespliegue; Dockerfile de `test` (CFG-04 CA-12) |

**Verificación de PROD (decisión del líder, 2026-11-22).** No se pide nada a Despliegue sobre el volumen de modelos.
La verificación es que Alex (Líder de Desarrollo) registre los modelos BOV-001 y TER-001 después del redespliegue.
Si falla con `Permission denied`, entonces se pide a Despliegue revisar el volumen: nombre real en Dokploy y dueño
de su raíz (`docker run --rm -v <volumen>:/m alpine stat -c '%u:%g %a' /m`, que no lista el contenido).

## 7. Preguntas abiertas para el líder

Ninguna. Decisiones del 2026-11-22: estrategia B para llevar `885f39de` a `test` (dentro de CFG-04 ST-04c) y la
verificación de PROD descrita arriba.
