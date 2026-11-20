# Development image for the Go API, migration runner and cron server.
# Source is bind-mounted by docker compose, so rebuild only when go.mod changes.
FROM golang:1.25-alpine AS dev

RUN apk add --no-cache git curl

# Hot reload for local development.
RUN go install github.com/air-verse/air@v1.63.9

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Entrypoint lives outside /app so the bind mount does not shadow it.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV PATH="/go/bin:${PATH}"

EXPOSE 3001 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["air", "-c", ".air.toml"]
