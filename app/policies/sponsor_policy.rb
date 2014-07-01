class SponsorPolicy < ApplicationPolicy

  def create?
    Chapter.find_roles(:organiser, user).any?
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
