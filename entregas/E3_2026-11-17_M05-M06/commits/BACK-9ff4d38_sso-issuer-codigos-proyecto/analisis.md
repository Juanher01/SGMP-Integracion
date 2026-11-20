# EXT-BACK-9ff4d38 — SSO AgroFusion: `AGROFUSION_ISSUER` con valor por defecto y códigos de proyecto SIGAB

> Análisis de cambio externo (Camino B, flujo 4) · Analista: Implementación · Fecha: 2026-11-17 · Entrega: E3
> Implementación no es revisor asignado: este informe no aprueba ni rechaza el cambio.

## 1. Ficha

| Campo | Valor |
|---|---|
| Repo | `Arekkazu/sgpmp-backend` |
| Commit | `9ff4d381082f21d0ae8e147ff9c37dbd0c496d6c` (`9ff4d38`) |
| PR | #1129 `feature/sso-agrofusion-administrador-2026-11-13` → `dev`, fusionado 2026-11-14 05:09 UTC por Arekkazu (merge `ca5d25f9`), 0 reviews |
| Autor / equipo | Arekkazu (Desarrollo) |
| Fecha del commit | 2026-11-13 23:35 (-05:00) |
| Llegada a `test` | Por el merge de `dev` en `test` (`ca5d25f9` está en la ascendencia de `origin/test`) |
| Llegada a `main` | Pendiente: incluido en el PR de release #941 `dev → main` (abierto, `REVIEW_REQUIRED`, actualizado 2026-11-16) |
| Corte (fetch del líder, 2026-11-17) | `origin/dev` `2b9ee221` · `origin/test` `5697ebbe` · `origin/main` `0abbeeef` |
| Fuente adicional | PDF de Desarrollo "05_Documento_despliegue" v1.0 (2026-11-14), §3 |

## 2. Qué se hizo

**Problema que resuelve (mensaje del commit, confirmado en el código):** el compose de DEV pasaba
`AGROFUSION_ISSUER: ${AGROFUSION_ISSUER}`. Si la variable no existe en Dokploy, Compose la interpola como
cadena **vacía** y la define así en el contenedor. El adaptador lee
`os.getenv("AGROFUSION_ISSUER", "agrofusion-auth")` (`src/identity_access/infrastructure/adapters/agrofusion_sso_adapter.py:37`):
el valor por defecto de `os.getenv` **solo aplica si la variable no existe**, no si está vacía. Resultado:
issuer `""` y todo token rechazado con `Invalid issuer`. Hecho verificado.

**Cambios de infraestructura (archivos de Implementación):**

| Archivo | Cambio |
|---|---|
| `docker-compose.yml` | `AGROFUSION_ISSUER: ${AGROFUSION_ISSUER:-agrofusion-auth}` (hoy línea 78 en `dev` y en `test`) + fila en la tabla de cambios (línea 6) |
| `.env.example` | Comentario de `AGROFUSION_PROJECT_CODE` (líneas 159-161): códigos `SIGAB-DEV` / `SIGAB-TEST` / `SIGAB`, y la URL de retorno `https://inmero.co/{código en minúscula}/sso`. La variable sigue vacía (sin valores reales) |

**Cambios de lógica (Desarrollo; solo se mencionan):** la cuenta creada por el SSO nace con rol
Administrador (`sso_login_use_case.py`, `usuario.py`, `sesiones_routers.py`), migración Alembic
`alembic/versions/f0d5920d51b6_retirar_rol_externo_agrofusion.py` (pasa usuarios del rol "Externo AgroFusion"
al Administrador y elimina el rol) y pruebas. Fuera del alcance de Implementación.

**Descripción vs. diff:** coinciden. El commit **no** toca `.env.prod.example` ni `docker-compose.prod.yml`
(ver §4 y §5).

## 3. Estado por rama

| Rama | `9ff4d38` (`merge-base --is-ancestor`) | Contenido verificado |
|---|---|---|
| `dev` `2b9ee221` | INCLUIDO | `docker-compose.yml:78` `${AGROFUSION_ISSUER:-agrofusion-auth}`; `.env.example:160-161` códigos SIGAB |
| `test` `5697ebbe` | INCLUIDO | Igual que `dev` en `docker-compose.yml:78` y `.env.example:160-161`. El compose que usa TEST, `docker-compose.test.yml:65`, ya tenía `${AGROFUSION_ISSUER:-agrofusion-auth}` antes de este commit |
| `main` `0abbeeef` | AUSENTE | `docker-compose.yml:72` `${AGROFUSION_ISSUER}` (sin default). `docker-compose.prod.yml:148` ya tiene `:-agrofusion-auth` |

