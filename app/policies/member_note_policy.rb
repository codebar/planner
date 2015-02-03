class MemberNotePolicy < ApplicationPolicy
  # Chapter organisers can create notes.
  def create?
    user and (user.is_admin? or user.chapter_organiser?)
  end
end
