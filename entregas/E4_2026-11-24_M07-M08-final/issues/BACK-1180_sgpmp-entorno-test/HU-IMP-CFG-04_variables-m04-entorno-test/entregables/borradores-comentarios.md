# Borradores de comentarios: PR #1204 e issue #1180 (Arekkazu/sgpmp-backend)

> Borradores. No publicados: los publica el Líder de Implementación. Corte 2026-11-20: `test@12965211`, PR `b8968e68`. Base: [`analisis.md`](../../../../prs/BACK-PR1204_compose-test-entorno-m04/analisis.md) (EXT-BACK-PR1204).

## 1. Comentario en el PR #1204

Gracias por la corrección, @Arekkazu. Revisamos el diff contra `test@12965211` y `dev@6cee5fc4`: la causa de #1180 queda resuelta (`SGPMP_ENTORNO: ${SGPMP_ENTORNO:-TEST}`) y TEST recibe las mismas variables de M04, OTA y logos que DEV, con la forma `${VAR:-…}` (los valores por defecto de las rutas difieren de DEV porque TEST no monta sus volúmenes). No hay conflicto con `test`.

Un punto antes de fusionar:

- **l. 82, `IOT_AUDITORIA_RESPALDO_PATH: ${IOT_AUDITORIA_RESPALDO_PATH:-var/auditoria_iot/fallas.sqlite3}`.** Hoy TEST toma el valor del `Dockerfile` (`ENV IOT_AUDITORIA_RESPALDO_PATH=/app/storage/auditoria_iot/fallas.sqlite3`, l. 61), una carpeta que se crea con dueño UID 1000 (l. 55-56). Con esta línea el compose la sustituye por una ruta relativa, que dentro del contenedor es `/app/var/...`: `/app` es de root, el proceso corre como `USER 1000` (l. 62) y `.dockerignore` excluye `var/auditoria_iot/` (l. 19). El respaldo de RF-53 fallaría con `PermissionError` justo cuando la BD no responde. Propuesta: quitar la línea (vale el `ENV` del Dockerfile) o usar la ruta absoluta `/app/storage/auditoria_iot/fallas.sqlite3`, que es la que DEV pone como valor literal (`docker-compose.yml:92`).

Para conocimiento (no bloquean este PR; los tomamos en Implementación):

- `AGROFUSION_HUB_CLIENT_ID` y `AGROFUSION_HUB_CLIENT_SECRET` siguen en el compose (l. 67-68) y en `.env.test.example` (l. 54-55), y el código de `test` ya no las lee. Las retiramos en un PR nuestro hacia `test` después de este.
- `.env.test.example` no documenta ninguna de las 11 variables nuevas; lo actualizamos nosotros junto con el catálogo.
- Sobre lo que se pidió en #1180 a Implementación (definir `M04_FIRMA_MODELOS_KEY` en TEST y revisar el `.env` de TEST para `IOT_INFERENCIA_M04_URL` y `OTA_URL_*`): no definimos ni leemos valores de secretos ni el `.env` real. El valor de `M04_FIRMA_MODELOS_KEY` (y de `IOT_INFERENCIA_M04_TOKEN` y `OTA_URL_SECRET`) lo carga Despliegue en Dokploy. Implementación documenta el nombre, la sensibilidad y la regla de carga, y le envía la ficha. Recordatorio: para que el contenedor tome las variables nuevas hace falta **Deploy**, no Restart.

Cuando `docker-compose*.yml`, `.env*.example` o el `Dockerfile` cambien, ¿nos pueden agregar como revisores? Así mantenemos el catálogo y la ficha de Despliegue al día.

## 2. Respuesta en el issue #1180

Gracias por el reporte, @TEX053, y a @Arekkazu por el diagnóstico. La corrección está en el PR #1204 (abierto hacia `test`, sin fusionar al 2026-11-20). TEST seguirá respondiendo `"Environment": "DEV"` hasta que:

1. se fusione #1204 en `test`, y
2. Despliegue (@soymoroo) haga **Deploy** del backend de TEST (un Restart no recrea el contenedor con el compose nuevo).

La re-prueba de TC-M07-378-G025 necesita sesión con permiso `exportacion_contable` (`GET /integracion/aaef/vista-previa/productores/{nit}`), así que queda en manos de Pruebas.

Implementación hace el seguimiento en INC-BE-09 y avisará aquí cuando el compose desplegado tenga `SGPMP_ENTORNO`, para coordinar la re-prueba.
