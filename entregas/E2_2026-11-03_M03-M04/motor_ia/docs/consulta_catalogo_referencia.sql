-- Consulta de referencia para armar catalogo.json del motor M04 en un ambiente.
-- Estado: vigente · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro
--
-- La ejecuta quien tenga acceso de lectura a la BD de ese ambiente (DEV, TEST o PROD), nunca
-- Implementación. Esquema verificado en sgpmp-backend origin/dev (4f0d54cd):
--   alembic/baseline/esquema_baseline.sql (CREATE TABLE modulo4.versiones_modelos) y las
--   migraciones cf12e716a4ec (componente, enum tipo_modelo de 6 valores) y c41f8e2d7a96.
--
-- Límites de hoy (no inventar lo que no existe):
--   * versiones_modelos NO tiene columna de animal: el id_activo_biologico de cada entrada del
--     catálogo se asigna a mano a partir del id_animal de los metadatos de ET-02 hasta RFC-010.
--   * El estado SOMBRA NO existe (enum_estado_version_modelo: EN_VALIDACION, APROBADO, ACTIVO,
--     DEPRECADO, RECHAZADO). Cuando B3 / RFC-010 lo cree, agregarlo al filtro de estado.
--   * Hoy solo puede haber una versión ACTIVO por (tipo_modelo, componente)
--     (uq_version_modelo_activa_tipo_componente): no caben versiones por animal hasta RFC-010.
--   * PENDIENTE DE CONFIRMACIÓN con Desarrollo: qué tipo_modelo usa el modelo individual ET-02.
--     Se filtran los dos tipos individuales asignables a especies (no poblacionales ni contagio).

SELECT
    vm.id_version_modelo,          -- → "id_version_modelo" del catálogo
    vm.nombre_version,             -- varchar(40): la de ET-02 tiene 46 caracteres (migración DBA pendiente)
    vm.tipo_modelo,
    vm.componente,
    vm.estado_version,
    vm.formato_artefacto,
    vm.ruta_artefacto,             -- de dónde copiar el .onnx al volumen
    vm.hash_artefacto_sha256,      -- debe coincidir con hash_artefacto_modelo de los metadatos
    vm.fecha_despliegue
FROM modulo4.versiones_modelos AS vm
WHERE vm.estado_version = 'ACTIVO'          -- + 'SOMBRA' cuando exista (RFC-010)
  AND vm.formato_artefacto = 'ONNX'         -- el motor solo carga ONNX
  AND vm.tipo_modelo IN ('MODELO_ESPECIES_MEDIANAS', 'MODELO_ESPECIES_GRANDES')
ORDER BY vm.tipo_modelo, vm.id_version_modelo;
