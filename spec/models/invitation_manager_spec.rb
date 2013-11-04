require 'spec_helper'

describe InvitationManager do

  let(:students) { 3.times.map { Fabricate(:student) } }
  let(:session) { Fabricate(:sessions) }

  it "#send_session_emails" do
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

  it "#send_session_reminders" do
    Fabricate(:attending_session_invitation, sessions: session)

    SessionInvitation.any_instance.should_receive(:send_reminder)

    InvitationManager.send_session_reminders session
  end
end
