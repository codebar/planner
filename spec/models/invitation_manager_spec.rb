require 'spec_helper'

describe InvitationManager do
  subject(:manager) { InvitationManager.new }

  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { Fabricate(:workshop, chapter: chapter) }
  let(:students) { Fabricate.times(3, :member) }
  let(:coaches) { Fabricate.times(6, :member) }

  describe '#send_workshop_emails' do

    it 'creates an invitation for each student' do
      student_group = Fabricate(:students, chapter: chapter, members: students)

      students.each do |student|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: student, role: 'Student').and_call_original
        expect(WorkshopInvitationMailer).to receive(:invite_student).and_call_original
      end

      manager.send_workshop_emails(workshop, 'students')
    end

    it 'creates an invitation for each coach' do
      coach_group = Fabricate(:coaches, chapter: chapter, members: coaches)

      coaches.each do |coach|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
        expect(WorkshopInvitationMailer).to receive(:invite_coach).and_call_original
      end

      manager.send_workshop_emails(workshop, 'coaches')
    end

    it 'does not invite banned coaches' do
      banned_coach = Fabricate(:banned_member)
      coach_group = Fabricate(:coaches, chapter: chapter, members: coaches + [banned_coach])

      manager.send_workshop_emails(workshop, 'everyone')

      coaches.each do |coach|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
      end
      expect(WorkshopInvitation).to_not receive(:create).with(workshop: workshop, member: banned_coach, role: 'Coach')
      manager.send_workshop_emails(workshop, 'coaches')
    end

    it 'sends emails when a WorkshopInvitation is created' do
      student_group = Fabricate(:students, chapter: chapter, members: students)
      coach_group = Fabricate(:coaches, chapter: chapter, members: coaches)

      expect {
        manager.send_workshop_emails(workshop, 'everyone')
      }.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)
    end

    it "does not send emails when no invitation is created" do
      student_group = Fabricate(:students, chapter: chapter, members: students)

      students.count.times { expect(WorkshopInvitation).to receive(:create).and_return(WorkshopInvitation.new) }

      expect {
        manager.send_workshop_emails(workshop, 'students')
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  it '#send_course_emails' do
    course = Fabricate(:course, chapter: chapter)
    invitation = Fabricate(:course_invitation)
    student_group = Fabricate(:students, chapter: chapter, members: students)

    students.each do |student|
      expect(CourseInvitation).to receive(:new).with(course: course, member: student).and_return(invitation)
    end

    manager.send_course_emails(course)
  end

  context '#send_event_emails' do
    let!(:student_group) { Fabricate(:students, chapter: chapter, members: students) }
    let!(:coaches_group) { Fabricate(:coaches, chapter: chapter, members: coaches) }

    it 'can email only students' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Students')
      students.each do |student|
        expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Student').and_call_original
      end

      coaches.each do |student|
        expect(Invitation).to_not receive(:new).with(event: event, member: student, role: 'Coach').and_call_original
      end

      manager.send_event_emails(event, chapter)
    end

    it 'can email only coaches' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Coaches')

      students.each do |student|
        expect(Invitation).to_not receive(:new).with(event: event, member: student, role: 'Student').and_call_original
      end

      coaches.each do |student|
        expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Coach').and_call_original
      end

      manager.send_event_emails(event, chapter)
    end

    it 'can email both students and coaches' do
      event = Fabricate(:event, chapters: [chapter])

      students.each do |student|
        expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Student').and_call_original
      end

      coaches.each do |student|
        expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Coach').and_call_original
      end

      manager.send_event_emails(event, chapter)
    end
  end

  describe '#send_monthly_attendance_reminder_emails', wip: true do
    it 'emails all attending members' do
      meeting = Fabricate(:meeting)
      attendees = Fabricate.times(4, :attending_meeting_invitation, meeting: meeting).map(&:member)

      attendees.each do |attendee|
        expect(MeetingInvitationMailer).to receive(:attendance_reminder).with(meeting, attendee)
      end

      manager.send_monthly_attendance_reminder_emails(meeting)
    end
  end

  describe '#send_workshop_attendance_reminder_emails' do
    it 'emails all attending members' do
      workshop = Fabricate(:workshop)
      invitations = Fabricate.times(4, :attending_workshop_invitation, workshop: workshop)

      invitations.each do |invitation|
        expect(WorkshopInvitationMailer).to receive(:attending_reminder)
          .with(workshop, invitation.member, invitation)
          .and_call_original
      end

      manager.send_workshop_attendance_reminders(workshop)
      invitations.each { |invitation| expect(invitation.reload.reminded_at).to_not be_nil }
    end
  end

  describe '#send_workshop_waiting_list_reminders', wip: true do
    it 'emails everyone that hasn\'t already been reminded from the workshop\'s waitinglist' do
      workshop = Fabricate(:workshop)
      invitations = Fabricate.times(4, :waitinglist_invitation, workshop: workshop)
      reminded_invitations = Fabricate.times(3, :waitinglist_invitation_reminded, workshop: workshop)

      invitations.each do |invitation|
        expect(WorkshopInvitationMailer).to receive(:waiting_list_reminder)
          .with(workshop, invitation.member, invitation)
          .and_call_original
      end

      reminded_invitations.each do |invitation|
        expect(WorkshopInvitationMailer).to_not receive(:waiting_list_reminder)
          .with(workshop, invitation.member, invitation)
      end

      manager.send_workshop_waiting_list_reminders(workshop)
      invitations.each { |invitation| expect(invitation.reload.reminded_at).to_not be_nil }
    end
  end

  describe '#send_change_of_details' do
    it 'emails all attending members about workshop details changes' do
      workshop = Fabricate(:workshop)
      sponsor = Fabricate(:sponsor)
      title = 'The workshop venue has changed'
      invitations = Fabricate.times(4, :attending_workshop_invitation, workshop: workshop)

      invitations.each do |invitation|
        expect(WorkshopInvitationMailer).to receive(:change_of_details)
          .with(workshop, sponsor, invitation.member, invitation, title)
          .and_call_original
      end

      manager.send_change_of_details(workshop, title, sponsor)
    end
  end
end
