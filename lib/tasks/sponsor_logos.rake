namespace :sponsor_logos do
  desc 'Restore sponsor logos missing from S3 using Wayback Machine copies of the old asset host'
  task restore: :environment do
    result = SponsorLogoRestore.call

    puts "Checked: #{result.skipped + result.restored.size + result.failed.size} logos"
    puts "Skipped (already present): #{result.skipped}"
    puts "Restored: #{result.restored.size}"
    result.failed.each do |f|
      puts "FAILED sponsor #{f[:sponsor_id]} #{f[:filename]}: #{f[:reason]}"
    end

    abort 'Some sponsor logos could not be restored; re-run to retry' if result.failed.any?
  end
end
