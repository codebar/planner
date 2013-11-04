require 'spec_helper'

describe InvitationManager do

  let(:students) { 3.times.map { Fabricate(:student) } }

  it "#send_session_emails" do
    session = Fabricate(:sessions)
    Member.should_receive(:students).and_return(students)

    students.each do |student|
      SessionInvitation.should_receive(:create).with(sessions: session, member: student)
    end

    InvitationManager.send_session_emails session
  end

  it "#send_course_emails" do
    course = Fabricate(:course)
    Member.should_receive(:students).and_return(students)

    students.each do |student|
      CourseInvitation.should_receive(:create).with(course: course, member: student)
    end

    InvitationManager.send_course_emails course
  end
end
