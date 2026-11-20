# Motor M04 — procedimiento para registrar versiones en RF-69 y armar el catálogo

> Estado: vigente · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

**No ejecutar hasta que RFC-010 esté aprobado y aplicado.** Hoy el registro está bloqueado:
la BD no admite una versión por animal ni el estado SOMBRA. Ver hallazgos H-08 y H-09 en
[F0-hallazgos.md](../evidencias/F0-hallazgos.md).

El registro en RF-69 lo hace RF-71 con su llave interna; Implementación no la maneja. Este
procedimiento ordena los pasos y deja el catálogo listo para el motor.

## Checklist por ambiente

```text
Checklist para cargar versiones SOMBRA en RF-69 y el catálogo del motor M04
[ ] RFC-010 aprobado por el Comité de cambios (versión por animal y estado SOMBRA).
[ ] Migración Alembic de nombre_version (varchar 40 → 60) aplicada por el DBA (la de ET-02 tiene 46).
[ ] Unicidad por animal resuelta: hoy el trigger (a9d4d253ac97) y el índice
    uq_version_modelo_activa_tipo_componente admiten una sola versión activa por
    (tipo_modelo, componente). Confirmar si es lo que el tablero llama DEV-01.
[ ] Especies del modelo individual creadas en el ambiente (hoy DEV solo tiene acuicultura).
[ ] Umbrales de RF-17 (FC y temperatura corporal) configurados y validados por especie.
[ ] B3 completado (RF-69 con llave por animal y estado SOMBRA).
[ ] Archivos .onnx, línea base y metadatos solicitados a Desarrollo; SHA-256 de cada .onnx
    igual a hash_artefacto_modelo de sus metadatos.
[ ] Registro ejecutado por quien tenga la llave interna de RF-71.
[ ] catalogo.json armado con consulta_catalogo_referencia.sql sobre la BD de ese ambiente
    (id_version_modelo de esa BD; id_activo_biologico del animal real) y copiado al volumen
    junto con los tres archivos de cada animal (dueño UID 1001).
[ ] MOTOR_IA_DIR_MODELOS=/data/modelos y BACKEND_URL cargadas en el motor; redespliegue.
[ ] Healthcheck del motor verificado: /v1/healthz → modelos_cargados > 0.
[ ] Solo después: IOT_INFERENCIA_M04_URL cargada en el backend (Despliegue).
Ambiente: [ ] DEV  [ ] TEST  [ ] PROD
Fecha:
Ejecutor:
```

Orden: DEV, después TEST, después PROD.

## Archivos de apoyo (esta carpeta)

| Archivo | Uso |
|---|---|
| `catalogo.template.json` | Forma de una entrada (la exige `motor_ia/individual.py`) |
| `catalogo.dev.json`, `catalogo.test.json`, `catalogo.prod.json` | `{"modelos": []}`: el motor arranca sin modelos y responde 503 a los paquetes. Se llenan con los IDs de cada BD |
| `catalogo.prueba.json` | Copia del fixture `tests/fixtures/et02_bov001/catalogo.json` (activo 885, versión 12). **Solo para pruebas locales**: esos IDs no existen en ninguna BD |
| `consulta_catalogo_referencia.sql` | Versiones ONNX activas de los tipos individuales, contra el esquema real |
