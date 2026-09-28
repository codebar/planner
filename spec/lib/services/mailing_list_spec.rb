require 'rails_helper'

require 'json'
require 'services/mailing_list'

RSpec.describe Services::MailingList do
  let(:mailing_list) { described_class.new(:list_id) }
  let(:client) { instance_double(Flodesk::Client) }

  before do
    allow(client).to receive(:disabled?).and_return(false)

    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FLODESK_KEY').and_return('test')
    allow(mailing_list).to receive(:client).and_return(client)
    allow(Rails).to receive(:env).and_return('production'.inquiry)
  end

  describe '#subscribe' do
    it 'adds a user to the mailing list' do
      allow(client).to receive(:subscribe)
        .with({
                email: :email,
                first_name: :first_name,
                last_name: :last_name,
                segment_ids: [:list_id]
              })

      mailing_list.subscribe(:email, :first_name, :last_name)

      expect(client).to have_received(:subscribe)
        .with({
                email: :email,
                first_name: :first_name,
                last_name: :last_name,
                segment_ids: [:list_id]
              })
    end
  end

  describe '#unsubscribe' do
    it 'removes a user from the mailing list' do
      allow(client).to receive(:unsubscribe)
        .with({ email: :email, segment_ids: [:list_id] })

      mailing_list.unsubscribe(:email)

      expect(client).to have_received(:unsubscribe)
        .with({ email: :email, segment_ids: [:list_id] })
    end
  end

  describe 'when Flodesk fails' do
    let(:error) { Flodesk::FlodeskError.new('Service unavailable', status_code: 503) }

    before { allow(Rollbar).to receive(:error) }

    it 'reports a failed subscribe with the list and email' do
      allow(client).to receive(:subscribe).and_raise(error)

      expect { mailing_list.subscribe(:email, :first_name, :last_name) }.not_to raise_error
      expect(Rollbar).to have_received(:error).with(error, list_id: :list_id, email: :email)
    end

    it 'reports a failed unsubscribe with the list and email' do
      allow(client).to receive(:unsubscribe).and_raise(error)

      expect { mailing_list.unsubscribe(:email) }.not_to raise_error
      expect(Rollbar).to have_received(:error).with(error, list_id: :list_id, email: :email)
    end
  end
end
