# God's Eye View — container for a private Railway deployment.
# Builds the app once, then serves it (including the /api provider routes)
# with `vite preview`. Not hardened for the public internet: keep the service
# private (no public domain) and reach it over a tailnet. See SECURITY.md.
FROM node:24-slim

WORKDIR /app
RUN chown node:node /app
USER node

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY --chown=node:node . .

# Browser-side keys are compiled into the client bundle at build time. They are
# public by design, so restrict them at the provider (referrer / URL rules).
# On Railway, Dockerfile builds only see variables declared with ARG.
# All three are optional; the app runs keyless on Esri + OSM.
ARG GOOGLE_MAPS_API_KEY
ARG CESIUM_ION_TOKEN
ARG MAPILLARY_CLIENT_TOKEN
RUN npm run build

# Server-side provider keys (OPENAI_API_KEY, GOOGLE_MAPS_SERVER_API_KEY,
# AISSTREAM_API_KEY, ...) are read from the runtime environment.
ENV PORT=4173
EXPOSE 4173
CMD ["sh", "-c", "exec node_modules/.bin/vite preview --host 0.0.0.0 --port ${PORT:-4173}"]
