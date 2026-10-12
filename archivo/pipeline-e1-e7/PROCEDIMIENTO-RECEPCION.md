# Procedimiento de Recepción — Etapa E1 (Implementación SGPMP)

> [!NOTE]
> Este documento detalla la **etapa E1 (Recepción y Aceptación de Superficies)** del flujo de trabajo de Implementación. Para el flujo completo E1→E7 y su encaje con las matrices, ver [FLUJO-TRABAJO.md].

## 1. Objetivo

Recibir y aceptar las **superficies de integración** de un componente ya aprobado por Pruebas, registrándolas en el DOC-01 Checklist del módulo.

## 2. Precondición

Ningún componente se incorpora a la integración sin la aprobación previa de Pruebas (compuerta de entrada del flujo `Desarrollo → Pruebas → Integración → Pruebas → Despliegue`).

La verificación se hace contra el código en la rama `dev` como **fuente principal**; el documento de Desarrollo es **fuente secundaria**. Ante divergencia, manda el código: la diferencia es un **hallazgo** que se registra como incidencia.

## 3. Registro

La entrega se documenta en el formulario oficial [FORMATO-RECEPCION.md], y las superficies en el **DOC-01 Checklist** del módulo.

## 4. Flujo de la etapa E1

### Paso 1 — Liberación

Pruebas comunica el commit SHA o tag de `dev` aprobado.

### Paso 2 — Identificación

Se registra el commit SHA o tag exacto aprobado. Para evidencia reproducible, la referencia se congela por SHA.

### Paso 3 — Rama de recepción

Se crea `recep/m0X-vY.Z.W` desde esa versión aprobada (ver [FLUJO-GIT.md]).

### Paso 4 — Inventario de superficies

Se listan en el DOC-01 **solo** las superficies que el módulo **expone** o **consume** (endpoints REST, esquemas de BD, interfaces entre módulos); **no** entidades ni objetos internos. Cada superficie se apunta a su doble fuente (código en `dev` + documento).

### Paso 5 — Verificación de contratos

Se verifican los contratos REST publicados por FastAPI vía Swagger/OpenAPI y la colección Bruno/Postman (ver [API-VALIDACION.md]).

### Paso 6 — Cotejo

Se compara lo recibido contra las superficies registradas en el DOC-01.

### Paso 7 — Evidencias

Se almacenan logs, requests, responses y capturas relevantes, con referencias congeladas por SHA.

### Paso 8 — Estado y cierre

Cada superficie avanza `PENDIENTE → RECIBIDO → VERIFICADO`. Si existe un problema, se abre una incidencia en el DOC-02 y la superficie **no** se marca como verificada.

## 5. Salida de la etapa

La **compuerta de E1** (conformidad de superficies) determina si el módulo es **apto**, **apto con observaciones** o **no apto** para continuar a E2.

Los pasos de configuración de entorno, levantamiento de ambiente, Docker, base de datos y verificación de integración entre módulos pertenecen a etapas posteriores (E2–E5) y se describen en [FLUJO-TRABAJO.md]. Este procedimiento cubre únicamente E1.
