# FR-IMP-CE-04
## Catálogo y clasificación de variables de entorno

**Proyecto:**SGPMP
**Historia relacionada:**HU-IMP-AMB-02
**Rama:**`feat/env-unificado`
**Estado:** Elaborado

---

## 1. Propósito

Registrar formalmente las variables de entorno que conforman el contrato de configuración de los ambientes DEV, TEST y PROD, indicando su componente consumidor, tipo funcional, sensibilidad y criterio de manejo.

---

## 2. Alcance

El registro comprende las variables utilizadas por:

```text
Docker Compose
PostgreSQL
Backend
Frontend
Gateway AIoT
Mosquitto / MQTT
Servicios auxiliares del backend
```

No incluye valores secretos reales.

---

## 3. Resumen de clasificación

### Conexión

Incluye:

```text
DB_HOST
DB_PORT
DB_NAME
FRONTEND_URL
SMTP_HOST
SMTP_PORT
VITE_API_BASE_URL
VITE_AGROFUSION_LOGIN_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_APP_ID
MQTT_HOST
MQTT_PORT
```

### Comportamiento

Incluye:

```text
ENVIRONMENT
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE
JWT_EXPIRE_HOURS
VITE_SW
MQTT_RECONNECT_DELAY
```

### Autenticación / Seguridad

Incluye:

```text
DB_ADMIN_USER
DB_APP_USER
DB_APP_PASSWORD
DB_IOT_USER
DB_IOT_PASSWORD
SECRET_KEY
RF71_INTERNAL_KEY
FIREBASE_CREDENTIALS_PATH
SMTP_USER
SMTP_PASSWORD
VITE_VAPID_KEY
GATEWAY_API_TOKEN
MQTT_USERNAME
MQTT_PASSWORD
MQTT_TLS
```

### AIoT / Analítica

Incluye:

```text
DB_SCHEMA_INGEST
DB_SCHEMA_REGISTRY
MODELOS_STORAGE_PATH
MQTT_CLIENT_ID
MQTT_TOPIC_PREFIX
MQTT_TOPIC_TELEMETRY
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_COMMAND
MQTT_TOPIC_STATUS
```

---

## 4. Variables secretas

Las siguientes variables se clasifican como **Secreta** y nunca deben versionarse con un valor real:

```text
DB_APP_PASSWORD
DB_IOT_PASSWORD
SECRET_KEY
RF71_INTERNAL_KEY
SMTP_PASSWORD
GATEWAY_API_TOKEN
MQTT_PASSWORD
```

Sus valores deben suministrarse mediante `.env` locales ignorados, secretos del entorno de despliegue o mecanismos equivalentes.

---

## 5. Configuración interna

Se consideran de configuración interna, aunque no son contraseñas:

```text
DATABASE_IMAGE
BACKEND_IMAGE
FRONTEND_IMAGE
GATEWAY_IMAGE
DB_HOST
DB_NAME
DB_ADMIN_USER
DB_APP_USER
DB_IOT_USER
DB_SCHEMA_INGEST
DB_SCHEMA_REGISTRY
FRONTEND_URL
FIREBASE_CREDENTIALS_PATH
SMTP_HOST
SMTP_USER
MODELOS_STORAGE_PATH
MQTT_HOST
MQTT_USERNAME
MQTT_CLIENT_ID
MQTT_TOPIC_PREFIX
MQTT_TOPIC_TELEMETRY
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_COMMAND
MQTT_TOPIC_STATUS
```

---

## 6. Variables públicas/no sensibles

Pueden documentarse mediante valores de ejemplo porque no representan secretos:

```text
ENVIRONMENT
DB_PORT
JWT_EXPIRE_HOURS
SMTP_PORT
VITE_API_BASE_URL
VITE_SW
VITE_AGROFUSION_LOGIN_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_APP_ID
VITE_VAPID_KEY
MQTT_PORT
MQTT_TLS
MQTT_RECONNECT_DELAY
```

**Nota:** que una variable `VITE_*` sea no secreta es además una condición necesaria, dado que su valor puede quedar expuesto en el bundle del cliente.

---

## 7. Convención por ambiente

| Elemento | DEV | TEST | PROD |
|---|---|---|---|
| `ENVIRONMENT` | `dev` | `test` | `prod` |
| BD interna | `database:5432/dba` | `database:5432/dba` | `database:5432/dba` |
| Frontend URL backend | `http://localhost:5173` | `http://localhost:8081` | externa |
| API frontend | `http://localhost:8000` | `http://localhost:8001` | externa |
| Service Worker | `false` | `false` | `true` |
| MQTT TLS | `false` | `false` | `true` |
| Imágenes de registry | No obligatorias para build local | Requeridas | Requeridas |

---

## 8. Convención PostgreSQL

El contrato unificado utiliza:

```text
DB_HOST=database
DB_PORT=5432
DB_NAME=dba
DB_ADMIN_USER=dba
```

Los roles de aplicación y AIoT se mantienen separados:

```text
DB_APP_USER
DB_APP_PASSWORD

DB_IOT_USER
DB_IOT_PASSWORD
```

Los valores definitivos de dichos roles deben ser entregados por las historias responsables de la capa de datos.

---

## 9. Convención MQTT

Contrato común:

```text
MQTT_HOST
MQTT_PORT
MQTT_USERNAME
MQTT_PASSWORD
MQTT_TLS
MQTT_CLIENT_ID
MQTT_RECONNECT_DELAY
MQTT_TOPIC_PREFIX
MQTT_TOPIC_TELEMETRY
MQTT_TOPIC_HEARTBEAT
MQTT_TOPIC_COMMAND
MQTT_TOPIC_STATUS
```

DEV y TEST trabajan actualmente con TLS desactivado; PROD exige TLS habilitado.

La autenticación real de producción debe suministrarse externamente.

---

## 10. Convención JWT

El backend consume:

```text
SECRET_KEY
JWT_EXPIRE_HOURS
```

El algoritmo JWT no es configurable por variable de entorno en la versión actual del backend; se encuentra fijado como `HS256`.

Por este motivo no forman parte del catálogo:

```text
JWT_SECRET_KEY
JWT_ALGORITHM
```

---

## 11. Evidencias de consistencia

Se validó que:

1. DEV, TEST y PROD contienen el mismo conjunto de nombres de variables.
2. No existen variables interpoladas por Compose ausentes del catálogo.
3. Las variables obsoletas `DEBUG` y `LOG_LEVEL` fueron retiradas.
4. Las variables backend reales `FRONTEND_URL`, `FIREBASE_CREDENTIALS_PATH`, `SMTP_*` y `MODELOS_STORAGE_PATH` fueron incorporadas.
5. DEV y TEST pasan `docker compose config --quiet`.
6. Las variables secretas permanecen sin valores reales en los archivos versionados.

---

## 12. Resultado

El registro FR-IMP-CE-04 queda establecido como evidencia de que HU-IMP-AMB-02 dispone de un contrato único de configuración para DEV, TEST y PROD, con clasificación funcional y de sensibilidad.
