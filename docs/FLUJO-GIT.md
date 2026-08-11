# Flujo Git — Proyecto SGPMP e Implementación

Este documento define, por un lado, el **flujo Git global** del proyecto SGPMP y, por otro, las **convenciones Git propias del grupo de Implementación** (nomenclatura de ramas, modelo de integración, convención de commits y buenas prácticas).

> [!NOTE]
> Las ramas descritas en la Sección 2 **viven en los repositorios de código del proyecto** (frontend y backend), no en este repositorio. El repositorio `SGMP-Integracion` únicamente **documenta** la convención de trabajo del ecosistema de Implementación.

---

## 1. Flujo general del proyecto

Flujo por grupos, según lo definido por el líder del proyecto:

```text
Desarrollo → Pruebas → Integración → Pruebas → Despliegue
```

> [!IMPORTANT]
> Pruebas interviene **dos veces**: aprueba lo que **entra** a Integración (compuerta de entrada) y valida el resultado **integrado** antes de que pase a Despliegue (compuerta de salida). Implementación no recibe ni entrega sin el visto bueno de Pruebas.

### 1.1 Desarrollo

Integra las funcionalidades terminadas en la rama `dev`.

### 1.2 Pruebas — compuerta de entrada

Valida las versiones disponibles en `dev` y aprueba el commit o tag que puede entrar a Integración.

### 1.3 Integración (Implementación)

Recibe únicamente versiones aprobadas. La rama `integration` se deriva del **commit o tag exacto** aprobado por Pruebas y recorre el pipeline de integración (ver [FLUJO-TRABAJO.md]).

### 1.4 Pruebas — compuerta de salida

Valida el resultado ya integrado antes de habilitar el paso a Despliegue.

### 1.5 Despliegue

Ejecuta el acto de liberación a partir del resultado integrado y validado.

### 1.6 Regla principal

No se debe actualizar `integration` automáticamente con el estado más reciente de `dev`. Antes de integrar una nueva versión se debe conocer:

- repositorio;
- rama origen;
- commit SHA o tag aprobado;
- fecha de aprobación;
- módulos incluidos;
- resultado de Pruebas;
- incidencias conocidas.

---

## 2. Convenciones Git de Implementación

### 2.1 Alcance

Estas convenciones aplican al **trabajo de integración**, que ocurre en los repositorios de código del proyecto. Este repositorio de Implementación solo las documenta y sirve como fuente de verdad de la convención acordada.

### 2.2 Modelo de ramas

El backend del SGPMP es un **monolito modular** (un solo servicio FastAPI con los módulos M01–M09) sobre una única base PostgreSQL. Por lo tanto, el objetivo de Implementación es que **todos los módulos converjan en un mismo punto integrado**. El modelo adoptado es:

- **`integration` — rama de larga vida.** Es el punto donde convergen los módulos ya recibidos y verificados. Refleja el estado integrado y estable del sistema desde la perspectiva de Implementación.
- **`recep/m0X-vY.Z.W` — ramas cortas de recepción.** Por **cada entrega aprobada por Pruebas** se crea una rama corta donde se ejecuta el procedimiento de recepción de forma aislada. Si la verificación pasa, la rama se fusiona a `integration` mediante Pull Request; si falla, la rama queda aislada, se registra la incidencia y `integration` permanece limpia.
- **`fix/m0X-<descripcion>` — correcciones de integración.** Para ajustes puntuales detectados durante la integración de un módulo ya recibido.

Se descarta el esquema de **una rama permanente por módulo**, porque ramas que nunca convergen son lo contrario de "integrar": el sistema final requiere que los módulos coexistan en un mismo backend y una misma base de datos.

> [!IMPORTANT]
> Las ramas de recepción usan el prefijo `recep/` y **no** `integration/`. Git almacena las referencias como archivos, por lo que no pueden coexistir una rama `integration` y ramas `integration/m0X` (colisión archivo/carpeta en `.git/refs/heads/`).

Representación del modelo:

```text
        (tag/commit aprobado por Pruebas — entrada)
                      │
                      ▼
              recep/m02-v0.1.0        ← recepción + verificación aislada
                      │
                 ¿verificado?
                      │ sí
                      ▼
                 integration          ← convergencia estable
                      │
                      ▼
              Pruebas (salida)        ← validación post-integración
                      │
                      ▼
                  Despliegue
```

