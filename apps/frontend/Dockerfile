FROM oven/bun:1.3.9 AS dev

WORKDIR /app

COPY package.json bun.lock turbo.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/zod/package.json ./packages/zod/
RUN bun install --frozen-lockfile

COPY . .

WORKDIR /app/apps/frontend

EXPOSE 3000

CMD ["bun", "--bun", "run", "dev"]
