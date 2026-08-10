# Base de Datos — Ecosistema de Implementación SGPMP

## 1. Objetivo

Este documento define la forma en que el grupo de Implementación gestionará la base de datos PostgreSQL dentro de los ambientes DEV, TEST y posteriormente PROD del proyecto SGPMP.

La estructura funcional de la base de datos es responsabilidad del DBA del proyecto.

El grupo de Implementación es responsable de preparar los ambientes técnicos necesarios para ejecutar la base de datos, restaurarla cuando corresponda y conectarla posteriormente con los componentes aprobados del sistema.

---

## 2. Motor de base de datos

El proyecto utiliza:

```text
PostgreSQL
```

Actualmente, el ecosistema Docker utiliza como base:

```text
postgres:16
```

Antes de restaurar la base de datos entregada por el DBA se debe verificar que esta versión sea compatible con el archivo `.dump`.

---

## 3. Fuente oficial de la base de datos

El DBA del proyecto entregó un archivo con extensión:

```text
.dump
```

Este archivo representa una copia de la base de datos del proyecto y será utilizado como fuente inicial para preparar los ambientes locales.

La ubicación definida para el archivo dentro del ecosistema es:

```text
implementation/database/dumps/
```

Ejemplo:

```text
implementation/
└── database/
    └── dumps/
        └── sgpmp.dump
```

---

## 4. Versionamiento del dump

Los archivos de respaldo de base de datos no deben almacenarse directamente en el repositorio Git.

El archivo `.gitignore` debe incluir:

```gitignore
database/dumps/*.dump
database/dumps/*.sql
```

Esto evita versionar copias de bases de datos que pueden:

- contener información sensible;
- tener un tamaño considerable;
- cambiar frecuentemente;
- no corresponder a código fuente.

---

## 5. Estrategia de ambientes

La base de datos debe mantenerse separada entre DEV y TEST.

La arquitectura inicial será:

```text
                      PostgreSQL
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
             DEV                     TEST
              │                       │
              ▼                       ▼
   sgpmp-postgres-dev      sgpmp-postgres-test
              │                       │
              ▼                       ▼
         sgpmp_dev                sgpmp_test
              │                       │
              ▼                       ▼
       volumen DEV              volumen TEST
```

DEV y TEST no deben compartir:

- contenedor;
- base de datos;
- usuario;
- volumen persistente.

---

## 6. Ambiente DEV

### Objetivo

El ambiente DEV será utilizado posteriormente para desarrollo e integración local de componentes previamente aprobados.

### Configuración

Servicio Docker Compose:

```text
postgres-dev
```

Contenedor:

```text
sgpmp-postgres-dev
```

Base de datos:

```text
sgpmp_dev
```

Usuario:

```text
sgpmp_dev
```

Puerto del host:

```text
5432
```

Puerto interno del contenedor:

```text
5432
```

Volumen:

```text
sgpmp-postgres-dev-data
```

Red:

```text
sgpmp-dev-network
```

Archivo de variables:

```text
.env.dev
```

### Comportamiento esperado

DEV tendrá persistencia.

Esto significa que la información debe mantenerse aunque los contenedores sean detenidos y posteriormente creados nuevamente.

Flujo:

```text
dump inicial
     ↓
sgpmp_dev
     ↓
integraciones
     ↓
datos persistentes
```

---

## 7. Ambiente TEST

### Objetivo

El ambiente TEST será utilizado para ejecutar pruebas y validaciones de forma independiente de DEV.

Puede ser utilizado por:

- grupo de Pruebas;
- grupo de Implementación.

Cada grupo mantiene responsabilidades diferentes sobre las validaciones realizadas.

### Configuración

Servicio Docker Compose:

```text
postgres-test
```

Contenedor:

```text
sgpmp-postgres-test
```

Base de datos:

```text
sgpmp_test
```

Usuario:

```text
sgpmp_test
```

Puerto del host:

```text
5433
```

Puerto interno del contenedor:

```text
5432
```

Volumen:

```text
sgpmp-postgres-test-data
```

Red:

```text
sgpmp-test-network
```

Archivo de variables:

```text
.env.test
```

---

## 8. Razón para separar DEV y TEST

Las pruebas pueden:

