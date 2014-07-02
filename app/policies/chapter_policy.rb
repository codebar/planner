class ChapterPolicy < ApplicationPolicy

  def index?
    show?
  end

  def create?
    user.is_admin?
  end

  def show?
    user.is_admin? or user.has_role?(:organiser, record) or user.has_role?(:organiser)
  end
end
