require 'spec_helper'

describe Invitation do
  let(:member) { Fabricate(:member) }
  let(:session) { Fabricate(:sessions) }

  it "sends an email to the member" do
    mailer = double(InvitationMailer)
    InvitationMailer.should_receive(:invite).with(session, member, "token").and_return(mailer)
    mailer.should_receive(:deliver)

    Fabricate(:invitation, member: member, sessions: session)
  end

end
