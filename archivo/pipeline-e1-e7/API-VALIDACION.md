# Validación de APIs — SGPMP

## 1. Objetivo

Definir el procedimiento que utilizará el grupo de Implementación para verificar las superficies REST entregadas por Desarrollo y aprobadas por Pruebas.

## 2. Fuente técnica

El backend utiliza FastAPI y publica documentación OpenAPI.

La interfaz Swagger se encuentra prevista en:

`/docs`

Ejemplo DEV:

`http://localhost:8000/docs`

Ejemplo TEST:

`http://localhost:8001/docs`

## 3. Herramienta

Se utilizará Postman para ejecutar y documentar solicitudes HTTP.

## 4. Colección

Colección:

`SGPMP - Integración`

Organización:

- M01 - Identity & Access
- M02 - Biological Assets
- M03 - Telemetry
- M04 - Prediction
- M05 - Supplies
- M06 - NIC 41 Valuation
- M07 - External Integration
- M08 - Business Intelligence
- M09 - Configuration

## 5. Ambientes Postman

### DEV

- `base_url`: `http://localhost:8000`
- `access_token`: token JWT activo

### TEST

- `base_url`: `http://localhost:8001`
- `access_token`: token JWT de pruebas

## 6. Flujo de validación

Pruebas aprueba una versión
↓
Implementación recibe commit/tag
↓
Se levanta backend en el ecosistema
↓
Se consulta Swagger/OpenAPI
↓
Se ejecutan endpoints mediante Postman
↓
Se compara contra DOC-01
↓
Se registra evidencia
↓
Se actualiza estado

## 7. Estados DOC-01

### PENDIENTE

La superficie se encuentra identificada documentalmente, pero aún no ha sido recibida como artefacto técnico.

### RECIBIDO

La superficie técnica fue entregada y puede localizarse en código, Swagger/OpenAPI u otro contrato técnico.

### VERIFICADO

La superficie fue ejecutada y validada dentro del ecosistema de Implementación.

## 8. Restricción

Implementación no realiza validaciones sobre código que aún no haya sido liberado por el grupo de Pruebas.