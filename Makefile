# GUI-Kiosk Heroku-style launcher
.DEFAULT_GOAL := run

APP ?= blender
OFFLINE ?= true

.PHONY: init build up down logs vendor run clean help

init: ## Ensure 'web' network exists
	@docker network inspect web >/dev/null 2>&1 || \
	(docker network create --driver bridge web && echo "[make] Created 'web' network")

build: ## Build container image with selected app
	docker compose build --build-arg APP=$(APP)

up: ## Start container stack
	docker compose up -d

down: ## Stop container stack
	docker compose down

logs: ## Follow container logs
	docker compose logs -f

vendor: ## Ensure vendor files are present and valid
	@python3 vendor-helper.py

run: clean init vendor build up logs ## Clean and run fresh

clean: ## Remove containers, volumes, and vendor cache
	docker compose down -v --remove-orphans
	@echo "[make] Removing vendor cache..."
	@rm -rf vendor/* || true

help: ## Show available make targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' Makefile | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
