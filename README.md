# Tareas

Tareas is an open-source task management application. It lets you create tasks,
group them into custom categories, set priorities and due dates, comment on them,
attach files, and receive email reminders for upcoming due dates.

- **Live site**: https://tareas.devansh.engineer
- **Stack**: TanStack Start, React 19, TypeScript, Tailwind CSS, shadcn/ui,
  Go (Echo), PostgreSQL, Redis, S3 object storage

## Features

- Create, update, search, filter, sort, and paginate todos
- Statuses: draft, active, completed, archived
- Priorities: low, medium, high
- Due dates with overdue detection and due-soon email reminders
- Categories with name, color, and description
- Comments on todos
- File attachments via S3-compatible storage with presigned download URLs
- Per-user data isolation (Clerk authentication)
- Stats endpoints (todo counts by status, weekly activity)

## Architecture

Tareas is a monorepo with three workspaces: two apps and one shared package.

```
┌──────────────────────────────────────────────────────────────┐
│                        TanStack Start                        │
└──────────────┬───────────────────────────────┬───────────────┘
               │ HTTP (REST)                   │ S3 presigned URLs
               ▼                               ▼
┌──────────────────────────────┐     ┌──────────────────────────┐
│        Go API (Echo)         │     │  S3-Compatible Storage   │
└──────┬───────────────┬───────┘     └──────────────────────────┘
       │               │
       ▼               ▼
┌─────────────┐  ┌─────────────┐
│ PostgreSQL  │  │ Redis       │
└─────────────┘  └──────┬──────┘
                        │
                        ▼
                ┌───────────────┐
                │ Cron server   │
                └───────────────┘
```

Request flow: routes in `apps/frontend` call the REST API under
`/api/v1`. The Go backend validates payloads, runs business logic in
`service`, persists through `repository` (pgx), and enqueues background work
(email reminders) on Redis via asynq. The cron process (`cmd/cron`) runs
scheduled jobs that enqueue per-user reminder emails through Resend. Migrations
run once via the `migrate` service before the API and cron start.

## Repository layout

```
tareas/
├── apps/
│   ├── backend/          # Go API, cron, and migrate binaries
│   └── frontend/         # TanStack Start web app
├── packages/
│   └── zod/              # Shared Zod schemas and DTOs
├── docker-compose.yaml   # Full dev stack
├── turbo.json            # Turborepo task pipeline
└── package.json          # Root workspace + scripts
```

## Contributing

Contributions are welcome. Please follow these guidelines.

### Quick start

Prerequisites: **Docker** with the Compose plugin. Nothing else is required for
the default setup.

Create a copy of `.env.example`, which contains the configurations for all the apps.

```bash
cp .env.example .env
```

Paste your Clerk secrets for authentication:

```text
TAREAS_AUTH.SECRET_KEY=clerk_secret_key
VITE_CLERK_PUBLISHABLE_KEY=clerk_publishable_key
```

(Optional) Paste Resend API key for testing emails:

```
TAREAS_INTEGRATION.RESEND_API_KEY=resend_api_key
```

Start the dev environment using:

```bash
docker compose up --build
```

The first run builds the Go and frontend images and can take a few minutes.
All services are accessible from below URL's.

| Service          | URL                          |
| ---------------- | ---------------------------- |
| Frontend         | http://localhost:3000        |
| API              | http://localhost:3001/api/v1 |
| API docs         | http://localhost:3001/docs   |
| Cron HTTP server | http://localhost:8080/cron   |

Stop the dev environment using:

```bash
docker compose down
```

Destroy all local data (database, Redis, attachments) using:

```bash
docker compose down -v
```

### Branching and commits

- Create a feature branch from `main`: `git checkout -b feat/short-description`.
- Keep commits focused and use conventional-ish prefixes (`feat:`, `fix:`,
  `chore:`, `docs:`, `refactor:`).
- Do not commit generated files (`routeTree.gen.ts`, `.output`, `.tanstack`,
  `.nitro`, build caches) or secrets (`.env`).

### Adding a feature

- Backend: add model/DTO in `internal/model`, repository in `internal/repository`,
  service in `internal/service`, handler in `internal/handler`, and register
  routes in `internal/router/v1`.
- Frontend: add TanStack Query hooks in `src/api/hooks`, components, and routes.
- Database changes: create a migration by running `bun run migrations:new name=foo`
  in apps/backend and apply with `bun run db:migrate`.
