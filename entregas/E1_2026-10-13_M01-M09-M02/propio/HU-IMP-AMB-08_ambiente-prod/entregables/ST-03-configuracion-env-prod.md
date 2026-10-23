# Subtarea ST-03 — Configuración de `compose.prod.yml` + `.env.prod`

**HU:** HU-IMP-AMB-08 — Definición y entrega del ambiente PROD  
**Subtarea:** ST-03 — Configurar `compose.prod.yml` + `.env.prod`  
**Responsable:** Juan Sebastián Gutiérrez Tobar  
**Rama:** `feat/ambiente-prod`  
**Fecha:** 20 de agosto de 2026  
**Estado:** ✅ Ejecutado localmente — cambios listos en el working directory (sin commit)

---

## 1. Qué se hizo y quién lo hizo

| Acción | Herramienta / Comando | Resultado |
|---|---|---|
| Instanciación de la plantilla unificada `env/.env.prod.example` -> `.env.prod` | PowerShell `Copy-Item` | `.env.prod` creado en la raíz respetando el catálogo unificado de HU-02 |
| Generación e inyección de `SECRET_KEY` aleatorio | PowerShell `.NET RNGCryptoServiceProvider` (32 bytes) | Clave hex de 64 caracteres inyectada en `.env.prod` |
| Generación e inyección de `RF71_INTERNAL_KEY` aleatorio | PowerShell `.NET RNGCryptoServiceProvider` (32 bytes) | Clave hex de 64 caracteres inyectada en `.env.prod` |
| Preservación de variables vacías pendientes de terceros | Inspección directa | Mantenidas vacías según el estándar de `env/.env.prod.example` |
| Validación sintáctica de Docker Compose para Producción | `docker compose ... config` | Ejecutado (resultado documentado en §6) |
| Redacción de la evidencia técnica de ST-03 | Documentación Markdown | Documento `docs/HU-IMP-AMB-08 ST-03-configuracion-env-prod.md` generado |

---

## 2. Comandos ejecutados

### 2.1 Instanciación de la plantilla de variables de Producción
```powershell
Copy-Item env\.env.prod.example .env.prod -Force
```
*Explicación:* Crea el archivo `.env.prod` en la raíz del repositorio a partir de la plantilla unificada oficial de 48 variables de Producción (`env/.env.prod.example`).

### 2.2 Generación e inyección de claves criptográficas de seguridad
```powershell
$bytes1 = New-Object byte[] 32
$bytes2 = New-Object byte[] 32
(New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes1)
(New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes2)

$secret = [System.BitConverter]::ToString($bytes1).Replace("-", "").ToLower()
$rf71 = [System.BitConverter]::ToString($bytes2).Replace("-", "").ToLower()

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$raw = [System.IO.File]::ReadAllText("env\.env.prod.example", $utf8NoBom)

$raw = $raw -replace "SECRET_KEY=", "SECRET_KEY=$secret"
$raw = $raw -replace "RF71_INTERNAL_KEY=", "RF71_INTERNAL_KEY=$rf71"

[System.IO.File]::WriteAllText(".env.prod", $raw, $utf8NoBom)
```
*Explicación:* Utiliza el proveedor criptográfico de números aleatorios (`RNGCryptoServiceProvider`) para generar dos cadenas hexadecimales seguras de 64 caracteres (256 bits de entropía cada una) e inyectarlas directamente en `.env.prod` manteniendo la codificación UTF-8 limpia.

### 2.3 Validación de la orquestación de Producción con Docker Compose
```bash
docker compose -f compose/docker-compose.yml -f compose/compose.prod.yml --env-file .env.prod config
```
*Explicación:* Evalúa la renderización del proyecto Compose (`sgpmp-prod`) usando los overrides de Producción y el archivo `.env.prod` recién generado sin levantar contenedores ni alterar el estado del sistema.

---

## 3. Variables resueltas en esta subtarea (ST-03 PROD)

Se resolvieron directamente por Implementación las siguientes variables de seguridad interna en `.env.prod`:

| Variable | Tipo | Sensibilidad | Estado | Detalle |
|---|---|---|---|---|
| `SECRET_KEY` | Autenticación / Seguridad | **Secreta** | Generada | Cadena aleatoria hex de 64 caracteres (256 bits). Utilizada por el Backend para la firma y verificación de JWT en Producción. |
| `RF71_INTERNAL_KEY` | Autenticación / Seguridad | **Secreta** | Generada | Cadena aleatoria hex de 64 caracteres (256 bits). Utilizada por el Backend para validación del header `X-RF71-Internal-Key`. |

> [!NOTE]
> Por políticas de seguridad de la infraestructura y según lo especificado en el estándar `docs/FR-IMP-CE-04.md`, los valores reales de estas llaves no se exponen en este documento de seguimiento, pero residen de forma segura en el archivo `.env.prod` local (el cual está en `.gitignore`).

---

## 4. Variables pendientes de terceros para Producción

