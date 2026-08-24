SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

MDFORMAT ?= mdformat

# NUL-delimited so paths with spaces or non-ASCII characters survive; quotePath
# is disabled because a quoted path would silently fail the worktree test below
# and drop the file from the gate. Tracked paths deleted in the worktree are
# skipped so mdformat is not handed a file that no longer exists.
MARKDOWN_PATHS_CMD = git -c core.quotePath=false ls-files -z --cached --others --exclude-standard '*.md' \
	| while IFS= read -r -d '' path; do test ! -f "$$path" || printf '%s\0' "$$path"; done

.PHONY: check help markdown-fmt markdown-fmt-check

check: markdown-fmt-check ## Run every repository check

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "; printf "\nUsage: make <target>\n\n"} \
		/^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

markdown-fmt: ## Format tracked and untracked non-ignored Markdown files
	@set -o pipefail; $(MARKDOWN_PATHS_CMD) | xargs -0 --no-run-if-empty $(MDFORMAT)

markdown-fmt-check: ## Check tracked and untracked non-ignored Markdown formatting
	@set -o pipefail; $(MARKDOWN_PATHS_CMD) | xargs -0 --no-run-if-empty $(MDFORMAT) --check
