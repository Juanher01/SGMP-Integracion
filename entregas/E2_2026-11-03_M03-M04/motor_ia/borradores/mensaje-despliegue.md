# Borrador — mensaje a Despliegue: valores para Dokploy del motor M04

> Estado: borrador (no enviado) · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

---

Hola, equipo de Despliegue:

Les comparto los valores para configurar los servicios `motor-ia-dev`, `motor-ia-test` y
`motor-ia-main` cuando se fusione el PR #54 del broker. El detalle completo está en
`SGMP-Integracion/entregas/E2_2026-11-03_M03-M04/motor_ia/docs/volumen-limites.md` y `variables.md`.

**Build**
- Tipo Application (Dockerfile). ¿Nos confirman que así crearon los tres servicios?
- Dockerfile `Dockerfile.motor-ia`, contexto en la raíz del repo del broker.
- Ramas: DEV `develop`, TEST `test`, PROD `main`. Hoy `main` todavía no tiene el código del motor.

**Red**
- Puerto del contenedor: 8000.
- Strip Path activo en los tres.
- En TEST, revisar que el path sea `/motor-ia-test`, con la `/` inicial.

**Volumen y recursos**
- Volumen montado en `/data/modelos`. Si es bind mount, la carpeta debe ser del UID 1001.
- CPU: límite 1.0. Memoria: límite 1 GB, reserva 256 MB. Son valores provisionales.
- El healthcheck ya viene en la imagen.

**Variables del motor** (los valores los cargan ustedes)
- `IOT_INFERENCIA_M04_TOKEN`: secreto, distinto por ambiente e igual al del backend de ese ambiente.
  Sin él, el motor no arranca.
- `BACKEND_URL`: DEV `https://api.inmero.co/api-sgpmp-dev` · TEST `…/api-sgpmp-test` · PROD `…/sigab`.
- `MOTOR_IA_DIR_MODELOS`: **no la carguen en el primer despliegue.** Si está definida y el volumen no
  tiene `catalogo.json`, el motor no arranca.
- Opcional: `UVICORN_ROOT_PATH=/motor-ia-dev` (o el path de cada ambiente), solo para Swagger.

**Orden**
1. Desplegar DEV y comprobar `https://api.inmero.co/motor-ia-dev/v1/healthz` → `"modelos_cargados": 0`.
2. Cuando haya catálogo (bloqueado por RFC-010), copiar los archivos al volumen, definir
   `MOTOR_IA_DIR_MODELOS=/data/modelos` y redesplegar.
3. **Solo cuando `modelos_cargados` sea mayor que 0**, cargar en el backend `IOT_INFERENCIA_M04_URL`
   (URL base, sin barra final: `https://api.inmero.co/motor-ia-dev`), con su token, TLS 1.3 y CA vacía.
   Antes, el backend necesita el PR de variables (Arekkazu/sgpmp-backend#909) en la rama de ese
   ambiente: como el backend corre como Compose, sin él las variables no llegan al contenedor.

Después, TEST y PROD en ese orden.

Gracias,
Sebastián Sandoval Chavarro — Implementación
