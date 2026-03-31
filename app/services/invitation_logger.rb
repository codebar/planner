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

    @log.entries.create!(
      member: member,
      invitation: invitation,
      status: :success,
      processed_at: Time.current
    ).tap { @log.increment!(:success_count) }
  end

  def log_failure(member, invitation, error)
    return unless @log

    @log.entries.create!(
      member: member,
      invitation: invitation,
      status: :failed,
      failure_reason: error.message,
      processed_at: Time.current
    ).tap { @log.increment!(:failure_count) }
  end

  def log_skipped(member, invitation, reason)
    return unless @log

    @log.entries.create!(
      member: member,
      invitation: invitation,
      status: :skipped,
      failure_reason: reason,
      processed_at: Time.current
    ).tap { @log.increment!(:skipped_count) }
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

  attr_reader :log
end
