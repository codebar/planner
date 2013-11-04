require 'spec_helper'

describe CourseInvitation do
  let(:invitation) { Fabricate(:course_invitation) }

  it "has a token set on creation" do

    invitation.token.should_not be nil
  end
end
