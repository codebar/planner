class ChapterPolicy < ApplicationPolicy
  def index?
    show?
  end

  def create?
    is_admin_or_organiser?
  end

  def show?
    is_admin_or_organiser?
  end

  def edit?
  	 is_admin_or_organiser?
  end

  def update?
  	 is_admin_or_organiser?
  end

  def members?
    is_admin_or_organiser?
  end

  private

  def is_admin_or_organiser?
  	 user.is_admin? || user.has_role?(:organiser, record) || user.has_role?(:organiser)
  end
end
