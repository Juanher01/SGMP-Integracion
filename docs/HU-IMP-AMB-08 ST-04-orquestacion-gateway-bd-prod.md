# Subtarea ST-04 — Acordar la orquestación del Gateway AIoT y la Base de Datos en PROD

**HU:** HU-IMP-AMB-08 — Definición y entrega del ambiente PROD  
**Subtarea:** ST-04 — Acordar orquestación de Gateway AIoT y BD en PROD  
**Responsable:** Juan Sebastián Gutiérrez Tobar  
**Rama:** `feat/ambiente-prod`  
**Fecha:** 20 de agosto de 2026  

---

## 1. Propósito y alcance de la subtarea

Establecer y formalizar los acuerdos de orquestación, persistencia, seguridad y delimitación de operabilidad para las capas transversales de **Base de Datos (`DBIntegrador`)** y **AIoT (`gateway` + `mosquitto`)** en el Ambiente de Producción.

---

## 2. Orquestación de la Capa de Base de Datos en PROD

### 2.1 Definición técnica en Compose
La capa de base de datos en Producción se encuentra definida en `compose/compose.prod.yml` mediante el servicio `database`:

*   **Nombre de contenedor:** `sgpmp-database-prod`
*   **Imagen:** `${DATABASE_IMAGE}` (Imagen oficial o versión de PostgreSQL 18 distribuida vía GHCR)
*   **Red:** `sgpmp-network` (driver `bridge` aislado)
*   **Puerto host:** **No expuesto hacia el host** (Puerto interno `5432` en la red privada del contenedor)
*   **Comprobación de salud (*healthcheck*):** `pg_isready -U ${DB_ADMIN_USER:-dba} -d ${DB_NAME:-dba}`

### 2.2 Persistencia de datos y estrategia de Backups
1.  **Volumen Nominado:** Se especifica el volumen persistente `postgres-data` montado en la ruta `/var/lib/postgresql`.
2.  **Irreversibilidad de Datos:** A diferencia de DEV (datos de prueba) y TEST (datos reiniciables con `down -v`), los datos de Producción representan la operación real del sistema SGPMP y **nunca se destruyen ni reinician**.
3.  **Operación de Copias de Seguridad:** La ejecución automatizada de respaldos (*backups* periódicos con `pg_dump`) y los planes de recuperación ante desastres (*Disaster Recovery*) son responsabilidad operativa exclusiva del equipo de Despliegue en el servidor productivo.

### 2.3 Roles y Esquemas
*   **Esquemas:** La base contiene los esquemas `auditoria` y `modulo1` a `modulo9` (187 tablas base).
*   **Roles de Conexión:**
    *   `member_app` (`DB_APP_USER`, `DB_APP_PASSWORD`): Acceso restringido para las consultas del Backend.
    *   `member_iot` (`DB_IOT_USER`, `DB_IOT_PASSWORD`): Acceso restringido a los esquemas `modulo3` y `modulo9` para la ingestión del Gateway.
    *   `member_deploy`: Rol de administración para mantenimiento por el equipo de Despliegue.

---

## 3. Orquestación de la Capa AIoT (Gateway + Mosquitto) en PROD

### 3.1 Definición técnica del Gateway AIoT
El servicio `gateway` en `compose/compose.prod.yml` desacopla la comunicación MQTT de la aplicación web:

*   **Nombre de contenedor:** `sgpmp-gateway-prod`
*   **Imagen:** `${GATEWAY_IMAGE}` (Imagen versionada en GHCR provista por el equipo de AIoT)
*   **Variables de entorno:**
    *   `ENVIRONMENT: prod`
    *   `DATABASE_URL: postgresql+asyncpg://${DB_IOT_USER}:${DB_IOT_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`
    *   `API_TOKEN: ${GATEWAY_API_TOKEN}`
*   **Healthcheck:** Comprobación activa en `http://127.0.0.1:8000/v1/healthz`
*   **Seguridad:** En Producción se exige el encabezado `Authorization: Bearer <GATEWAY_API_TOKEN>` para todas las peticiones a la API del Gateway (`POST /v1/commands` y `GET /v1/devices`).

### 3.2 Definición técnica del Broker Mosquitto (MQTT con TLS)
*   **Nombre de contenedor:** `sgpmp-mosquitto-prod`
*   **Imagen:** `eclipse-mosquitto:2`
*   **Seguridad Cifrada (TLS):** En Producción se fija `MQTT_TLS=true` en `.env.prod`.
*   **Certificados SSL/TLS:** La provisión de certificados válidos, llaves privadas y la configuración de `mosquitto.conf` con `allow_anonymous false` es responsabilidad compartida entre el equipo de AIoT (definición de seguridad) y el equipo de Despliegue (montaje en el servidor).

---

## 4. Matriz de Responsabilidades y Frontera en Producción

| Capa / Componente | Implementación (Juan Sebastián) | Despliegue (Dokploy) | DBA (Samuel) | AIoT |
|---|---|---|---|---|
| **Definición Compose Base + Override PROD** | Entrega `compose.prod.yml` | Despliega e interpreta el YAML | N/A | N/A |
| **Catálogo de Variables (`.env.prod.example`)** | Entrega catálogo de 48 vars | Inyecta secretos en Dokploy | Provee `DB_APP_*` / `DB_IOT_*` | Provee `GATEWAY_API_TOKEN` |
| **Imágenes Docker (GHCR)** | N/A (Consume referencias) | Configura la descarga desde GHCR | Provee tag de PostgreSQL | Provee tag del Gateway |
| **Persistencia y Backups BD** | Define volumen `postgres-data` | Ejecuta políticas de `pg_dump` | Valida esquemas y roles | N/A |
| **Seguridad MQTT / Certificados TLS** | Configura `MQTT_TLS=true` | Monta certificados en el servidor | N/A | Provee credenciales y certs |
| **Exposición Web (HTTPS / Proxy)** | Omite `ports:` en Compose | Administra Nginx / Dokploy Proxy | N/A | N/A |

---

## 5. Estado de cierre de ST-04 PROD

- [x] Definición técnica de la orquestación del Gateway AIoT en Producción documentada.
- [x] Requisitos de cifrado SSL/TLS (`MQTT_TLS=true`) y autenticación de Mosquitto formalizados.
- [x] Definición del almacenamiento persistente de BD (`postgres-data`) y deslinde de backups documentado.
- [x] Matriz de delimitación de responsabilidades de operabilidad entre Implementación, Despliegue, DBA y AIoT formalizada.
- [ ] Inyección final de certificados TLS y contraseñas de producción — *Pendiente de Despliegue / AIoT / DBA*.
- [ ] Commit en Git — *Pendiente de revisión manual por el responsable Juan Sebastián Gutiérrez Tobar*.

**ST-04 de HU-IMP-AMB-08 queda ejecutado y documentado en el repositorio local.**
