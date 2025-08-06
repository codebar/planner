require 'json'
require 'services/mailing_list'

RSpec.describe MailingList do
  let(:mailing_list) { MailingList.new(:list_id) }
  let(:client) { double(:flodesk) }

  before do
    allow(client).to receive(:disabled?).and_return(false)

    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FLODESK_KEY').and_return('test')
    allow(mailing_list).to receive(:client).and_return(client)
    allow(Rails).to receive(:env).and_return("production".inquiry)
  end

  context '#subscribe' do
    it 'adds a user to the mailing list' do
      expect(client).to receive(:subscribe)
        .with({
          email: :email,
          first_name: :first_name,
          last_name: :last_name,
          segment_ids: [:list_id]
        })

      mailing_list.subscribe(:email, :first_name, :last_name)
    end
  end

  context '#unsubscribe' do
    it 'removes a user from the mailing list' do
      expect(client).to receive(:unsubscribe)
        .with({ email: :email, segment_ids: [:list_id] })

      mailing_list.unsubscribe(:email)
    end
  end

  context '#subscribed?' do
    it 'checks if a user is already subscribed to the mailing list' do
      expect(client).to receive(:subscribed?)
        .with({ email: :email, segment_ids: [:list_id] })
        .and_return(true)
      expect(mailing_list.subscribed?(:email)).to be true
    end
  end
end
