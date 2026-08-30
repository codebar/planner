class GroupPolicy < ApplicationPolicy
  def show?
    admin_or_chapter_organiser?
  end
end
