require 'spec_helper'

RSpec.describe EventInvitationMailer, type: :mailer  do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:event) { Fabricate(:event, date_and_time: Time.zone.local(2017, 11, 12, 10, 0), name: 'Test event') }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:invitation, event: event, member: member) }

  it '#invite_student' do
    email_subject = "Invitation: #{event.name}"
    EventInvitationMailer.invite_student(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match('hello@codebar.io')
  end

  it '#invite_coach' do
    email_subject = "Coach Invitation: #{event.name}"
    EventInvitationMailer.invite_coach(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match('hello@codebar.io')
  end

  it '#attending' do
    email_subject = "Your spot to #{event.name} has been confirmed."
    EventInvitationMailer.attending(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match('hello@codebar.io')
  end
end
