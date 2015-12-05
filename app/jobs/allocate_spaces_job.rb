class AllocateSpacesJob < ActiveJob::Base
  queue_as :default

  def self.perform_when_needed(workshop)
    logger.info "Scheduling allocation of #{workshop.date_and_time} " \
                "workshop at #{workshop.random_allocate_at}"
    AllocateSpacesJob.set(
      wait_until: workshop.random_allocate_at).perform_later(workshop)
  end

  def perform(workshop)
    if workshop.random_allocate_at.nil?
      return
    end

    if not workshop.random_allocate_at.past?
      AllocateSpacesJob.perform_when_needed(workshop)
      return
    end

    logger.info "Performing space allocation for #{workshop.date_and_time}"

    @workshop = WorkshopPresenter.new(workshop)

    workshop.transaction do
      while @workshop.student_spaces?
        assign_space(workshop, 'Student') or break
      end

      while @workshop.coach_spaces?
        assign_space(workshop, 'Coach') or break
      end
    end
  end

  private

  def assign_space(workshop, role)
    waiting = WaitingList.waiting_for(workshop, role)
    winner = waiting.sample or return false

    invitation = winner.invitation
    winner.destroy!
    invitation.update!({attending: true})
    SessionInvitationMailer.attending(
      invitation.sessions, invitation.member, invitation, true).deliver
    return true
  end

end
