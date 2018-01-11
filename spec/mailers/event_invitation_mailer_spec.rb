require 'spec_helper'

describe EventInvitationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:event) { Fabricate(:event, date_and_time: Time.zone.local(2017, 11, 12, 10, 0), name: 'Event of the day') }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:invitation, event: event, member: member) }

  it '#invite_student' do
    email_subject = "Invitation: #{event.name}"
    EventInvitationMailer.invite_student(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
  end

  it '#invite_coach' do
    email_subject = "Coach Invitation: #{event.name}"
    EventInvitationMailer.invite_coach(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
  end
end