Comandos: `git merge-base --is-ancestor 9ff4d38 origin/<rama>`; `git show origin/<rama>:<archivo> | grep -nE 'AGROFUSION|SGPMP_ENTORNO|SIGAB|SGPMP-DEV'`
(en Git Bash de Windows con `MSYS_NO_PATHCONV=1`, si no, `origin/<rama>:.env…` se convierte en ruta y falla en silencio).

## 4. Archivos de Implementación tocados y conformidad

Cambio de otro equipo en archivos de Implementación: `docker-compose.yml`, `.env.example`.

| Regla | Veredicto | Evidencia |
|---|---|---|
| `compose-entornos` 4 (toda variable en `environment:`) | Conforme | Ya estaba; solo cambia el default |
| `compose-entornos` 3 / `variables-entorno` 5 (guardas en TEST/PROD) | No aplica | Es DEV; además un default es correcto aquí: el valor es igual en los tres entornos y no sensible |
| `variables-entorno` 1 (un nombre, tres valores) | Conforme | Mismo nombre en los tres compose |
| `variables-entorno` 2 (plantillas sin valores reales, comentario útil) | Conforme en `.env.example` | `AGROFUSION_PROJECT_CODE=` vacía; los códigos van solo en el comentario (no son secretos) |
| Paridad de plantillas | **Desviación** | `.env.prod.example:234-235` en `dev` y `test` sigue diciendo "DEV usa SGPMP-DEV; TEST y PROD usan el código con que se registre cada entorno". Esa línea la escribió Implementación en `0dbe294` (`git blame`); el commit de Desarrollo actualizó solo `.env.example` |
| `docker compose config --no-interpolate --quiet` sobre `origin/dev:docker-compose.yml` | Válido | `DEV-OK` (2026-11-17) |

## 5. Impacto

| Punto | Resultado | Evidencia |
|---|---|---|
| Variables nuevas, renombradas o eliminadas | No. Cambia el default de `AGROFUSION_ISSUER` y la documentación de `AGROFUSION_PROJECT_CODE` | Diff |
| `AGROFUSION_ISSUER` llega a todos los eslabones | Sí en DEV (`docker-compose.yml:78`, `.env.example:165`), TEST (`docker-compose.test.yml:65`, `.env.test.example:51`) y PROD (`docker-compose.prod.yml:152` en `dev`, `:148` en `main`; `.env.prod.example:242`). Solo `main:docker-compose.yml:72` sigue sin default, y ese archivo es el compose de DEV: llega con el release | `git show` por rama |
| PDF §3: "default agrofusion-auth en los tres compose" | **Cierto** en `dev`+`test` (los tres archivos). En `main` falta en `docker-compose.yml` | Ídem |
| Paridad | `.env.prod.example` desalineado con `.env.example` (ver §4). `.env.test.example` (solo en `test`) no documenta el código `SIGAB-TEST` | `test:.env.test.example:49-51` |
| Catálogo | **Hallazgo:** `registros/variables/VARIABLES-ENTORNO.md:87` dice "Si viene vacía, el código usa `agrofusion-auth`": es falso (justo el fallo que corrige este commit). Línea 88 dice "DEV usa `SGPMP-DEV`": desactualizado | `os.getenv` con default no cubre la cadena vacía |
| Dependencias, imágenes, usuario | No aplica | — |
| Servicios, puertos, volúmenes, redes | No | — |
| Orígenes externos / CSP / cookies | **Pregunta abierta:** el comentario nuevo dice que AgroFusion devuelve al usuario a `https://inmero.co/{código en minúscula}/sso` (p. ej. `https://inmero.co/sigab-dev/sso`). Ningún frontend vive en `inmero.co/<prefijo>` (DEV `dev.inmero.co`, TEST `api.inmero.co`). Hipótesis: hace falta una redirección en Traefik (Despliegue) o el dato es de AgroFusion y no de SIGAB | `.env.example:161` |
| Workflows / SEG | No aplica | — |
| Cambios temporales | No | — |
| Secretos | Sin valores. `AGROFUSION_PROJECT_CODE` e issuer son no sensibles | Diff |
| Migración `f0d5920d51b6` | Lógica de Desarrollo. Para Implementación: corre en el arranque o en el despliegue de cada entorno; no exige cambios de compose | — |

