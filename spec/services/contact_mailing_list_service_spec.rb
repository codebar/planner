require 'rails_helper'

RSpec.describe ContactMailingListService do
  subject(:service) { described_class.new }

  let(:contact) { Fabricate.build(:contact, mailing_list_consent: consent) }
  let(:mailing_list) { instance_spy(Services::MailingList) }

  before do
    allow(Services::MailingList).to receive(:new).and_return(mailing_list)
    allow(ContactMailer).to receive_message_chain(:subscription_notification, :deliver_now)
  end

  describe '#sync' do
    context 'when consent is true' do
      let(:consent) { true }

      it 'subscribes to mailing list and sends notification' do
        service.sync(contact)

        expect(mailing_list).to have_received(:subscribe).with(contact.email, contact.name, contact.surname)
        expect(ContactMailer).to have_received(:subscription_notification).with(contact)
      end
    end

    context 'when consent is false' do
      let(:consent) { false }

      it 'unsubscribes from mailing list' do
        service.sync(contact)

        expect(mailing_list).to have_received(:unsubscribe).with(contact.email)
        expect(ContactMailer).not_to have_received(:subscription_notification)
      end
    end
  end
end
