require 'spec_helper'

describe SessionInvitation do
  it "has a token set on creation" do
    invitation = Fabricate(:session_invitation)

    invitation.token.should_not be nil
  end

end
