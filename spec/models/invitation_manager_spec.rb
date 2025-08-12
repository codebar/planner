RSpec.describe InvitationManager do
  subject(:manager) { InvitationManager.new }

  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { Fabricate(:workshop, chapter: chapter) }
  let(:students) { Fabricate.times(3, :member) }
  let(:coaches) { Fabricate.times(6, :member) }

  describe '#send_workshop_emails' do
    let(:mailer) { WorkshopInvitationMailer }
    let(:send_email) { 'send_workshop_emails' }

    include_examples 'sending workshop emails'
  end

  describe '#send_virtual_workshop_emails' do
    let(:mailer) { VirtualWorkshopInvitationMailer }
    let(:send_email) { 'send_virtual_workshop_emails' }

    include_examples 'sending workshop emails'
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

    it 'emails only students that accepted toc' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Students')

      first_student, *other_students = students
      first_student.update(accepted_toc_at: nil)

      expect(Invitation).to_not(
        receive(:new).
        with(event: event, member: first_student, role: 'Student').
        and_call_original
      )

      other_students.each do |other_student|
        expect(Invitation).to(
          receive(:new).
          with(event: event, member: other_student, role: 'Student').
          and_call_original
        )
      end

      manager.send_event_emails(event, chapter)
    end

    it 'emails only coaches that accepted toc' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Coaches')

      first_coach, *other_coaches = coaches
      first_coach.update(accepted_toc_at: nil)

      expect(Invitation).to_not(
        receive(:new).
        with(event: event, member: first_coach, role: 'Coach').
        and_call_original
      )

      other_coaches.each do |other_coach|
        expect(Invitation).to(
          receive(:new).
          with(event: event, member: other_coach, role: 'Coach').
          and_call_original
        )
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

  describe '#send_waiting_list_emails' do
    it 'emails coaches when there are free coach spots' do
      waitinglist_invitation = Fabricate(:waitinglist_invitation, workshop: workshop, role: 'Coach')

      expect(WorkshopInvitationMailer).to receive(:notify_waiting_list).once
                                                                       .with(waitinglist_invitation)
                                                                       .and_call_original

      manager.send_waiting_list_emails(workshop)
    end

    it 'does not email coaches when no coach spots are available' do
      workshop = Fabricate(:workshop, coach_count: 0)
      waitinglist_invitation = Fabricate(:waitinglist_invitation, workshop: workshop, role: 'Coach')

      expect(WorkshopInvitationMailer).not_to receive(:notify_waiting_list)
        .with(waitinglist_invitation)
        .and_call_original

      manager.send_waiting_list_emails(workshop)
    end

    it 'emails students when there are free student spots' do
      waitinglist_invitation = Fabricate(:waitinglist_invitation, workshop: workshop, role: 'Student')

      expect(WorkshopInvitationMailer).to receive(:notify_waiting_list).once
                                                                       .with(waitinglist_invitation)
                                                                       .and_call_original

      manager.send_waiting_list_emails(workshop)
    end

    it 'does not email students when no student spots are available' do
      workshop = Fabricate(:workshop, student_count: 0)
      waitinglist_invitation = Fabricate(:waitinglist_invitation, workshop: workshop, role: 'Student')

      expect(WorkshopInvitationMailer).not_to receive(:notify_waiting_list)
        .with(waitinglist_invitation)
        .and_call_original

      manager.send_waiting_list_emails(workshop)
    end
  end

  describe '#send_meeting_emails' do
    it 'emails all invitees that are not banned' do
      meeting = Fabricate(:meeting, chapters: [chapter])
      Fabricate(:students, chapter: chapter, members: students)

      # Ban one member
      Fabricate(:ban, member: students.last)
      expected_student_count = students.count - 1

      expect(MeetingInvitationMailer).to receive(:invite)
        .exactly(expected_student_count).times
        .with(meeting, instance_of(Member), instance_of(MeetingInvitation))
        .and_call_original

      manager.send_meeting_emails(meeting)
    end

    it 'emails valid invitees only once' do
      meeting = Fabricate(:meeting, chapters: [chapter])
      Fabricate(:students, chapter: chapter, members: students)

      # Emulate a member already invited
      MeetingInvitation.create(meeting: meeting, member: students.last, role: 'Participant')
      expected_student_count = students.count - 1

      expect(MeetingInvitationMailer).to receive(:invite)
        .exactly(expected_student_count).times
        .with(meeting, instance_of(Member), instance_of(MeetingInvitation))
        .and_call_original

      manager.send_meeting_emails(meeting)
    end
  end
end
