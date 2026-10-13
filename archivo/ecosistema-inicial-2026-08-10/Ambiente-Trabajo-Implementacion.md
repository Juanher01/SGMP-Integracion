# Ambiente de Trabajo — Grupo de Implementación (SGPMP)

Documento fuente para exponer el ambiente de trabajo del grupo de Implementación del proyecto **Sistema de Gestión Pecuaria Multiespecie de Precisión (SGPMP)**. Describe qué es el ambiente de trabajo, el rol del grupo, los repositorios, y el estado de cada uno de los ocho elementos que lo componen.

---

## 1. Contexto del proyecto

El SGPMP es un sistema de gestión pecuaria multiespecie de precisión, desarrollado bajo un ciclo de vida de software (SDLC) organizado en grupos: **Análisis, Diseño, Desarrollo, AIoT, Implementación, Pruebas y Despliegue**.

Arquitectónicamente el sistema es:

- **Backend:** un monolito modular en FastAPI con los módulos **M01–M09**, diseñado *database-first* (se apoya en el esquema y los procedimientos que provee la base de datos).
- **Base de datos:** PostgreSQL 17.10 con un esquema por módulo (`modulo1..modulo9` + `auditoria`), extensiones `pg_cron` y `pgcrypto`, y una matriz de roles por perfil.
- **Frontend:** una PWA en React 19 + Ionic + Vite (con Capacitor para móvil).
- **AIoT:** los módulos **M03, M04 y M09** incorporan flujos de IoT y predicción.

## 2. Rol del grupo de Implementación

Implementación ocupa la etapa de **Integración** dentro del flujo global del proyecto:

```
Desarrollo → Pruebas → Integración → Pruebas → Despliegue
```

Recibe versiones ya aprobadas por Pruebas (**compuerta de entrada**), las integra de forma incremental en un sistema coherente, y su resultado vuelve a Pruebas (**compuerta de salida**) antes de pasar a Despliegue. No desarrolla funcionalidad ni libera a producción. Sus fronteras: Pruebas aprueba y verifica interoperabilidad; Despliegue ejecuta el acto de liberar; AIoT co-autoría los flujos IoT.

## 3. Los repositorios del proyecto

El ecosistema se reparte en cuatro repositorios:

| Repositorio | Contenido | Stack |
| :--- | :--- | :--- |
| `sgpmp-backend` | API del sistema (M01–M09) | FastAPI · SQLAlchemy · PostgreSQL |
| `SGPMP-FRONT-END-PWA` | Interfaz de usuario (PWA) | React 19 · Ionic · Vite · Capacitor |
| `docuemntacionDB` | Contenedor y documentación de la BD | PostgreSQL 17.10 · pg_cron · Docker |
| `SGMP-Integracion` | Documentación y orquestación del ambiente de Implementación | Docker · documentación |

El repositorio `SGMP-Integracion` es propio del grupo: **documenta** el ambiente de trabajo y **orquesta** la integración; no aloja el código de la aplicación.

---

## 4. Los ocho elementos del ambiente de trabajo

El ambiente de trabajo se considera "listo" cuando estos ocho elementos están resueltos. A continuación, qué significa cada uno, cómo se aborda en el proyecto y su estado.

### 4.1 Repositorios

**Qué significa listo:** todos pueden clonar y trabajar con el proyecto.

Los cuatro repositorios existen y son clonables. El código de aplicación vive en la rama `dev` de backend y frontend. El grupo trabaja sobre copias locales clonadas en un único workspace.

**Estado:** ✅ Listo. *(Observación: se detectaron descuidos de higiene en los repos ajenos —doble lockfile en el frontend, `.env` versionado en el de BD, referencias a un `.env.example` inexistente— que se reportan a sus equipos.)*

### 4.2 Rama de integración

**Qué significa listo:** existe una rama exclusiva para integración.

Se definió el modelo y las convenciones (documento `FLUJO-GIT.md`): una rama **`integration`** de larga vida donde convergen los módulos, más ramas cortas **`recep/m0X-vY.Z.W`** por cada recepción y **`fix/m0X-…`** para correcciones. Incluye nomenclatura, convención de commits (Conventional Commits) y reglas de Pull Request. Estas ramas viven en los repositorios de código (backend/frontend); el repo de Implementación solo documenta la convención.

**Estado:** 🟡 Convención definida y documentada; la rama física queda pendiente de crearse en los repos de código.

### 4.3 Entorno local

**Qué significa listo:** se sabe cómo levantar frontend, backend y servicios necesarios.

El procedimiento está validado de punta a punta y documentado en un runbook: base de datos (contenedor), backend (`python main.py`, puerto 8000) y frontend (`pnpm dev`, puerto 5173). Se comprobó que el trío **frontend → backend → base de datos** conversa (la pantalla de login dispara un `POST /sesiones/` que el backend atiende y consulta contra la BD).

**Estado:** ✅ Listo y verificado.

### 4.4 Docker

**Qué significa listo:** preparado para levantar infraestructura sin configuraciones manuales.

Se decidió adoptar el **contenedor de base de datos del equipo de BD como fuente de verdad** (PostgreSQL 17.10 + `pg_cron` + matriz de roles). Se construyó un **script de restauración** (`restaurar-bd.sh`) que levanta ese contenedor y restaura el dump de forma reproducible, resolviendo por el lado de Implementación tres problemas detectados (finales de línea CRLF, `.env` versionado, y un bucle de `pg_cron`), sin modificar el repositorio del equipo de BD.

