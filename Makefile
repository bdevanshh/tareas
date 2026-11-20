.PHONY: dev up down logs reset migrate db-shell build test

dev:
	docker compose up --build

up:
	docker compose up --build -d

down:
	docker compose down

logs:
	docker compose logs -f

reset:
	docker compose down -v

migrate:
	docker compose run --rm migrate

db-shell:
	docker compose exec postgres psql -U postgres -d tareas

build:
	docker compose build

test:
	cd apps/backend && go test ./...
