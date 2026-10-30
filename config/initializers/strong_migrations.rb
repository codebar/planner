# frozen_string_literal: true

# Analyze migrations for unsafe operations before they reach production.
# https://github.com/ankane/strong_migrations
StrongMigrations.start_after = 20260101000000 # rubocop:disable Style/NumericLiterals
StrongMigrations.target_postgresql_version = 16

# With preboot, the release phase runs before old web dynos stop, so old code
# serves against the new schema for ~3 minutes. Say so where the migration
# author will see it, next to the gem's `safety_assured` advice.
preboot_note = <<~TXT
  Heroku preboot: this runs in the release phase before old web dynos stop,
  so old code serves against the new schema for ~3 minutes after the deploy.
  See AGENTS.md ("Migrations and Heroku preboot"). If the migration cannot
  be made forward-compatible, disable preboot for this deploy.
TXT

%i[change_column change_column_with_not_null change_column_default
   change_column_null rename_column rename_table rename_schema
   rename_enum_value execute].each do |key|
  StrongMigrations.error_messages[key] = "#{StrongMigrations.error_messages.fetch(key)}\n\n#{preboot_note}"
end
