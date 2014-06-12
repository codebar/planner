class GroupPolicy < ApplicationPolicy

  def create?
    user.is_admin?
  end

  def show?
    user.is_organiser? or user.is_admin?
  end
end
