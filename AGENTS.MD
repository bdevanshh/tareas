# AGENTS.md

This file provides context for AI agents working with the Tareas codebase.

## Project Overview

**Tareas** is an open-source service for managing tasks. It allows users to create task, categorize them into custom categories, assign priorities & due dates and attach files to it.

- **Live Site**: https://tareas.devansh.engineer
- **Tech Stack**: Tanstack Start, React 19, TypeScript, Tailwind CSS, Shadcn UI, Golang, PostgreSQL, Redis, S3-compatible object storage
- **Package Manager**: bun (1.3.9)
- **Node Version**: 24 (Docker dev images use `oven/bun:1.3.9`)

## Project Structure

```
Tareas
├── apps
│   ├── backend
│   │   ├── cmd
│   │   │   ├── cron
│   │   │   ├── migrate
│   │   │   └── tareas
│   │   ├── internal
│   │   │   ├── config
│   │   │   ├── cron
│   │   │   ├── database
│   │   │   │   └── migrations
│   │   │   ├── errs
│   │   │   ├── handler
│   │   │   ├── lib
│   │   │   │   ├── aws
│   │   │   │   ├── email
│   │   │   │   ├── job
│   │   │   │   └── utils
│   │   │   ├── logger
│   │   │   ├── middleware
│   │   │   ├── model
│   │   │   │   ├── category
│   │   │   │   ├── comment
│   │   │   │   └── todo
│   │   │   ├── repository
│   │   │   ├── router
│   │   │   │   └── v1
│   │   │   ├── server
│   │   │   ├── service
│   │   │   ├── sqlerr
│   │   │   ├── testing
│   │   │   └── validator
│   │   ├── static
│   │   └── templates
│   │       └── emails
│   └── frontend
│       ├── public
│       └── src
│           ├── api
│           │   └── hooks
│           ├── components
│           │   ├── categories
│           │   ├── todos
│           │   └── ui
│           ├── integrations
│           │   ├── clerk
│           │   └── tanstack-query
│           ├── lib
│           └── routes
│               └── _authed
│                   ├── categories
│                   └── todos
└── packages
    └── zod
        └── src
            ├── category
            ├── comment
            └── todo
```

## Key Commands

```bash
bun dev                  # start the full stack with Docker (recommended)
bun dev:host             # infra in Docker + apps on the host with hot reload
bun dev:logs             # follow container logs
bun dev:down             # stop containers, keep data
bun dev:reset            # stop containers and delete local data volumes
bun db:migrate           # apply migrations in the migrate container
bun build                # production build
bun lint                 # run linter
bun format               # run code formatter
```

Backend-only commands (from `apps/backend`):

```bash
go run ./cmd/migrate     # apply pending migrations
go run ./cmd/tareas      # run the API on :3001
go run ./cmd/cron        # run the cron HTTP service on :8080
go test ./...            # tests (requires Docker for testcontainers)
```

## Local Environment (Docker)

`docker compose up --build` starts every service:

| Service | Address |
| --- | --- |
| Frontend | http://localhost:3000 |
| API | http://localhost:3001 |
| API health | http://localhost:3001/status |
| API docs | http://localhost:3001/docs |
| Cron | http://localhost:8080 |
| SeaweedFS S3 | http://localhost:8333 (`test` / `test`) |
| SeaweedFS filer UI | http://localhost:8888 |
| PostgreSQL | localhost:5432 (`postgres` / `secret`, db `tareas`) |
| Redis | localhost:6379 |

The `migrate` service is one-shot and must finish before `backend` and `cron`
start. The API and frontend containers bind-mount the source tree, so edits are
picked up by air and Vite without rebuilding. Rebuild after changing `go.mod`,
`package.json` or `bun.lock`.

### Environment quirks

- A single root `.env` file is the source of truth for both apps. The backend
  loads it via `godotenv` (`.env` then `../../.env`, so host dev from
  `apps/backend` still works); Vite reads it through `envDir` in
  `vite.config.ts`. Compose only overrides container-only values (DB host,
  Redis address, S3 endpoint).
- Backend env vars are prefixed with `TAREAS_` and use **dots** for nesting:
  `TAREAS_SERVER.PORT`, `TAREAS_DATABASE.HOST`, etc. Do not rewrite them
  with underscores.
- The backend refuses to start if required config values are empty. The root
  `.env.example` provides dummy Clerk/Resend values so the app boots without
  external accounts. Real sign-in and email need real keys (set them in `.env`).
- `TAREAS_PRIMARY.ENV=local` skips automatic migrations in the API binary, which
  is why migrations are a separate compose service. Do not remove that service.
- The frontend Vite server must listen on `0.0.0.0` inside Docker; this is set in
  `apps/frontend/vite.config.ts`. Do not remove `server.host`.
- `bun lint` currently fails because `eslint` is not declared in
  `apps/frontend/package.json` (pre-existing). Fix with
  `bun add -d eslint` in `apps/frontend`, which also updates `bun.lock`.

### Object storage

LocalStack has been removed. SeaweedFS provides S3 on port 8333 and creates the
`tareas-todo-attachments` bucket on startup. The backend uses two endpoints:

- `TAREAS_AWS.ENDPOINT_URL=http://seaweedfs:8333` for container-to-container
  requests.
- `TAREAS_AWS.PUBLIC_ENDPOINT_URL=http://localhost:8333` for presigned URLs
  opened by the browser.

When running the backend natively, set both to `http://localhost:8333`.

### Testing

- Backend: `cd apps/backend && go test ./...`. The tests use testcontainers, so
  Docker must be running and reachable from the test process.
- Frontend: `bun --cwd apps/frontend test` (Vitest).

### Generated files

- `apps/frontend/src/routeTree.gen.ts` is generated by TanStack Router. Do not
  edit it by hand.
- `apps/frontend/.output`, `.tanstack`, `.nitro` and `apps/backend/tmp` are build
  artifacts and should stay out of commits.

## Development Guidelines

### Code Style
- **Linter/Formatter**: Prettier
- **Import Aliases**: Use `#/` for imports (e.g. `#/components/...`). The codebase
  already uses `#/`; `@/` also resolves via `tsconfig.json` paths but prefer `#/`.
- **Styling**: Tailwind CSS with shadcn/ui components & Huge Icons
