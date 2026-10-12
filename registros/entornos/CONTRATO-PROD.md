# Contrato de entrega del ambiente PROD y Frontera Implementación → Despliegue

**HU:** HU-IMP-AMB-08 — Definición y entrega del ambiente PROD  
**Subtarea:** ST-01 / ST-02 — Confirmar artefactos/equivalencia y redactar contrato de frontera  
**Responsable:** Juan Sebastián Gutiérrez Tobar  
**Ejecutado por:** Antigravity (bajo supervisión de Juan Sebastián Gutiérrez Tobar)  
**Rama:** `feat/ambiente-prod`  
**Fecha:** 20 de agosto de 2026  
**Fuente:** Análisis directo de `compose/docker-compose.yml`, `compose/compose.prod.yml`, `env/.env.prod.example`, `docs/VARIABLES-ENTORNO.md`, `docs/FR-IMP-CE-04.md` y acuerdos de frontera de Despliegue/Dokploy.

---

## 1. Principio de responsabilidad y frontera de entrega

**Implementación define y entrega la arquitectura Compose; Despliegue lo opera en Producción con Dokploy.**

*   **Delimitación de frontera:** Implementación es responsable de la arquitectura de orquestación, las plantillas Compose (`docker-compose.yml` + `compose.prod.yml`), el catálogo unificado de variables (`env/.env.prod.example`) y las comprobaciones de salud (*healthchecks*). Despliegue es responsable de aprovisionar la infraestructura física/cloud, administrar la herramienta Dokploy, gestionar el proxy inverso, inyectar los secretos reales y realizar la operación continua.
*   **Equivalencia de nomenclatura:** El ambiente que el equipo de Implementación y Pruebas valida como **TEST** es documentado y operado por el equipo de Despliegue bajo la nomenclatura de **STAGING**. Los contratos técnicos y la matriz de 48 variables son idénticos entre ambos.

---

## 2. Orquestación y levantamiento del ambiente

El comando de validación y renderización sintáctica para Producción se ejecuta desde la raíz del repositorio:

```bash
docker compose -f compose/docker-compose.yml -f compose/compose.prod.yml --env-file .env.prod config
```

*   **Proyecto Compose:** `sgpmp-prod`
*   **Red compartida:** `sgpmp-network` (driver: `bridge`)
*   **Volumen persistente de base de datos:** `postgres-data` (montado en `/var/lib/postgresql`)

---

## 3. Matriz de Servicios, Imágenes y Exposición de Puertos

A diferencia de DEV y TEST, el ambiente de Producción **no publica puertos directos hacia el host (`ports:` omitidos)** en el archivo Compose. La exposición de servicios hacia el exterior (CORS/HTTPS) es administrada directamente por el proxy inverso del panel de Dokploy.

| Capa | Contenedor | Puerto interno | Imagen (GHCR / Registry) | Healthcheck |
|---|---|:---:|---|---|
| **Base de datos** | `sgpmp-database-prod` | `5432` | `${DATABASE_IMAGE}` | `pg_isready -U ${DB_ADMIN_USER:-dba} -d ${DB_NAME:-dba}` |
| **Backend** | `sgpmp-backend-prod` | `8000` | `${BACKEND_IMAGE}` | Depende de `database` en estado `healthy` |
| **Frontend** | `sgpmp-frontend-prod` | `80` | `${FRONTEND_IMAGE}` | Depende de `backend` en estado `healthy` |
| **Gateway AIoT** | `sgpmp-gateway-prod` | `8000` | `${GATEWAY_IMAGE}` | `http://127.0.0.1:8000/v1/healthz` (depende de `database` y `mosquitto` `healthy`) |
| **Broker Mosquitto** | `sgpmp-mosquitto-prod` | `1883` / `9001` | `eclipse-mosquitto:2` | Comprobación en puerto 1883 (salud de red interna) |

---

## 4. Requisitos de Seguridad y Certificados TLS (Mosquitto & Gateway)

1.  **TLS Obligatorio:** Según la matriz de seguridad del proyecto SGPMP y el estándar `docs/FR-IMP-CE-04.md`, el ambiente de Producción fija la variable `MQTT_TLS=true`.
2.  **Configuración de Mosquitto:** El contenedor `sgpmp-mosquitto-prod` en Producción requiere un archivo `mosquitto.conf` autenticado (con `allow_anonymous false`) y la provisión de certificados SSL/TLS válidos. Despliegue y AIoT son los encargados de inyectar y montar el volumen con las llaves SSL/TLS correspondientes en la instancia productiva.
3.  **Seguridad del Gateway:** El Gateway opera con `ENVIRONMENT=prod` y exige autenticación mediante el header `Authorization: Bearer <GATEWAY_API_TOKEN>`.

---

## 5. Catálogo de Variables de Entorno de Producción

El catálogo completo de Producción vive en `env/.env.prod.example` (48 variables unificadas).

### 5.1 Variables con valores por defecto o comportamiento de Producción

