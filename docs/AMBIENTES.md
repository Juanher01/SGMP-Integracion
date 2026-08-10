# Ambientes del ecosistema SGPMP

## DEV

Propósito:
Desarrollo e integración local de los componentes aprobados.

Características previstas:

- PostgreSQL independiente.
- Datos persistentes.
- Hot reload para backend y frontend.
- Logs detallados.
- Puertos expuestos localmente.
- Swagger habilitado.

## TEST

Propósito:
Ejecutar pruebas automatizadas y validaciones reproducibles.

Características previstas:

- PostgreSQL independiente de DEV.
- Datos reiniciables.
- pytest y pytest-cov para backend.
- Vitest para frontend.
- Cypress para pruebas E2E.
- Uso compartido entre Pruebas e Implementación.

## PROD

Propósito:
Ejecutar una versión equivalente a producción y preparar la entrega a Despliegue.

Características previstas:

- Sin hot reload.
- Sin debug.
- Build optimizado.
- Secretos no versionados.
- Frontend compilado.
- Configuración mínima necesaria para ejecución.