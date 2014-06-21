class ChapterPolicy < ApplicationPolicy

  def create?
    user.is_admin?
  end

  def show?
    user.is_organiser? or user.is_admin? or user.has_role?(:organiser, record)
  end
end
