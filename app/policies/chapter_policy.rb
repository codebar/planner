class ChapterPolicy < ApplicationPolicy
  def index?
    show?
  end

  def create?
    admin_or_organiser?
  end

  def show?
    admin_or_organiser?
  end

  def edit?
    admin_or_organiser?
  end

  def update?
    admin_or_organiser?
  end

  def members?
    admin_or_organiser?
  end

  def contact?
    !user.banned? && user.contactable_chapters.where(id: record.id).exists?
  end

  def contact_index?
    !user.banned? && user.manages_chapters?
  end

  private

  def admin_or_organiser?
    user.is_admin? || user.has_role?(:organiser, record) || user.has_role?(:organiser)
  end
end
