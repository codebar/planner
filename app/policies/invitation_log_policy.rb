class InvitationLogPolicy < ApplicationPolicy
  def index?
    admin_or_chapter_organiser?
  end

  def show?
    admin_or_chapter_organiser?
  end
end
