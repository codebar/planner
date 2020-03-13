class VirtualWorkshopPresenter < WorkshopPresenter
  def title
    I18n.t('workshops.virtual.title', chapter: chapter.name)
  end

  def attending_and_available_student_spots
    "#{attending_students.length}/#{student_spaces}"
  end

  def attending_and_available_coach_spots
    "#{attending_coaches.length}/#{coach_spaces}"
  end

  def student_spaces?
    student_spaces > attending_students.length
  end

  def coach_spaces?
    coach_spaces > attending_coaches.length
  end

  def spaces?
    virtual_workshop_spaces?
  end

  def send_attending_email(invitation)
    WorkshopInvitationMailer.attending_virtual(model, invitation.member, invitation).deliver_now
  end

  private

  def virtual_workshop_spaces?
    coach_spaces? || student_spaces?
  end
end
