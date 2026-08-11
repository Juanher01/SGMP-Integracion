# Procedimiento de Recepción — Implementación SGPMP

## 1. Objetivo

Establecer el proceso mediante el cual el grupo de Implementación recibe componentes previamente aprobados por el grupo de Pruebas.

## 2. Precondición

Ningún componente debe incorporarse a la rama de integración sin aprobación previa del grupo de Pruebas.

## 3. Información requerida

Toda entrega formal realizada por el equipo de Pruebas debe documentarse mediante el diligenciamiento completo del formulario oficial de recepción disponible en [FORMATO-RECEPCION.md].

## 4. Flujo

### Paso 1 — Liberación

Pruebas comunica que una versión de `dev` ha sido aprobada.

### Paso 2 — Identificación

Implementación registra el commit SHA o tag exacto aprobado.

### Paso 3 — Rama de integración

Se crea o actualiza `integration` exclusivamente desde esa versión aprobada.

### Paso 4 — Revisión técnica

Se identifican cambios en:

Backend:
- `requirements.txt`
- configuración
- migraciones
- contratos OpenAPI

Frontend:
- `package.json`
- variables Vite
- dependencias
- rutas API

### Paso 5 — Variables de entorno

Se comparan las necesidades del componente con la matriz oficial de variables de entorno.

Toda nueva variable debe documentarse antes de incorporarse.

### Paso 6 — Docker

Se crean o actualizan los Dockerfiles necesarios.

### Paso 7 — Docker Compose

Se incorporan los servicios aprobados al ecosistema.

### Paso 8 — Base de datos

Se conecta el componente con la instancia correspondiente de base de datos.

### Paso 9 — Ejecución

Se levanta el ambiente correspondiente.

### Paso 10 — Swagger/OpenAPI

Se verifican los contratos REST publicados por FastAPI.

### Paso 11 — Postman

Se ejecutan las solicitudes correspondientes.

### Paso 12 — Integraciones

Se verifican las interacciones entre:

- Frontend ↔ Backend
- Backend ↔ PostgreSQL
- Módulo ↔ Módulo
- Autenticación ↔ módulos protegidos
- Servicios externos cuando corresponda

### Paso 13 — DOC-01

Se compara la implementación recibida con las superficies registradas.

### Paso 14 — Evidencias

Se almacenan logs, requests, responses y capturas relevantes.

### Paso 15 — Resultado

La superficie se actualiza a:

`PENDIENTE → RECIBIDO → VERIFICADO`

Si existe un problema, se registra una incidencia y no se marca como verificada.