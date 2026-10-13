# Registro de incidencias — Implementación (BORRADOR)

> Destino: `registros/incidencias/registro.md` en `SGMP-Integracion` (HU-IMP-DOC-01, CA-5).
> Fecha de corte: 2026-10-12. Los IDs `SAL-IMP-NN` son **provisionales**: reemplácelos por los IDs definitivos del registro.
> Origen: tabla de salvedades de la §11.4 de la v1.4, actualizada con REV-01 (C2, C3, C4–C8) y las variables de Dokploy vigentes.
> No incluir valores de credenciales en este archivo.

| ID | Salvedad | Detalle | Responsable | Estado |
|---|---|---|---|---|
| SAL-IMP-01 | Rol de conexión del backend | El diseño de PROD nombra un rol `member_app` que no existe en los roles del DBA (`member_dev`, `member_qa`, `member_impl`, `member_iot`, `member_deploy`). En DEV y TEST el gateway AIoT usa hoy el rol `dba` y se conecta por host y puerto publicado (5447 / 5448); el backend usa `sgpmp_app`. | DBA / AIoT | Vigente |
| SAL-IMP-02 | Prerrequisito de repositorios hermanos | El compose local construye desde carpetas hermanas de `SGMP-Integracion`. Incorporado en el runbook (§11.2). | Implementación | Documentado |
| SAL-IMP-03 | Carpeta de Mosquitto en TEST | El override local de TEST monta desde `BROKER-MQTT-SGPMP-develop`, distinta del nombre usado en DEV. Unificar la convención. | Implementación | Vigente |
| SAL-IMP-04 | Restauración de BD sin integrar a `main` | Restauración contra DBIntegrador completa y validada, ejecutada en una rama divergente. Reaplicar script y reporte sobre `main`. | Implementación | Por confirmar |
| SAL-IMP-05 | Imágenes sin publicar en GHCR | Ningún repositorio publica imágenes; Dokploy construye en cada despliegue. Incumple "construir una vez, ejecutar en todos los entornos". Automatizar por tag antes de PROD. | Implementación / Desarrollo | Vigente |
| SAL-IMP-06 | Sandbox: código solo en la rama `test` (REV-01 C3) | El compose de TEST ya reenvía `ENABLE_TEST_SANDBOX` y `TEST_SANDBOX_SECRET` (parte cerrada). El código (`src/shared/rollback/…`, `main.py`) existe solo en `test`; si `test` se reconstruye desde `dev`, la Sandbox desaparece. | Desarrollo / Pruebas | Abierto |
| SAL-IMP-07 | Compose de TEST: almacenamiento (REV-01 C2) | Ya reenvía `MQTT_BROKER_URL` y `MQTT_BROKER_TOKEN` (con `:?`). Pendientes `LOGOS_STORAGE_PATH` y `MODELOS_STORAGE_PATH` (cae a `/tmp/sgpmp_modelos`, sin volumen). | Implementación | Vigente |
| SAL-IMP-08 | `ROOT_PATH` frente a la ruta pública | `/api-sgpmp` y `/api-sgpmp-test` difieren de `/back-sigab-dev` y `/back-sigab-test`; solo afecta los enlaces de `/docs`. Alinear o confirmar que es intencional. | Implementación | Verificar |
| SAL-IMP-09 | Puerto 5449 de PROD | Reserva documental; `docker-compose.prod.yml` no publica la base. Acceso por túnel SSH o firewall restringido. | Despliegue | Aclarado |
| SAL-IMP-10 | Rama de AIoT que alimenta TEST | AIoT mantiene `develop`, `test` y `main`. Confirmar que `test` alimenta la instancia de TEST (puerto 1885, `/broker-sigab-test`) y cómo se promueve. | AIoT | Por confirmar |
| SAL-IMP-11 | Creación de PROD desde cero | `alembic/baseline/esquema_baseline.sql` tiene 979 sentencias `OWNER TO postgres`; con otro `POSTGRES_USER`, `alembic upgrade head` falla en base vacía. | Desarrollo / DBA | Vigente |
| SAL-IMP-12 | Manejo de credenciales | Valores sensibles circularon en archivos de texto y chats: gestionar solo desde la consola de Dokploy y **rotar**. Hoy DEV y TEST comparten la contraseña de la base y la clave de reCAPTCHA. | Implementación | Acción requerida |
| SAL-IMP-13 | Plantillas `.env.*.example` desalineadas | `.env.test.example` usa `sgpmp_test_user` y `ROOT_PATH=/api`, y omite cookies, JWT y MQTT; el compose de TEST las consume. | Implementación | Vigente |
| SAL-IMP-14 | `VITE_AGROFUSION_LOGIN_URL` fuera del build (REV-01 C6) | El código de `dev` la lee, pero ningún build de Docker la recibe. Enlazar con INC-FE-01. | Desarrollo | Pendiente de triage |
| SAL-IMP-15 | Variables sin catalogar (REV-01 C7) | `AUDITORIA_M02_EVENTOS_POR_SEGUNDO` y `ALEMBIC_DATABASE_URL` agregadas al catálogo con valor por confirmar; `FORWARDED_ALLOW_IPS` la fija el Dockerfile. | Desarrollo | Por confirmar |
| SAL-IMP-16 | TLS y ACL del broker (REV-01 C8) | TLS implementado en código (PR #19) en `develop` y `test`, sin activar; ACL dynamic-security activa en `develop` y `test`, no en `main`. Ver HU-IMP-SEG-03. | AIoT | Vigente |
| SAL-IMP-17 | Ruta del SSO AgroFusion en DEV | `AGROFUSION_SSO_PUBLIC_KEY_PATH` apunta a una carpeta local de un desarrollador, no a una ruta montada en el contenedor. | Desarrollo | Por confirmar |
