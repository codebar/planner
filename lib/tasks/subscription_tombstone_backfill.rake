# frozen_string_literal: true

namespace :subscriptions do
  desc 'Reconstruct tombstone rows for unsubscribes recorded before tombstones existed (issue #2920)'
  task tombstone_backfill: :environment do
    dry_run = ENV['EXECUTE'] != '1'

    result = SubscriptionTombstoneBackfill.call(dry_run:)

    puts 'DRY RUN — re-run with EXECUTE=1 to write tombstone rows.' if dry_run

    puts "created=#{result.created} skipped_active_or_tombstoned=#{result.skipped_existing} " \
         "skipped_missing_member=#{result.skipped_missing_member}"
  end
end
