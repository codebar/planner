class OrganiserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
    admin?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    user.is_admin?
  end
end
