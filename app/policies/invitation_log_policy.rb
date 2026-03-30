class InvitationLogPolicy < ApplicationPolicy
  def index?
    is_admin_or_chapter_organiser?
  end

  def show?
    is_admin_or_chapter_organiser?
  end
end
