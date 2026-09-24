COMPOSE := docker compose

.DEFAULT_GOAL := help

.PHONY: help up bootstrap down reset ps logs

help:
	@echo "  make bootstrap     Start + bootstrap org/user/sample API (runs up.sh)"
	@echo "  make up            Start the stack (Dashboard, Gateway, Pump, Portal)"
	@echo "  make down          Stop the stack"
	@echo "  make reset         Stop the stack and wipe volumes"
	@echo "  make ps            Show running containers"
	@echo "  make logs [SERVICE=tyk-ent-portal]   (default: all services)"

up:
	$(COMPOSE) up -d

bootstrap:
	./up.sh

down:
	$(COMPOSE) down

reset:
	$(COMPOSE) down -v

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f $(SERVICE)
