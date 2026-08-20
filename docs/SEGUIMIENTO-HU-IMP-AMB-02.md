# Seguimiento técnico — HU-IMP-AMB-02
## Catálogo unificado de variables de entorno

**Responsable:** Juan Esteban Hernández Lozano  
**Rama de trabajo:** `feat/env-unificado`  
**Repositorio:** `SGMP-Integracion`  
**Historia de Usuario:** HU-IMP-AMB-02 — Catálogo unificado de variables de entorno  
**Estado:** ⏳ En progreso

---

# 1. Objetivo de la Historia de Usuario

Consolidar los archivos de ejemplo de variables de entorno de DEV, TEST y PROD en un catálogo coherente, completo y consistente, incorporando las variables requeridas por backend, frontend y la capa AIoT.

La historia debe producir:

```text
env/.env.dev.example
env/.env.test.example
env/.env.prod.example
docs/VARIABLES-ENTORNO.md
FR-IMP-CE-04
```

El catálogo deberá clasificar las variables por función y sensibilidad.

---

# 2. Criterios de aceptación

| Criterio | Estado |
|---|---|
| Los tres `.env.*.example` quedan completos y consistentes para backend, frontend, JWT y MQTT | ⏳ En progreso |
| Cada variable queda clasificada por tipo y sensibilidad | ⏳ Pendiente |
| Se resuelven discrepancias de nombre de base de datos y puerto | ⏳ Pendiente |
| Se redacta el artefacto `FR-IMP-CE-04` | ⏳ Pendiente |

Tipos de variable previstos:

```text
Conexión
Comportamiento
Autenticación / Seguridad
AIoT / Analítica
```

---

# 3. Subtareas

| Subtarea | Descripción | Estado |
|---|---|---|
| ST-01 | Incorporar variables del frontend desde `origin/dev` | ✅ Completada |
| ST-02 | Incorporar variables MQTT y de seguridad | ⏳ Pendiente |
| ST-03 | Reconciliar nombres de base de datos y puertos | ⏳ Pendiente |
| ST-04 | Catálogo por sensibilidad, `FR-IMP-CE-04` y `docs/VARIABLES-ENTORNO.md` | ⏳ Pendiente |

---

# 4. Dependencia con HU-IMP-AMB-01

HU-02 depende de la definición Compose construida durante HU-IMP-AMB-01.

HU-01 fue desarrollada en:

```text
feat/compose-base
```

y fue subida al remoto para revisión del Líder, sin merge directo a `main`.

Por esta razón, HU-02 se inició temporalmente a partir de `feat/compose-base`.

Antes del Pull Request definitivo de HU-02, una vez HU-01 haya sido aprobada y fusionada, la rama deberá reubicarse sobre el `main` actualizado.

---

# 5. Inventario inicial

Se encontraron:

```text
env/.env.dev
env/.env.dev.example
env/.env.test
env/.env.test.example
env/.env.prod
env/.env.prod.example
```

Los archivos reales:

```text
env/.env.dev
env/.env.test
env/.env.prod
```

no están versionados.

Validación con `git ls-files`:

```text
env/.env.dev.example
env/.env.prod.example
env/.env.test.example
```

Validación con `git check-ignore`:

```text
.gitignore:3:.env.dev
.gitignore:4:.env.test
.gitignore:5:.env.prod
```

Por tanto, únicamente los archivos `.example` forman parte del repositorio.

---

# 6. Inventario de variables actuales del Compose

Se identificaron referencias a:

```text
BACKEND_IMAGE
DATABASE_IMAGE
DB_ADMIN_USER
DB_APP_PASSWORD
DB_APP_USER
DB_HOST
DB_NAME
DB_PORT
FRONTEND_IMAGE
FRONTEND_URL
GATEWAY_API_TOKEN
GATEWAY_DATABASE_URL
GATEWAY_IMAGE
SECRET_KEY
VITE_API_BASE_URL
```

Este inventario se utilizará principalmente en ST-02 y ST-03.

---

# 7. ST-01 — Incorporación de variables del frontend

**Estado:** ✅ Completada

## 7.1 Fuente de referencia

La subtarea requería tomar como referencia el frontend en:

```text
origin/dev
```

del repositorio:

```text
SGPMP-FRONT-END-PWA
```

Se actualizó la referencia remota mediante:

```bash
git -C ../SGPMP-FRONT-END-PWA fetch origin
```

Luego se verificó si existía un archivo `.env.example` dentro de `origin/dev`.

Resultado:

```text
README.md
```

No existe `.env.example` versionado en esa rama.

Por ello, el contrato real del frontend se reconstruyó mediante dos fuentes:

```text
README.md / CLAUDE.md
código fuente bajo src/
```

