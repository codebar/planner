require "spec_helper"

describe EventInvitationMailer, wip: true do

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:event) { Fabricate(:event, date_and_time: DateTime.new(2017,11,12,10,0), name: "Event of the day") }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:invitation, event: event, member: member) }

  it "#invite_student" do
    email_subject = "Join us for a day long Codebar #{event.name} event on the 12th!"
    EventInvitationMailer.invite_student(event, member, invitation).deliver

    expect(email.subject).to eq(email_subject)
  end

  it "#invite_coach" do
    email_subject = "Join us for a day long Codebar #{event.name} event on the 12th!"
    EventInvitationMailer.invite_coach(event, member, invitation).deliver

    expect(email.subject).to eq(email_subject)
  end

end
