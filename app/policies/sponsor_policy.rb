class SponsorPolicy < ApplicationPolicy

  def create?
    user.is_admin? or user.is_organiser?
  end

  def show?
    user.is_organiser? or user.is_admin?
  end

  def edit?
    user.is_organiser? or user.is_admin?
  end

  def update?
    user.is_organiser? or user.is_admin?
  end
end
