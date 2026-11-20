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

COPY apps/frontend/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /app/apps/frontend

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bun", "--bun", "run", "dev"]
