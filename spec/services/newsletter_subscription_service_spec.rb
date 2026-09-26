# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsletterSubscriptionService, type: :service do
  subject(:subscribe_members) { described_class.call(newsletter_id:) }

  let(:newsletter_id) { 'newsletterid' }
  let(:newsletter) { Services::MailingList.new(:id) }

  before do
    allow(Services::MailingList).to receive(:new).and_return(newsletter)
    allow(newsletter).to receive(:subscribe)
  end

  it 'subscribes all active members to the newsletter mailing list' do
    non_subscribed = Fabricate.times(2, :member)
    subscribed = Fabricate.times(2, :member)
    subscribed.each { |member| Fabricate(:subscription, member:) }

    subscribe_members

    subscribed.each do |subscriber|
      expect(newsletter).to have_received(:subscribe).with(subscriber.email,
                                                           subscriber.name,
                                                           subscriber.surname).once
      expect(subscriber.reload.opt_in_newsletter_at).not_to be_nil
    end

    non_subscribed.each do |inactive_subscriber|
      expect(newsletter).not_to have_received(:subscribe).with(inactive_subscriber.email,
                                                               inactive_subscriber.name,
                                                               inactive_subscriber.surname)
    end
  end

  it 'excludes members whose only subscription is a tombstone' do
    churned = Fabricate(:member)
    Fabricate(:discarded_subscription, member: churned)

    subscribe_members

    expect(newsletter).not_to have_received(:subscribe).with(churned.email, churned.name, churned.surname)
    expect(churned.reload.opt_in_newsletter_at).to be_nil
  end
end
