# Seguimiento técnico — HU-IMP-AMB-06
## Montaje del ambiente DEV

**Rama prevista:** `feat/ambiente-dev`
**Repositorio:** `SGMP-Integracion`
**Historia de Usuario:** HU-IMP-AMB-06 — Montaje del ambiente DEV
**Estado:** ⏳ En progreso

---

# 1. Objetivo

Montar y validar el ambiente DEV de extremo a extremo a partir de las piezas ya preparadas por Implementación y de las dependencias entregadas por otras historias.

La HU se trabajará de forma incremental y documentada. Si una subtarea depende de una HU externa todavía no integrada o presenta una discrepancia contractual, se registrará el punto exacto de bloqueo y la razón antes de continuar.

---

# 2. Dependencias de esta HU

HU-06 depende principalmente de:

```text
HU-01 — Compose base
HU-02 — Catálogo unificado de variables
HU-04 — Restauración / capa de base de datos
HU-05 — Capa AIoT / gateway / broker
```

Estado conocido al iniciar HU-06:

```text
HU-01 → desarrollada en feat/compose-base, publicada, pendiente de revisión/merge
HU-02 → desarrollada en feat/env-unificado, publicada, pendiente de revisión/merge
HU-04 → informada como terminada por su responsable y publicada en feat/db-restauracion-dbintegrador
HU-05 → estado todavía no confirmado para integración final
```

---

# 3. Estrategia de ramas

Como HU-01 y HU-02 todavía no se encuentran en `main`, HU-06 no debe crearse desde `main`.

La cadena temporal de trabajo será:

```text
main
  └── feat/compose-base
       └── feat/env-unificado
            └── feat/ambiente-dev
```

Esto permite que HU-06 utilice el Compose base y el catálogo de variables ya desarrollados sin fusionarlos prematuramente a `main`.

Cuando HU-01 y HU-02 sean aprobadas y fusionadas, la base de HU-06 deberá revisarse antes de su Pull Request definitivo.

---

# 4. Tratamiento de HU-04

La rama remota identificada es:

```text
feat/db-restauracion-dbintegrador
```

La entrega reporta técnicamente:

```text
PostgreSQL 18
base dba
usuario dba
puerto host 5433
dump backup7_1_0.dump
roles restaurados
pg_cron habilitado
scripts/restaurar-bd.sh validado
```

También reporta que la BD se consume como una capa externa al Compose de integración.

No se hará merge directo de esta rama sobre `feat/ambiente-dev` en el inicio de HU-06.

Motivos:

1. HU-04 fue creada en paralelo desde `main`.
2. HU-04 modifica archivos `.env.*.example` que HU-02 ya normalizó posteriormente.
3. Un merge o cherry-pick completo podría reintroducir nomenclatura anterior o generar conflictos innecesarios.
4. Para pruebas de dependencia se podrá usar la rama HU-04 de forma separada.
5. Los artefactos específicos de HU-04 se integrarán o referenciarán únicamente cuando se llegue a ST-02.

---

# 5. Discrepancia detectada antes de ST-02

Existe una diferencia arquitectónica que debe reconciliarse antes del cierre de ST-02:

### HU-01 / HU-02 actuales

El Compose base contiene un servicio:

```text
database
```

con comunicación interna mediante:

```text
database:5432
```

### HU-04

El reporte de HU-04 indica que DBIntegrador se restaura y opera de forma separada y que DEV la consume mediante:

```text
host.docker.internal:5433
```

Por tanto, antes de integrar definitivamente la capa de BD en HU-06 debe confirmarse cuál topología será la oficial:

```text
A. PostgreSQL como servicio interno del Compose integrado
o
B. DBIntegrador restaurada como capa externa al Compose
```

Esta discrepancia no impide trabajar ST-01.

---

# 6. Subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Build local de backend/frontend con configuración DEV | ⏳ Por iniciar |
| ST-02 | Integrar capa BD de HU-04 y capa AIoT de HU-05 | ⏳ Pendiente; BD disponible provisionalmente, AIoT por confirmar |
| ST-03 | Verificación integral, healthchecks y evidencias | ⏳ Pendiente |

---

# 7. Plan de ST-01

ST-01 se puede ejecutar sin esperar HU-04/HU-05.

Objetivos:

```text
1. Crear feat/ambiente-dev desde feat/env-unificado.
2. Confirmar estructura y archivos DEV.
3. Validar resolución de docker compose.
4. Construir backend local.
5. Construir frontend local.
6. Validar healthchecks/builds sin depender todavía de integración completa.
7. Registrar resultados.
8. Commit de cierre de ST-01.
```

No se realizarán merges a `main`.

---

# 8. Criterio de bloqueo

Si durante ST-02 la integración requiere una decisión o dato todavía no entregado por HU-04/HU-05, se registrará:

```text
- punto exacto alcanzado;
- prueba realizada;
- resultado;
- dato/dependencia faltante;
- rama/HU responsable;
- razón por la que no se continúa.
```

La HU permanecerá en progreso hasta que la dependencia sea resuelta.

---

# 9. Estado actual

```text
HU-IMP-AMB-06
├── ST-01 ⏳ Build local DEV
├── ST-02 ⏳ Integración BD / AIoT
└── ST-03 ⏳ Verificación integral
```

**Siguiente acción:** crear `feat/ambiente-dev` desde `feat/env-unificado` e iniciar ST-01.
