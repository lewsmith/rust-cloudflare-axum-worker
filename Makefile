all: help

.PHONY: dev
dev: deps ## Run the development server using Wrangler
	npx wrangler dev build/worker/shim.mjs --live-reload -c ./wrangler/config.toml --env dev

.PHONY: dev-watch
dev-watch: ## Run the development server using Wrangler and watch for changes\n
	@make -s dev & pid1=$$!; make -s watch & pid2=$$!; trap 'kill -9 $$pid1 $$pid2; exit 0' SIGINT; wait

.PHONY: watch
watch:
	# Build command requires worker-build to be <= v0.0.10 due to @cloudflare/vitest-pool-workers compatibility bug.
    # See https://github.com/cloudflare/workers-sdk/issues/5726
	cargo install -q --locked watchexec-cli worker-build@0.0.10
	echo -e "\n\033[1m\033[36mWatching for changes\033[0m"
	watchexec -p -N -w ./src -w ./Cargo.toml 'worker-build  --dev'

.PHONY: lint
lint: ## Run all linters
	make -s -j 2 lint-rust lint-typescript

.PHONY: lint-fix
lint-fix: ## Run all lint fixers & formatters
	make -s -j 2 lint-fix-rust lint-fix-typescript

.PHONY: lint-rust
lint-rust: ## Run Rust linting using Cargo Fmt and Clippy
	cargo fmt -- --check
	cargo clippy --no-deps -- -D warnings

.PHONY: lint-typescript
lint-typescript: ## Run TypeScript linting using ESlint (mainly integration tests)
	npx @biomejs/biome check .

.PHONY: lint-fix-rust
lint-fix-rust: ## Run Rust lint fixers & formatter using Cargo Fmt
	cargo fmt
	cargo clippy --fix --allow-staged

.PHONY: lint-fix-typescript
lint-fix-typescript: ## Run TypeScript lint fixers & formatter using ESlint (mainly integration tests)\\n
	npx @biomejs/biome check --apply .

.PHONY: deps
deps: ## Install dependencies
	npm install

.PHONY: build
build: ## Build the worker using Wrangler\n
	npx wrangler deploy --minify --dry-run --outdir $$(pwd)/wrangler/dist/ -c ./wrangler/config.toml

.PHONY: test
test: ## Run unit tests & integration tests
	make -s -j 2 test-unit test-integration

.PHONY: test-unit
test-unit: ## Run unit tests
	cargo test

.PHONY: test-integration
test-integration: ## Run integration tests\n
	npx vitest run -c ./integration/vitest.config.ts

.PHONY: deploy-preview
deploy-preview: ## Deploy the project to Cloudflare Workers for preview
	$(if $(filter yes,$(CI)),,@$(confirm-preview-release))
	npx wrangler deploy --env preview --minify -c ./wrangler/config.toml

.PHONY: deploy-release
deploy-release: ## Deploy the project to Cloudflare Workers\n
	$(if $(filter yes,$(CI)),,@$(confirm-deploy-release))
	npx wrangler deploy --minify -c ./wrangler/config.toml

.PHONY: act
act: ## Run GitHub Actions locally with Act (use '-- --gh' to use GitHub CLI)\n
	@if [ -n "$(filter --gh,$(MAKECMDGOALS))" ]; then \
		command gh --version >/dev/null 2>&1 || { echo >&2 "GitHub CLI is required but it's not installed. Check https://cli.github.com/manual/installation"; exit 0; }; \
		gh act --rm --secret-file wrangler/.dev.vars -e act.json --defaultbranch main --artifact-server-path /tmp/artifacts; \
	else \
		command act --version >/dev/null 2>&1 || { echo >&2 "Act is required but it's not installed. If you installed using the Github CLI use '-- --gh'.  Check https://nektosact.com/installation/index.html"; exit 0; }; \
		act --rm --secret-file wrangler/.dev.vars -e act.json --defaultbranch main --artifact-server-path /tmp/artifacts; \
	fi

.PHONY: help
help:  ## Display this help screen
	@echo -e "⚡ \e[4m\e[1mRust Cloudflare Axum Worker\e[0m\n"
	@grep -h -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {gsub(/\\n/, "\n", $$2); printf "  \033[1m> \033[36m%-30s\033[0m %s\n", $$1, $$2}'

ifndef CI
define confirm-deploy-release
	@read -p "Are you sure you want to deploy a release? Type 'yes' to continue: " response; \
	if [ "$$response" != "yes" ]; then \
		echo "Release deployment aborted."; exit 1; \
	fi
endef
define confirm-preview-release
	@read -p "Are you sure you want to deploy a preview? Type 'yes' to continue: " response; \
	if [ "$$response" != "yes" ]; then \
		echo "Preview deployment aborted."; exit 1; \
	fi
endef
endif
