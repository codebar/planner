class VirtualWorkshopPresenter < WorkshopPresenter
  def title
    I18n.t('workshops.virtual.title', chapter: chapter.name)
  end

  delegate :coach_spaces, :student_spaces, to: :model

  def student_spaces?
    student_spaces > attending_students.length
  end

  def coach_spaces?
    coach_spaces > attending_coaches.length
  end

  def spaces?
    virtual_workshop_spaces?
  end

  def send_attending_email(invitation, waitinglist = false)
    VirtualWorkshopInvitationMailer.attending(model, invitation.member, invitation, waitinglist).deliver_now
  end

  private

  def virtual_workshop_spaces?
    coach_spaces? || student_spaces?
  end
end
