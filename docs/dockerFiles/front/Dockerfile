# ---------- Etapa base: instala dependencias con pnpm ----------
FROM node:20-slim AS base
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

# ---------- Etapa "dev": servidor de Vite con hot-reload ----------
# Se usa en el entorno dev (docker build --target dev). El código real se monta
# como volumen desde el compose de dev, así que el COPY de aquí solo cubre el
# caso de construir la imagen sin volumen.
FROM base AS dev
COPY . .
EXPOSE 5173
# --host 0.0.0.0 es obligatorio: Vite por defecto solo escucha en localhost,
# lo que lo dejaría inalcanzable desde fuera del contenedor.
CMD ["pnpm", "exec", "vite", "--host", "0.0.0.0"]

# ---------- Etapa "build": compila los assets estáticos ----------
# Las variables VITE_* quedan HORNEADAS en el JS compilado en este paso.
# A diferencia del backend, NO se pueden cambiar luego con variables de entorno
# en tiempo de ejecución: cada entorno (test/prod) necesita su propio build,
# con sus propios --build-arg, no una sola imagen reconfigurable.
FROM base AS build
ARG VITE_API_BASE_URL
ARG VITE_FIREBASE_API_KEY
ARG VITE_FIREBASE_AUTH_DOMAIN
ARG VITE_FIREBASE_PROJECT_ID
ARG VITE_FIREBASE_STORAGE_BUCKET
ARG VITE_FIREBASE_MESSAGING_SENDER_ID
ARG VITE_FIREBASE_APP_ID
ARG VITE_VAPID_KEY
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL \
    VITE_FIREBASE_API_KEY=$VITE_FIREBASE_API_KEY \
    VITE_FIREBASE_AUTH_DOMAIN=$VITE_FIREBASE_AUTH_DOMAIN \
    VITE_FIREBASE_PROJECT_ID=$VITE_FIREBASE_PROJECT_ID \
    VITE_FIREBASE_STORAGE_BUCKET=$VITE_FIREBASE_STORAGE_BUCKET \
    VITE_FIREBASE_MESSAGING_SENDER_ID=$VITE_FIREBASE_MESSAGING_SENDER_ID \
    VITE_FIREBASE_APP_ID=$VITE_FIREBASE_APP_ID \
    VITE_VAPID_KEY=$VITE_VAPID_KEY
COPY . .
RUN pnpm build

# ---------- Etapa "prod": sirve los estáticos con nginx ----------
# Se usa para test y para prod (mismo Dockerfile; lo que cambia son los
# --build-arg pasados en el "docker build" de cada entorno).
FROM nginx:1.27-alpine AS prod
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:80/ || exit 1