- crear registros;
- modificar registros;
- eliminar registros;
- generar datos temporales;
- provocar errores intencionalmente;
- probar restricciones;
- ejecutar múltiples escenarios.

Por este motivo, TEST no debe utilizar la misma base de datos que DEV.

La separación evita:

```text
Pruebas
   ↓
sgpmp_test

Integración local
   ↓
sgpmp_dev
```

en lugar de:

```text
Pruebas ───────┐
               ├──→ misma base de datos
Integración ───┘
```

---

## 9. Uso del dump del DBA

El archivo `.dump` será utilizado para preparar un estado inicial conocido de la base de datos.

La estrategia prevista es:

```text
                   dump DBA
                       │
             ┌─────────┴─────────┐
             │                   │
             ▼                   ▼
        PostgreSQL DEV      PostgreSQL TEST
             │                   │
             ▼                   ▼
          sgpmp_dev           sgpmp_test
```

Sin embargo, antes de realizar esta restauración se debe analizar el archivo.

---

## 10. Verificaciones previas del dump

Antes de restaurar el archivo se debe comprobar:

1. formato del dump;
2. versión de PostgreSQL utilizada por el DBA;
3. versión de `pg_dump` utilizada;
4. schemas incluidos;
5. propietarios de los objetos;
6. roles requeridos;
7. extensiones PostgreSQL utilizadas;
8. si contiene únicamente estructura o también datos;
9. nombre original de la base;
10. posibles dependencias externas.

La restauración no debe realizarse hasta completar estas verificaciones.

---

## 11. Herramienta de restauración

Si el archivo `.dump` fue generado utilizando el formato personalizado de PostgreSQL, la restauración se realizará mediante:

```text
pg_restore
```

Por ejemplo, conceptualmente:

```text
archivo.dump
     ↓
pg_restore
     ↓
PostgreSQL
```

Los comandos definitivos de restauración se documentarán después de analizar el archivo entregado por el DBA.

---

## 12. Estrategia de DEV

Una vez validado el dump:

```text
dump DBA
    ↓
restauración
    ↓
sgpmp_dev
    ↓
estado inicial
    ↓
trabajo de integración
```

DEV conservará los cambios mediante su volumen persistente.

El volumen DEV es:

```text
sgpmp-postgres-dev-data
```

Durante la operación normal no debe eliminarse.

---

## 13. Estrategia de TEST

TEST debe ser reproducible.

La estrategia prevista será:

```text
dump DBA
    ↓
estado inicial TEST
    ↓
ejecución de pruebas
    ↓
datos modificados
    ↓
reset
    ↓
estado inicial TEST
```

Esto permite repetir las mismas pruebas sobre condiciones conocidas.

Posteriormente se documentará un procedimiento específico para:

```text
reset TEST
```

que podrá:

1. eliminar el estado actual de TEST;
2. recrear la base;
3. restaurar el dump;
4. dejarla preparada para una nueva ejecución.

---

## 14. Uso compartido del ambiente TEST

El grupo de Pruebas y el grupo de Implementación pueden utilizar la definición del ambiente TEST.

Sin embargo, sus responsabilidades son diferentes.

### Grupo de Pruebas

Utiliza TEST para validar aspectos como:

- funcionamiento de requerimientos;
- casos positivos;
- casos negativos;
- pruebas automatizadas;
- pruebas unitarias;
- pruebas E2E;
- regresiones.

### Grupo de Implementación

Después de recibir una versión aprobada, utiliza TEST para verificar aspectos como:

- conectividad entre componentes;
- Frontend ↔ Backend;
- Backend ↔ PostgreSQL;
- comunicación entre módulos;
- contratos REST;
- autenticación;
- integraciones externas cuando correspondan.

Por lo tanto:

```text
PRUEBAS
¿La funcionalidad cumple?

          ↓ aprobación

IMPLEMENTACIÓN
¿La funcionalidad aprobada se integra correctamente?
```

---

## 15. Responsabilidad del DBA

El DBA es responsable principalmente de:

- diseño del modelo de datos;
- definición de tablas;
- schemas;
- relaciones;
- restricciones;
- índices;
- tipos de datos;
- estructura oficial;
- respaldo de referencia cuando corresponda.

---

## 16. Responsabilidad de Desarrollo

Desarrollo es responsable principalmente de:

