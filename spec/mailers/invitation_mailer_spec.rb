require "spec_helper"

describe InvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }

  it "#invite" do
    member = Fabricate(:member)
    sessions = Fabricate(:sessions)
    invitation_token = "token"

    email_subject = "Post Rails Workshop sessions / HTML by Codebar - Wednesday Oct 23rd, 18:30"
    InvitationMailer.invite(sessions, member, invitation_token).deliver

    expect(email.subject).to eq(email_subject)
  end
end