### 2.3 Nomenclatura de ramas

| Tipo | Patrón | Ejemplo | Propósito |
| :--- | :--- | :--- | :--- |
| Integración | `integration` | `integration` | Rama de larga vida; sistema integrado estable |
| Recepción | `recep/m0X-vY.Z.W` | `recep/m02-v0.1.0` | Recepción y verificación aislada de una entrega |
| Corrección | `fix/m0X-<desc>` | `fix/m02-jwt-header` | Ajuste puntual durante la integración |

Reglas de nomenclatura:

- Siempre en **minúsculas**, sin espacios ni tildes; separar palabras con guion (`-`).
- Incluir el **módulo** (`m0X`) para trazabilidad por módulo.
- Incluir la **versión** de la entrega (`vY.Z.W`) en las ramas de recepción, para enlazar con el registro de recepción.

### 2.4 Convención de commits

Se adopta **Conventional Commits** con el formato:

```text
<tipo>(<alcance>): <descripción breve en imperativo>
```

| Tipo | Uso |
| :--- | :--- |
| `feat` | Nueva funcionalidad o servicio incorporado |
| `fix` | Corrección de un problema |
| `docs` | Cambios en documentación (mayoría en este repositorio) |
| `chore` | Configuración, mantenimiento, tareas auxiliares |
| `test` | Pruebas de integración o verificación |
| `refactor` | Reorganización sin cambio de comportamiento |

- El **alcance** (opcional) referencia el módulo: `docs(m02)`, `test(m02)`, `chore(docker)`.
- Descripción en **imperativo y minúscula**, sin punto final.

Ejemplos:

```text
docs(git): define convenciones de ramas de Implementación
integration(m02): recibe entrega aprobada tag v0.1.0
test(m02): verifica superficie SUP-M02-016 contra DOC-01
fix(m02): corrige mapeo de contrato REST reportado en recepción
```

### 2.5 Pull Requests y fusión a `integration`

- **Prohibido `push` directo a `integration`.** Toda incorporación se hace vía **Pull Request** desde una rama `recep/*`.
- El PR debe **referenciar el commit SHA o tag aprobado** por Pruebas y adjuntar (o enlazar) el registro de recepción diligenciado.
- El PR solo se fusiona cuando la recepción resultó **verificada**; si hay incidencias, no se fusiona y se documenta.
- Preferir fusión que conserve trazabilidad de la entrega (evitar reescribir el historial de la rama de recepción).

### 2.6 Trazabilidad con el flujo de recepción

El modelo de ramas está diseñado para encajar 1 a 1 con el procedimiento de recepción:

```text
1 entrega aprobada  =  1 rama recep/m0X-vY.Z.W  =  1 FORMATO-RECEPCION  =  1 Pull Request a integration
```

Para el detalle del procedimiento y el formato de registro, consultar:

- [FLUJO-TRABAJO.md] — flujo completo de Implementación (pipeline E1→E7).
- [PROCEDIMIENTO-RECEPCION.md] — detalle operativo de la etapa E1 (recepción de superficies).
- [FORMATO-RECEPCION.md] — plantilla de registro de cada entrega.

### 2.7 Buenas prácticas generales

1. Una rama de recepción atiende **una sola entrega**; no acumular varios módulos en la misma rama.
2. No incorporar a `integration` código de `dev` que **no haya sido liberado** por Pruebas.
3. Mantener las ramas de recepción **cortas**: se crean, se verifican y se fusionan o descartan; no se dejan vivas indefinidamente.
4. Registrar toda incidencia detectada durante la integración antes de descartar o corregir una rama.
5. No versionar secretos ni archivos `.env` reales (ver reglas en [VARIABLES-ENTORNO.md]).

---

## 3. Documentos de referencia

- [FLUJO-TRABAJO.md] — flujo de trabajo de Implementación (pipeline E1→E7).
- [PROCEDIMIENTO-RECEPCION.md] — procedimiento de la etapa E1.
- [FORMATO-RECEPCION.md] — registro de recepción por entrega.
- [API-VALIDACION.md] — validación de superficies REST y estados DOC-01.
- [VARIABLES-ENTORNO.md] — convención de variables y manejo de secretos.
- [DOCKER.md] — operación de los ambientes DEV y TEST.
