RSpec.describe 'rake mailing_list:subscribe_active_members', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully' do
    # See https://stackoverflow.com/questions/23146353/rspec-3-0-how-to-mock-a-method-replacing-the-parameter-but-with-no-return-value
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('NEWSLETTER_ID').and_return('newsletterid')
    expect { task.invoke }.not_to raise_error
  end

  it 'subscribes all active members to the newsletter mailing list' do
    ENV['NEWSLETTER_ID'] = 'newsletterid'
    non_subscribed = Fabricate.times(2, :member)
    subscribed = Fabricate.times(2, :member)
    subscribed.each { |member| Fabricate(:subscription, member:) }
    subscribed[0...3].each { |member| Fabricate(:subscription, member:) }

    newslettter = Services::MailingList.new(:id)
    allow(Services::MailingList).to receive(:new).and_return(newslettter)

    subscribed.each do |subscriber|
      allow(newslettter).to receive(:subscribe).with(subscriber.email,
                                                     subscriber.name,
                                                     subscriber.surname).once
    end

    task.execute

    expect(Services::MailingList).to have_received(:new)

    subscribed.each do |subscriber|
      expect(newslettter).to have_received(:subscribe).with(subscriber.email,
                                                            subscriber.name,
                                                            subscriber.surname).once
    end

    non_subscribed.each do |inactive_subscriber|
      expect(newslettter).not_to have_received(:subscribe).with(inactive_subscriber.email,
                                                                inactive_subscriber.name,
                                                                inactive_subscriber.surname)
    end

    subscribed.each { |subscriber| expect(subscriber.reload.opt_in_newsletter_at).not_to be_nil }
  end
end
