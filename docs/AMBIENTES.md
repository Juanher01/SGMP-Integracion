# Ambientes del Ecosistema SGPMP

## 1. Visión General de Ambientes

El ecosistema SGPMP define tres ambientes con propósitos y configuraciones técnicas aisladas:

| Característica | DEV | TEST | PROD |
| :--- | :--- | :--- | :--- |
| **Propósito** | Desarrollo e integración local | Pruebas automatizadas y validación técnica | Despliegue final de producción |
| **Servicio BD** | `postgres-dev` (`5432`) | `postgres-test` (`5433`) | Instancia productiva |
| **Persistencia** | Datos persistentes | Datos reiniciables / reproducibles | Persistencia gestionada |
| **Backend** | Port `8000` (Hot-reload, Swagger) | Port `8001` (Pytest) | Port `8000` (Sin debug, optimizado) |
| **Frontend** | Port `5173` (Vite dev server) | Port `5174` (Vitest / Cypress) | Bundle compilado en servidor |
| **Perfil Docker** | `dev` | `test` | `prod` |

---

## 2. Documentos de Referencia Técnica

Para profundizar en la configuración y operación de los ambientes, consulte los siguientes documentos:

* **Operación de Contenedores:** Consultar [DOCKER.md] para comandos CLI de inicio, logs y detención.
* **Matriz de Variables:** Consultar [VARIABLES-ENTORNO.md] para mapeo de puertos y variables de entorno.
* **Gestión de Base de Datos:** Consultar [BASE-DATOS.md] para reglas de dumps, restauración y volúmenes.