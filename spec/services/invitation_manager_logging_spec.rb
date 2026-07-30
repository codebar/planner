RSpec.describe InvitationManager, :invitation_logging do
  subject(:manager) { described_class.new }

  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { Fabricate(:workshop, chapter: chapter) }
  let(:initiator) { Fabricate(:member) }
  let(:students) { Fabricate.times(2, :member) }
  let(:coaches) { Fabricate.times(2, :member) }

  before do
    Fabricate(:students, chapter: chapter, members: students)
    Fabricate(:coaches, chapter: chapter, members: coaches)
  end

  describe '#send_workshop_emails with logging' do
    it 'creates an InvitationLog when initiator_id is provided' do
      expect do
        manager.send_workshop_emails(workshop, 'students', initiator.id)
      end.to change(InvitationLog, :count).by(1)

      log = InvitationLog.last
      expect(log.loggable).to eq workshop
      expect(log.initiator).to eq initiator
      expect(log.audience).to eq 'students'
      expect(log.action).to eq 'invite'
      expect(log.status).to eq 'completed'
    end

    it 'logs successful email sends' do
      manager.send_workshop_emails(workshop, 'students', initiator.id)

      log = InvitationLog.last
      expect(log.success_count).to eq students.count
      expect(log.failure_count).to eq 0
    end

    it 'logs failed email sends' do
      allow(WorkshopInvitationMailer).to receive(:invite_student).and_raise(StandardError.new('SMTP error'))

      manager.send_workshop_emails(workshop, 'students', initiator.id)

      log = InvitationLog.last
      expect(log.failure_count).to eq students.count
      expect(log.success_count).to eq 0
    end

    it 'does not create log when initiator_id is nil' do
      expect do
        manager.send_workshop_emails(workshop, 'students', nil)
      end.not_to change(InvitationLog, :count)
    end

    it 'prevents duplicate concurrent batches when start_batch is called' do
      Fabricate(:invitation_log, loggable: workshop, audience: 'students', action: 'invite',
                                 status: :running, chapter_id: workshop.chapter_id)

      logger = InvitationLogger.new(workshop, initiator, 'students', :invite,
                                    chapter_id: workshop.chapter_id)
      expect { logger.start_batch }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'sets chapter_id on log' do
      manager.send_workshop_emails(workshop, 'students', initiator.id)

      log = InvitationLog.last
      expect(log.chapter_id).to eq workshop.chapter_id
    end

    it 'sets total_invitees count correctly' do
      manager.send_workshop_emails(workshop, 'students', initiator.id)

      log = InvitationLog.last
      expect(log.total_invitees).to eq students.count
    end

    it 'logs batch as failed when exception occurs' do
      allow(WorkshopInvitationMailer).to receive(:invite_student).and_raise(StandardError.new('SMTP error'))

      manager.send_workshop_emails(workshop, 'students', initiator.id)

      log = InvitationLog.last
      expect(log.status).to eq 'completed'
      expect(log.error_message).to be_nil
    end

    it 'returns early and sends no emails when a batch is already running' do
      Fabricate(:invitation_log, loggable: workshop, audience: 'students', action: 'invite',
                                 status: :running, chapter_id: workshop.chapter_id)

      allow(WorkshopInvitationMailer).to receive(:invite_student).and_call_original
      result = manager.send_workshop_emails_without_delay(workshop, 'students', initiator.id)

      expect(result).to eq 'A batch is already running for this loggable and audience'
      expect(WorkshopInvitationMailer).not_to have_received(:invite_student)
      expect(InvitationLog.count).to eq 1
    end
  end

  describe '#send_virtual_workshop_emails with logging' do
    let(:workshop) { Fabricate(:virtual_workshop, chapter: chapter) }

    it 'creates an InvitationLog when initiator_id is provided' do
      expect do
        manager.send_virtual_workshop_emails(workshop, 'students', initiator.id)
      end.to change(InvitationLog, :count).by(1)
    end

    it 'logs successful email sends' do
      manager.send_virtual_workshop_emails(workshop, 'students', initiator.id)

      log = InvitationLog.last
      expect(log.success_count).to eq students.count
    end

    it 'returns early and sends no emails when a batch is already running' do
      Fabricate(:invitation_log, loggable: workshop, audience: 'students', action: 'invite',
                                 status: :running, chapter_id: workshop.chapter_id)

      allow(VirtualWorkshopInvitationMailer).to receive(:invite_student).and_call_original
      result = manager.send_virtual_workshop_emails_without_delay(workshop, 'students', initiator.id)

      expect(result).to eq 'A batch is already running for this loggable and audience'
      expect(VirtualWorkshopInvitationMailer).not_to have_received(:invite_student)
      expect(InvitationLog.count).to eq 1
    end
  end

  describe '#send_event_emails with logging' do
    let(:event) { Fabricate(:event, chapters: [chapter]) }

    it 'creates an InvitationLog with the chapter and initiator' do
      expect do
        manager.send_event_emails(event, chapter, initiator.id)
      end.to change(InvitationLog, :count).by(1)

      log = InvitationLog.last
      expect(log.loggable).to eq event
      expect(log.initiator).to eq initiator
      expect(log.chapter_id).to eq chapter.id
      expect(log.audience).to eq 'everyone'
      expect(log.status).to eq 'completed'
    end

    it 'logs successful email sends' do
      manager.send_event_emails(event, chapter, initiator.id)

      log = InvitationLog.last
      expect(log.success_count).to eq(students.count + coaches.count)
      expect(log.failure_count).to eq 0
    end

    it 'returns early and sends no emails when a batch is already running' do
      Fabricate(:invitation_log, loggable: event, audience: 'everyone', action: 'invite',
                                 status: :running, chapter_id: chapter.id)

      allow(EventInvitationMailer).to receive(:invite_student).and_call_original
      result = manager.send_event_emails_without_delay(event, chapter, initiator.id)

      expect(result).to eq 'A batch is already running for this loggable and audience'
      expect(EventInvitationMailer).not_to have_received(:invite_student)
      expect(InvitationLog.count).to eq 1
    end

    it 'logs skipped members on a second run without resending emails' do
      manager.send_event_emails(event, chapter, initiator.id)

      allow(EventInvitationMailer).to receive(:invite_student).and_call_original
      manager.send_event_emails(event, chapter, initiator.id)

      expect(EventInvitationMailer).not_to have_received(:invite_student)
      log = InvitationLog.last
      expect(log.skipped_count).to eq(students.count + coaches.count)
      expect(log.success_count).to eq 0
    end
  end
end
