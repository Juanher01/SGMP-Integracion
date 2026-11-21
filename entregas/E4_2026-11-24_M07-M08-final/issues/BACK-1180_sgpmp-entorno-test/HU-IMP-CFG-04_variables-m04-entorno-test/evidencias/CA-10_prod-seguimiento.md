# CA-10 — Seguimiento de PROD (HU-IMP-CFG-04)

**Estado:** seguimiento. El release #941 sigue abierto; repetir esta tabla cuando se fusione.

**Corte:** `git fetch` del 2026-11-21, 17:55 (America/Bogota) · BE `dev@8d4981f6` · `test@cd5f36de` · `main@0abbeeef` (2026-10-13) · PR #1204 OPEN `097f6d80` · SGMP-Integracion `main@a910760`.

## Comando

```bash
for c in b2b9097b d417c0c6 5e87d61e 098f635a; do
  for b in dev test main; do
    git -C sgpmp-backend merge-base --is-ancestor $c origin/$b && echo "$c $b INCLUIDO" || echo "$c $b AUSENTE"
  done
done
gh pr view 941 -R Arekkazu/sgpmp-backend --json state,baseRefName,headRefOid,reviewDecision
MSYS_NO_PATHCONV=1 git -C sgpmp-backend show origin/main:docker-compose.prod.yml | grep -n 'SGPMP_ENTORNO:'
```

## Resultado

| Commit | `dev` | `test` | `main` (PROD) |
|---|---|---|---|
| `b2b9097b` | INCLUIDO | INCLUIDO | AUSENTE |
| `d417c0c6` | INCLUIDO | INCLUIDO | AUSENTE |
| `5e87d61e` | INCLUIDO | INCLUIDO | AUSENTE |
| `098f635a` | INCLUIDO | INCLUIDO | AUSENTE |

- PR #941 (`dev` → `main`): **OPEN**, cabeza `8d4981f6` (= `origin/dev`), `reviewDecision: REVIEW_REQUIRED`.
- `docker-compose.prod.yml` de `main`: sin `SGPMP_ENTORNO:` (el `grep` no devuelve nada).

## Lectura

PROD sigue sin `SGPMP_ENTORNO` y sin el código que la lee, así que hoy no tiene efecto. Todo llega con el release #941. Cuando se fusione, se espera: 4 × `INCLUIDO` en `main` y `SGPMP_ENTORNO: ${SGPMP_ENTORNO:-PROD}` en `docker-compose.prod.yml`. Después, ficha de PROD para Despliegue (ficha de TEST, §5).
