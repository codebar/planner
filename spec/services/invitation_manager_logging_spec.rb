RSpec.describe InvitationManager, :invitation_logging do
  subject(:manager) { InvitationManager.new }

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
      Fabricate(:invitation_log, loggable: workshop, audience: 'students', action: 'invite', status: :running)

      logger = InvitationLogger.new(workshop, initiator, 'students', :invite)
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
  end
end
