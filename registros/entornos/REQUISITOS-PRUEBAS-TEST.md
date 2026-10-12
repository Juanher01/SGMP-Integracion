# Requisitos de Pruebas para el ambiente TEST

**HU:** HU-IMP-AMB-07 — Montaje del ambiente TEST
**Subtarea:** ST-01 — Recabar requisitos de Pruebas
**Responsable:** Juan Sebastián Gutiérrez Tobar
**Estado:** Recabado — con puntos pendientes de respuesta de Pruebas (ver §4)
**Fecha:** 20 de agosto de 2026


---

## 1. Aclaración de responsabilidad (hallazgo central)

La evaluación previa de Pruebas asumía que el montaje de TEST era responsabilidad de Pruebas. Se concilió y quedó confirmado:

> **Implementación monta y orquesta los tres ambientes (DEV, TEST y PROD).**
> Lo que varía es **quién opera** cada uno una vez montado:
> - DEV → lo opera Implementación / Desarrollo / AIoT.
> - **TEST → lo opera Pruebas.**
> - PROD → lo opera Despliegue (Dokploy).


---

## 2. Stack de Pruebas y qué le corresponde a cada parte

| Herramienta | Uso | ¿Quién la instala/mantiene? | Qué necesita de Implementación |
|---|---|---|---|
| Cypress | E2E (frontend) | Pruebas | URL estable del frontend en TEST |
| Vitest | Unitarias (frontend) | Pruebas | No requiere infraestructura de TEST |
| Pytest (+pytest-cov, pytest-html) | Backend | Pruebas | URL estable del backend en TEST |
| Playwright | E2E cross-browser (WebKit/Safari) | Pruebas | Misma URL de frontend, sin restricciones por user-agent |
| cypress-axe | Accesibilidad (WCAG 2.1 AA) | Pruebas | Solo necesita el frontend servido |
| Newman (CLI Postman) | Pruebas de contrato de API | Pruebas | URL base del backend + colección Postman (a coordinar, ver §4) |
| k6 (grafana/k6) | Carga/rendimiento | Pruebas | Endpoints objetivo (a confirmar, ver §4) |
| OWASP ZAP (zaproxy/zap-stable) | Seguridad | Pruebas | Alcance/URL autorizada de escaneo (a confirmar, ver §4) |

**Conclusión:** Implementación **no instala, configura ni mantiene** ninguna de estas herramientas. Su única responsabilidad es **exponer una URL estable del ambiente TEST** una vez montado, y coordinar con Pruebas los endpoints/flujos críticos que cada herramienta necesita.

---

## 3. Datos confirmados (insumo directo para compose/env de TEST)

| Dato | Valor confirmado | Fuente |
|---|---|---|
| Rol de base de datos para Pruebas | `member_qa` (grupo `grp_qa`, límite de 10 conexiones, contraseña propia) — ya existe en `DBIntegrador` | Comunicación con DBA / Pruebas |
| Versión de PostgreSQL oficial | `postgres:18` | Confirmado por el DBA (Samuel) |
| Equivalencia de nomenclatura | Lo que Implementación llama **TEST**, Despliegue lo documenta como **STAGING** | Comunicación con Despliegue |
| Rama de integración (Git) | Aprobado, sin acción pendiente | Evaluación de Pruebas, fila 12 |

**Acción derivada:** coordinar con el DBA la entrega de las credenciales del rol `member_qa` para inyectarlas en `.env.test`.

---

## 4. Preguntas enviadas a Pruebas — pendientes de respuesta

Estas preguntas fueron enviadas a Pruebas. ST-01 se considera recabado con este catálogo; las respuestas alimentarán directamente el Contrato de entrega de TEST (ST-02) y la configuración de `compose.test.yml` / `.env.test` (ST-03).

1. **Acceso.** ¿Contra qué URL/dominio y puerto van a ejecutarse las herramientas (Cypress, Vitest, Pytest, Playwright, cypress-axe, Newman, k6, OWASP ZAP)? ¿Qué esquema de acceso esperan (dominio/puerto)?
2. **Alcance de componentes.** ¿Basta con frontend y backend servidos, o también necesitan el **gateway AIoT + Mosquitto activos** para validar los flujos IoT de M03/M04/M09?
3. **Política de datos.** ¿Requieren datos semilla precargados por Implementación, o Pruebas siembra sus propios datos mediante sus scripts/fixtures? ¿La base de datos de TEST debe reiniciarse a un estado determinista antes de cada corrida?
4. **Healthchecks y puertos.** ¿Qué rutas de salud (healthchecks) y puertos esperan encontrar disponibles?
5. **Usuarios y roles (RBAC).** ¿Qué usuarios/roles de prueba necesitan, más allá del rol `member_qa` que ya tiene preparado el DBA?
6. **Newman.** ¿Cuál es la colección Postman a usar, y la URL base sobre la que corre?
7. **k6.** ¿Cuáles son los endpoints objetivo de las pruebas de carga?
8. **OWASP ZAP.** ¿Cuál es el alcance/URL autorizada para el escaneo de seguridad?

> Con las respuestas a estos ocho puntos, Implementación cierra formalmente el **Contrato de entrega del ambiente TEST** y avanza con su montaje técnico.

---

## 5. Estado de la subtarea

- [x] Stack de Pruebas identificado y su responsable de instalación/mantenimiento aclarado.
- [x] Malentendido de responsabilidad de montaje (TEST) resuelto y documentado.
- [x] Datos de infraestructura confirmados (rol BD, versión PostgreSQL, nomenclatura TEST=STAGING).
- [x] Catálogo de preguntas formales enviado a Pruebas.
- [ ] Respuestas de Pruebas al catálogo de la sección 4 — **pendiente**, no bloquea el cierre de ST-01, alimenta ST-02 y ST-03.

**ST-01 se entrega como completada** en este estado: los requisitos fueron recabados y documentados; el seguimiento de las respuestas pendientes continúa en paralelo con la redacción del Contrato de entrega (ST-02).
