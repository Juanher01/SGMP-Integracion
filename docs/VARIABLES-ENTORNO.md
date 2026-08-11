# Variables de Entorno — Ecosistema SGPMP

## 1. Objetivo

Las variables de entorno permiten configurar el comportamiento del ecosistema SGPMP sin modificar el código fuente.

El grupo de Implementación define la convención de nombres y la separación de variables entre los ambientes DEV, TEST y PROD.

## 2. Ambientes

El ecosistema contempla tres ambientes con propósitos diferentes:

### DEV

Ambiente utilizado para desarrollo e integración local.

Permitirá levantar los componentes del sistema en los equipos de trabajo y realizar verificaciones de integración sin afectar los demás ambientes.

### TEST

Ambiente destinado a pruebas reproducibles.

Será utilizado tanto por el grupo de Pruebas como por el grupo de Implementación, respetando las responsabilidades de cada grupo.

Debe mantenerse aislado de DEV para que la ejecución de pruebas no modifique los datos utilizados durante la integración local.

### PROD

Ambiente destinado a representar la configuración final con la que el sistema será entregado al grupo de Despliegue.

No contendrá secretos reales dentro del repositorio.

## 3. Reglas generales

1. No se deben hardcodear credenciales, URLs técnicas ni secretos en el código.
2. Los archivos `.env.dev`, `.env.test` y `.env.prod` no deben versionarse.
3. Los archivos `.env.*.example` sí deben versionarse.
4. Ninguna variable expuesta al frontend mediante el prefijo `VITE_` puede contener secretos.
5. Los secretos de PROD deben suministrarse externamente durante el despliegue.
6. DEV y TEST deben utilizar bases de datos independientes.
7. Los nombres de las variables deben mantenerse iguales entre ambientes; únicamente cambia su valor.

## 4. Variables generales

| Variable   |      Servicio     | DEV     | TEST    | PROD    | Secreto | Descripción       |
|------------|-------------------|---------|---------|---------|---------|-------------------|
| `APP_ENV`  | Backend / Docker  | `dev`   | `test`  | `prod`  | No      | Ambiente activo   |
| `DEBUG`    | Backend           | `true`  | `false` | `false` | No      | Activa modo debug |
| `LOG_LEVEL`| Backend           | `DEBUG` | `INFO`  | `INFO`  | No      | Nivel de logs     |

## 5. Base de datos

|         Variable        |      DEV        |     TEST        |          PROD          | Secreto |          Descripción          |
|-------------------------|-----------------|-----------------|------------------------|---------|-------------------------------|
| `POSTGRES_HOST`         | `postgres-dev`  | `postgres-test` | Definido en despliegue | No      | Host PostgreSQL               |
| `POSTGRES_PORT`         | `5432`          | `5432`          | `5432`                 | No      | Puerto interno PostgreSQL     |
| `POSTGRES_HOST_PORT`    | `5432`          | `5433`          | Definido en despliegue | No      | Puerto mapeado en el Host     |
| `POSTGRES_DB`           | `sgpmp_dev`     | `sgpmp_test`    | Definido en despliegue | No      | Nombre de base                |
| `POSTGRES_USER`         | `sgpmp_dev`     | `sgpmp_test`    | Definido en despliegue | Sí*     | Usuario de base               |
| `POSTGRES_PASSWORD`     | Local           | Local TEST      | Externo                | Sí      | Contraseña de base            |

\* El nombre del usuario no necesariamente es secreto, pero se maneja junto con las credenciales de base de datos.

## 6. Backend

|        Variable       |    DEV    |     TEST   |          PROD          | Secreto |          Descripción           |
|-----------------------|-----------|------------|------------------------|---------|--------------------------------|
| `BACKEND_HOST`        | `0.0.0.0` | `0.0.0.0`  | `0.0.0.0`              | No      | Interfaz donde escucha FastAPI |
| `BACKEND_PORT`        | `8000`    | `8000`     | `8000`                 | No      | Puerto interno del backend     |
| `BACKEND_HOST_PORT`   | `8000`    | `8001`     | Definido en despliegue | No      | Puerto mapeado en el Host      |
| `JWT_SECRET_KEY`      | Local     | Local TEST | Externo                | Sí      | Clave para firma JWT           |
| `JWT_ALGORITHM`       | `HS256`   | `HS256`    | `HS256`                | No      | Algoritmo JWT                  |

## 7. Frontend

|       Variable      |          DEV            |   TEST   |      PROD      | Secreto |         Descripción          |
|---------------------|-------------------------|----------|----------------|---------|------------------------------|
| `VITE_APP_ENV`      | `dev`                   | `test`   | `prod`         | No      | Ambiente visible en frontend |
| `VITE_API_BASE_URL` | `http://localhost:8000` | URL TEST | URL productiva | No      | URL pública del backend      |
| `VITE_SW`           | `false`                 | `false`  | `true`         | No      | Activa Service Worker        |

## 8. Firebase Frontend

Las siguientes variables ya están contempladas por el frontend:

- `VITE_FIREBASE_API_KEY`
- `VITE_FIREBASE_AUTH_DOMAIN`
- `VITE_FIREBASE_PROJECT_ID`
- `VITE_FIREBASE_STORAGE_BUCKET`
- `VITE_FIREBASE_MESSAGING_SENDER_ID`
- `VITE_FIREBASE_APP_ID`
- `VITE_VAPID_KEY`

Aunque algunas claves de Firebase pueden aparecer en el bundle del cliente, no se deben almacenar secretos privados del servidor en variables `VITE_*`.

## 9. Puertos del host

Para evitar conflictos entre DEV y TEST:

|  Servicio  |   DEV  |  TEST  |
|------------|-------:|-------:|
| PostgreSQL | `5432` | `5433` |
| Backend    | `8000` | `8001` |
| Frontend   | `5173` | `5174` |

Los puertos internos de los contenedores pueden permanecer iguales.

## 10. Variables futuras

Las siguientes categorías podrán agregarse cuando el proyecto las requiera:

- SMTP
- MQTT
- Firebase Admin
- servicios externos
- almacenamiento
- observabilidad

Toda nueva variable debe registrarse primero en este documento.