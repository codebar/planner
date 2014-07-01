class WorkshopPolicy < ApplicationPolicy

  def new?
    Chapter.find_roles(:organiser, user).any?
  end

  def create?
    Chapter.find_roles(:organiser, user).any?
  end

  def show?
    is_admin_or_chapter_organiser?
  end

  def invite?
    is_admin_or_chapter_organiser?
  end

  def update?
    is_admin_or_chapter_organiser?
  end

  private
  def is_chapter_organiser?
    user.has_role?(:organiser, record.chapter) or user.has_role?(:organiser, Chapter)
  end
end
