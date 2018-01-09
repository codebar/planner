require 'spec_helper'

describe CourseInvitation do
  let(:invitation) { Fabricate(:course_invitation) }
  let!(:accepted_invitation) { 2.times { Fabricate(:course_invitation, attending: true) } }

  it_behaves_like InvitationConcerns
end
