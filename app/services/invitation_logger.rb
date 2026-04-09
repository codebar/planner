class InvitationLogger
  def initialize(loggable, initiator, audience, action)
    @loggable = loggable
    @initiator = initiator
    @audience = audience
    @action = action
    @log = nil
  end

  def start_batch
    @log = InvitationLog.create!(
      loggable: @loggable,
      initiator: @initiator,
      chapter_id: @loggable.try(:chapter_id),
      audience: @audience,
      action: @action,
      started_at: Time.current,
      status: :running
    )
  end

  def log_success(member, invitation = nil)
    return unless @log

    entry = find_or_build_entry(member, invitation, :success)
    return entry if entry.persisted?

    entry.assign_attributes(processed_at: Time.current)
    save_entry(entry, :success_count)
  end

  def log_failure(member, invitation, error)
    return unless @log

    entry = find_or_build_entry(member, invitation, :failed)
    return entry if entry.persisted?

    entry.assign_attributes(
      failure_reason: error.message,
      processed_at: Time.current
    )
    save_entry(entry, :failure_count)
  end

  def log_skipped(member, invitation, reason)
    return unless @log

    entry = find_or_build_entry(member, invitation, :skipped)
    return entry if entry.persisted?

    entry.assign_attributes(
      failure_reason: reason,
      processed_at: Time.current
    )
    save_entry(entry, :skipped_count)
  end

  def finish_batch(total_invitees)
    return unless @log

    @log.update!(
      total_invitees: total_invitees,
      completed_at: Time.current,
      status: :completed
    )
  end

  def fail_batch(error)
    return unless @log

    @log.update!(
      status: :failed,
      error_message: error.message,
      completed_at: Time.current
    )
  end

  private

  def find_or_build_entry(member, invitation, status)
    @log.entries.find_or_initialize_by(
      member: member,
      invitation: invitation,
      status: status
    )
  end

  def save_entry(entry, counter)
    entry.save!
    @log.increment!(counter)
    entry
  end

  attr_reader :log
end
