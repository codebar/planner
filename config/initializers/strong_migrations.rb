# frozen_string_literal: true

# Analyze migrations for unsafe operations before they reach production.
# https://github.com/ankane/strong_migrations
StrongMigrations.start_after = 20260101000000 # rubocop:disable Style/NumericLiterals
StrongMigrations.target_postgresql_version = 16
