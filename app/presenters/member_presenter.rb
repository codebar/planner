class MemberPresenter < SimpleDelegator
  def organiser?
    has_role?(:organiser, :any)
  end

  def newbie?
    session_invitations.attended.exists?
  end

end
