RSpec.describe 'rake mailing_list:subscribe_active_members', type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it 'should run gracefully' do
    # See https://stackoverflow.com/questions/23146353/rspec-3-0-how-to-mock-a-method-replacing-the-parameter-but-with-no-return-value
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('NEWSLETTER_ID').and_return('newsletterid')
    expect { task.invoke }.to_not raise_error
  end

  it 'subscribes all active members to the newsletter mailing list' do
    ENV['NEWSLETTER_ID'] = 'newsletterid'
    non_subscribed = Fabricate.times(2, :member)
    subscribed = Fabricate.times(2, :member)
    subscribed.each { |member| Fabricate(:subscription, member: member) }
    subscribed[0...3].each { |member| Fabricate(:subscription, member: member) }

    newslettter = Services::MailingList.new(:id)
    expect(Services::MailingList).to receive(:new).and_return(newslettter)

    subscribed.each do |subscriber|
      expect(newslettter).to receive(:subscribe).with(subscriber.email,
                                                      subscriber.name,
                                                      subscriber.surname).once
    end

    non_subscribed.each do |inactive_subscriber|
      expect(newslettter).to_not receive(:subscribe).with(inactive_subscriber.email,
                                                          inactive_subscriber.name,
                                                          inactive_subscriber.surname)
    end

    task.execute

    subscribed.each { |subscriber| expect(subscriber.reload.opt_in_newsletter_at).to_not eq(nil) }
  end
end