**Estado:** 🟡 La base de datos se levanta y puebla con un comando. Falta el **`docker compose` reconciliado** que levante los tres servicios (BD + backend + frontend) juntos con un solo comando.

### 4.5 Variables de entorno

**Qué significa listo:** existe un `.env.example` documentado.

El backend y el repositorio de Implementación cuentan con archivos de ejemplo. El grupo mantiene además archivos de entorno unificados por ambiente (dev/test) pensados para el compose reconciliado, que están en proceso de alinearse con el diseño de BD adoptado.

**Estado:** 🟡 Parcial. El frontend carece de `.env.example` (se crea a mano); los archivos de entorno unificados requieren reconciliación (sección de BD, ensamblado de `DATABASE_URL`, finales de línea).

### 4.6 Base de datos

**Qué significa listo:** PostgreSQL preparado para recibir el esquema del sistema.

El contenedor del equipo de BD levanta PostgreSQL 17.10 con `pg_cron`, `pgcrypto` y su matriz de roles, y se restaura desde el dump oficial (`backup7_0_0.dump`): quedan los esquemas `auditoria` + `modulo1..modulo9` con ~187 tablas, además de funciones, procedimientos y triggers.

Un hallazgo importante del proceso de integración: el sistema es **database-first**. El backend no gestiona migraciones; el esquema y los procedimientos los provee la base de datos. Por eso el enunciado original ("recibir migraciones") se ajusta a la realidad del diseño: la BD **es** la fuente del esquema, no lo genera el backend.

**Estado:** 🟡 Base de datos levantada y restaurada. Quedan cabos por cerrar con el equipo de BD (versión con que se generó el dump, contenido residual de otro proyecto en el esquema `public`, y la base destino frente a la configuración de `pg_cron`).

### 4.7 Herramientas de prueba

**Qué significa listo:** Postman/Bruno/Insomnia y Swagger preparados.

El backend expone documentación interactiva **Swagger/OpenAPI** en `/docs`, verificada y operativa. El procedimiento de validación de superficies REST (documento `API-VALIDACION.md`) contempla el uso de Swagger junto a una colección Postman/Bruno y los estados de verificación.

**Estado:** 🟡 Swagger operativo de fábrica. La colección Postman/Bruno está prevista y documentada; queda confirmar su publicación en el repositorio.

### 4.8 Flujo de recepción

**Qué significa listo:** definido qué hace Implementación cuando recibe un módulo.

El flujo de trabajo está documentado como un **pipeline de siete etapas (E1→E7)**, cada una asociada a una matriz de Implementación (DOC-01 a DOC-04 y el DOC-03A de sistema) y con su compuerta de avance:

| Etapa | Nombre | Documento |
| :---: | :--- | :--- |
| E1 | Recepción y aceptación de superficies | DOC-01 |
| E2 | Integración de arquitectura lógica | DOC-02 |
| E3 | Validación de datos del sistema | DOC-03A |
| E4 | Configuración (y flujos AIoT) | DOC-04 · DOC-03B |
| E5 | Pruebas sistémicas | — |
| E6 | Estabilización | DOC-02 |
| E7 | Entrega | DOC-04 |

Se apoya en los principios de "referenciar, no copiar" y doble fuente (el código en `dev` manda sobre el documento). El detalle operativo de la recepción (E1) y el formato de registro están en documentos aparte (`PROCEDIMIENTO-RECEPCION.md`, `FORMATO-RECEPCION.md`), y el flujo encaja con el modelo de ramas: cada recepción es una rama `recep/m0X` que se fusiona a `integration` vía Pull Request.

**Estado:** ✅ Definido y documentado.

---

## 5. Estado general del ambiente

| # | Elemento | Estado |
| :---: | :--- | :--- |
| 1 | Repositorios | ✅ Listo |
| 2 | Rama de integración | 🟡 Convención definida; rama por crear |
| 3 | Entorno local | ✅ Listo y verificado |
| 4 | Docker | 🟡 BD por script; compose único pendiente |
| 5 | Variables de entorno | 🟡 Parcial; ejemplos y unificados por afinar |
| 6 | Base de datos | 🟡 Restaurada; cabos con el DBA |
| 7 | Herramientas de prueba | 🟡 Swagger listo; colección por confirmar |
| 8 | Flujo de recepción | ✅ Definido y documentado |

## 6. Decisiones y hallazgos clave de la integración

- **La base de datos del equipo de BD es la fuente de verdad del dato**, no una imagen propia de Implementación (la exige `pg_cron` y la versión de PostgreSQL).
- **El sistema es database-first:** el backend se conecta a un esquema ya poblado; no corre migraciones. Esto descarta el riesgo de choque esquema-vs-migraciones.
- **El flujo global tiene doble compuerta de Pruebas** (antes y después de Integración).
- **El trabajo de recepción se estructura como pipeline E1→E7**, trabajando de la mano con las matrices de Implementación.

## 7. Pendientes

- Crear físicamente la rama `integration` en los repos de código.
- Construir el `docker compose` reconciliado que levante los tres servicios juntos.
- Conectar el backend con el rol `backend_dev` (hoy se usa el superusuario para pruebas).
- Cerrar con el equipo de BD los ajustes del dump y la configuración de `pg_cron`.
- Completar/alinear los `.env.example` y los archivos de entorno unificados.
