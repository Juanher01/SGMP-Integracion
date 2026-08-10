# Ecosistema de Implementación — SGPMP

Este directorio contiene los artefactos técnicos y documentales utilizados por el grupo de Implementación del proyecto SGPMP.

## Flujo del proyecto

Desarrollo → Pruebas → Implementación → Despliegue

El grupo de Implementación únicamente integra versiones previamente aprobadas por el grupo de Pruebas.

## Rama de integración

La rama `integration` debe derivarse de una versión aprobada de `dev`.

No se deben incorporar cambios de `dev` que no hayan sido liberados por Pruebas.

## Ambientes

Se definirán tres ambientes:

- DEV: desarrollo e integración local.
- TEST: pruebas reproducibles.
- PROD: ejecución equivalente a producción y entrega a Despliegue.

## Componentes del ecosistema

- Docker
- Docker Compose
- PostgreSQL
- FastAPI
- Ionic / React
- Swagger / OpenAPI
- Postman

## Estado actual

- Repositorios frontend y backend clonados.
- Ecosistema base en construcción.
- Módulos funcionales pendientes de liberación por el grupo de Pruebas.