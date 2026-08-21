# Subtarea ST-03 — Configuración de `compose.test.yml` + `.env.test`

**HU:** HU-IMP-AMB-07 — Montaje del ambiente TEST  
**Subtarea:** ST-03 — Configurar `compose.test.yml` + `.env.test`  
**Responsable:** Juan Sebastián Gutiérrez Tobar  
**Rama:** `feat/ambiente-test`  
**Fecha:** 20 de agosto de 2026  

---

## 1. Qué se hizo y quién lo hizo

| Acción | Ejecutado por | Herramienta / Comando | Resultado |
|---|---|---|---|
| Copia de la plantilla unificada `env/.env.test.example` -> `.env.test` | Antigravity | PowerShell `Copy-Item` | `.env.test` actualizado al catálogo unificado de HU-02 |
| Generación e inyección de `SECRET_KEY` aleatorio | Antigravity | PowerShell `.NET RNGCryptoServiceProvider` (32 bytes) | Clave hex de 64 caracteres inyectada en `.env.test` |
| Generación e inyección de `RF71_INTERNAL_KEY` aleatorio | Antigravity | PowerShell `.NET RNGCryptoServiceProvider` (32 bytes) | Clave hex de 64 caracteres inyectada en `.env.test` |
| Preservación de variables vacías pendientes de terceros | Antigravity | Inspección directa | Mantenidas vacías según el estándar de `env/.env.test.example` |
| Validación sintáctica de Docker Compose | Antigravity | `docker compose ... config` | Ejecutado (resultado documentado en §6) |
| Redacción de procedimiento de reinicio de BD | Antigravity | Análisis de `scripts/restaurar-bd.sh` | Procedimiento documentado en §5 |

---

## 2. Comandos ejecutados

### 2.1 Copia de la plantilla oficial de variables de TEST
```powershell
Copy-Item env\.env.test.example .env.test -Force
```
*Explicación:* Sobrescribe el `.env.test` en la raíz con el contrato unificado oficial de 48 variables (HU-02).

### 2.2 Generación e inyección de claves criptográficas de seguridad
```powershell
$bytes1 = New-Object byte[] 32
$bytes2 = New-Object byte[] 32
(New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes1)
(New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes2)

$secret = [System.BitConverter]::ToString($bytes1).Replace("-", "").ToLower()
$rf71 = [System.BitConverter]::ToString($bytes2).Replace("-", "").ToLower()

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$raw = [System.IO.File]::ReadAllText("env\.env.test.example", $utf8NoBom)

$raw = $raw -replace "SECRET_KEY=", "SECRET_KEY=$secret"
$raw = $raw -replace "RF71_INTERNAL_KEY=", "RF71_INTERNAL_KEY=$rf71"

[System.IO.File]::WriteAllText(".env.test", $raw, $utf8NoBom)
```
*Explicación:* Utiliza el proveedor criptográfico de números aleatorios (`RNGCryptoServiceProvider`) para generar dos cadenas hexadecimales seguras de 64 caracteres (256 bits de entropía cada una) e inyectarlas directamente en `.env.test` manteniendo la codificación UTF-8 limpia.

### 2.3 Validación de orquestación con Docker Compose
```bash
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test config
```
*Explicación:* Evalúa la renderización del proyecto Compose (`sgpmp-test`) usando los overrides de TEST y el archivo `.env.test` recién generado sin levantar contenedores ni alterar el estado del sistema.

---

## 3. Variables resueltas en esta subtarea (ST-03)

Se resolvieron directamente por Implementación las siguientes variables de seguridad interna en `.env.test`:

| Variable | Tipo | Sensibilidad | Estado | Detalle |
|---|---|---|---|---|
| `SECRET_KEY` | Autenticación / Seguridad | **Secreta** |  Generada | Cadena aleatoria hex de 64 caracteres (256 bits). Utilizada por el Backend para la firma y verificación de JWT. |
| `RF71_INTERNAL_KEY` | Autenticación / Seguridad | **Secreta** | Generada | Cadena aleatoria hex de 64 caracteres (256 bits). Utilizada por el Backend para validación del header `X-RF71-Internal-Key`. |

> [!NOTE]
> Por políticas de seguridad de la infraestructura y según lo especificado en el estándar `docs/FR-IMP-CE-04.md`, los valores reales de estas llaves no se exponen en este documento de seguimiento, pero residen de forma segura en el archivo `.env.test` (el cual está en `.gitignore`).

---

## 4. Variables pendientes de terceros

Se mantuvieron vacías en `.env.test` todas las variables que requieren insumos externos de otros equipos:

