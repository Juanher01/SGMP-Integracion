#!/usr/bin/env bash
#
# restaurar-bd.sh — Levanta el contenedor de BD del DBA y restaura el dump del SGPMP,
# sorteando por nuestro lado los problemas detectados en el spike SIN tocar el repo del DBA:
#   - CRLF en los scripts de init  -> se normaliza en una copia LF fuera del repo.
#   - .env versionado con claves    -> se usa un .env de prueba propio (--env-file).
#   - pg_cron en bucle tras restore -> se reasigna el job a la base/rol locales.
#
# Uso:
#   ./restaurar-bd.sh                 # recrea la BD desde cero y restaura el dump
#   ./restaurar-bd.sh --clean-public  # además elimina las tablas ajenas del esquema public
#   ./restaurar-bd.sh --keep          # no descarta el volumen (no recomendado si ya hay datos)
#
# Requisitos: Docker Desktop corriendo, y el repo del DBA (docuemntacionDB) clonado con el dump.
# Córrelo desde Git Bash / el mismo shell que usa Claude Code.

set -euo pipefail

# ===================== Configuración (ajusta si tus rutas difieren) =====================
REPO_DBA="${REPO_DBA:-./docuemntacionDB}"          # ruta al repo del DBA
DUMP="${DUMP:-$REPO_DBA/backup7_0_0.dump}"          # ruta al dump
SCRATCH="${SCRATCH:-./.sgpmp-local}"                # carpeta de trabajo (fuera del repo del DBA)
CONTAINER="SGPMP"                                   # nombre fijo del contenedor (lo define su compose)
DBUSER="dba"
DBNAME="dba"
TEST_PASS="dev123"                                  # contraseña de prueba para roles locales
# =======================================================================================

RESET=1
CLEAN_PUBLIC=0
for arg in "$@"; do
  case "$arg" in
    --keep) RESET=0 ;;
    --clean-public) CLEAN_PUBLIC=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Argumento no reconocido: $arg" >&2; exit 2 ;;
  esac
done

# --- Comprobaciones previas ---
command -v docker >/dev/null 2>&1 || { echo "ERROR: Docker no está en el PATH."; exit 1; }
docker info >/dev/null 2>&1 || { echo "ERROR: Docker Desktop no está corriendo. Ábrelo y reintenta."; exit 1; }
[ -f "$REPO_DBA/DOCKER/docker-compose.yml" ] || { echo "ERROR: no encuentro $REPO_DBA/DOCKER/docker-compose.yml"; exit 1; }
[ -f "$DUMP" ] || { echo "ERROR: no encuentro el dump en $DUMP"; exit 1; }

mkdir -p "$SCRATCH"
SCRATCH="$(cd "$SCRATCH" && pwd)"   # ruta absoluta

echo ">> Preparando copia de trabajo con finales de línea LF (sin tocar el repo del DBA)..."
rm -rf "$SCRATCH/DOCKER"
cp -r "$REPO_DBA/DOCKER" "$SCRATCH/DOCKER"
rm -f "$SCRATCH/DOCKER/.env"        # no usamos las contraseñas reales versionadas
# normalizar CRLF -> LF en los scripts de init
find "$SCRATCH/DOCKER/sql" -type f \( -name '*.sh' -o -name '*.sql' -o -name '*.template' \) | while IFS= read -r f; do
  sed 's/\r$//' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
chmod +x "$SCRATCH/DOCKER/sql/"*.sh 2>/dev/null || true

echo ">> Generando .env de prueba (fuera del repo del DBA)..."
cat > "$SCRATCH/dba-test.env" <<EOF
DBA_PASSWORD=$TEST_PASS
BACKEND_DEV_PASSWORD=$TEST_PASS
QA_PASSWORD=$TEST_PASS
DEVOPS_DEV_PASSWORD=$TEST_PASS
DEVOPS_STAGING_PASSWORD=$TEST_PASS
DEVOPS_PROD_PASSWORD=$TEST_PASS
IOT_PASSWORD=$TEST_PASS
EOF

COMPOSE=(docker compose -f "$SCRATCH/DOCKER/docker-compose.yml" --env-file "$SCRATCH/dba-test.env")

if [ "$RESET" -eq 1 ]; then
  echo ">> Recreando la BD desde cero (se descarta el volumen local; solo contiene datos del dump)..."
  "${COMPOSE[@]}" down -v >/dev/null 2>&1 || true
