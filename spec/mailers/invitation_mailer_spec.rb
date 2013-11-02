require "spec_helper"

describe InvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }

  it "#invite" do
    member = Fabricate(:member)
    sessions = Fabricate(:sessions, title: "HTML & CSS", date_and_time: DateTime.new(2013,10,30,18,30))
    invitation_token = "token"

    email_subject = "HTML & CSS by Codebar - Wednesday, 30 Oct at 18:30"
    InvitationMailer.invite(sessions, member, invitation_token).deliver

    expect(email.subject).to eq(email_subject)
  end
end
