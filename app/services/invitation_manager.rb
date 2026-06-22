class InvitationManager
  def send_event_emails(event, chapter)
    return 'The event is not invitable' unless event.invitable?

    invite_coaches_to_event(event, chapter) unless event.audience.eql?('Students')
    invite_students_to_event(event, chapter) unless event.audience.eql?('Coaches')
  end
  handle_asynchronously :send_event_emails

  def send_monthly_attendance_reminder_emails(monthly)
    invitees = Member.attending_meeting(monthly)
    invitees.each do |member|
      MeetingInvitationMailer.attendance_reminder(monthly, member).deliver_now
    end
  end
  handle_asynchronously :send_monthly_attendance_reminder_emails

  def send_meeting_emails(meeting)
    meeting.invitees.not_banned.each do |invitee|
      invitation = MeetingInvitation.new(meeting: meeting, member: invitee, role: 'Participant')
      next unless invitation.save

      MeetingInvitationMailer.invite(meeting, invitee, invitation).deliver_now
    rescue StandardError => e
      log_event_meeting_invitation_failure("meeting_id=#{meeting.id}", invitee, e)
    end
  end
  handle_asynchronously :send_meeting_emails

  def send_workshop_attendance_reminders(workshop)
    workshop_mailer = workshop.virtual? ? VirtualWorkshopInvitationMailer : WorkshopInvitationMailer
    workshop.attendances.not_reminded.each do |invitation|
      workshop_mailer.send(:attending_reminder, workshop, invitation.member, invitation).deliver_later
      invitation.update(reminded_at: Time.zone.now)
    end
  end
  handle_asynchronously :send_workshop_attendance_reminders

  def send_workshop_emails(workshop, audience, initiator_id = nil)
    return 'The workshop is not invitable' unless workshop.invitable?

    initiator = initiator_id ? Member.find_by(id: initiator_id) : nil
    logger = initiator ? InvitationLogger.new(workshop, initiator, audience, :invite) : nil

    if logger
      begin
        logger.start_batch
      rescue ActiveRecord::RecordNotUnique
        return 'A batch is already running for this workshop and audience'
      end
    end

    total = 0
    begin
      if audience.in?(%w[students everyone])
        total += invite_students_to_workshop(workshop, logger)
      end
      if audience.in?(%w[coaches everyone])
        total += invite_coaches_to_workshop(workshop, logger)
      end
      logger&.finish_batch(total)
    rescue StandardError => e
      logger&.fail_batch(e)
      raise
    end
  end
  handle_asynchronously :send_workshop_emails

  def send_virtual_workshop_emails(workshop, audience, initiator_id = nil)
    return 'The workshop is not invitable' unless workshop.invitable?

    initiator = initiator_id ? Member.find_by(id: initiator_id) : nil
    logger = initiator ? InvitationLogger.new(workshop, initiator, audience, :invite) : nil

    if logger
      begin
        logger.start_batch
      rescue ActiveRecord::RecordNotUnique
        return 'A batch is already running for this workshop and audience'
      end
    end

    total = 0
    begin
      if audience.in?(%w[students everyone])
        total += invite_students_to_virtual_workshop(workshop, logger)
      end
      if audience.in?(%w[coaches everyone])
        total += invite_coaches_to_virtual_workshop(workshop, logger)
      end
      logger&.finish_batch(total)
    rescue StandardError => e
      logger&.fail_batch(e)
      raise
    end
  end
  handle_asynchronously :send_virtual_workshop_emails

  def send_waiting_list_emails(workshop)
    workshop = WorkshopPresenter.decorate(workshop)

    retrieve_and_notify_waitlisted(workshop, role: 'Coach') if workshop.coach_spaces?
    retrieve_and_notify_waitlisted(workshop, role: 'Student') if workshop.student_spaces?
  end
  handle_asynchronously :send_waiting_list_emails

  def send_workshop_waiting_list_reminders(workshop)
    workshop_mailer = workshop.virtual? ? VirtualWorkshopInvitationMailer : WorkshopInvitationMailer
    workshop.invitations.on_waiting_list.not_reminded.each do |invitation|
      workshop_mailer.send(:waiting_list_reminder, workshop, invitation.member, invitation).deliver_later
      invitation.update(reminded_at: Time.zone.now)
    end
  end
  handle_asynchronously :send_workshop_waiting_list_reminders

  private

  def invite_students_to_event(event, chapter)
    chapter_students(chapter).each do |student|
      invitation = Invitation.new(event: event, member: student, role: 'Student')
      next unless invitation.save

      EventInvitationMailer.invite_student(event, student, invitation).deliver_now
    rescue StandardError => e
      log_event_meeting_invitation_failure("event_id=#{event.id}", student, e)
    end
  end

  def invite_coaches_to_event(event, chapter)
    chapter_coaches(chapter).each do |coach|
      invitation = Invitation.new(event: event, member: coach, role: 'Coach')
      next unless invitation.save

      EventInvitationMailer.invite_coach(event, coach, invitation).deliver_now
    rescue StandardError => e
      log_event_meeting_invitation_failure("event_id=#{event.id}", coach, e)
    end
  end

  def log_event_meeting_invitation_failure(context, member, error)
    Rails.logger.error(
      '[InvitationManager] Failed to create invitation: ' \
      "#{context}, member_id=#{member.id}, " \
      "error=#{error.class.name}: #{error.message}"
    )
  end

  def chapter_students(chapter)
    Member.in_group(chapter.groups.students).distinct
  end

  def chapter_coaches(chapter)
    Member.in_group(chapter.groups.coaches).distinct
  end

  def create_invitation(workshop, member, role)
    invitation = WorkshopInvitation.find_or_initialize_by(workshop: workshop, member: member, role: role)
    invitation.save! if invitation.new_record?
    invitation
  rescue StandardError => e
    log_invitation_failure(workshop, member, role, e)
    nil
  end

  def log_invitation_failure(workshop, member, role, error)
    Rails.logger.error(
      '[InvitationManager] Failed to create invitation: ' \
      "workshop_id=#{workshop.id}, chapter_id=#{workshop.chapter_id}, " \
      "member_id=#{member.id}, role=#{role}, " \
      "error=#{error.class.name}: #{error.message}"
    )
  end

  def invite_coaches_to_virtual_workshop(workshop, logger = nil)
    invite_members(workshop, logger, chapter_coaches(workshop.chapter)) do |coach, invitation|
      VirtualWorkshopInvitationMailer.invite_coach(workshop, coach, invitation).deliver_later
    end
  end

  def invite_coaches_to_workshop(workshop, logger = nil)
    invite_members(workshop, logger, chapter_coaches(workshop.chapter)) do |coach, invitation|
      WorkshopInvitationMailer.invite_coach(workshop, coach, invitation).deliver_later
    end
  end

  def invite_students_to_virtual_workshop(workshop, logger = nil)
    invite_members(workshop, logger, chapter_students(workshop.chapter), 'Student') do |student, invitation|
      VirtualWorkshopInvitationMailer.invite_student(workshop, student, invitation).deliver_later
    end
  end

  def invite_students_to_workshop(workshop, logger = nil)
    invite_members(workshop, logger, chapter_students(workshop.chapter), 'Student') do |member, invitation|
      WorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_later
    end
  end

  def invite_members(workshop, logger, members, role = 'Coach')
    count = 0
    members.shuffle.each do |member|
      invitation = create_invitation(workshop, member, role)
      next unless invitation

      if invitation.previously_new_record?
        count += 1
        send_email_with_logging(logger, member, invitation) do
          yield member, invitation
        end
      else
        logger&.log_skipped(member, invitation, 'Already invited to this workshop')
      end
    end
    count
  end

  def send_email_with_logging(logger, member, invitation)
    if logger
      begin
        yield
        logger.log_success(member, invitation)
      rescue StandardError => e
        logger.log_failure(member, invitation, e)
      end
    else
      yield
    end
  end

  def retrieve_and_notify_waitlisted(workshop, role:)
    WaitingList.by_workshop(workshop).where_role(role).each do |waiting_list|
      WorkshopInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver_later
      waiting_list.destroy
    end
  end
end
