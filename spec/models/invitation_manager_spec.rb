require 'spec_helper'

describe InvitationManager do

  let(:chapter) { Fabricate(:chapter) }
  let(:students) { Fabricate(:students, chapter: chapter) }
  let(:coaches) { Fabricate(:coaches, chapter: chapter) }
  let!(:session) { Fabricate(:sessions, chapter: chapter) }

  let(:student) { Fabricate(:student, groups: [ students ]) }

  it "#send_session_emails" do
    chapter.groups.should_receive(:students).and_return([students])
    chapter.groups.should_receive(:coaches).and_return([coaches])

    students.members.each do |student|
      SessionInvitation.should_receive(:create).with(sessions: session, member: student, role: "Student")
    end

    InvitationManager.send_session_emails session
  end

  it "#send_course_emails" do
    course = Fabricate(:course)
    course.chapter.groups.should_receive(:students).and_return([students])

    students.members.each do |student|
      CourseInvitation.should_receive(:create).with(course: course, member: student)
    end

    InvitationManager.send_course_emails course
  end

  it "#send_workshop_attendance_reminders" do
    Fabricate(:attending_session_invitation, sessions: session)

    SessionInvitationMailer.any_instance.should_receive(:reminder)

    InvitationManager.send_workshop_attendance_reminders(session)
  end

end
