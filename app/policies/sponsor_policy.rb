class SponsorPolicy < ApplicationPolicy
  def index?
    is_admin_or_chapter_organiser?
  end

  def create?
    is_admin_or_chapter_organiser?
  end

  def show?
    is_admin_or_chapter_organiser?
  end

  def edit?
    is_admin_or_chapter_organiser?
  end

  def update?
    is_admin_or_chapter_organiser?
  end
end
