class AdminPortalPolicy < ApplicationPolicy
  def index?
    user.has_role?(:admin)
  end
end
