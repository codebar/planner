require 'spec_helper'
require 'services/mailing_list'

describe MailingList, wip: true do
  let(:client) { double(:gibbon) }
  let(:mailing_list) { MailingList.new(:list_id) }
  let(:lists) { double(:lists) }

  before do
    allow(mailing_list).to receive(:client).and_return(client)

    expect(client).to receive(:lists).and_return(lists)
  end

  context '#subscribe' do
    xit 'add user to mailing list' do
      expect(lists).to receive(:subscribe)

      mailing_list.subscribe(:email, :first_name, :last_name)
    end
  end

  context '#unsubscribe' do
    xit 'removes a user from the mailing list' do
      expect(lists).to receive(:unsubscribe)

      mailing_list.unsubscribe(:email)
    end
  end
end
