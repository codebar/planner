require 'rails_helper'

RSpec.describe 'rake chaser:coach_milestones' do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'enqueues the coach milestone email job' do
    allow(SendCoachMilestoneEmailJob).to receive(:perform_later)

    task.invoke

    expect(SendCoachMilestoneEmailJob).to have_received(:perform_later)
  end
end
