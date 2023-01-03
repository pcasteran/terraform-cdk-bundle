#
# Project Makefile.
#

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo
	@echo "\033[1;94mProject Makefile\033[0m"
	@echo
	@echo "\033[1;93mAvailable targets:\033[0m"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo

.PHONY: lint
lint: ## Lint the project sources
	docker run --rm \
		--name super-linter \
		--env RUN_LOCAL=true \
		--env-file ".github/super-linter.env" \
		--volume "$(shell pwd)":/tmp/lint:ro \
		github/super-linter:slim-v4

.PHONY: lint_shell
lint_shell: ## Open a shell in a linter container
	docker run --rm -it \
		--name super-linter \
		--env RUN_LOCAL=true \
		--env-file ".github/super-linter.env" \
		--volume "$(shell pwd)":/tmp/lint \
		--entrypoint /bin/bash \
		--workdir /tmp/lint \
		github/super-linter:slim-v4