| Variable | Valor | Descripción / Uso |
|---|---|---|
| `ENVIRONMENT` | `prod` | Identificador del ambiente productivo |
| `DB_HOST` | `database` | Host interno PostgreSQL en `sgpmp-network` |
| `DB_PORT` | `5432` | Puerto interno de PostgreSQL |
| `DB_NAME` | `dba` | Nombre de la base de datos integrada |
| `DB_ADMIN_USER` | `dba` | Usuario administrador para comprobaciones de salud |
| `DB_SCHEMA_INGEST` | `modulo3` | Esquema de ingestión telemetría AIoT |
| `DB_SCHEMA_REGISTRY` | `modulo9` | Esquema de registro de dispositivos AIoT |
| `JWT_EXPIRE_HOURS` | `24` | Duración de los tokens JWT |
| `VITE_SW` | `true` | Habilita el Service Worker PWA en Producción |
| `MQTT_TLS` | `true` | Habilita la comunicación cifrada SSL/TLS en MQTT |
| `MQTT_CLIENT_ID` | `sgpmp` | Identificador de cliente MQTT |
| `MQTT_RECONNECT_DELAY` | `5` | Tiempo de reconexión MQTT en segundos |
| `MQTT_TOPIC_*` | Prefix `sgpmp`, topics `telemetry`, `heartbeat`, `command`, `status` | Estructura unificada de topics MQTT |

### 5.2 Variables sin valor (Secretos y Configuración Externa de Producción)

Las siguientes variables deben ser administradas e inyectadas como **Secretos de Entorno** en Dokploy por el equipo de Despliegue / DBA / AIoT:

| Variable | Proveedor | Descripción |
|---|---|---|
| `DATABASE_IMAGE`, `BACKEND_IMAGE`, `FRONTEND_IMAGE`, `GATEWAY_IMAGE` | CI/CD / Registro GHCR | Tags definitivos de las imágenes compiladas en GHCR |
| `DB_APP_USER`, `DB_APP_PASSWORD` | DBA | Credenciales del rol de aplicación para el Backend |
| `DB_IOT_USER`, `DB_IOT_PASSWORD` | DBA | Credenciales del rol AIoT para el Gateway |
| `SECRET_KEY` | Implementación / DevOps | Clave privada de firma JWT en Backend (Generada en ST-03) |
| `RF71_INTERNAL_KEY` | Implementación / DevOps | Clave privada para seguridad interna RF71 (Generada en ST-03) |
| `FRONTEND_URL` | Despliegue | URL pública/dominio HTTPS del Frontend |
| `VITE_API_BASE_URL` | Despliegue | URL pública/dominio HTTPS del Backend API |
| `GATEWAY_API_TOKEN` | AIoT | Token de autenticación Backend → Gateway |
| `MQTT_HOST`, `MQTT_PORT` | Despliegue / AIoT | Host y puerto del Broker MQTT de Producción |
| `MQTT_USERNAME`, `MQTT_PASSWORD` | AIoT | Credenciales de autenticación en Broker MQTT |
| `SMTP_USER`, `SMTP_PASSWORD` | Desarrollo / Despliegue | Credenciales del servidor de correo SMTP productivo |

---

## 6. Construcción de Conexiones de Base de Datos

*   **Backend:** `postgresql://${DB_APP_USER}:${DB_APP_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`
*   **Gateway AIoT:** `postgresql+asyncpg://${DB_IOT_USER}:${DB_IOT_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`

---

## 7. Checklist de Entregables de la Frontera (Implementación → Despliegue)

| # | Entregable | Estado |
|---|---|:---:|
| 1 | Orquestación Compose Base + Override PROD (`docker-compose.yml` + `compose.prod.yml`) | ✅ Entregado |
| 2 | Catálogo unificado de variables de Producción (`env/.env.prod.example`) | ✅ Entregado |
| 3 | Documento de Frontera de Entrega (`docs/CONTRATO-PROD.md`) | ✅ Entregado |
| 4 | Ausencia de puertos publicados al host para compatibilidad con Dokploy | ✅ Entregado |
| 5 | Habilitación de TLS para MQTT (`MQTT_TLS=true`) | ✅ Entregado |
| 6 | Tags finales de imágenes GHCR publicadas por pipeline | 🟡 Pendiente CI/CD |
| 7 | Contraseñas reales de roles `member_app` y `member_iot` | 🟡 Pendiente DBA |
| 8 | Certificados SSL/TLS e inyección de secretos en Dokploy | 🟡 Pendiente Despliegue |

---

## 8. Estado de la Subtarea ST-01 y ST-02

- [x] Equivalencia TEST ≡ STAGING y modelo de responsabilidad con Despliegue formalizado.
- [x] Contrato de entrega del ambiente PROD y frontera redactado y documentado en `docs/CONTRATO-PROD.md`.
- [x] Matriz de servicios, imágenes GHCR y ocultamiento de puertos host para Dokploy especificada.
- [x] Catálogo de variables de Producción y requisitos TLS de Mosquitto auditados.
- [ ] Inyección de llaves de seguridad en `.env.prod` local y validación Compose PROD — *Corresponde a ST-03*.
- [ ] Documentación del acuerdo de orquestación Gateway/BD en PROD — *Corresponde a ST-04*.

**ST-01 y ST-02 de HU-IMP-AMB-08 quedan completadas y documentadas.**