---

## 7.2 Variables respaldadas por código o documentación

Las variables identificadas fueron:

```text
VITE_API_BASE_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_APP_ID
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_VAPID_KEY
VITE_SW
VITE_AGROFUSION_LOGIN_URL
```

---

## 7.3 `VITE_AGROFUSION_LOGIN_URL`

Se encontró uso directo en:

```text
src/auth/pages/LoginPage.tsx
```

mediante:

```text
import.meta.env.VITE_AGROFUSION_LOGIN_URL
```

El comportamiento del frontend es:

```text
Si la variable existe → redirección hacia AgroFusion
Si la variable no existe → no se ejecuta la redirección
```

Los tres `.env.*.example` no contenían esta variable inicialmente.

Se agregó:

```text
VITE_AGROFUSION_LOGIN_URL=
```

como placeholder vacío, sin inventar una URL.

---

## 7.4 `VITE_SW`

La variable:

```text
VITE_SW
```

no apareció en el primer barrido de `import.meta.env.*` dentro de `src/`, pero sí está documentada en:

```text
README.md
CLAUDE.md
```

como control del Service Worker.

Por ello se conserva.

Valores actuales:

```text
DEV  → VITE_SW=false
TEST → VITE_SW=false
PROD → VITE_SW=true
```

---

## 7.5 `VITE_APP_ENV`

La variable:

```text
VITE_APP_ENV
```

existía inicialmente en:

```text
.env.dev.example
.env.test.example
.env.prod.example
```

pero no apareció en:

```text
código de origin/dev
README.md
CLAUDE.md
```

Se consideró una variable no respaldada por la versión actual del frontend.

Fue retirada de los tres `.env.*.example`.

---

## 7.6 Contrato frontend resultante

Los tres ambientes quedaron con el mismo conjunto de variables frontend:

```text
VITE_AGROFUSION_LOGIN_URL
VITE_API_BASE_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_APP_ID
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_SW
VITE_VAPID_KEY
```

---

## 7.7 Validaciones realizadas

### Eliminación de variable obsoleta

Comando:

```bash
grep -Rni "VITE_APP_ENV" env/.env.*.example
```

Resultado:

```text
Sin salida
```

Esto confirma que `VITE_APP_ENV` ya no está presente.

### Incorporación de AgroFusion

Comando:

```bash
grep -n "VITE_AGROFUSION_LOGIN_URL" env/.env.*.example
```

Resultado:

```text
env/.env.dev.example:30:VITE_AGROFUSION_LOGIN_URL=
env/.env.prod.example:29:VITE_AGROFUSION_LOGIN_URL=
env/.env.test.example:30:VITE_AGROFUSION_LOGIN_URL=
```

### Consistencia del contrato `VITE_*`

Se extrajeron y ordenaron todas las variables `VITE_*` de los tres archivos.

DEV:

```text
VITE_AGROFUSION_LOGIN_URL
VITE_API_BASE_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_APP_ID
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_SW
VITE_VAPID_KEY
```

TEST:

```text
VITE_AGROFUSION_LOGIN_URL
VITE_API_BASE_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_APP_ID
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_SW
VITE_VAPID_KEY
```

PROD:

```text
VITE_AGROFUSION_LOGIN_URL
VITE_API_BASE_URL
VITE_FIREBASE_API_KEY
VITE_FIREBASE_APP_ID
VITE_FIREBASE_AUTH_DOMAIN
VITE_FIREBASE_MESSAGING_SENDER_ID
VITE_FIREBASE_PROJECT_ID
VITE_FIREBASE_STORAGE_BUCKET
VITE_SW
VITE_VAPID_KEY
```

Los tres contratos coinciden.

---

# 8. Hallazgos reservados para subtareas posteriores

Durante ST-01 también se detectaron discrepancias que se resolverán más adelante.

Los `.env.*.example` actuales utilizan:

```text
APP_ENV
POSTGRES_*
JWT_SECRET_KEY
```

mientras Compose/backend utilizan:

```text
ENVIRONMENT / ENV
DB_*
SECRET_KEY
DATABASE_URL
```

La reconciliación corresponde a ST-03.

También se identificaron variables backend adicionales:

```text
JWT_EXPIRE_HOURS
RF71_INTERNAL_KEY
MODELOS_STORAGE_PATH
FIREBASE_CREDENTIALS_PATH
ENV
```

Estas deberán evaluarse antes del catálogo definitivo.

---

# 9. Estado general

```text
HU-IMP-AMB-02
├── ST-01 ✅ Frontend
├── ST-02 ⏳ MQTT / seguridad
├── ST-03 ⏳ BD / puertos
└── ST-04 ⏳ Catálogo / FR-IMP-CE-04
```
