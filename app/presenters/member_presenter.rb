class MemberPresenter < BasePresenter
  def organiser?
    has_role? :organiser, :any
  end

  def event_organiser?(event)
    has_role?(:organiser, event) || has_role?(:organiser, event.chapter) || has_role?(:admin)
  end

  def newbie?
    !workshop_invitations.attended.exists?
  end

  def attending?(event)
    event.invitations.accepted.where(member: model).exists?
  end

  def subscribed_to_newsletter?
    opt_in_newsletter_at.present?
  end

  def pairing_details_array(role, note)
    role.eql?('Coach') ? coach_pairing_details : student_pairing_details(note)
  end

  private

  def coach_pairing_details
    [newbie?, full_name, 'Coach', 'N/A', skill_list.to_s]
  end

  def student_pairing_details(note)
    [newbie?, full_name, 'Student', note, 'N/A']
  end
end
