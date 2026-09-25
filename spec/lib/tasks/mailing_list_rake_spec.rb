require 'rails_helper'

RSpec.describe 'rake mailing_list:subscribe_active_members', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'delegates to the newsletter subscription service' do
    allow(NewsletterSubscriptionService).to receive(:call)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('NEWSLETTER_ID').and_return('newsletterid')

    task.execute

    expect(NewsletterSubscriptionService).to have_received(:call).with(newsletter_id: 'newsletterid')
  end

  it 'aborts when NEWSLETTER_ID is not set' do
    allow(NewsletterSubscriptionService).to receive(:call)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('NEWSLETTER_ID').and_return(nil)
    allow(Rails.logger).to receive(:info)

    expect { task.execute }.to raise_error(SystemExit)
    expect(Rails.logger).to have_received(:info).with('NEWSLETTER_ID not set. Aborting task')
    expect(NewsletterSubscriptionService).not_to have_received(:call)
  end
end
