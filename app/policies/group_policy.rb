class GroupPolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def show?
    is_admin_or_chapter_organiser?
  end
end
