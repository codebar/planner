# frozen_string_literal: true

namespace :delayed_jobs do
  desc 'Delete failed jobs that failed before the given date, or one year ago by default'
  task :prune_failed, [:before] => :environment do |_task, args|
    cutoff = args[:before] ? Date.parse(args[:before]) : 1.year.ago.to_date

    count = Delayed::Job.where.not(failed_at: nil)
                        .where(failed_at: ...cutoff)
                        .delete_all

    puts "deleted=#{count} cutoff=#{cutoff}"
  end
end
