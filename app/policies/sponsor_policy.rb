class SponsorPolicy < ApplicationPolicy
  def index?
    is_admin_or_chapter_organiser?
  end

  def create?
    user.has_role?(:admin) || Chapter.find_roles(:organiser, user).any?
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
