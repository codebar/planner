require 'spec_helper'

RSpec.describe ContactPresenter do
  let(:contact_presenter) { ContactPresenter.new(contact) }
  let(:contact) { Fabricate(:contact) }

  context '#full_name' do
    it 'returns the contact\'s full name' do
      expect(contact_presenter.full_name).to eq("#{contact.name} #{contact.surname}")
    end
  end

  context '#mailing_list_subscription_class' do
    it 'when subscribed to the Sponsors mailing list it returns the correct css class' do
      contact.mailing_list_consent = true

      expect(contact_presenter.mailing_list_subscription_class).to eq('fa-bell')
    end

    it 'when not  subscribed to the Sponsors mailing list it returns the correct css class' do
      contact.mailing_list_consent = false

      expect(contact_presenter.mailing_list_subscription_class).to eq('fa-bell-slash')
    end
  end
end
