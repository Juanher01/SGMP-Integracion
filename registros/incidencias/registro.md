# Registro de incidencias de comunicación entre componentes

> Estado: vigente · Actualizado: 2026-10-12 · Responsable: Líder de Implementación · Mantiene: agente `triage`

Procedimiento: skill `triage-comunicacion`. Estados: `detectado` → `diagnosticado` → `derivado (equipo)` / `en HU (ID)` → `resuelto` → `verificado`.

| ID | Fecha | Entorno | Síntoma | Capa | Responsable | Estado | Enlace |
|---|---|---|---|---|---|---|---|
| INC-FE-01 | 2026-10-12 | DEV, TEST, PROD | El botón "Continuar con AgroFusion" quedaría deshabilitado en todo build Docker | Build del frontend (`VITE_*`) | Por confirmar (Implementación: Dockerfile y compose) | detectado — pendiente de triage | — |
| INC-FE-02 | 2026-10-12 | TEST | El service worker de la PWA podría servir la app en rutas del backend o del gateway que comparten host (`api.inmero.co`) | Frontend (PWA) y Traefik | Por confirmar (Desarrollo: `vite.config.ts`; Despliegue: hosts) | detectado — pendiente de triage | — |
| INC-BE-01 | 2026-10-12 | TEST | El código de la Sandbox (`ENABLE_TEST_SANDBOX`, `src/shared/rollback/…`) existe solo en la rama `test` del backend, no en `dev` ni en `main`: si `test` se reconstruye desde `dev`, la Sandbox desaparece | Código de aplicación (divergencia de ramas) | Desarrollo (informar a Pruebas) | detectado — confirmar con Desarrollo | historias/HU-IMP-DOC-01_documento-ambiente-trabajo/revisiones/REV-01.md (C3) |

## Notas de detección (insumo para el triage)

- **INC-FE-01**: `src/auth/config/sso.ts` lee `VITE_AGROFUSION_LOGIN_URL` y `.env.example` la documenta, pero el `Dockerfile` no la declara como `ARG` ni el `docker-compose.yml` la pasa en `build.args` (`origin/dev@aab2625`).
- **INC-FE-02**: `vite.config.ts` define `navigateFallback: "index.html"` con `navigateFallbackDenylist: [/^\/api\//]`. El frontend de TEST vive en `https://api.inmero.co/`, el mismo host que `/back-sigab-test` y `/broker-sigab-test`. Hipótesis sin comprobar en el navegador.
