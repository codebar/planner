# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake delayed_jobs:prune_failed', type: :task do
  def create_failed_job(failed_at:)
    Delayed::Job.create!(
      handler: '--- !ruby/object:Delayed::PerformableMethod {}',
      run_at: failed_at,
      attempts: 3,
      failed_at:
    )
  end

  let!(:old_job) { create_failed_job(failed_at: 2.years.ago) }
  let!(:recent_job) { create_failed_job(failed_at: 1.week.ago) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'deletes jobs that failed more than a year ago by default' do
    expect { task.execute }.to change { Delayed::Job.where.not(failed_at: nil).count }.by(-1)

    expect(Delayed::Job.exists?(old_job.id)).to be(false)
    expect(Delayed::Job.exists?(recent_job.id)).to be(true)
  end

  it 'accepts an explicit cutoff date and deletes everything before it' do
    args = Rake::TaskArguments.new([:before], [1.year.from_now.to_date.iso8601])

    expect { task.execute(args) }.to change { Delayed::Job.where.not(failed_at: nil).count }.by(-2)
  end

  it 'deletes nothing when the cutoff precedes every failure' do
    args = Rake::TaskArguments.new([:before], [3.years.ago.to_date.iso8601])

    expect { task.execute(args) }.not_to(change { Delayed::Job.where.not(failed_at: nil).count })
  end
end
