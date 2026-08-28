SHELL := /bin/sh

FLUTTER ?= flutter
SOURCE_DIRS := lib test
BUILD_ARGS ?=

VERSION := $(shell sed -n 's/^version:[[:space:]]*//p' pubspec.yaml)
BUILD_NUMBER := $(shell printf '%s\n' '$(VERSION)' | sed -n 's/.*+//p')

APK_PATH := build/app/outputs/flutter-apk/app-release.apk
AAB_PATH := build/app/outputs/bundle/release/app-release.aab

.DEFAULT_GOAL := help
.NOTPARALLEL:

.PHONY: help doctor get clean format format-check analyze test check \
	version-check signing-check build-apk build-aab release

help: ## Exibe os comandos disponíveis
	@awk 'BEGIN {FS = ":.*## "; printf "Uso: make <alvo>\n\nAlvos:\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

doctor: ## Verifica a instalação e as ferramentas do Flutter
	$(FLUTTER) doctor -v

get: ## Instala ou atualiza as dependências do projeto
	$(FLUTTER) pub get

clean: ## Remove os artefatos gerados pelo Flutter
	$(FLUTTER) clean

format: ## Formata o código Dart
	dart format $(SOURCE_DIRS)

format-check: ## Verifica a formatação sem alterar arquivos
	dart format --output=none --set-exit-if-changed $(SOURCE_DIRS)

analyze: ## Executa a análise estática
	$(FLUTTER) analyze

test: ## Executa a suíte completa de testes
	$(FLUTTER) test

check: get format-check analyze test ## Executa todas as validações do projeto

version-check: ## Valida a versão usada pela publicação Android
	@test -n "$(VERSION)" || { echo "Erro: versão não encontrada em pubspec.yaml."; exit 1; }
	@case "$(BUILD_NUMBER)" in ''|*[!0-9]*) echo "Erro: use version: <nome>+<número> em pubspec.yaml."; exit 1;; esac
	@test "$(BUILD_NUMBER)" -gt 0 || { echo "Erro: o build number deve ser maior que zero para publicação no Google Play (atual: $(VERSION))."; exit 1; }

signing-check: ## Confere a configuração local de assinatura Android
	@test -f android/key.properties || { echo "Erro: android/key.properties não encontrado."; exit 1; }
	@for key in storePassword keyPassword keyAlias storeFile; do \
		grep -Eq "^$${key}=.+" android/key.properties || { echo "Erro: $${key} ausente em android/key.properties."; exit 1; }; \
	done

build-apk: version-check signing-check ## Gera um APK release assinado para distribuição direta
	$(FLUTTER) build apk --release $(BUILD_ARGS)
	@echo "APK gerado em $(APK_PATH)"

build-aab: version-check signing-check ## Gera o Android App Bundle para o Google Play
	$(FLUTTER) build appbundle --release $(BUILD_ARGS)
	@echo "AAB gerado em $(AAB_PATH)"

release: check build-aab ## Valida o projeto e gera o AAB de publicação
