RSpec.describe 'rake chaser:signup_nudges', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'enqueues the signup nudge email job' do
    allow(SendSignupNudgeEmailJob).to receive(:perform_later)

    task.invoke

    expect(SendSignupNudgeEmailJob).to have_received(:perform_later)
  end
end
