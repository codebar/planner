class SponsorPolicy < ApplicationPolicy
  def index?
    admin_or_chapter_organiser?
  end

  def create?
    admin_or_chapter_organiser?
  end

  def show?
    admin_or_chapter_organiser?
  end

  def edit?
    admin_or_chapter_organiser?
  end

  def update?
    admin_or_chapter_organiser?
  end
end
