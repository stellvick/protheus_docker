.PHONY: help build up down logs clean restart shell test certs dev prod

# Cores para output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

help: ## Exibir esta mensagem de ajuda
	@echo '${GREEN}Makefile${RESET}'
	@echo ''
	@echo 'Uso:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${YELLOW}%-15s${RESET} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

certs: ## Gerar certificados SSL/TLS
	@chmod +x generate-certs.sh
	@./generate-certs.sh

build: ## Build da imagem Docker
	@echo '${GREEN}Building Docker image...${RESET}'
	docker-compose build

up: ## Iniciar containers em background
	@echo '${GREEN}Starting containers...${RESET}'
	docker-compose up -d
	@echo '${GREEN}Containers iniciados!${RESET}'
	@docker-compose ps

down: ## Parar containers
	@echo '${YELLOW}Stopping containers...${RESET}'
	docker-compose down

restart: ## Reiniciar containers
	@echo '${YELLOW}Restarting containers...${RESET}'
	docker-compose restart
	@docker-compose ps

logs: ## Ver logs em tempo real
	docker-compose logs -f

logs-app: ## Ver logs apenas da aplicação
	docker-compose logs -f app

logs-nginx: ## Ver logs apenas do nginx
	docker-compose logs -f nginx-ssl

shell: ## Entrar no container da aplicação
	docker-compose exec app /bin/bash

clean: ## Remover containers e volumes
	@echo '${YELLOW}Cleaning up...${RESET}'
	docker-compose down -v
	@echo '${GREEN}Cleanup complete!${RESET}'

prune: ## Limpar sistema Docker
	docker system prune -f

ps: ## Status dos containers
	docker-compose ps

dev: ## Iniciar ambiente de desenvolvimento
	@echo '${GREEN}Starting development environment...${RESET}'
	docker-compose -f docker-compose.dev.yml up -d
	@docker-compose -f docker-compose.dev.yml ps

dev-down: ## Parar ambiente de desenvolvimento
	@echo '${YELLOW}Stopping development environment...${RESET}'
	docker-compose -f docker-compose.dev.yml down

dev-logs: ## Ver logs do desenvolvimento
	docker-compose -f docker-compose.dev.yml logs -f

dev-shell: ## Entrar no container de desenvolvimento
	docker-compose -f docker-compose.dev.yml exec app /bin/bash

test: ## Verificar saúde dos containers
	@echo '${GREEN}Checking container health...${RESET}'
	@docker-compose ps
	@echo ''
	@echo '${GREEN}Checking application health...${RESET}'
	curl -f https://localhost/ || echo 'Application is starting...'

config: ## Validar docker-compose.yml
	docker-compose config

validate: ## Validar tudo
	@echo '${GREEN}Validating configuration...${RESET}'
	@docker-compose config > /dev/null && echo '${GREEN}✓ docker-compose.yml is valid${RESET}'
	@[ -f Dockerfile ] && echo '${GREEN}✓ Dockerfile found${RESET}' || echo '${YELLOW}✗ Dockerfile not found${RESET}'
	@[ -f docker-compose.yml ] && echo '${GREEN}✓ docker-compose.yml found${RESET}' || echo '${YELLOW}✗ docker-compose.yml not found${RESET}'

version: ## Exibir versões de ferramentas
	@echo '${GREEN}Tool versions:${RESET}'
	@docker --version
	@docker-compose --version
	@openssl version
