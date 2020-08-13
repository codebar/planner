class ContactPolicy < ApplicationPolicy
  def index?
    admin?
  end

  private

  def admin?
    return false unless user

    user.is_admin?
  end
end