fi

echo ">> Levantando el contenedor del DBA (build + pg_cron + roles)..."
"${COMPOSE[@]}" up -d --build

echo ">> Esperando a que PostgreSQL acepte conexiones..."
ready=0
for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -U "$DBUSER" -d "$DBNAME" >/dev/null 2>&1; then ready=1; break; fi
  sleep 2
done
[ "$ready" -eq 1 ] || { echo "ERROR: el contenedor no quedó listo. Revisa: docker logs $CONTAINER"; exit 1; }

echo ">> Restaurando el dump (por STDIN, evita el mangling de rutas de Git Bash en Windows)..."
set +e
docker exec -i "$CONTAINER" pg_restore -U "$DBUSER" -d "$DBNAME" --no-owner --no-privileges < "$DUMP"
RC=$?
set -e
echo ">> pg_restore terminó con código: $RC (0 = limpio; distinto de 0 puede ser solo avisos)"

echo ">> Parcheando pg_cron para evitar el bucle de reinicio (reasigna el job a la base/rol locales)..."
docker exec -i "$CONTAINER" psql -U "$DBUSER" -d "$DBNAME" -v ON_ERROR_STOP=1 <<'SQL'
DO $do$
BEGIN
  IF EXISTS (SELECT FROM pg_extension WHERE extname = 'pg_cron') THEN
    UPDATE cron.job SET username = 'dba', database = 'dba';
    TRUNCATE cron.job_run_details;
  END IF;
END
$do$;
SQL

if [ "$CLEAN_PUBLIC" -eq 1 ]; then
  echo ">> Eliminando tablas ajenas del esquema public (otro proyecto)..."
  docker exec -i "$CONTAINER" psql -U "$DBUSER" -d "$DBNAME" <<'SQL'
DO $do$
DECLARE r record;
BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('DROP TABLE IF EXISTS public.%I CASCADE', r.tablename);
  END LOOP;
END
$do$;
SQL
fi

echo ""
echo "==================== VERIFICACIÓN ===================="
echo "-- Esquemas --"
docker exec "$CONTAINER" psql -U "$DBUSER" -d "$DBNAME" -c "\dn"
echo "-- Tablas base y vistas por esquema objetivo --"
docker exec "$CONTAINER" psql -U "$DBUSER" -d "$DBNAME" -c \
"SELECT table_schema, \
        count(*) FILTER (WHERE table_type = 'BASE TABLE') AS tablas, \
        count(*) FILTER (WHERE table_type = 'VIEW')       AS vistas \
 FROM information_schema.tables \
 WHERE table_schema IN ('auditoria','modulo1','modulo2','modulo3','modulo4','modulo5','modulo6','modulo7','modulo8','modulo9') \
 GROUP BY table_schema ORDER BY table_schema;"

# Guarda: confirmar que la restauración cargó tablas de negocio (evita reportar 'LISTO' sobre una base vacía)
N_TABLAS=$(docker exec "$CONTAINER" psql -U "$DBUSER" -d "$DBNAME" -tAc \
"SELECT count(*) FROM information_schema.tables \
 WHERE table_type = 'BASE TABLE' \
 AND table_schema IN ('auditoria','modulo1','modulo2','modulo3','modulo4','modulo5','modulo6','modulo7','modulo8','modulo9');" | tr -d '[:space:]')
if [ "${N_TABLAS:-0}" -lt 1 ]; then
  echo "ERROR: la restauración no cargó tablas en los esquemas de negocio (obtenido: ${N_TABLAS:-0}). Revisa la salida de pg_restore arriba."
  exit 1
fi

echo ""
echo "==================== LISTO ($N_TABLAS tablas base restauradas) ===================="
echo "Base de datos poblada y corriendo en el contenedor '$CONTAINER'."
echo "Conexión desde tu máquina (puerto publicado 5433):"
echo "  Admin:   postgresql://dba:$TEST_PASS@localhost:5433/dba"
echo "  Backend: postgresql://backend_dev:$TEST_PASS@localhost:5433/dba"
echo ""
echo "Para apagar cuando termines:  docker compose -f \"$SCRATCH/DOCKER/docker-compose.yml\" --env-file \"$SCRATCH/dba-test.env\" down"
