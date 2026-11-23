# CA-12 — Dockerfile en `test` (HU-IMP-CFG-04, ST-04c)

Fecha: 2026-11-23. Solo lectura, desde `PI4` en Git Bash (`export MSYS_NO_PATHCONV=1; B=sgpmp-backend`), después de `git -C sgpmp-backend fetch --prune origin`.
Corte: BE `origin/dev 77e0d772` · `origin/test 1ee56516` · `origin/main e3b07ae6` · PR #1204 `097f6d80` (OPEN) · PR #1220 `184112a1` (OPEN).

Comandos de CA-12 del bloque «Comandos de la ampliación de ST-04c» de la HU, con su salida:

```bash
$ git -C $B merge-base --is-ancestor 885f39de origin/test && echo PROMOVIDO
PROMOVIDO
$ git -C $B log --oneline --grep='cherry picked from commit 885f39de' origin/test
(sin salida: no hubo cherry-pick; llegó por la promoción)
$ git -C $B cherry -v origin/test 885f39de 885f39de^
(sin salida: el commit ya es ancestro de test)
$ git -C $B show origin/test:Dockerfile | grep -n 'mkdir -p /app/storage/auditoria_iot /app/storage/modelos'
60:    && mkdir -p /app/storage/auditoria_iot /app/storage/modelos \
$ git -C $B log --format='%h %ad %s' --date=iso -3 origin/test -- Dockerfile docker-compose.test.yml
51f0bbf6 2026-11-22 20:49:44 -0500 Merge dev into test
885f39de 2026-11-22 09:02:30 -0500 fix(rf69-mod4): crear el almacenamiento de modelos del usuario 1000 en la imagen
9a52ad5c 2026-11-14 00:01:26 -0500 chore(docker): montar la clave publica del SSO de AgroFusion en el backend de TEST
```

Comprobaciones adicionales:

```bash
$ git -C $B log --format="%h %ad %an %s" --date=iso -1 51f0bbf6
51f0bbf6 2026-11-22 20:49:44 -0500 HulkyZeus Merge dev into test
$ git -C $B diff 885f39de origin/test -- Dockerfile
(sin salida: el Dockerfile de test es el de 885f39de)
$ git -C $B show origin/test:Dockerfile | sed -n "59,61p;66,67p"
RUN useradd --create-home --uid 1000 appuser \
    && mkdir -p /app/storage/auditoria_iot /app/storage/modelos \
    && chown 1000:1000 /app/storage/auditoria_iot /app/storage/modelos
ENV IOT_AUDITORIA_RESPALDO_PATH=/app/storage/auditoria_iot/fallas.sqlite3
USER 1000
```

**Veredicto (2026-11-23): CA-12 cumple.** El Dockerfile de `origin/test@1ee56516` crea `/app/storage/auditoria_iot` y `/app/storage/modelos` con dueño 1000 en el mismo `RUN` (l. 59-61), con el contenido de `885f39de` (PR #1224). Llegó por la promoción `dev`→`test` (merge `51f0bbf6`, 2026-11-22), la vía alternativa que prevé el CA, no por el cherry-pick de ST-04c. La condición de orden también se cumple: el compose de TEST todavía no monta volúmenes (`docker-compose.test.yml@1ee56516`, solo `sgpmp_pgdata_test`), así que el Dockerfile llega antes que los volúmenes de CA-3.
