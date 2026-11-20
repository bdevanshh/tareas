# Development image for the TanStack Start frontend.
# The repository is bind-mounted by docker-compose, so Vite picks up edits.
FROM oven/bun:1.3.9 AS dev

WORKDIR /app

# Install workspace dependencies first so this layer is cached.
COPY package.json bun.lock turbo.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/zod/package.json ./packages/zod/
RUN bun install --frozen-lockfile

COPY . .

WORKDIR /app/apps/frontend

EXPOSE 3000

CMD ["bun", "--bun", "run", "dev"]
