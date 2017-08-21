SHELL := /usr/bin/env bash

# Local env
KEYWORD=cat
PHP=php

# Exported env
export PUBSUB_EMULATOR_HOST

AWK := $(shell command -v awk 2> /dev/null)
help:
ifndef AWK
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
else
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
endif

##
## App
##------------------------------
install-shell: ## Install shell tool
	@cat ~/.zshrc | grep 'worker-gif' || cat .bash >> ~/.zshrc
	@source ~/.zshrc
	@echo 'Shell installed'
install: ## Install project
	@composer install
	@cp .env.dist .env
run: ## Run worker
	@php application.php
send-message: ## Send message to pubsub
	@php application.php test:gif $(KEYWORD)
local-pubsub: ## Run pubsub in local
	@gcloud beta emulators pubsub start

##
## Docker compose
##------------------------------
up: ## Start project
	@docker-compose up
down: ## Stop project
	@docker-compose down

##
## Kubernetes
##------------------------------
kube-build: ## Build docker image
	@docker build . -f kubernetes/builder/worker/Dockerfile -t darkilliant/worker-gif
kube-push:
	@docker push darkilliant/worker-gif
kube-deploy:
	kubectl create -f kubernetes/deployment/worker.yaml
kube-destroy:
	kubectl delete -f kubernetes/deployment/worker.yaml
kube-local-run: ## Run docker image
	@docker run --rm -it darkilliant/worker-gif