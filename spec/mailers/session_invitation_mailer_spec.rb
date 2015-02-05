require "spec_helper"

describe SessionInvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:session) { Fabricate(:sessions, title: "HTML & CSS") }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:session_invitation, sessions: session, member: member) }

  it "#invite_student" do
    invitation_token = "token"

    email_subject = "Workshop Invitation #{humanize_date_with_time(session.date_and_time, session.time)}"
    SessionInvitationMailer.invite_student(session, member, invitation).deliver

    expect(email.subject).to eq(email_subject)
  end

  it "#attending_reminder" do
    email_subject = "Workshop Reminder #{humanize_date_with_time(session.date_and_time, session.time)}"
    SessionInvitationMailer.attending_reminder(session, member, invitation).deliver

    expect(email.subject).to eq(email_subject)
  end
end
