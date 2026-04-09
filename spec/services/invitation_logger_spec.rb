require 'rails_helper'

RSpec.describe InvitationLogger do
  let(:workshop) { Fabricate(:workshop) }
  let(:initiator) { Fabricate(:member) }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }

  describe '#start_batch' do
    it 'creates an InvitationLog record' do
      logger = described_class.new(workshop, initiator, 'students', :invite)
      log = logger.start_batch

      expect(log).to be_persisted
      expect(log.loggable).to eq workshop
      expect(log.initiator).to eq initiator
      expect(log.audience).to eq 'students'
      expect(log.action).to eq 'invite'
      expect(log.status).to eq 'running'
    end

    it 'raises error if a running batch already exists' do
      Fabricate(:invitation_log, loggable: workshop, audience: 'students', action: 'invite', status: :running)
      logger = described_class.new(workshop, initiator, 'students', :invite)

      expect { logger.start_batch }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'sets chapter_id from loggable' do
      logger = described_class.new(workshop, initiator, 'students', :invite)
      log = logger.start_batch

      expect(log.chapter_id).to eq workshop.chapter_id
    end
  end

  describe '#log_success' do
    let(:logger) { described_class.new(workshop, initiator, 'students', :invite) }
    let!(:log) { logger.start_batch }

    it 'creates entry with success status and increments count' do
      entry = logger.log_success(member, invitation)

      expect(entry.status).to eq 'success'
      expect(entry.member).to eq member
      expect(entry.invitation).to eq invitation
      expect(log.reload.success_count).to eq 1
    end

    it 'does not create duplicate entry on retry' do
      entry1 = logger.log_success(member, invitation)
      entry2 = logger.log_success(member, invitation)

      expect(entry2).to eq entry1
      expect(log.reload.success_count).to eq 1
    end
  end

  describe '#log_failure' do
    let(:logger) { described_class.new(workshop, initiator, 'students', :invite) }
    let!(:log) { logger.start_batch }

    it 'creates entry with failure status and increments count' do
      error = StandardError.new('SMTP error')
      entry = logger.log_failure(member, invitation, error)

      expect(entry.status).to eq 'failed'
      expect(entry.failure_reason).to eq 'SMTP error'
      expect(log.reload.failure_count).to eq 1
    end

    it 'does not create duplicate entry on retry' do
      error = StandardError.new('SMTP error')
      entry1 = logger.log_failure(member, invitation, error)
      entry2 = logger.log_failure(member, invitation, error)

      expect(entry2).to eq entry1
      expect(log.reload.failure_count).to eq 1
    end
  end

  describe '#log_skipped' do
    let(:logger) { described_class.new(workshop, initiator, 'students', :invite) }
    let!(:log) { logger.start_batch }

    it 'creates entry with skipped status and increments count' do
      entry = logger.log_skipped(member, invitation, 'Already invited')

      expect(entry.status).to eq 'skipped'
      expect(entry.failure_reason).to eq 'Already invited'
      expect(log.reload.skipped_count).to eq 1
    end

    it 'does not create duplicate entry on retry' do
      entry1 = logger.log_skipped(member, invitation, 'Already invited')
      entry2 = logger.log_skipped(member, invitation, 'Already invited')

      expect(entry2).to eq entry1
      expect(log.reload.skipped_count).to eq 1
    end
  end

  describe '#finish_batch' do
    let(:logger) { described_class.new(workshop, initiator, 'students', :invite) }
    let!(:log) { logger.start_batch }

    it 'updates status to completed with counts' do
      2.times { logger.log_success(Fabricate(:member), Fabricate(:workshop_invitation, workshop: workshop)) }
      logger.log_failure(Fabricate(:member), Fabricate(:workshop_invitation, workshop: workshop), StandardError.new('err'))

      logger.finish_batch(5)

      expect(log.reload.status).to eq 'completed'
      expect(log.total_invitees).to eq 5
      expect(log.completed_at).to be_present
    end
  end

  describe '#fail_batch' do
    let(:logger) { described_class.new(workshop, initiator, 'students', :invite) }
    let!(:log) { logger.start_batch }

    it 'updates status to failed with error message' do
      error = StandardError.new('Something went wrong')
      logger.fail_batch(error)

      expect(log.reload.status).to eq 'failed'
      expect(log.error_message).to eq 'Something went wrong'
      expect(log.completed_at).to be_present
    end
  end
end
