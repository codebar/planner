class SponsorPolicy < ApplicationPolicy
  def create?
    user.has_role?(:admin) or Chapter.find_roles(:organiser, user).any?
  end

  def show?
    Chapter.find_roles(:organiser, user).any?
  end

  def edit?
    Chapter.find_roles(:organiser, user).any?
  end

  def update?
    Chapter.find_roles(:organiser, user).any?
  end
end
