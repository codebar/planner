class WorkshopPolicy < ApplicationPolicy
  def new?
    user.has_role?(:admin) || Chapter.find_roles(:organiser, user).any?
  end

  def create?
    user.has_role?(:admin) || Chapter.find_roles(:organiser, user).any?
  end

  def show?
    admin_or_chapter_organiser?
  end

  def invite?
    admin_or_chapter_organiser?
  end

  def update?
    admin_or_chapter_organiser?
  end

  def destroy?
    admin_or_chapter_organiser?
  end

  private

  def chapter_organiser?
    user.has_role?(:organiser, record) ||
      user.has_role?(:organiser, record.chapter) ||
      user.has_role?(:organiser, Chapter)
  end
end
