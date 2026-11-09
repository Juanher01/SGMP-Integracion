# Borrador de PR — `chore/agrofusion-sso-clave-publica` → `dev` (sgpmp-backend)

> **PR abierto:** [Arekkazu/sgpmp-backend#1051](https://github.com/Arekkazu/sgpmp-backend/pull/1051) · 2026-11-09 · commit `0dbe294` · base `origin/dev` `3251d78d`. La descripción del PR es el contenido de este archivo debajo de la línea `---`.

**Título sugerido:** `chore(docker): montar clave publica del SSO AgroFusion y excluir *.pem/*.key de la imagen`

---

**Qué:** el compose de DEV y el de PROD montan la clave pública RS256 del SSO de AgroFusion en `/app/secrets/agrofusion_sso_public.pem` (solo lectura). Además, `.dockerignore` deja fuera de la imagen todo `.pem` y `.key`, en la raíz y en subcarpetas. Archivos:

| Archivo | Cambio |
|---|---|
| `docker-compose.yml` | Montaje `../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro` en `backend`, debajo del de `firebase.json` |
| `docker-compose.prod.yml` | El mismo montaje en el `backend` de PROD |
| `.env.example` | Comentario sobre las tres variables del SSO (ruta montada, claim `aud`, claim `iss`). Las variables no cambian |
| `.env.prod.example` | El mismo comentario. El aviso "Despliegue debe montar ese archivo" se reemplaza: el compose ya lo monta y Despliegue solo sube el archivo y carga las variables |
| `.dockerignore` | `**/*.pem` y `**/*.key` (en la raíz y en cualquier subcarpeta) |

**Por qué:** solicitud del líder de Desarrollo (2026-11-07) de dejar configurado el SSO con AgroFusion. El código ya lee `AGROFUSION_SSO_PUBLIC_KEY_PATH` y abre ese archivo (`agrofusion_sso_adapter.py`), pero ningún compose lo montaba. **Sin el montaje, el SSO responde 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE` aunque la variable tenga valor.** El Dockerfile hace `COPY . .` y `.dockerignore` no excluía claves, así que un `.pem` o `.key` en la carpeta del repositorio terminaba dentro de la imagen. — HU `HU-IMP-CFG-03`

**Rama destino y aprobador:** `dev` → Líder de Desarrollo

**Commits:** `0dbe294` (base `origin/dev` `3251d78d`)

**Cómo se verificó:**
- `docker compose -f docker-compose.yml config --no-interpolate --quiet` → `DEV-OK` (código 0).
- `docker compose -f docker-compose.prod.yml config --no-interpolate --quiet` → `PROD-OK` (código 0).
- `docker compose ... config --no-interpolate` muestra el montaje `target: /app/secrets/agrofusion_sso_public.pem` **solo** en el servicio `backend` de los dos compose.
- `git diff --stat`: solo los cinco archivos de la tabla.
- Exclusión de `.dockerignore` (`docker build` con `zz_prueba_dockerignore.pem` en la raíz y `zz_prueba_dir/zz_prueba.key` en una subcarpeta): la imagen se construyó (código 0) y los dos `ls /app/...` dentro del contenedor fallan con `No such file or directory` (código 2). La carpeta `zz_prueba_dir` sí entra, vacía, lo que confirma que el patrón actúa en subcarpetas. Archivos de prueba e imagen borrados; `git status` limpio. Evidencia: `evidencias/03-dockerignore-build.txt`.

**Variables:** no se agregan variables nuevas. Las tres (`AGROFUSION_ISSUER`, `AGROFUSION_PROJECT_CODE`, `AGROFUSION_SSO_PUBLIC_KEY_PATH`) ya estaban en los compose y en las plantillas. Catálogo: `SGMP-Integracion/registros/variables/VARIABLES-ENTORNO.md`.

**Instrucciones para Despliegue, en este orden:**
1. Subir `agrofusion_sso_public.pem` como *File Mount* del compose en Dokploy (*File Path* `agrofusion_sso_public.pem`) **antes** del primer despliegue que incluya este cambio. Si falta el archivo, Docker crea una **carpeta** con ese nombre en `../files/`. Esa carpeta hay que borrarla antes de subir el archivo.
2. Cargar `AGROFUSION_SSO_PUBLIC_KEY_PATH=/app/secrets/agrofusion_sso_public.pem`.
3. Cargar el `AGROFUSION_PROJECT_CODE` de cada entorno. Lo provee Desarrollo, según el registro de cada entorno en AgroFusion.
4. El backend corre como UID 1000 (`USER 1000` en el Dockerfile), así que el `.pem` debe poder leerlo cualquier usuario (por ejemplo, permisos `644`). Después del despliegue, comprobarlo con:
   ```bash
   docker exec <contenedor-backend> sh -c 'test -r "$AGROFUSION_SSO_PUBLIC_KEY_PATH" && echo LEGIBLE'
   ```
   Si no responde `LEGIBLE`, el SSO dará 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE`.

**Riesgos / notas:**
- El Dockerfile no cambia. Docker crea `/app/secrets` al montar el archivo, como ya ocurre con `firebase.json`.
- El `.pem` es una clave pública y no se versiona en el repositorio (`.gitignore` ya excluye `*.pem` y `*.key`).
- La ruta no queda fija en el compose: sale de la variable. Mientras Despliegue no la cargue, `POST /sesiones/sso` responde 503 `SSO_NO_CONFIGURADO` y el resto del backend funciona igual.
- TEST se cubre en un PR aparte a `test`, porque `docker-compose.test.yml` solo existe en esa rama.
- No hace falta reconstruir el frontend. Solo se redespliega el backend.
