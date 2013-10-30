require 'spec_helper'

describe Invitation do
  it "has a token set on creation" do
    invitation = Fabricate(:invitation)

    invitation.token.should_not be nil
  end

end
