require "spec_helper"

describe SessionInvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:session) { Fabricate(:sessions, title: "HTML & CSS") }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:session_invitation, sessions: session, member: member) }

  it "#invite_student" do
    invitation_token = "token"

    email_subject = "Workshop Invitation #{humanize_date_with_time(session.date_and_time, session.time)}"
    SessionInvitationMailer.invite_student(session, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
  end

  it "#attending_reminder" do
    email_subject = "Workshop Reminder #{humanize_date_with_time(session.date_and_time, session.time)}"
    SessionInvitationMailer.attending_reminder(session, member, invitation).deliver_now
    expect(email.subject).to eq(email_subject)
  end

  it "#waitlist_reminder" do
    email_subject = "Reminder: you're on the codebar waiting list (#{humanize_date_with_time(session.date_and_time, session.time)})"
    SessionInvitationMailer.waiting_list_reminder(session, member, invitation).deliver_now
    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match("you should keep your laptop with you and check your email during the afternoon on the day of the workshop.")
    expect(email.body.encoded).to match("This is a quick email to remind you that you're on the waiting list for the workshop on #{humanize_date_with_time(session.date_and_time, session.time)}")

  end
end
