# Brief para Claude Code: SSO de AgroFusion, montaje de la clave pública (PR a `dev`)

> Brief 1 de 2. El brief 2 hace el mismo cambio en la rama `test`, porque `docker-compose.test.yml` solo existe allí.

## Contexto

El líder de Desarrollo pidió dejar configuradas tres variables del SSO con AgroFusion en el backend (`Arekkazu/sgpmp-backend`):

| Variable | Qué es | Sensibilidad |
|---|---|---|
| `AGROFUSION_ISSUER` | Emisor esperado en el claim `iss` del token. El código ya usa `agrofusion-auth` si viene vacía. | No sensible |
| `AGROFUSION_PROJECT_CODE` | Código con que el proyecto está registrado en AgroFusion; se valida contra el claim `aud`. En DEV es `SGPMP-DEV`. | No sensible |
| `AGROFUSION_SSO_PUBLIC_KEY_PATH` | **Ruta** dentro del contenedor a la clave pública RS256 (`.pem`). No es la clave. | Interna (la ruta); el `.pem` es público, pero hay que proteger su integridad |

Esto ya se revisó en la rama `dev`:
- El código lee las tres variables en `src/identity_access/infrastructure/adapters/agrofusion_sso_adapter.py` (líneas 35–37) y abre el archivo de la ruta con `open()`.
- `sesiones_routers.py` (línea 170) solo activa el SSO si `AGROFUSION_SSO_PUBLIC_KEY_PATH` y `AGROFUSION_PROJECT_CODE` tienen valor. Si falta alguna, responde 503 `SSO_NO_CONFIGURADO`.
- Las tres variables ya están en `.env.example`, `.env.prod.example`, `docker-compose.yml` y `docker-compose.prod.yml`.
- **Lo que falta:** ningún compose monta el `.pem` en el contenedor. Con la ruta cargada, el login SSO daría 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE`.
- **Hallazgo:** `.dockerignore` no excluye `*.pem` ni `*.key`. Como el Dockerfile hace `COPY . .`, una clave que quede en la carpeta del repositorio terminaría dentro de la imagen.

**Decisión:** montar el `.pem` siguiendo el patrón que ya existe para Firebase. Despliegue sube el archivo como *File Mount* en Dokploy con *File Path* `agrofusion_sso_public.pem`. Dokploy lo guarda en `../files/` y el compose lo monta como solo lectura en `/app/secrets/agrofusion_sso_public.pem`.

La ruta **no** se escribe fija en el compose: sigue saliendo de la variable. Así, mientras Despliegue no cargue la ruta, el SSO queda en 503 y el backend no se cae.

## Restricciones

- Trabaja en una rama nueva creada desde `origin/dev` actualizado: `chore/agrofusion-sso-clave-publica`.
- **Solo** puedes tocar estos cinco archivos: `docker-compose.yml`, `docker-compose.prod.yml`, `.env.example`, `.env.prod.example` y `.dockerignore`.
- No cambies código de aplicación (`src/`, `main.py`, `alembic/`). Si algo exige tocarlo, detente y repórtalo como hallazgo para Desarrollo.
- No cambies otras variables, volúmenes ni puertos, aunque veas diferencias entre compose. La alineación general va en un PR aparte.
- **Nunca** escribas valores reales. `AGROFUSION_PROJECT_CODE` queda vacía en los `.env.*.example`; el valor `SGPMP-DEV` solo va en un comentario.
- No hagas `git push` ni abras el PR sin mi aprobación. Primero muéstrame el diff y el reporte.

## Dónde va cada cosa

Hay dos repositorios y cada uno tiene su función. No los mezcles.

| Repositorio | Qué se hace ahí | Qué NO va ahí |
|---|---|---|
| `sgpmp-backend` | Solo los cambios de configuración: los cinco archivos permitidos, en la rama `chore/agrofusion-sso-clave-publica`. | Briefs, HU, evidencias, reportes, borradores del PR, notas. |
| `SGMP-Integracion` | Toda la documentación: la HU, este brief y el brief 2, evidencias, el borrador de la descripción del PR y la actualización del catálogo de variables. | Código o configuración de los repositorios de aplicación. |

Carpeta de la HU (en adelante, `<HU>`): `SGMP-Integracion/entregas/E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-<NN>_agrofusion-sso/`

- Los dos briefs se guardan en la raíz de `<HU>` como `brief-01-pr-dev.md` y `brief-02-pr-test.md`.
- Las salidas de las verificaciones van a `<HU>/evidencias/`.
- El borrador de la descripción del PR va a `<HU>/entregables/`.
- Si un comando deja archivos temporales en `sgpmp-backend`, bórralos antes del commit. `git status` debe mostrar solo los cinco archivos permitidos.

## Pasos

### 1. Preparar la rama
```bash
cd sgpmp-backend
git fetch origin
git switch -c chore/agrofusion-sso-clave-publica origin/dev
git status
```
Si el árbol de trabajo tiene cambios, detente y avísame.

### 2. `docker-compose.yml` (DEV)
En el servicio `backend`, bajo `volumes:`, agrega este montaje justo después de la línea de `firebase.json`, con su comentario:
```yaml
      # SSO AgroFusion (Mecanismo A): clave publica RS256 para verificar el
      # token de handoff. Se carga como File Mount del compose en Dokploy con
      # File Path `agrofusion_sso_public.pem` (Dokploy la guarda en ../files/).
      # AGROFUSION_SSO_PUBLIC_KEY_PATH debe ser /app/secrets/agrofusion_sso_public.pem.
      # Sin la variable, el SSO responde 503 y el resto del backend funciona igual.
      - ../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro
```
Agrega una fila a la tabla de cambios del encabezado del archivo, con fecha 2026-11-07, nombre "Sebastián Sandoval (Implementación)" y la descripción "SSO AgroFusion: montar la clave pública RS256 en /app/secrets".

### 3. `docker-compose.prod.yml` (PROD)
Haz el mismo cambio en el `backend` de PROD, debajo de la línea de `firebase.json`, y agrega la misma fila a la tabla de cambios.

### 4. `.env.example` y `.env.prod.example`
En el bloque `AGROFUSION — SSO`, deja las tres variables como están (`AGROFUSION_ISSUER=agrofusion-auth` y las otras dos vacías). Encima de ellas agrega o reemplaza este comentario:
```
# AGROFUSION_SSO_PUBLIC_KEY_PATH: RUTA al .pem dentro del contenedor, no su contenido.
#   En Docker/Dokploy: /app/secrets/agrofusion_sso_public.pem (el compose monta
#   ../files/agrofusion_sso_public.pem ahí). En ejecución local sin Docker: ruta local al .pem.
# AGROFUSION_PROJECT_CODE: código del proyecto registrado en AgroFusion (claim "aud").
#   DEV usa SGPMP-DEV; TEST y PROD usan el código con que se registre cada entorno.
# AGROFUSION_ISSUER: claim "iss" esperado; agrofusion-auth por defecto.
```
En `.env.prod.example`, reemplaza el párrafo que dice "Si se usa en PROD, Despliegue debe montar ese archivo" por esta aclaración: el compose ya monta el archivo, y Despliegue solo debe subirlo en Dokploy como *File Mount* `agrofusion_sso_public.pem` y cargar las dos variables. Agrega también una fila a la tabla de cambios de cada archivo.

### 5. `.dockerignore`
Al final del archivo, agrega:
```
# Claves y certificados: nunca dentro de la imagen (se montan en ejecución).
*.pem
*.key
```
Agrega también una fila a su tabla de cambios.

### 6. Verificar
1. Los dos compose deben ser válidos:
   ```bash
   docker compose -f docker-compose.yml config --no-interpolate --quiet && echo DEV-OK
   docker compose -f docker-compose.prod.yml config --no-interpolate --quiet && echo PROD-OK
   ```
2. El montaje debe quedar declarado en el servicio `backend` de los dos compose:
   ```bash
   docker compose -f docker-compose.yml config --no-interpolate | grep -n "agrofusion_sso_public"
   docker compose -f docker-compose.prod.yml config --no-interpolate | grep -n "agrofusion_sso_public"
   ```
3. `.dockerignore` debe excluir las claves de la imagen. Crea un archivo de prueba vacío, construye y comprueba que no entró:
   ```bash
   echo "prueba" > zz_prueba_dockerignore.pem
   docker build -t sgpmp-backend:prueba-dockerignore .
   docker run --rm --entrypoint sh sgpmp-backend:prueba-dockerignore -c "ls /app/zz_prueba_dockerignore.pem" ; echo "codigo=$?"
   rm zz_prueba_dockerignore.pem
   docker image rm sgpmp-backend:prueba-dockerignore
   ```
   Esperado: `ls` falla (código distinto de 0). Si la construcción falla por un motivo que no tiene que ver con este cambio, anótalo y sigue con lo demás.
4. El diff solo debe incluir los cinco archivos permitidos:
   ```bash
   git diff --stat
   ```

### 7. Commit (sin push)
```bash
git add docker-compose.yml docker-compose.prod.yml .env.example .env.prod.example .dockerignore
git commit -m "chore(docker): montar clave publica del SSO AgroFusion y excluir *.pem/*.key de la imagen"
```
Al final del mensaje del commit agrega las líneas de atribución que uses normalmente.

### 8. Registro en SGMP-Integracion (repositorio de documentación, no el backend)
1. Crea la HU con la skill `hu-taiga` en `<HU>`. Usa el siguiente número libre de `CFG`. Copia ahí los dos briefs, como se indica en "Dónde va cada cosa". Origen: solicitud del líder de Desarrollo, 2026-11-07. Tipo de flujo: cambio de configuración. Subtareas:
   - PR a `dev` (este brief).
   - PR a `test` (brief 2).
   - Verificación cuando llegue a `main`.
   - Coordinación con Despliegue (subir el archivo y cargar los valores).
2. En `SGMP-Integracion/registros/variables/VARIABLES-ENTORNO.md`, agrega a la tabla del catálogo las tres variables (componente: Backend; tipo: Autenticación / Seguridad), con la sensibilidad de la tabla de Contexto. En la descripción de `AGROFUSION_SSO_PUBLIC_KEY_PATH`, explica que la ruta apunta a un archivo que se monta.
3. Guarda las salidas del paso 6 en `<HU>/evidencias/`.
4. No hagas commit en SGMP-Integracion; lo reviso yo.

### 9. Preparar el PR (no lo abras)
Redacta la descripción del PR con la plantilla de la skill `promocion-entornos` y guárdala en `<HU>/entregables/PR-dev.md`. No la guardes en `sgpmp-backend`. Debe incluir:
- **Qué cambia:** los cinco archivos.
- **Por qué:** sin el montaje, el SSO responde 500 aunque la variable tenga valor.
- **Instrucciones para Despliegue, en este orden:**
  1. Subir `agrofusion_sso_public.pem` como *File Mount* del compose en Dokploy, **antes** del primer despliegue que incluya este cambio. Si falta el archivo, Docker crea una carpeta con ese nombre en `../files/`, y esa carpeta hay que borrarla antes de subir el archivo.
  2. Cargar `AGROFUSION_SSO_PUBLIC_KEY_PATH=/app/secrets/agrofusion_sso_public.pem`.
  3. Cargar el `AGROFUSION_PROJECT_CODE` de cada entorno.
  4. El backend corre como UID 1000 (`USER 1000` en el Dockerfile), así que el `.pem` debe poder leerlo cualquier usuario (por ejemplo, permisos 644). Después del despliegue, comprobarlo con:
     `docker exec <contenedor-backend> sh -c 'test -r "$AGROFUSION_SSO_PUBLIC_KEY_PATH" && echo LEGIBLE'`
     Si no responde `LEGIBLE`, el SSO dará 500 `AGROFUSION_CLAVE_PUBLICA_NO_DISPONIBLE`.
- **Nota:** el Dockerfile no cambia. Docker crea `/app/secrets` al montar el archivo, como ya ocurre con `firebase.json`.
- **Nota:** el `.pem` es una clave pública y no se versiona en el repositorio.

## Reporte de vuelta

Detente y entrégame:
1. El `git diff` completo de los cinco archivos.
2. El resultado de cada verificación del paso 6, con la salida y el código de salida.
3. La ruta de la HU creada y el diff de `VARIABLES-ENTORNO.md`.
4. El borrador de la descripción del PR.
5. Cualquier hallazgo. Por ejemplo, si la estructura de `volumes:` del backend no es la que describe este brief.