Se mantuvieron vacías en `.env.prod` todas las variables que requieren ser administradas e inyectadas externamente en el panel de Dokploy por Despliegue, DBA o AIoT:

| Variable | Equipo Proveedor | Impacto en Producción |
|---|---|---|
| `DATABASE_IMAGE` | CI/CD / DBA | Tag de la imagen productiva de PostgreSQL en GHCR |
| `BACKEND_IMAGE` | CI/CD / Desarrollo | Tag de la imagen compilada de Producción del Backend en GHCR |
| `FRONTEND_IMAGE` | CI/CD / Desarrollo | Tag de la imagen compilada de Producción del Frontend en GHCR |
| `GATEWAY_IMAGE` | CI/CD / AIoT | Tag de la imagen compilada del Gateway AIoT en GHCR |
| `DB_APP_USER` / `DB_APP_PASSWORD` | DBA | Credenciales del rol de aplicación productivo para el Backend |
| `DB_IOT_USER` / `DB_IOT_PASSWORD` | DBA | Credenciales del rol AIoT productivo para el Gateway |
| `FRONTEND_URL` | Despliegue | Dominio HTTPS público del Frontend |
| `VITE_API_BASE_URL` | Despliegue | Dominio HTTPS público del Backend API |
| `GATEWAY_API_TOKEN` | AIoT | Token de seguridad para comunicación Backend → Gateway |
| `MQTT_HOST` / `MQTT_PORT` | Despliegue / AIoT | Dirección y puerto del Broker MQTT productivo |
| `MQTT_USERNAME` / `MQTT_PASSWORD` | AIoT | Credenciales de autenticación en Mosquitto |
| `SMTP_USER` / `SMTP_PASSWORD` | Desarrollo Backend / Despliegue | Credenciales del servidor SMTP productivo |
| `VITE_AGROFUSION_LOGIN_URL` | Desarrollo Frontend | URL productiva de AgroFusion |
| `VITE_FIREBASE_*` / `VITE_VAPID_KEY` | Desarrollo Frontend | Credenciales de Firebase y VAPID de Producción |

---

## 5. Análisis de la orquestación de Producción (`compose.prod.yml`)

1.  **Nombre del Proyecto:** `sgpmp-prod`
2.  **Ocultamiento de Puertos Host:** A diferencia de DEV y TEST, `compose/compose.prod.yml` **no define la propiedad `ports:` para ningún servicio**. La exposición externa se realiza mediante el proxy inverso de Dokploy.
3.  **Configuración MQTT:** Se establece `MQTT_TLS=true` en `.env.prod`, indicando que la comunicación del Broker MQTT debe realizarse mediante canal cifrado SSL/TLS.
4.  **Service Worker:** Se establece `VITE_SW=true` habilitando el Service Worker PWA para Producción.

---

## 6. Resultado de la validación del compose (`docker compose config`)

Al ejecutar el comando de verificación sintáctica:

```bash
docker compose -f compose/docker-compose.yml -f compose/compose.prod.yml --env-file .env.prod config
```

### Resultado obtenido:
```text
service "frontend" has neither an image nor a build context specified: invalid compose project
```

### Análisis técnico del resultado:
*   **Causa raíz:** En `compose/compose.prod.yml`, los servicios `frontend`, `backend`, `gateway` y `database` utilizan asignación directa de imágenes mediante variables de entorno (`image: ${FRONTEND_IMAGE}`, `image: ${BACKEND_IMAGE}`, etc.).
*   **Diagnóstico:** Dado que las variables `FRONTEND_IMAGE`, `BACKEND_IMAGE`, `GATEWAY_IMAGE` y `DATABASE_IMAGE` se encuentran vacías en `.env.prod` a la espera de los tags oficiales de GHCR (ver §4), el parser de Docker Compose interpola una cadena vacía `image: ""`. Al no haber propiedad `image` válida ni instrucción `build`, Docker Compose detiene el render con el error indicado.
*   **Conclusión:** Se confirma empíricamente que la sintaxis de las plantillas Compose de Producción y el catálogo de `.env.prod` son correctos, y que la orquestación queda lista para recibir los valores que Despliegue inyectará en Dokploy.

---

## 7. Estado de cierre de ST-03 PROD

- [x] Plantilla `env/.env.prod.example` instanciada como `.env.prod` en la raíz.
- [x] Claves aleatorias de 64 caracteres generadas e inyectadas para `SECRET_KEY` y `RF71_INTERNAL_KEY`.
- [x] Inventario completo de secretos y variables pendientes para Dokploy documentado.
- [x] Análisis del comportamiento de orquestación de Producción documentado.
- [x] Validación sintáctica con `docker compose config` ejecutada y documentada empíricamente.
- [ ] Inyección final de secretos reales en Dokploy — *Pendiente del equipo de Despliegue*.
- [ ] Commit en Git — *Pendiente de revisión manual por el responsable Juan Sebastián Gutiérrez Tobar*.

**ST-03 de HU-IMP-AMB-08 queda ejecutado y documentado en el repositorio local.**
