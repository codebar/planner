require "spec_helper"

describe InvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }

  it "#invite" do
    member = Fabricate(:member)
    sessions = Fabricate(:sessions)
    invitation_token = "token"

    email_subject = "HTML & CSS by Codebar - Wednesday Oct 30th, 18:30"
    InvitationMailer.invite(sessions, member, invitation_token).deliver

    expect(email.subject).to eq(email_subject)
  end
end
