# CA-10 — Seguimiento de PROD (HU-IMP-CFG-04)

**Estado:** cumple (2026-11-21, 22:15, America/Bogota). El PR #941 se cerró sin fusionar (2026-11-21, 20:24 America/Bogota) y el release 1.4.0 entró a `main` por el [PR #1219](https://github.com/Arekkazu/sgpmp-backend/pull/1219) (`dev` → `main`, fusionado el 2026-11-21, 20:32 America/Bogota; 01:32 UTC del 22-11; merge `14ee0808`).

**Corte:** `git fetch` del 2026-11-21, 22:15 (America/Bogota) · BE `dev@5115b83d` · `test@c698c656` · `main@9655f389` · PR #1204 OPEN `097f6d80` · SGMP-Integracion `main@a910760`.

## Comando

```bash
for c in b2b9097b d417c0c6 5e87d61e 098f635a; do
  git -C sgpmp-backend merge-base --is-ancestor $c origin/main && echo "$c INCLUIDO" || echo "$c AUSENTE"
done
gh pr view 941 -R Arekkazu/sgpmp-backend --json state,closedAt,mergedAt
gh pr view 1219 -R Arekkazu/sgpmp-backend --json mergedAt,mergeCommit,headRefName
MSYS_NO_PATHCONV=1 git -C sgpmp-backend show origin/main:docker-compose.prod.yml | grep -n 'SGPMP_ENTORNO:'
```

## Resultado

| Commit | `main` (PROD) |
|---|---|
| `b2b9097b` | INCLUIDO |
| `d417c0c6` | INCLUIDO |
| `5e87d61e` | INCLUIDO |
| `098f635a` | INCLUIDO |

- PR #941: `CLOSED`, `mergedAt: null`, `closedAt: 2026-11-22T01:24:37Z`.
- PR #1219: `mergedAt: 2026-11-22T01:32:10Z`, merge `14ee0808`, cabeza `dev`.
- `docker-compose.prod.yml` de `main`: `155:      SGPMP_ENTORNO: ${SGPMP_ENTORNO:-PROD}`.

## Corte anterior (2026-11-21, 17:55)

Los 4 commits estaban en `dev` y `test` y ausentes en `main@0abbeeef`; #941 abierto (`REVIEW_REQUIRED`); `main` sin `SGPMP_ENTORNO:`.

## Lectura

PROD recibe `SGPMP_ENTORNO` con valor por defecto `PROD` y el código que la lee. Sigue la ficha de PROD para Despliegue (ficha de TEST, §5). En el mismo release llegó `e2ec9ed5` (respaldo de auditoría IoT con volumen persistente en PROD): anotado en HU-IMP-AMB-10 e INC-BE-02, pendiente de `/impacto`.
