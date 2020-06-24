require 'spec_helper'
require 'services/mailing_list'

RSpec.describe MailingList do
  let(:client) { double(:gibbon, lists: lists) }
  let(:mailing_list) { MailingList.new(:list_id) }
  let(:lists) { double(:lists, members: members) }
  let(:members) { double(:members) }

  before do
    allow(ENV).to receive(:[]).with('MAILCHIMP_KEY').and_return('test')
    allow(mailing_list).to receive(:client).and_return(client)
    allow(Rails).to receive(:env).and_return("production".inquiry)
  end

  context '#subscribe' do
    it 'adds a user to the mailing list' do
      expect(members).to receive(:create)
        .with(body: { email_address: :email,
                      status: "subscribed",
                      merge_fields: { FNAME: :first_name, LNAME: :last_name } })

      mailing_list.subscribe(:email, :first_name, :last_name)
    end

    it 'updates the subscription of existing mailing list contacts' do
      email = 'test@email.com'

      allow(members).to receive(:create)
        .and_raise(Gibbon::MailChimpError.new('Error',
                                              { status_code: 400,
                                                title: MailingList::MEMBER_EXISTS }))

      expect(Digest::MD5).to receive(:hexdigest).with(email)
      expect(members).to receive(:upsert)
        .with(body: { email_address: email,
                      status: "subscribed",
                      merge_fields: { FNAME: :first_name, LNAME: :last_name } })

      mailing_list.subscribe(email, :first_name, :last_name)
    end
  end

  context '#reactivate_subscription' do
    it 'updates an existing inactive subscription' do
      email = 'test@email.com'

      expect(Digest::MD5).to receive(:hexdigest).with(email)
      expect(members).to receive(:upsert)
        .with(body: { email_address: email,
                      status: "subscribed",
                      merge_fields: { FNAME: :first_name, LNAME: :last_name } })

      mailing_list.reactivate_subscription(email, :first_name, :last_name)
    end
  end

  context '#unsubscribe' do
    it 'removes a user from the mailing list' do
      email = 'test@email.com'

      expect(Digest::MD5).to receive(:hexdigest).with(email)
      expect(members).to receive(:update)
        .with(body: { status: "unsubscribed" })

      mailing_list.unsubscribe(email)
    end
  end

  context '#subscribed?' do
    it 'checks if a user is already subscribed to the mailing list' do
      email = 'test@email.com'
      info = double(:info, body: { status: MailingList::SUBSCRIBED })

      expect(Digest::MD5).to receive(:hexdigest).with(email)
      expect(members).to receive(:retrieve).and_return(info)

      expect(mailing_list.subscribed?(email)).to be true
    end
  end
end
