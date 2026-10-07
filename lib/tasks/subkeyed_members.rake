# frozen_string_literal: true

# Detect, deactivate (dry run unless EXECUTE=1), and verify members keyed on
# the auth-app user id. Logic in app/services/subkeyed_member_cleanup.rb;
# this task owns all operator-facing output.
#
# Usage:
#   List matches (read-only):
#     rake member:subkeyed:detect
#
#   Dry-run the deactivation (default; prints what would happen):
#     rake member:subkeyed:deactivate
#
#   Deactivate for real (one transaction per member):
#     EXECUTE=1 rake member:subkeyed:deactivate
#
#   Confirm the end state (exits 1 while deactivatable members remain):
#     rake member:subkeyed:verify
#
#   Run against a local production dump instead of the environment's own
#   database:
#     DB_NAME=codebar_production_dump rake member:subkeyed:detect
#
#   On Heroku (uses the app's DATABASE_URL; no DB_NAME needed):
#     heroku run rake member:subkeyed:detect --app codebar-production
#     heroku run rake member:subkeyed:deactivate EXECUTE=1 --app codebar-production
#
# Sequencing: run EXECUTE=1 in production only after the fail-closed
# strategy guard (#2986) is deployed.

def print_actions(result, dry_run: true)
  result.actions.each { |action| print_action(action, dry_run) }
end

def print_action(action, dry_run)
  case action.outcome
  when :skipped
    puts "Skipping sub-keyed member #{action.member_id} (#{action.email}) — owns #{action.owned.join(', ')}. " \
         'Review manually; merging needs planner-external evidence (an auth-DB link), never a guess.'
  when :deactivated
    verb = dry_run ? 'Would deactivate' : 'Deactivating'
    puts "  #{verb} sub-keyed member #{action.member_id} (#{action.email}): " \
         'remove auth services, rename email, add member note'
  end
end

def print_counts(result)
  puts "detected=#{result.detected} deactivated=#{result.deactivated} skipped=#{result.skipped}"
end

def print_summary(result, dry_run:)
  puts 'DRY RUN — re-run with EXECUTE=1 to deactivate.' if dry_run
  print_counts(result)
  puts 'Skipped members count as handled: review them manually before any merge.'
end

# When DB_URL or DB_NAME is set, connect to that database (a live production
# database or a local dump) instead of the environment's own. DB_URL takes a
# full connection URL; DB_NAME is a local database on DB_HOST. Otherwise the
# task uses the Rails environment's database (e.g. Heroku's DATABASE_URL).
def connect_to_dump_if_requested
  if ENV['DB_URL'].present?
    connect_to_remote(ENV['DB_URL'])
  elsif ENV['DB_NAME']
    connect_to_local(ENV['DB_NAME'])
  end
end

def connect_to_local(database)
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: ENV.fetch('DB_HOST', '/var/run/postgresql'),
    port: ENV.fetch('DB_PORT', 5432),
    database:,
    username: ENV['DB_USER'] || '',
    password: ENV['POSTGRES_PASSWORD'] || ''
  )
end

def connect_to_remote(db_url)
  url = URI.parse(db_url)
  unless %w[localhost 127.0.0.1].include?(url.host)
    puts "WARNING: Connecting to REMOTE database #{url.host}"
  end
  ActiveRecord::Base.establish_connection(db_url)
end

namespace :member do
  namespace :subkeyed do
    desc 'Detect members keyed on the auth-app user id (id_token sub fallback incident)'
    task detect: :environment do
      connect_to_dump_if_requested
      result = SubkeyedMemberCleanup.call(dry_run: true)

      print_actions(result)
      print_counts(result)
    end

    desc 'Deactivate sub-keyed members (dry run by default; EXECUTE=1 to write)'
    task deactivate: :environment do
      connect_to_dump_if_requested
      dry_run = ENV['EXECUTE'] != '1'
      result = SubkeyedMemberCleanup.call(dry_run:)

      print_actions(result, dry_run:)
      print_summary(result, dry_run:)
    end

    desc 'Verify no unhandled sub-keyed members remain (deactivatable-but-active fails)'
    task verify: :environment do
      connect_to_dump_if_requested
      verification = SubkeyedMemberCleanup.new.verification
      unhandled = verification[:unhandled]
      skipped = verification[:skipped]

      if unhandled.empty?
        puts 'PASS: no deactivatable sub-keyed members remain.'
        puts "Note: #{skipped.size} skipped member(s) count as handled — review manually." if skipped.any?
      else
        puts "FAIL: #{unhandled.size} deactivatable sub-keyed member(s) still active:"
        unhandled.each { |id| puts "  member #{id}" }
        exit 1
      end
    end
  end
end
