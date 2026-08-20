# Ambientes del Ecosistema SGPMP

> [!WARNING]
> Esta versión reemplaza la anterior (10 de agosto de 2026), que describía un diseño ya superado: solo la base de datos orquestada por *profiles* de Docker Compose, sin backend, frontend ni gateway AIoT, y sin ambiente PROD. El diseño vigente es **compose base + un override por entorno**, con las cuatro capas presentes en los tres ambientes.

## 1. Visión general de ambientes

El ecosistema SGPMP define tres ambientes de ejecución. Los tres son **montados y orquestados por Implementación**; lo que cambia entre ellos es el origen de cada imagen, la configuración y quién opera el ambiente una vez montado (ver `docs/CONTRATO-TEST.md` y `docs/CONTRATO-PROD.md`).

| Capa | DEV | TEST | PROD |
| :--- | :--- | :--- | :--- |
| **Base de datos** | Externa — fork `DBIntegrador` del DBA, vía `host.docker.internal:5433` | Servicio interno (`database`), imagen `${DATABASE_IMAGE}`, sin puerto publicado | Servicio interno (`database`), imagen `${DATABASE_IMAGE}`, sin puerto publicado |
| **Backend** | Build local, puerto `8000` (recarga en caliente) | Imagen `${BACKEND_IMAGE}`, puerto `8001` → `8000` | Imagen `${BACKEND_IMAGE}`, sin puerto publicado (interno `8000`) |
| **Frontend** | Build local (`target: dev`), puerto `5173` (Vite) | Imagen `${FRONTEND_IMAGE}`, puerto `8081` → `80` | Imagen `${FRONTEND_IMAGE}`, sin puerto publicado (interno `80`) |
| **Gateway AIoT** | Build local, puerto `8002` → `8000` | Imagen `${GATEWAY_IMAGE}`, puerto `8003` → `8000` | Imagen `${GATEWAY_IMAGE}`, sin puerto publicado (interno `8000`) |
| **Broker Mosquitto** | Puerto `1883` / `9001` | Puerto `1884` → `1883` / `9002` → `9001` | Sin puerto publicado |

> El puerto `8000` del gateway colisionaba con el del backend; se resolvió remapeando el puerto publicado por entorno (nunca el interno del contenedor, que sigue siendo `8000` en los tres).

## 2. Archivos que definen cada ambiente

| Ambiente | Override | Variables |
| :--- | :--- | :--- |
| DEV | `compose/compose.dev.yml` | `env/.env.dev.example` → copiar a `.env.dev` |
| TEST | `compose/compose.test.yml` | `env/.env.test.example` → copiar a `.env.test` |
| PROD | `compose/compose.prod.yml` | `env/.env.prod.example` → copiar a `.env.prod` |

Los tres overrides se combinan siempre con la base común `compose/docker-compose.yml` (servicios, red `sgpmp-network`, volumen `postgres-data`, healthchecks). Ningún override se usa solo.

## 3. Documentos de referencia técnica

* **Operación de contenedores:** [DOCKER.md](DOCKER.md) — comandos de levantamiento, logs y detención por ambiente.
* **Matriz de variables:** [VARIABLES-ENTORNO.md](VARIABLES-ENTORNO.md) — catálogo de 48 variables y su sensibilidad.
* **Gestión de base de datos:** [BASE-DATOS.md](BASE-DATOS.md) — restauración, roles y estrategia por ambiente.
* **Contratos de entrega:** [CONTRATO-TEST.md](CONTRATO-TEST.md) y [CONTRATO-PROD.md](CONTRATO-PROD.md) — servicios, puertos, healthchecks y puntos pendientes de cierre por ambiente.