- adaptadores de persistencia;
- repositorios SQLAlchemy;
- mapeo entre dominio y persistencia;
- código que consume PostgreSQL;
- migraciones cuando sean requeridas;
- manejo técnico de errores de persistencia.

---

## 17. Responsabilidad de Pruebas

Pruebas puede utilizar la infraestructura TEST para ejecutar:

```text
backend
↓
pytest
```

y posteriormente:

```text
frontend
↓
Vitest / Cypress
```

cuando los componentes correspondientes estén incorporados al ecosistema.

---

## 18. Responsabilidad de Implementación

Implementación será responsable de:

- preparar PostgreSQL en Docker;
- mantener ambientes separados;
- gestionar variables de conexión;
- restaurar el dump entregado por el DBA;
- verificar conectividad;
- incorporar posteriormente las migraciones recibidas;
- conectar Backend con PostgreSQL;
- documentar evidencias;
- mantener reproducible el ambiente.

---

## 19. Restricciones

El grupo de Implementación no debe modificar por decisión propia:

- tablas;
- columnas;
- relaciones;
- llaves;
- restricciones;
- índices;
- schemas;
- reglas del modelo de datos.

Tampoco debe:

- crear manualmente estructuras funcionales que no hayan sido definidas;
- modificar el dump original;
- utilizar la misma base para DEV y TEST;
- almacenar credenciales reales en Git;
- versionar dumps que contengan información sensible.

---

## 20. Migraciones

Cuando Desarrollo entregue componentes que requieran cambios del esquema, dichos cambios deben recibirse mediante el mecanismo acordado por el proyecto.

Implementación no debe reproducir manualmente los cambios mediante instrucciones SQL improvisadas.

El flujo esperado será:

```text
Desarrollo
    ↓
migración
    ↓
Pruebas
    ↓
aprobación
    ↓
Implementación
    ↓
ejecución controlada
    ↓
verificación
```

---

## 21. Persistencia

Los volúmenes definidos actualmente son:

### DEV

```text
sgpmp-postgres-dev-data
```

### TEST

```text
sgpmp-postgres-test-data
```

Se pueden consultar mediante:

```bash
docker volume ls
```

Los volúmenes permiten que PostgreSQL conserve su información al detener los contenedores.

---

## 22. Eliminación de datos

El comando:

```bash
docker compose down
```

detiene los servicios sin eliminar intencionalmente los volúmenes persistentes.

En cambio:

```bash
docker compose down -v
```

puede eliminar volúmenes y provocar pérdida de datos.

Por este motivo, `-v` únicamente debe utilizarse de forma controlada cuando se pretenda reconstruir un ambiente.

---

## 23. Estado actual

A la fecha de preparación inicial del ecosistema:

- PostgreSQL DEV está definido mediante Docker Compose.
- PostgreSQL TEST está definido mediante Docker Compose.
- DEV y TEST utilizan contenedores independientes.
- DEV y TEST utilizan bases independientes.
- DEV y TEST utilizan volúmenes independientes.
- DEV y TEST utilizan redes independientes.
- El archivo `.dump` fue entregado por el DBA.
- El dump está pendiente de análisis técnico.
- El dump todavía no ha sido restaurado.
- Backend todavía no está incorporado al Docker de Implementación.
- Frontend todavía no está incorporado al Docker de Implementación.
- La integración de código se realizará únicamente después de la aprobación del grupo de Pruebas.

---

## 24. Arquitectura actual

```text
                      ECOSISTEMA DE BASE DE DATOS

                              DBA
                               │
                               │
                         archivo .dump
                               │
                       pendiente análisis
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼

         POSTGRESQL DEV                POSTGRESQL TEST

       postgres-dev                   postgres-test
             │                             │
             ▼                             ▼
        sgpmp_dev                      sgpmp_test
             │                             │
             ▼                             ▼
     volumen persistente             volumen independiente
             │                             │
             ▼                             ▼
      integración local               pruebas reproducibles
```

---

## 25. Próximo paso

El siguiente paso será analizar técnicamente el archivo `.dump` entregado por el DBA.

Se deberá identificar:

- formato;
- versión;
- contenido;
- compatibilidad;
- método correcto de restauración.

Después de esta validación se documentará y ejecutará la restauración de DEV y TEST.