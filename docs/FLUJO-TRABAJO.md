# Flujo de Trabajo — Grupo de Implementación (SGPMP)

Este documento describe **cómo trabaja el grupo de Implementación**: cómo lleva un módulo desde que Pruebas lo aprueba hasta que el resultado integrado se valida y pasa a Despliegue, trabajando de la mano con las matrices de Implementación (DOC-01 a DOC-04 y el DOC-03A de sistema).

> [!NOTE]
> Este documento describe el **proceso**. El **estado** de cada módulo y las **métricas** de cada etapa viven en las matrices (`M0X_IMP_matrices` y `SIST_IMP_DOC-03A`), que son la única fuente de verdad. Aquí no se copian umbrales ni valores; se explica el flujo que los produce.

---

## 1. Rol y alcance

El flujo global del proyecto, definido por el líder, es:

```text
Desarrollo → Pruebas → Integración → Pruebas → Despliegue
```

Implementación ocupa la etapa de **Integración**, entre dos compuertas de Pruebas: recibe versiones aprobadas por Pruebas (**compuerta de entrada**), las integra de forma incremental en un sistema coherente, y su resultado vuelve a Pruebas (**compuerta de salida**) antes de pasar a Despliegue. No desarrolla funcionalidad ni libera a producción.

Fronteras de responsabilidad:

- **Pruebas** interviene dos veces: aprueba las versiones que entran y **valida el resultado integrado** antes de Despliegue. Además, la **verificación de interoperabilidad** entre módulos es de Pruebas; Implementación define el contrato mínimo de cada interfaz.
- **Despliegue** ejecuta el **acto de liberar** (ficha de versión, contenido, cambios). De toda la liberación, lo único que es de Implementación es la **compuerta de entrega**: la luz verde que certifica que el módulo está listo.
- **AIoT** co-autoría los flujos IoT (DOC-03B) de los módulos M03, M04 y M09.

---

## 2. Principios de trabajo

1. **Referenciar, no copiar.** Cada dato tiene una sola fuente de verdad; las matrices guardan un puntero, no una copia. Los enlaces reales viven una sola vez en el *Registro de Fuentes de Verdad* de cada workbook.
2. **Convención de doble fuente.** Al registrar una superficie, contrato o interfaz se apuntan dos fuentes: la **principal** es el código en la rama `dev` (ruta relativa en el repo backend u `operationId` en `/api/openapi.json`), y la **secundaria** es el documento de Desarrollo. La principal es la verdad del estado actual; la secundaria da la intención.
3. **Ante divergencia código ↔ documento, manda el código.** Esa divergencia es un **hallazgo** que se registra como incidencia, no un empate a resolver por criterio.
4. **Evidencia reproducible.** Para congelar una referencia (evidencia de verificación) se reemplaza `dev` por el commit SHA en el puntero.

---

## 3. Los dos niveles del flujo

El trabajo ocurre en dos niveles que se entrelazan:

- **Nivel macro — orden del sistema (DOC-03A).** Define en qué **orden topológico** entran los módulos (M01 → M09 → M02 → M03/M05 → M04 → M06 → M07/M08) y qué **restricciones globales** (`R-001`…`R-010`) deben estar resueltas antes de empezar con cada módulo. Estas restricciones actúan como compuertas previas: si una restricción bloqueante del módulo no está resuelta, el módulo no entra al pipeline.
- **Nivel micro — pipeline por módulo (E1 → E7).** Cada módulo aprobado recorre siete etapas. Cada etapa llena un DOC, tiene una **compuerta** que decide si se avanza, y un **presupuesto de tiempo**. El nivel micro alimenta de vuelta al macro: cuando un módulo supera E7, se cumple su condición de salida en el DOC-03A y se habilita el siguiente.

---

## 4. El pipeline E1 → E7

Vista de conjunto:

| Etapa | Nombre | DOC que llena | Compuerta (índice) |
| :---: | :--- | :--- | :--- |
| **E1** | Recepción y Aceptación de Superficies | DOC-01 Checklist | Conformidad de Superficies de Entrada |
| **E2** | Integración de Arquitectura Lógica | DOC-02 Dependencias e Interfaces | Integridad de Interfaces |
| **E3** | Validación de Datos del Sistema | DOC-03A (sistema) | Calidad de Datos Operativos |
| **E4** | Configuración (+ Flujos AIoT) | DOC-04 config · DOC-03B (M03/M04/M09) | Configuración Segura y Controlada |
| **E5** | Pruebas Sistémicas | — (validación sistémica) | Cobertura de Flujos Sistémicos Críticos |
| **E6** | Estabilización | DOC-02 bitácora de incidencias | Estabilidad Operativa |
| **E7** | Entrega | DOC-04 Compuerta de Entrega | Preparación Formal para Entrega |

> [!NOTE]
> El nombre de cada índice, su fórmula, su umbral y el presupuesto de tiempo de la etapa están definidos en la sección de métricas del DOC correspondiente. Este documento solo nombra la compuerta; no reproduce sus valores.

### E1 — Recepción y Aceptación de Superficies

Se registran en el **DOC-01** las superficies de integración del módulo: solo lo que **expone** o **consume** (endpoints REST, esquemas de BD, interfaces), nunca entidades internas. Cada superficie se apunta a su doble fuente y avanza por los estados `PENDIENTE → RECIBIDO → VERIFICADO`. La compuerta mide qué proporción de las superficies recibidas quedaron conformes; su resultado marca el módulo como apto, apto con observaciones o no apto para integración. El detalle operativo de esta etapa está en [PROCEDIMIENTO-RECEPCION.md].

### E2 — Integración de Arquitectura Lógica

