class MemberNotePolicy < ApplicationPolicy
  def create?
    user && (user.has_role?(:admin) || user.roles.where(resource_type: 'Chapter').any?)
  end

  def update?
    author_or_chapter_organiser?
  end

  def destroy?
    author_or_chapter_organiser?
  end

  private

  def author_or_chapter_organiser?
    return false unless user

    user.has_role?(:admin) || user == record.author || organiser_of_member_chapter?
  end

  def organiser_of_member_chapter?
    record.member&.chapters&.any? { |chapter| user.has_role?(:organiser, chapter) }
  end
end
