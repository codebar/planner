class ChapterPolicy < ApplicationPolicy
  def index?
    show?
  end

  def create?
    admin_or_organiser?
  end

  def show?
    admin_or_organiser?
  end

  def edit?
    admin_or_organiser?
  end

  def update?
    admin_or_organiser?
  end

  def members?
    admin_or_organiser?
  end

  private

  def admin_or_organiser?
    user.is_admin? || user.has_role?(:organiser, record) || user.has_role?(:organiser)
  end
end