## 6. Trabajo derivado

| Tipo | Rama / entorno | Trabajo | Estrategia |
|---|---|---|---|
| Sin acción | `test` | `AGROFUSION_ISSUER` con default **ya está** en `docker-compose.yml:78` y en `docker-compose.test.yml:65` | — |
| Implementación (verificar) | `main` | Default en `docker-compose.yml` llega con el release #941; `docker-compose.prod.yml:148` ya lo tiene, así que PROD no tiene el fallo. No justifica PR dirigido | A (release); verificar con `--is-ancestor 9ff4d38 origin/main` |
| Implementación (CFG) | `dev` → `test` → `main` | Corregir `.env.prod.example:234-235` (hoy "DEV usa SGPMP-DEV…") → "PROD: `SIGAB`" y alinear la redacción con `.env.example:159-161`. Es texto nuestro (`0dbe294`). En `main` la línea no existe: llega con el release | PR a `dev`; A para `test` y `main` |
| Implementación (CFG, ST-02 de CFG-03) | `test` | En `.env.test.example`, comentar `AGROFUSION_PROJECT_CODE` con `SIGAB-TEST` (el brief-02 ya pide copiar el comentario del brief 1; usar la redacción nueva) | PR a `test` |
| Implementación (catálogo) | SGMP-Integracion | Corregir `VARIABLES-ENTORNO.md:87-88` (cadena vacía ≠ ausente; códigos SIGAB) | Commit en `SGMP-Integracion` |
| Despliegue | DEV, TEST, PROD | Ficha: `AGROFUSION_PROJECT_CODE` = `SIGAB-DEV` / `SIGAB-TEST` / `SIGAB` (no sensible, lo provee Desarrollo, confirmado en PDF §3). `AGROFUSION_ISSUER`: no hace falta cargarla; **si se carga, no debe quedar vacía** | Encaja en la ficha de ST-04 de CFG-03 |
| Equipo autor | — | Nada que corregir del cambio. Opcional, comentario informativo: "La plantilla `.env.prod.example` aún dice SGPMP-DEV; la corrige Implementación." | El líder decide |

**Resumen para `/planificar`:** ampliar HU-IMP-CFG-03 (o HU CFG nueva) con: (a) `.env.prod.example:234-235`
en `dev`; (b) comentario `SIGAB-TEST` en `.env.test.example` (ST-02); (c) catálogo `VARIABLES-ENTORNO.md:87-88`;
(d) ficha a Despliegue con los tres códigos. Dominio sugerido: CFG.

## 7. Preguntas abiertas para el líder

1. ¿Se amplía HU-IMP-CFG-03 con la corrección de `.env.prod.example` o se abre una HU CFG aparte?
2. La URL de retorno `https://inmero.co/{código}/sso` no coincide con ningún host del frontend. ¿Se consulta a Desarrollo si eso exige ruta en Traefik (Despliegue)?
3. #1129 se fusionó sin reviews (aprobador de `dev`: Líder de Desarrollo, que es el mismo autor). ¿Se registra como patrón?
4. Índice: falta agregar la fila de este origen en `entregas/E3_2026-11-17_M05-M06/README.md` (estado sugerido `analizado`); este análisis no lo editó por instrucción del líder.

> **Actualización 2026-11-17** (anotada el 2026-11-20). Los frontends sí viven en `inmero.co/<prefijo>` (`/sigab-dev`, `/sigab`; curl en `propio/HU-IMP-CFG-03_agrofusion-sso/revisiones/VERIF-DOC-agrofusion.md` §2 y §8): la fila «Orígenes externos» de §5 y la pregunta 2 quedan respondidas. La fila de este origen ya está en el README de E3 (pregunta 4). Ficha para Despliegue: `registros/variables/fichas/HU-IMP-CFG-03_2026-11-17.md`.
