.DEFAULT_GOAL := help

.PHONY: help
help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

backup_production: ## Capture and download a production database backup
	heroku pgbackups:capture --app=codebar-production
	curl -o pg-production-latest.dump `heroku pgbackups:url --app=codebar-production`
	bzip2 pg-production-latest.dump
# ---------------------------------------------------------------------------
# dump_production - restore a fresh copy of the production database locally
#
# Usage:
#   make dump_production
#
# Fetches the codebar-production Heroku database directly and restores it into a
# local PostgreSQL database named $(DUMP_DB), overwriting whatever is there.
# Use this as the starting point for working against production data locally.
#
# Requirements:
#   - Heroku CLI installed and logged in (works when `heroku auth:whoami` succeeds)
#   - Local PostgreSQL running (matches config/database.yml): DB_HOST / DB_PORT
#     env vars are respected, defaulting to your OS user on localhost:5432
#
# How it works:
#   1. Pulls the live connection string (host/db/user/password) from Heroku, so
#      no credentials are hardcoded and they can't go stale.
#   2. `pg_dump`s the production database to a temporary SQL file first. Any
#      dump failure aborts here, before the local database is touched.
#   3. Creates the local database if missing.
#   4. Drops and recreates the public schema (a clean overwrite every run), then
#      restores from the temp file and removes it. `--no-owner --no-acl` stops
#      production roles colliding with local ones.
#
# Any failing step aborts loudly; the previous local copy is never destroyed
# unless a fresh dump has already succeeded.
# ---------------------------------------------------------------------------
DUMP_APP := codebar-production
DUMP_DB  := codebar_production_dump

dump_production: ## Restore a fresh copy of production data locally
	@command -v heroku   >/dev/null || { echo "error: Heroku CLI not installed"; exit 1; }
	@command -v pg_dump  >/dev/null || { echo "error: pg_dump not found on PATH"; exit 1; }
	@command -v psql     >/dev/null || { echo "error: psql not found on PATH"; exit 1; }
	@command -v createdb >/dev/null || { echo "error: createdb not found on PATH"; exit 1; }
	@command -v pg_isready >/dev/null || { echo "error: pg_isready not found on PATH"; exit 1; }
	@heroku auth:whoami >/dev/null 2>&1 || { echo "error: not logged in to Heroku (run: heroku login)"; exit 1; }
	@echo "Checking access to $(DUMP_APP)..."
	@heroku pg:info --app=$(DUMP_APP) >/dev/null 2>&1 || { echo "error: cannot read $(DUMP_APP) database (check Heroku access)"; exit 1; }
	@echo "Checking local PostgreSQL..."
	@pg_isready -h "$${DB_HOST:-localhost}" -p "$${DB_PORT:-5432}" >/dev/null 2>&1 || { echo "error: local PostgreSQL not running"; exit 1; }
	@echo "Dumping $(DUMP_APP) to a temporary file..."
	@DUMP_FILE="$$(mktemp -t codebar_dump.XXXXXX).sql"; \
	  DUMP_URL="$$(heroku pg:credentials:url DATABASE_URL --app=$(DUMP_APP) 2>/dev/null | grep -o 'postgres://[^ ]*' | head -1)"; \
	  [ -n "$$DUMP_URL" ] || { echo "error: could not read connection URL for $(DUMP_APP)"; exit 1; }; \
	  pg_dump "$$DUMP_URL" --no-owner --no-acl -f "$$DUMP_FILE" \
	    || { echo "error: production dump failed"; rm -f "$$DUMP_FILE"; exit 1; }; \
	  createdb "$(DUMP_DB)" 2>/dev/null || true; \
	  psql -d "$(DUMP_DB)" -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;' >/dev/null \
	    || { echo "error: could not reset local schema in $(DUMP_DB)"; rm -f "$$DUMP_FILE"; exit 1; }; \
	  psql -d "$(DUMP_DB)" -f "$$DUMP_FILE" \
	    || { echo "error: restore into $(DUMP_DB) failed"; rm -f "$$DUMP_FILE"; exit 1; }; \
	  rm -f "$$DUMP_FILE"; \
	  echo "Done: production copy restored into '$(DUMP_DB)'."

deploy_production: ## Deploy master to production
	heroku maintenance:on --app=codebar-production
	git tag production_release_`date +"%Y%m%d-%H%M%S"`
	git push upstream --tags
	git push production master
	heroku run rake db:migrate --app=codebar-production
	heroku maintenance:off --app=codebar-production
backup_staging: ## Capture and download a staging database backup
	heroku pgbackups:capture --app=codebar-staging
	curl -o pg-staging-latest.dump `heroku pgbackups:url --app=codebar-staging`
	bzip2 pg-staging-latest.dump
deploy_staging: ## Deploy master to staging
	heroku maintenance:on --app=codebar-staging
	git tag staging_release_`date +"%Y%m%d-%H%M%S"`
	git push upstream --tags
	git push staging master
	heroku run rake db:migrate --app=codebar-staging
	heroku maintenance:off --app=codebar-staging
serve: ## Run the Rails dev server
	rm -f ./tmp/pids/server.pid && bundle exec rails server --binding=0.0.0.0 --port=3000

test: ## Run the test suite in parallel
	bundle exec rake parallel:setup
	bundle exec parallel_rspec spec/ -n 3

check: ## Run setup checks
	bundle exec rake setup:check
