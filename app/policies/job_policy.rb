class JobPolicy < ApplicationPolicy
  def index?
    user.has_role?(:admin) || Chapter.find_roles(:organiser, user).any?
  end

  def show?
    user.has_role?(:admin) || Chapter.find_roles(:organiser, user).any?
  end

  def approve?
    user.has_role?(:admin) || Chapter.find_roles(:organiser, user).any?
  end

  def all?
    is_admin_or_chapter_organiser?
  end
end
