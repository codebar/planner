require 'spec_helper'

describe InvitationManager do

  let(:session) { Fabricate(:sessions) }

  it "#email_students" do
    students = 3.times.map { Fabricate(:student) }

    Member.should_receive(:students).and_return(students)

    students.each do |student|
      SessionInvitation.should_receive(:create).with(sessions: session, member: student)
    end

    InvitationManager.email_students session
  end
end
