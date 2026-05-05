RSpec.describe InvitationManager do
  subject(:manager) { InvitationManager.new }

  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { Fabricate(:workshop, chapter: chapter) }
  let(:students) { Fabricate.times(2, :member) }
  let(:coaches) { Fabricate.times(2, :member) }

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

  describe '#send_event_emails' do
    let!(:student_group) { Fabricate(:students, chapter: chapter, members: students) }
    let!(:coaches_group) { Fabricate(:coaches, chapter: chapter, members: coaches) }

    it 'can email only students' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Students')
      students.each do |student|
        expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Student').and_call_original
      end

      coaches.each do |student|
        expect(Invitation).not_to receive(:new).with(event: event, member: student, role: 'Coach').and_call_original
      end

      manager.send_event_emails(event, chapter)
    end

    it 'can email only coaches' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Coaches')

      students.each do |student|
        expect(Invitation).not_to receive(:new).with(event: event, member: student, role: 'Student').and_call_original
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

      expect(Invitation).not_to(
        receive(:new)
        .with(event: event, member: first_student, role: 'Student')
        .and_call_original
      )

      other_students.each do |other_student|
        expect(Invitation).to(
          receive(:new)
          .with(event: event, member: other_student, role: 'Student')
          .and_call_original
        )
      end

      manager.send_event_emails(event, chapter)
    end

    it 'emails only coaches that accepted toc' do
      event = Fabricate(:event, chapters: [chapter], audience: 'Coaches')

      first_coach, *other_coaches = coaches
      first_coach.update(accepted_toc_at: nil)

      expect(Invitation).not_to(
        receive(:new)
        .with(event: event, member: first_coach, role: 'Coach')
        .and_call_original
      )

      other_coaches.each do |other_coach|
        expect(Invitation).to(
          receive(:new)
          .with(event: event, member: other_coach, role: 'Coach')
          .and_call_original
        )
      end

      manager.send_event_emails(event, chapter)
    end
  end

  describe '#send_monthly_attendance_reminder_emails', :wip do
    it 'emails all attending members' do
      meeting = Fabricate(:meeting)
      attendees = Fabricate.times(2, :attending_meeting_invitation, meeting: meeting).map(&:member)

      attendees.each do |attendee|
        expect(MeetingInvitationMailer).to receive(:attendance_reminder).with(meeting, attendee)
      end

      manager.send_monthly_attendance_reminder_emails(meeting)
    end
  end

  describe '#send_workshop_attendance_reminder_emails' do
    it 'emails all attending members' do
      workshop = Fabricate(:workshop)
      invitations = Fabricate.times(2, :attending_workshop_invitation, workshop: workshop)

      invitations.each do |invitation|
        expect(WorkshopInvitationMailer).to receive(:attending_reminder)
          .with(workshop, invitation.member, invitation)
          .and_call_original
      end

      manager.send_workshop_attendance_reminders(workshop)
      invitations.each { |invitation| expect(invitation.reload.reminded_at).not_to be_nil }
    end
  end

  describe '#send_workshop_waiting_list_reminders', :wip do
    it 'emails everyone that hasn\'t already been reminded from the workshop\'s waitinglist' do
      workshop = Fabricate(:workshop)
      invitations = Fabricate.times(2, :waitinglist_invitation, workshop: workshop)
      reminded_invitations = Fabricate.times(2, :waitinglist_invitation_reminded, workshop: workshop)

      invitations.each do |invitation|
        expect(WorkshopInvitationMailer).to receive(:waiting_list_reminder)
          .with(workshop, invitation.member, invitation)
          .and_call_original
      end

      reminded_invitations.each do |invitation|
        expect(WorkshopInvitationMailer).not_to receive(:waiting_list_reminder)
          .with(workshop, invitation.member, invitation)
      end

      manager.send_workshop_waiting_list_reminders(workshop)
      invitations.each { |invitation| expect(invitation.reload.reminded_at).not_to be_nil }
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

  describe '#create_invitation' do
    let(:member) { Fabricate(:member) }

    it 'creates a new invitation and returns it with previously_new_record? as true' do
      invitation = manager.send(:create_invitation, workshop, member, 'Student')

      expect(invitation).to be_a(WorkshopInvitation)
      expect(invitation).to be_persisted
      expect(invitation.previously_new_record?).to be true
      expect(invitation.workshop).to eq(workshop)
      expect(invitation.member).to eq(member)
      expect(invitation.role).to eq('Student')
    end

    it 'returns existing invitation with previously_new_record? as false on duplicate call' do
      # First call creates the invitation
      invitation1 = manager.send(:create_invitation, workshop, member, 'Student')
      expect(invitation1.previously_new_record?).to be true

      # Second call finds the existing invitation
      invitation2 = manager.send(:create_invitation, workshop, member, 'Student')
      expect(invitation2.previously_new_record?).to be false
      expect(invitation2.id).to eq(invitation1.id)
    end

    it 'does not create duplicate records in database' do
      expect do
        # Multiple calls should not create duplicates
        3.times { manager.send(:create_invitation, workshop, member, 'Student') }
      end.to change(WorkshopInvitation, :count).by(1)
    end
  end

  describe '#create_invitation resilience' do
    let(:member) { Fabricate(:member) }

    it 'returns nil when find_or_initialize_by raises an exception' do
      allow(WorkshopInvitation).to receive(:find_or_initialize_by)
        .and_raise(StandardError.new('database error'))

      result = manager.send(:create_invitation, workshop, member, 'Student')

      expect(result).to be_nil
    end

    it 'logs error with member_id and workshop_id but no PII' do
      allow(WorkshopInvitation).to receive(:find_or_initialize_by)
        .and_raise(StandardError.new('database error'))

      expect(Rails.logger).to receive(:error) do |message|
        expect(message).to include("member_id=#{member.id}")
        expect(message).to include("workshop_id=#{workshop.id}")
        expect(message).to include('role=Student')
        expect(message).not_to include(member.email)
        expect(message).not_to include(member.name)
      end

      manager.send(:create_invitation, workshop, member, 'Student')
    end

    it 'continues processing when invitation creation fails for one member' do
      Fabricate(:students, chapter: chapter, members: students)
      call_count = 0

      allow(WorkshopInvitation).to receive(:find_or_initialize_by) do
        call_count += 1
        if call_count == 1
          raise StandardError.new('database error')
        end

        WorkshopInvitation.new(persisted?: true)
      end

      expect do
        manager.send_workshop_emails(workshop, 'students')
      end.not_to raise_error
    end
  end

  describe 'duplicate invitation prevention' do
    let(:initiator) { Fabricate(:member) }

    before do
      Fabricate(:students, chapter: chapter, members: students)
    end

    it 'logs skipped entries for already invited members when re-running batch' do
      # First invitation round
      manager.send_workshop_emails(workshop, 'students', initiator.id)

      # Get the first log
      first_log = InvitationLog.where(loggable: workshop, audience: 'students').order(:created_at).first
      expect(first_log.success_count).to eq(students.count)
      expect(first_log.skipped_count).to eq(0)

      # Second invitation round
      manager.send_workshop_emails(workshop, 'students', initiator.id)

      # Get the second log
      second_log = InvitationLog.where(loggable: workshop, audience: 'students').order(:created_at).last
      expect(second_log.success_count).to eq(0)
      expect(second_log.skipped_count).to eq(students.count)
    end

    it 'only sends emails to newly eligible members when batch is re-run' do
      # First invitation round
      manager.send_workshop_emails(workshop, 'students', initiator.id)
      ActionMailer::Base.deliveries.clear

      # Add a new student
      new_student = Fabricate(:member)
      Fabricate(:students, chapter: chapter, members: [new_student])

      # Second invitation round - should only email the new student
      expect do
        manager.send_workshop_emails(workshop, 'students', initiator.id)
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      log = InvitationLog.where(loggable: workshop, audience: 'students').order(:created_at).last
      expect(log.success_count).to eq(1)
      expect(log.skipped_count).to eq(students.count)
    end
  end

  describe '#send_workshop_emails async behavior' do
    let!(:chapter) { Fabricate(:chapter, id: 1) }

    context 'when chapter is in ASYNC_EMAIL_CHAPTER_IDS' do
      before { Rails.application.config.async_email_chapter_ids = [1] }

      it 'sends invitation emails' do
        Fabricate(:students, chapter: chapter, members: students)
        Fabricate(:coaches, chapter: chapter, members: coaches)

        expect(WorkshopInvitationMailer).to receive(:invite_student).at_least(:once).and_call_original
        expect(WorkshopInvitationMailer).to receive(:invite_coach).at_least(:once).and_call_original

        manager.send_workshop_emails(workshop, 'everyone')
      end
    end

    context 'when chapter is NOT in ASYNC_EMAIL_CHAPTER_IDS' do
      before { Rails.application.config.async_email_chapter_ids = [99] }

      it 'sends emails synchronously' do
        Fabricate(:students, chapter: chapter, members: students)
        Fabricate(:coaches, chapter: chapter, members: coaches)

        expect do
          manager.send_workshop_emails(workshop, 'everyone')
        end.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)

        expect(Delayed::Job.count).to eq(0)
      end
    end

    context 'when ASYNC_EMAIL_CHAPTER_IDS is empty' do
      before { Rails.application.config.async_email_chapter_ids = [] }

      it 'sends emails synchronously' do
        Fabricate(:students, chapter: chapter, members: students)
        Fabricate(:coaches, chapter: chapter, members: coaches)

        expect do
          manager.send_workshop_emails(workshop, 'everyone')
        end.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)

        expect(Delayed::Job.count).to eq(0)
      end
    end
  end

  describe '#send_workshop_attendance_reminders async behavior' do
    let!(:chapter) { Fabricate(:chapter, id: 1) }

    context 'when chapter is in ASYNC_EMAIL_CHAPTER_IDS' do
      before { Rails.application.config.async_email_chapter_ids = [1] }

      it 'sends attendance reminder emails' do
        invitation = Fabricate(:attending_workshop_invitation, workshop: workshop)

        expect(WorkshopInvitationMailer).to receive(:attending_reminder).at_least(:once).and_call_original

        manager.send_workshop_attendance_reminders(workshop)
      end
    end

    context 'when chapter is NOT in ASYNC_EMAIL_CHAPTER_IDS' do
      before { Rails.application.config.async_email_chapter_ids = [99] }

      it 'uses deliver_now' do
        invitation = Fabricate(:attending_workshop_invitation, workshop: workshop)

        expect do
          manager.send_workshop_attendance_reminders(workshop)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
