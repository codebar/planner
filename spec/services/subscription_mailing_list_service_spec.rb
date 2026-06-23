require 'rails_helper'

RSpec.describe SubscriptionMailingListService do
  subject(:service) { described_class.new }

  let(:subscription) { Fabricate.build(:subscription) }
  let(:mailing_list) { instance_spy(Services::MailingList) }

  before do
    allow(Services::MailingList).to receive(:new).and_return(mailing_list)
  end

  describe '#subscribe' do
    it 'subscribes the member to the group mailing list' do
      service.subscribe(subscription)

      expect(Services::MailingList).to have_received(:new)
        .with(subscription.group.mailing_list_id)
      expect(mailing_list).to have_received(:subscribe)
        .with(subscription.member.email, subscription.member.name, subscription.member.surname)
    end
  end

  describe '#unsubscribe' do
    it 'unsubscribes the member from the group mailing list' do
      service.unsubscribe(subscription)

      expect(Services::MailingList).to have_received(:new)
        .with(subscription.group.mailing_list_id)
      expect(mailing_list).to have_received(:unsubscribe)
        .with(subscription.member.email)
    end
  end
end
