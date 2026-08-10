# Flujo Git de Implementación

## Flujo general

feature/* → dev → Pruebas → integration → Despliegue

## Desarrollo

El grupo de Desarrollo integra las funcionalidades terminadas en la rama `dev`.

## Pruebas

El grupo de Pruebas valida las versiones disponibles en `dev`.

## Implementación

Implementación únicamente recibe versiones previamente aprobadas.

La rama `integration` debe derivarse del commit o tag exacto aprobado por Pruebas.

## Regla principal

No se debe actualizar `integration` automáticamente con el estado más reciente de `dev`.

Antes de integrar una nueva versión se debe conocer:

- repositorio;
- rama origen;
- commit SHA o tag aprobado;
- fecha de aprobación;
- módulos incluidos;
- resultado de Pruebas;
- incidencias conocidas.