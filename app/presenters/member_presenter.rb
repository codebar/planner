class MemberPresenter < SimpleDelegator
  def organiser?
    has_role?(:organiser, :any)
  end

  def newbie?
    session_invitations.attended.exists?
  end

  def attending?(event)
    event.invitations.accepted.where(member: member).exists?
  end

  private

  def model
    __getobj__
  end

end
