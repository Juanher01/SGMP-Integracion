# Borrador — promoción de la imagen del motor M04 a TEST y PROD

> Estado: borrador (no abrir aún) · Actualizado: 2026-10-31 · Responsable: Sebastián Sandoval Chavarro

Estado verificado (`git fetch` + `git merge-base --is-ancestor 976ec7c origin/<rama>`):

| Rama del broker | Punta | Código del motor (#49–#51) | Archivos de la imagen (PR #54) |
|---|---|---|---|
| `develop` | `ace799f` | Sí | Pendiente del merge de #54 |
| `test` | `dc4daf7` | Sí (PR #53) | No |
| `main` | `cebd430` | **No** | No |

## TEST

Cuando #54 esté en `develop`, la promoción va en el PR habitual `develop → test` del equipo AIoT
(como #53). No hace falta un PR dirigido: `test` ya tiene el código del motor. Si AIoT no hace pronto
ese PR, la alternativa es un cherry-pick de los commits de #54 sobre `test`, aprobado por AIoT.

Verificación después del merge:

```bash
git -C BROKER-MQTT-SGPMP fetch
git -C BROKER-MQTT-SGPMP merge-base --is-ancestor 789eb7b origin/test && echo INCLUIDO
```

Y en el servidor: `https://api.inmero.co/motor-ia-test/v1/healthz` → 200.

## PROD

**No abrir** hasta que Desarrollo lleve #49–#51 a `main`. Sin ese código la imagen no tiene `motor_ia`,
y el build falla en `COPY motor_ia`. Cuando ocurra, la promoción va con el release `develop → main`.

## Backend

El PR `fix/imp-m04-variables-motor-ia` sigue el mismo camino en el backend (`dev → test → main`).
Debe estar en la rama de cada ambiente antes de cargar `IOT_INFERENCIA_M04_URL` allí.
