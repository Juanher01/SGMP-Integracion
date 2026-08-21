# ---------- Etapa 1: build de dependencias ----------
FROM python:3.12-slim AS builder

WORKDIR /app

# Herramientas de compilación (por si algún paquete no trae wheel para esta plataforma)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiamos primero requirements + el wheel vendorizado del audit_sdk
# (requirements.txt lo referencia con ruta relativa: file:vendor/audit_sdk-...whl)
# para aprovechar el cache de capas cuando solo cambia el código de la app.
COPY requirements.txt .
COPY vendor/ vendor/

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ---------- Etapa 2: imagen de ejecución ----------
FROM python:3.12-slim

WORKDIR /app

# Usuario no-root
RUN groupadd -r app && useradd -r -g app app

# Traemos el venv ya armado (sin build-essential: imagen final más liviana)
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Código de la aplicación (respeta .dockerignore: no arrastra .venv/.env/.git locales)
COPY . .
RUN chown -R app:app /app
USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# uvicorn directo (no "python main.py") para poder controlar --reload en dev
# o --workers en prod desde el docker-compose de cada entorno, sin tocar esta imagen.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
