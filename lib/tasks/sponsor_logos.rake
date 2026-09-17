# Restores sponsor logos missing from the prod-sponsor-logos S3 bucket using
# Wayback Machine copies of the old assets.codebar.io asset host.
#
# Environment variables (all optional):
#   SPONSORS_URL   page to scan for logo URLs (default: https://codebar.io/sponsors)
#   RESTORE_LIMIT  restore only the first N missing logos; the rest are
#                  reported as deferred and left for a later run
#   DRY_RUN=1      full-pipeline rehearsal: download and validate archive
#                  copies but do not upload anything to S3
#   AWS_ACCESS_KEY / AWS_SECRET_ACCESS_KEY   S3 credentials (same pair the
#                  CarrierWave initializer uses); not needed for DRY_RUN
#   REFRESH_CACHE=1  ignore the local cache (tmp/cache/sponsor_logos) and
#                  refetch availability probes and the CDX index
#   CACHE_TTL_MINUTES  cache freshness window in minutes (default: 360)
namespace :sponsor_logos do
  desc 'Restore sponsor logos missing from S3 using Wayback Machine copies of the old asset host'
  task restore: :environment do
    result = SponsorLogoRestore.call
    dry_run = ENV['DRY_RUN'] == '1'

    puts 'Dry run: nothing will be uploaded' if dry_run
    checked = result.restored.size + result.rehearsed.size + result.skipped +
              result.failed.size + result.deferred.size
    puts "Checked: #{checked} logos"
    puts "Skipped (already present): #{result.skipped}"
    puts "Rehearsed (dry run): #{result.rehearsed.size}" if dry_run
    puts "Deferred (limit): #{result.deferred.size}" if result.deferred.any?
    puts "Restored: #{result.restored.size}"
    result.failed.each do |f|
      puts "FAILED sponsor #{f[:sponsor_id]} #{f[:filename]}: #{f[:reason]}"
    end

    abort 'Some sponsor logos could not be restored; re-run to retry' if result.failed.any?
  end
end
