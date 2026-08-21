#!/usr/bin/env bash
set -euo pipefail

# HU-04: restaura la fuente externa DBIntegrador sin modificar ese repositorio.
# Ejecutar desde la raíz de SGMP-Integracion:
#   DBA_PASSWORD='valor-local' ./scripts/restaurar-bd.sh
# Opciones: --keep (por defecto), --reset, --help.

# Evita que Git Bash convierta rutas internas de contenedor como /scripts/roles.sql.
export MSYS_NO_PATHCONV=1

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DBA="${REPO_DBA:-$ROOT_DIR/../DBIntegrador-master}"
DUMP_NAME="${DUMP_NAME:-backup7_1_0.dump}"
DUMP="$REPO_DBA/$DUMP_NAME"
SCRATCH="${SCRATCH:-$ROOT_DIR/.sgpmp-local/dbintegrador}"
COMPOSE_FILE="$SCRATCH/docker-compose.hu04.yml"
CONTAINER="${CONTAINER:-SGP}"
DB_NAME="${DB_NAME:-dba}"
DB_USER="${DB_USER:-dba}"
DB_PORT="${DB_PORT:-5433}"
VOLUME="${VOLUME:-sgmp_hu04_pgdata}"
RESET=0

for arg in "$@"; do
  case "$arg" in
    --keep) RESET=0 ;;
    --reset) RESET=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "ERROR: argumento no reconocido: $arg" >&2; exit 2 ;;
  esac
done

require_file() {
  [ -f "$1" ] || { echo "ERROR: no existe $1" >&2; exit 1; }
}

command -v docker >/dev/null 2>&1 || { echo "ERROR: Docker no está disponible." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "ERROR: Docker Desktop no está corriendo." >&2; exit 1; }
require_file "$REPO_DBA/docker-compose.yml"
require_file "$DUMP"
require_file "$REPO_DBA/backup_roles.sql"
[ -n "${DBA_PASSWORD:-}" ] || {
  echo "ERROR: define DBA_PASSWORD con una contraseña local antes de continuar." >&2
  exit 1
}
command -v iconv >/dev/null 2>&1 || { echo "ERROR: iconv no está disponible para normalizar backup_roles.sql." >&2; exit 1; }

mkdir -p "$SCRATCH"
cp "$DUMP" "$SCRATCH/$DUMP_NAME"
ROLE_BOM="$(head -c 2 "$REPO_DBA/backup_roles.sql" | od -An -tx1 | tr -d ' \r\n')"
if [ "$ROLE_BOM" = "fffe" ]; then
  iconv -f UTF-16LE -t UTF-8 "$REPO_DBA/backup_roles.sql" > "$SCRATCH/roles.sql"
else
  sed 's/\r$//' "$REPO_DBA/backup_roles.sql" > "$SCRATCH/roles.sql"
fi

if [ -f "$REPO_DBA/Dockerfile" ]; then
  cp "$REPO_DBA/Dockerfile" "$SCRATCH/Dockerfile"
else
  require_file "$REPO_DBA/dockerfile"
  cp "$REPO_DBA/dockerfile" "$SCRATCH/Dockerfile"
fi

cat > "$SCRATCH/.env" <<EOF
DBA_PASSWORD=$DBA_PASSWORD
EOF

cat > "$COMPOSE_FILE" <<EOF
services:
  postgres:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: $CONTAINER
    environment:
      POSTGRES_USER: $DB_USER
      POSTGRES_PASSWORD: \${DBA_PASSWORD}
    ports:
      - "$DB_PORT:5432"
    volumes:
      - $VOLUME:/var/lib/postgresql
      - ./$DUMP_NAME:/backup/$DUMP_NAME:ro
      - ./roles.sql:/scripts/roles.sql:ro
    command: >
      -c shared_preload_libraries=pg_cron
      -c cron.database_name=$DB_NAME
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $DB_USER -d $DB_NAME"]
      interval: 5s
      timeout: 5s
      retries: 20
volumes:
  $VOLUME:
EOF

cd "$SCRATCH"
COMPOSE=(docker compose -f docker-compose.hu04.yml --env-file .env)

if [ "$RESET" -eq 1 ]; then
  echo ">> Reset explícito del volumen HU-04: $VOLUME"
  "${COMPOSE[@]}" down -v
else
  echo ">> Modo seguro: se conserva el volumen existente. Use --reset para reconstruirlo."
fi

echo ">> Levantando PostgreSQL 18 desde la copia temporal de DBIntegrador..."
"${COMPOSE[@]}" up -d --build

echo ">> Esperando PostgreSQL..."
for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then break; fi
  sleep 2
done
docker exec "$CONTAINER" pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1 || {
  echo "ERROR: PostgreSQL no quedó disponible. Revise: docker logs $CONTAINER" >&2
  exit 1
}

echo ">> Aplicando roles de backup_roles.sql..."
docker exec "$CONTAINER" psql -v ON_ERROR_STOP=0 -U "$DB_USER" -d "$DB_NAME" -f /scripts/roles.sql

echo ">> Habilitando pg_cron..."
docker exec "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS pg_cron;"

echo ">> Restaurando $DUMP_NAME..."
docker exec "$CONTAINER" pg_restore -U "$DB_USER" -d "$DB_NAME" --no-owner --no-privileges --role="$DB_USER" "/backup/$DUMP_NAME"

echo ">> Validando schemas, tablas, roles y pg_cron..."
docker exec "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('modulo1','modulo2','modulo3','modulo4','modulo5','modulo6','modulo7','modulo8','modulo9') ORDER BY schema_name;"
docker exec "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -c "SELECT table_schema, count(*) AS tablas FROM information_schema.tables WHERE table_type='BASE TABLE' AND table_schema IN ('auditoria','modulo1','modulo2','modulo3','modulo4','modulo5','modulo6','modulo7','modulo8','modulo9') GROUP BY table_schema ORDER BY table_schema;"
docker exec "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -c "SELECT rolname FROM pg_roles WHERE rolname IN ('dba','member_impl','member_iot','member_qa','member_dev','member_deploy') ORDER BY rolname;"
docker exec "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -c "SELECT extname FROM pg_extension WHERE extname='pg_cron';"
ROLE_COUNT="$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT count(*) FROM pg_roles WHERE rolname IN ('dba','member_impl','member_iot','member_qa','member_dev','member_deploy');" | tr -d '[:space:]')"
[ "${ROLE_COUNT:-0}" -ge 6 ] || { echo "ERROR: faltan roles esperados (encontrados: ${ROLE_COUNT:-0})." >&2; exit 1; }
CRON_COUNT="$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT count(*) FROM pg_extension WHERE extname='pg_cron';" | tr -d '[:space:]')"
[ "${CRON_COUNT:-0}" -eq 1 ] || { echo "ERROR: pg_cron no quedó habilitado." >&2; exit 1; }

echo "OK: restauración HU-04 completada."
echo "Contenedor: $CONTAINER | Base: $DB_NAME | Usuario: $DB_USER | Puerto: $DB_PORT"
echo "Para apagar conservando datos: ${COMPOSE[*]} down"