En el **DOC-02** se documentan las dependencias que el módulo **consume** (con su criticidad y método de verificación), el catálogo de interfaces entre módulos (contrato mínimo) y la bitácora de incidencias de integración. La compuerta mide la integridad de las interfaces evaluadas. Las dependencias marcadas **BLOQUEANTE** deben quedar verificadas para avanzar.

### E3 — Validación de Datos del Sistema

Se ubica el módulo en la **secuencia del sistema (DOC-03A)** y se validan las reglas de datos operativos, los puertos y los protocolos que le aplican. La compuerta mide la calidad de los datos operativos y se ejecuta **antes de habilitar módulos predictivos** (los que dependen de datos acumulados, como M04).

### E4 — Configuración (y Flujos AIoT)

Se completa la configuración de entorno del módulo en el **DOC-04** (recursos y variables por entorno). En los módulos con IoT (M03, M04, M09) se llena además el **DOC-03B**: se referencian los flujos del catálogo de AIoT y se definen los **puntos de validación** de integración (dónde y cómo se comprueba que el dato llegó bien). La compuerta mide qué proporción de los controles de configuración definidos quedaron implementados.

### E5 — Pruebas Sistémicas

Se validan los flujos sistémicos críticos del módulo ya integrado con el resto. La compuerta mide la cobertura de esos flujos; superarla habilita la estabilización.

### E6 — Estabilización

Se cierran las incidencias abiertas durante la integración, priorizando las **CRÍTICAS**, y se vigila que no se reabran. La compuerta mide la estabilidad operativa (incidencias críticas cerradas sin reapertura).

### E7 — Entrega

Se verifica la **Compuerta de Entrega** del **DOC-04**: superficies del DOC-01 en VERIFICADO, dependencias bloqueantes del DOC-02 verificadas, incidencias críticas cerradas, condición del DOC-03A cumplida y, si aplica, puntos de validación del DOC-03B verificados con AIoT. Superar esta compuerta es la única parte de la liberación que le corresponde a Implementación: certifica que el módulo integrado está listo. El resultado pasa entonces a la **compuerta de salida de Pruebas** (validación post-integración) y, aprobado, se transfiere a Despliegue.

---

## 5. Modelo de estados

Los estados que llevan las matrices son los que alimentan las compuertas:

- **Superficies de integración (DOC-01):** `PENDIENTE → RECIBIDO → VERIFICADO`.
- **Recursos de entorno (DOC-04):** `PENDIENTE → SIMULADO → DISPONIBLE`.
- **Incidencias de integración (DOC-02):** `ABIERTA → EN PROCESO → CERRADA`, con severidad CRÍTICA / ALTA / MEDIA / BAJA.

Mover un elemento de estado es lo que hace avanzar el conteo de una compuerta; ninguna etapa se cierra con elementos en un estado intermedio que su compuerta no admita.

---

## 6. Las compuertas y sus tres salidas

Cada compuerta tiene tres resultados posibles:

- **Continúa** — se supera el umbral; el módulo pasa a la etapa siguiente.
- **Ajusta** — queda en zona intermedia; se corrige y se vuelve a medir sin retroceder de etapa.
- **Bloquea** — no alcanza el mínimo; el módulo no avanza y se abre o mantiene una incidencia en el DOC-02 hasta resolverlo.

Los umbrales exactos de cada salida están en la sección de métricas del DOC de la etapa.

---

## 7. Gestión: tablero Scrumban y tiempos

El avance de cada módulo por E1→E7 se gestiona en un **tablero Scrumban**, registrando fecha de apertura y cierre de cada etapa. Cada etapa tiene un **presupuesto de tiempo** definido en las matrices; el tiempo de permanencia real se contrasta contra ese presupuesto como una métrica más del proceso.

---

## 8. Casos especiales

- **Módulos sin backend (M06, M07, M08).** Aún no tienen código que apuntar como fuente principal. Sus superficies se registran contra la **fuente secundaria** (Diseño/Desarrollo) y se marcan **"No verificable — backend no construido"** hasta que exista el dominio.
- **Módulos AIoT (M03, M04, M09).** Además del pipeline general, en E4 llenan el **DOC-03B** en co-autoría con AIoT. En estos módulos la validación no termina en el backend: incluye los puntos de validación sobre broker, edge y —en M04— el modelo de predicción.

---

## 9. Enlace con el flujo Git

El pipeline encaja con el modelo de ramas de Implementación (ver [FLUJO-GIT.md]):

```text
1 módulo aprobado  =  1 rama recep/m0X-vY.Z.W  =  1 recorrido E1→E7  =  1 Pull Request a integration (al superar E7)
```

La rama de recepción aísla el recorrido del módulo; al superar la compuerta de entrega (E7) se fusiona a `integration`. El resultado integrado en `integration` es lo que pasa a la compuerta de salida de Pruebas antes de Despliegue.

---

## 10. Documentos y fuentes de referencia

- **DOC-01 Checklist** — superficies de integración y su recepción (E1).
- **DOC-02 Dependencias** — dependencias, interfaces e incidencias (E2, E6).
- **DOC-03A (sistema)** — secuencia topológica, puertos y protocolos; orden macro (E3).
- **DOC-03B Flujos AIoT** — puntos de validación IoT de M03/M04/M09 (E4).
- **DOC-04 Config y Entrega** — configuración por entorno y compuerta de entrega (E4, E7).
- [PROCEDIMIENTO-RECEPCION.md] — detalle operativo de la etapa E1.
- [API-VALIDACION.md] — apoyo de verificación de superficies REST (Swagger / colección Bruno).
- [FORMATO-RECEPCION.md] — registro de recepción por entrega.
- *Registro de Fuentes de Verdad* (hoja "Léeme" de las matrices) — enlaces únicos a repos, OpenAPI y catálogos.
