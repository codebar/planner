class UpdateJobStatuses < ActiveRecord::Migration
  def change
    Job.where(submitted: false, approved: false).each do |job|
      job.draft!
    end

    Job.where(submitted: true, approved: false).each do |job|
      job.pending!
    end

    Job.where(submitted: true, approved: true).each do |job|
      job.published!
    end
  end
end
