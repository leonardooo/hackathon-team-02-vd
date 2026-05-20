# ── Stage 1: dependências ─────────────────────────────────────────────────────
FROM node:20-alpine AS deps

RUN corepack enable && corepack prepare pnpm@9 --activate

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# ── Stage 2: build ────────────────────────────────────────────────────────────
FROM node:20-alpine AS build

RUN corepack enable && corepack prepare pnpm@9 --activate

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# ── Stage 3: runtime ──────────────────────────────────────────────────────────
FROM node:20-alpine AS runtime

RUN corepack enable && corepack prepare pnpm@9 --activate

# Executa como usuário não-root (OWASP)
RUN addgroup -S sifap && adduser -S sifap -G sifap
USER sifap

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=build --chown=sifap:sifap /app/.next/standalone ./
COPY --from=build --chown=sifap:sifap /app/.next/static ./.next/static
COPY --from=build --chown=sifap:sifap /app/public ./public

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD wget --spider http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