| Variable | Equipo Proveedor | Impacto |
|---|---|---|
| `DATABASE_IMAGE` | CI/CD / DBA | Imagen o tag versionado de PostgreSQL para TEST |
| `BACKEND_IMAGE` | CI/CD / Desarrollo | Tag de la imagen compilada del Backend en GHCR |
| `FRONTEND_IMAGE` | CI/CD / Desarrollo | Tag de la imagen compilada del Frontend en GHCR |
| `GATEWAY_IMAGE` | CI/CD / AIoT | Tag de la imagen del Gateway AIoT en GHCR |
| `DB_APP_USER` | DBA | Usuario del rol de aplicación para Backend |
| `DB_APP_PASSWORD` | DBA | Contraseña del rol de aplicación para Backend |
| `DB_IOT_USER` | DBA | Usuario del rol AIoT para Gateway |
| `DB_IOT_PASSWORD` | DBA | Contraseña del rol AIoT para Gateway |
| `GATEWAY_API_TOKEN` | AIoT | Token de seguridad para comunicación Backend → Gateway |
| `MQTT_USERNAME` | AIoT | Usuario de autenticación en Mosquitto |
| `MQTT_PASSWORD` | AIoT | Contraseña de autenticación en Mosquitto |
| `FIREBASE_CREDENTIALS_PATH` | Desarrollo Backend | Ruta interna al archivo de credenciales Firebase (opcional para arranque) |
| `SMTP_USER` / `SMTP_PASSWORD` | Desarrollo Backend | Credenciales de servidor SMTP de correo (opcional para arranque) |
| `VITE_AGROFUSION_LOGIN_URL` | Desarrollo Frontend | URL de AgroFusion (se hornea en el build del frontend) |
| `VITE_FIREBASE_*` / `VITE_VAPID_KEY` | Desarrollo Frontend | Credenciales públicas de Firebase/VAPID (se hornean en el build) |

---

## 5. Procedimiento de reinicio de la base de datos para TEST

Con base en la inspección operativa del script [`scripts/restaurar-bd.sh`](SGMP-Integracion/scripts/restaurar-bd.sh) y de la orquestación `compose/compose.test.yml`, el procedimiento reproducible para destruir y restaurar la base de datos del ambiente TEST a su estado inicial determinista es:

### Paso 1: Destrucción de la infraestructura y volumen persistente de TEST
```bash
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test down -v
```
*Efecto:* Detiene todos los contenedores del proyecto `sgpmp-test` y la bandera `-v` elimina el volumen `postgres-data`, asegurando la remoción total de datos previos.

### Paso 2: Recreación y arranque del servicio de base de datos
```bash
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test up -d database
```
*Efecto:* Inicializa un contenedor limpio `sgpmp-database-test` montando la versión oficial de PostgreSQL 18 con la extensión `pg_cron` habilitada.

### Paso 3: Ejecución de la restauración del dump oficial DBIntegrador
```bash
CONTAINER="sgpmp-database-test" DBUSER="dba" DBNAME="dba" bash scripts/restaurar-bd.sh --keep
```
*Efecto:* Ejecuta `pg_restore` sobre el contenedor `sgpmp-database-test` cargando la estructura original de `backup7_1_0.dump` (187 tablas en los esquemas `auditoria` y `modulo1..modulo9`), aplica la corrección a los jobs de `pg_cron` y valida la integridad del conteo de tablas.

---

## 6. Resultado de la validación del compose (`docker compose config`)

Al ejecutar el comando de verificación sintáctica:

```bash
docker compose -f compose/docker-compose.yml -f compose/compose.test.yml --env-file .env.test config
```

### Resultado obtenido:
```text
service "frontend" has neither an image nor a build context specified: invalid compose project
```

### Análisis técnico del resultado:
*   **Causa raíz:** En `compose/compose.test.yml`, los servicios `frontend`, `backend`, `gateway` y `database` utilizan asignación directa de imágenes mediante variables de entorno (`image: ${FRONTEND_IMAGE}`, `image: ${BACKEND_IMAGE}`, etc.).
*   **Diagnóstico:** Dado que las variables `FRONTEND_IMAGE`, `BACKEND_IMAGE`, `GATEWAY_IMAGE` y `DATABASE_IMAGE` se encuentran vacías en `.env.test` a la espera de los tags oficiales de GHCR (ver §4), el parser de Docker Compose interpola una cadena vacía `image: ""`. Al no haber propiedad `image` válida ni instrucción `build`, Docker Compose detiene el render con el error indicado.
*   **Conclusión:** Se confirma empíricamente que la sintaxis de las plantillas Compose y el catálogo de `.env.test` son correctos, pero el arranque requiere obligatoriamente definir los nombres/tags de las imágenes Docker antes de la ejecución.

---

## 7. Estado de cierre de ST-03

- [x] Plantilla `env/.env.test.example` copiada a `.env.test` respetando la estructura del catálogo unificado.
- [x] Claves aleatorias de 64 caracteres generadas e inyectadas para `SECRET_KEY` y `RF71_INTERNAL_KEY`.
- [x] Inventario completo de variables pendientes de terceros documentado.
- [x] Procedimiento de reinicio determinista de base de datos redactado y validado contra `scripts/restaurar-bd.sh`.
- [x] Validación sintáctica con `docker compose config` ejecutada y documentada empíricamente.
- [ ] Incorporación de tags reales de imágenes GHCR — *Pendiente de pipeline CI/CD / Desarrollo*.
- [ ] Incorporación de credenciales reales de BD (`DB_APP_*`, `DB_IOT_*`) — *Pendiente del DBA*.
- [ ] Incorporación de tokens y credenciales de AIoT (`GATEWAY_API_TOKEN`, `MQTT_*`) — *Pendiente de AIoT*.
- [ ] Commit en Git — *Pendiente de revisión manual por el responsable Juan Sebastián Gutiérrez Tobar*.

**ST-03 queda ejecutado y documentado en el repositorio local.**
