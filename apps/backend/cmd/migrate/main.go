package main

import (
	"context"

	"github.com/DevanshBhavsar3/tareas/internal/config"
	"github.com/DevanshBhavsar3/tareas/internal/database"
	"github.com/DevanshBhavsar3/tareas/internal/logger"
)

// cmd/migrate applies all pending database migrations using the same
// configuration as the API server. It is used by docker-compose before the
// backend and cron services start, and can also be run directly with:
//
//	go run ./cmd/migrate
func main() {
	cfg := config.Load()

	loggerService := logger.NewLoggerService(cfg.Observability)
	defer loggerService.Shutdown()

	log := logger.New(cfg.Observability, loggerService)

	if err := database.Migrate(context.Background(), &log, cfg); err != nil {
		log.Fatal().Err(err).Msg("failed to migrate database")
	}
}
