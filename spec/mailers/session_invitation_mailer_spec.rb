require "spec_helper"

describe SessionInvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:chapter) { Fabricate(:chapter, email: "london@codebar.io") }
  let(:session) { Fabricate(:sessions, title: "HTML & CSS", chapter: chapter) }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:session_invitation, sessions: session, member: member) }

  it "#invite_student" do
    invitation_token = "token"

    email_subject = "Workshop Invitation #{humanize_date_with_time(session.date_and_time, session.time)}"
    SessionInvitationMailer.invite_student(session, member, invitation).deliver

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(chapter.email)
    expect(email.body.encoded).to match("cc=hello@codebar.io")
  end

  it "#attending_reminder" do
    email_subject = "Workshop Reminder #{humanize_date_with_time(session.date_and_time, session.time)}"
    SessionInvitationMailer.attending_reminder(session, member, invitation).deliver

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(chapter.email)
    expect(email.body.encoded).to match("cc=hello@codebar.io")
  end

end
