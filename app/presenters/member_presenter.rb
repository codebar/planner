class MemberPresenter < SimpleDelegator
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

  private

  def model
    __getobj__
  end
end
