class EventPolicy < ApplicationPolicy
  def invite?
    admin_or_organiser?
  end

  def show?
    admin_or_organiser?
  end

  private

  def admin_or_organiser?
    return false unless user

    user.is_admin? || user.has_role?(:organiser, record)
  end
end
