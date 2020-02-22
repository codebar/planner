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
end
