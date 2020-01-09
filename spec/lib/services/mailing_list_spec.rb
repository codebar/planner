require 'spec_helper'
require 'services/mailing_list'

RSpec.describe MailingList, wip: true do
  let(:client) { double(:gibbon) }
  let(:mailing_list) { MailingList.new(:list_id) }
  let(:lists) { double(:lists) }

  before do
    allow(mailing_list).to receive(:client).and_return(client)
    allow(Rails).to receive(:env).and_return("production".inquiry)

    expect(client).to receive(:lists).and_return(lists)
  end

  context '#subscribe' do
    it 'adds a user to the mailing list' do
      expect(lists).to receive(:subscribe)

      mailing_list.subscribe(:email, :first_name, :last_name)
    end
  end

  context '#unsubscribe' do
    it 'removes a user from the mailing list' do
      expect(lists).to receive(:unsubscribe)

      mailing_list.unsubscribe(:email)
    end
  end
end
