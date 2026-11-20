# Borrador — mensaje a Desarrollo sobre el motor M04

> Estado: borrador (no enviado) · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

---

Hola, equipo de Desarrollo:

Les escribimos desde Implementación sobre la imagen del motor M04 (PR #54 del broker).

1. **Tablero:** les pedimos marcar «Registrar en RF-69 las versiones y armar el catálogo» como
   **bloqueado por RFC-010**. La BD actual admite una sola versión activa por `(tipo_modelo, componente)`
   (migración `a9d4d253ac97` e índice `uq_version_modelo_activa_tipo_componente`), no tiene columna de
   animal ni estado SOMBRA, y `nombre_version` es `varchar(40)`. El procedimiento queda escrito y listo
   para cuando se apruebe la RFC.
   - Pregunta: ¿«DEV-01» del tablero se refiere a ese trigger de unicidad?
   - Pregunta: ¿qué `tipo_modelo` usará el modelo individual ET-02? Asumimos `MODELO_ESPECIES_MEDIANAS` / `MODELO_ESPECIES_GRANDES`.
2. **Path:** el plan del motor y el `.env.example` del backend usan `/model-ia[-test]`, pero en Dokploy
   y en el tablero el path es `/motor-ia[-test]`. Corregimos el `.env.example` en el PR
   Arekkazu/sgpmp-backend#909, que también pasa las cuatro `IOT_INFERENCIA_*` al contenedor (los compose
   no las incluían). ¿Pueden revisarlo y aprobarlo en `dev`, y actualizar el plan?
3. **Forma de la URL:** confirmamos en el código (`url_paquetes()`) que `IOT_INFERENCIA_M04_URL` acepta
   la URL base. La documentamos así, sin `/v1/paquetes`.
4. **Puerto:** la imagen arranca el motor en el puerto 8000, porque es al que apunta Dokploy. El docstring
   de `motor_ia/main.py` todavía dice 8100.
5. **Artefactos:** para los ambientes necesitamos los `.onnx`, la línea base y los metadatos de cada
   animal que entre al modelo, con su SHA-256. Para la prueba local usamos el fixture BOV-001 del repo.
6. **Informativo:** con `MOTOR_IA_DIR_MODELOS` definida y sin `catalogo.json`, el motor no arranca. No es
   un error, pero lo documentamos para Despliegue. Además, `pip install ".[motor-ia]"` instala también
   las dependencias del broker (aiomqtt, sqlalchemy, asyncpg): la imagen pesa 590 MB.

Gracias,
Sebastián Sandoval Chavarro — Implementación
