class EventPolicy < ApplicationPolicy
  def invite?
    is_admin_or_organiser?
  end

  def show?
    is_admin_or_organiser?
  end

  private

  def is_admin_or_organiser?
    return false unless user
    user.is_admin? || user.has_role?(:organiser, record)
  end
end
