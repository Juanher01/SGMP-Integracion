# Brief para Claude Code: SSO de AgroFusion en TEST (PR a `test`)

> Brief 2 de 2. Antes, lee el brief 1 (`BRIEF-ClaudeCode-agrofusion-sso-PR-dev.md`): ahí está el contexto completo y la HU donde se registra este trabajo.

## Contexto

`docker-compose.test.yml` y `.env.test.example` existen **solo en la rama `test`**, así que el cambio del brief 1 no les llega con el merge de `dev` a `test`. Los demás archivos (`.dockerignore`, `docker-compose.yml` y los `.env` de DEV y PROD) sí llegan cuando Desarrollo hace "Merge dev into test", así que este brief no los toca.

Esto ya se revisó en la rama `test`:
- `docker-compose.test.yml` ya pasa al backend las tres variables `AGROFUSION_*`, pero el servicio `backend` **no tiene sección `volumes:`**, así que el `.pem` no llega al contenedor.
- `.env.test.example` y `docker-compose.test.yml` todavía declaran `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET`. El código de `test` ya no las lee: desde RF-101 (M07), esas credenciales se registran en la base de datos. En `main` sí se siguen leyendo, porque `main` está atrasada, así que este cambio es **solo para `test`**.

## Restricciones

- Trabaja en una rama nueva creada desde `origin/test` actualizado: `chore/agrofusion-sso-compose-test`.
- **Solo** puedes tocar `docker-compose.test.yml` y `.env.test.example`.
- En el `backend`, agrega **únicamente** el montaje del `.pem`. No agregues otros volúmenes, como `firebase.json`, modelos o logos, aunque falten. Eso va en el PR de alineación de compose, que se hará por separado.
- No cambies código de aplicación. Nunca escribas valores reales.
- No hagas `git push` ni abras el PR sin mi aprobación.

## Agentes

- **Pasos 1 a 6:** delega en el subagente `contenedores` («Usa el subagente contenedores para…»). Él aplica su propio método de verificación (`verificacion` §2–§3) y revisa la paridad con los otros compose. Las diferencias que encuentre van como hallazgos; no las corrijas en este PR.
- **Paso 7:** el borrador del PR y las evidencias se registran igual que en el brief.
- **Después del commit y antes del push:** ejecuta `/revisar HU-IMP-CFG-03` sobre la rama `chore/agrofusion-sso-compose-test`. El dictamen queda en `<HU>/revisiones/`. Si sale `SOLICITAR CAMBIOS` o `BLOQUEADO`, detente y entrégamelo.

## Dónde va cada cosa

La regla es la misma del brief 1:

- En `sgpmp-backend` solo van los dos archivos permitidos, en la rama `chore/agrofusion-sso-compose-test`.
- Todo lo documental va a `SGMP-Integracion`, en la HU que creó el brief 1: `<HU>` = `SGMP-Integracion/entregas/E3_2026-11-17_M05-M06/propio/HU-IMP-CFG-03_agrofusion-sso/`. Eso incluye evidencias y el borrador del PR.

Si la HU todavía no existe, detente: el brief 1 debe ejecutarse antes.

## Pasos

### 1. Preparar la rama
```bash
cd sgpmp-backend
git fetch origin
git switch -c chore/agrofusion-sso-compose-test origin/test
git status
```

### 2. Confirmar que el código de `test` no usa las variables `HUB`
```bash
git grep -n "AGROFUSION_HUB" -- src main.py
```
Esperado: ninguna coincidencia. Si aparece alguna, **no las quites**: sigue solo con el montaje y anótalo como hallazgo.

### 3. `docker-compose.test.yml`
1. En el servicio `backend`, agrega una sección `volumes:` justo antes de `expose:`:
   ```yaml
       volumes:
         # SSO AgroFusion (Mecanismo A): clave publica RS256. Mismo patron que DEV/PROD:
         # File Mount del compose en Dokploy con File Path `agrofusion_sso_public.pem`
         # (Dokploy la guarda en ../files/). AGROFUSION_SSO_PUBLIC_KEY_PATH debe ser
         # /app/secrets/agrofusion_sso_public.pem. Sin la variable, el SSO responde 503.
         - ../files/agrofusion_sso_public.pem:/app/secrets/agrofusion_sso_public.pem:ro
   ```
2. Quita las líneas `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` del `environment` del backend (solo si el paso 2 salió vacío).
3. Agrega una fila a la tabla de cambios del encabezado, con fecha 2026-11-07, nombre "Sebastián Sandoval (Implementación)" y la descripción "SSO AgroFusion: montar clave pública; quitar AGROFUSION_HUB_* (credenciales en BD desde RF-101)".

### 4. `.env.test.example`
1. Sobre las tres variables `AGROFUSION_*` del SSO, agrega el mismo comentario del paso 4 del brief 1. Las variables quedan con el mismo valor que tienen ahora.
2. Quita el bloque `# AgroFusion - integración M2M` con sus dos variables (solo si el paso 2 salió vacío).
3. Si el archivo tiene tabla de cambios, agrega una fila.

### 5. Verificar
```bash
docker compose -f docker-compose.test.yml config --no-interpolate --quiet && echo TEST-OK
docker compose -f docker-compose.test.yml config --no-interpolate | grep -n "agrofusion_sso_public"
grep -n "AGROFUSION_HUB" docker-compose.test.yml .env.test.example ; echo "codigo=$?"   # esperado: codigo=1 (sin coincidencias)
git diff --stat   # solo los dos archivos
```

### 6. Commit (sin push)
```bash
git add docker-compose.test.yml .env.test.example
git commit -m "chore(docker): montar clave publica del SSO AgroFusion en TEST y quitar AGROFUSION_HUB_*"
```

### 7. Registro y PR (en SGMP-Integracion, no en el backend)
- Guarda las salidas del paso 5 en `<HU>/evidencias/`, en un archivo con sufijo `-test`.
- Redacta la descripción del PR con la plantilla de `promocion-entornos` y guárdala en `<HU>/entregables/PR-test.md`. Usa las mismas instrucciones para Despliegue del brief 1, aplicadas al entorno TEST: subir el archivo antes del despliegue, cargar las dos variables y comprobar después del despliegue que el `.pem` se puede leer (`test -r`). Agrega una nota que explique por qué se quitan las variables `HUB` y aclare que en `main` siguen hasta que llegue la versión que las elimina del código.

## Reporte de vuelta

Detente y entrégame:
1. El `git diff` completo.
2. La salida del paso 2 y de las verificaciones del paso 5.
3. El borrador de la descripción del PR.
4. Cualquier hallazgo.
