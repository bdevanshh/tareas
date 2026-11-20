# Tareas

Tareas is a task management app: create tasks, group them into categories, set
priorities and due dates, comment on them, and attach files.

- **Live site**: https://tareas.devansh.engineer
- **Stack**: TanStack Start, React 19, TypeScript, Tailwind CSS, Shadcn UI,
  Go (Echo), PostgreSQL, Redis, S3-compatible object storage

## Quick start

Prerequisites: **Docker** with the Compose plugin. Nothing else is required for
the default setup.

```bash
bun dev
# or
make dev
# or
docker compose up --build
```

The first run builds the Go and frontend images and can take a few minutes.
After that, source changes hot-reload automatically.

| Service            | URL                             |
| ------------------ | ------------------------------- |
| Frontend           | http://localhost:3000           |
| API                | http://localhost:3001/api/v1    |
| API health         | http://localhost:3001/status    |
| API docs           | http://localhost:3001/docs      |
| Cron HTTP server   | http://localhost:8080/cron      |
| S3 API (SeaweedFS) | http://localhost:8333           |
| S3 file browser    | http://localhost:8888           |
| SeaweedFS master   | http://localhost:9333           |

Stop the stack:

```bash
bun run dev:down   # docker compose down
```

Destroy all local data (database, Redis, attachments):

```bash
bun run dev:reset  # docker compose down -v
```

## What runs in the dev stack

`docker-compose.yaml` starts every part of the app, not just the infrastructure:

| Service     | Purpose                                                      |
| ----------- | ------------------------------------------------------------ |
| `postgres`  | PostgreSQL 16                                                |
| `redis`     | Redis 7, used by the API and the asynq job queue             |
| `seaweedfs` | Free S3-compatible storage; creates the attachments bucket   |
| `migrate`   | One-shot migration runner; API/cron wait for it to finish    |
| `backend`   | Go API on `:3001`, hot-reloaded with [air]                    |
| `cron`      | Cron/job HTTP server on `:8080`                              |
| `frontend`  | Vite dev server on `:3000`, hot-reloaded                     |

LocalStack is no longer used. SeaweedFS provides the S3 API and is free to run
locally. The backend talks to `http://seaweedfs:8333` inside the Docker network,
while presigned download URLs are signed for `http://localhost:8333` so your
browser can open them.

## Local development without Docker

Useful when you want to run Go or Vite directly on your machine.

Prerequisites: Go 1.25+, Bun 1.3.9+, and Docker (for PostgreSQL, Redis and
SeaweedFS).

```bash
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env
bun install
bun run dev:host
```

`dev:host` starts the infrastructure containers, waits for them to become
healthy, then runs the backend and frontend through Turborepo. The backend
applies migrations before starting.

## Configuration

Development defaults live in `docker-compose.yaml`, so no `.env` file is needed
for the Docker setup.

- **Backend env names use dots**, for example `TAREAS_SERVER.PORT`. This is
  intentional: `koanf` maps them to nested config keys. Do not rewrite them with
  underscores.
- **Clerk** is used for authentication. The compose default is a public Clerk
  test publishable key. Override it with a root `.env` file:
  ```bash
  VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_key
  ```
  The backend also needs a real `TAREAS_AUTH.SECRET_KEY` for authenticated API
  calls; the compose value is a dummy that only lets the app boot.
- **Resend** sends email from cron jobs. The compose value is a dummy; set
  `TAREAS_INTEGRATION.RESEND_API_KEY` to send real email.
- **S3 credentials** are `test` / `test` locally. The bucket
  `tareas-todo-attachments` is created automatically by SeaweedFS.

## Common commands

| Command                  | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `bun dev`                | Start the full stack in Docker                   |
| `bun run dev:host`       | Start infra in Docker, apps on the host          |
| `bun run dev:logs`       | Follow all container logs                        |
| `bun run dev:down`       | Stop containers                                  |
| `bun run dev:reset`      | Stop containers and delete all data              |
| `bun run db:migrate`     | Apply pending migrations                         |
| `bun run db:shell`       | Open `psql` in the PostgreSQL container          |
| `bun run build`          | Build all packages                               |
| `bun run lint`           | Lint all packages                                |
| `bun run check-types`    | Type-check all packages                          |

Backend tests use testcontainers and need a running Docker daemon:

```bash
cd apps/backend && go test ./...
```

Frontend tests:

```bash
bun --cwd apps/frontend test
```

## Troubleshooting

- **Port already in use**: stop the old stack with `bun run dev:down`, or change
  the published port in `docker-compose.yaml`.
- **Dependency changes are not picked up**: rebuild the images with
  `docker compose up --build`.
- **Database looks stale**: `bun run dev:reset` removes the named volumes and
  starts from scratch.
- **Sign-in does not work**: replace the dummy Clerk keys as described above.
- **Attachments fail to upload**: check the SeaweedFS container is healthy and
  the bucket exists at http://localhost:8888.
- **`bun run lint` fails with `eslint: command not found`**: this is
  pre-existing. `eslint` is not declared in `apps/frontend/package.json`, so run
  `bun add -d eslint` inside `apps/frontend` to fix it (this updates
  `bun.lock`).

More agent-oriented notes live in [AGENTS.MD](./AGENTS.MD).
