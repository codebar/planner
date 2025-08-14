class MemberNotePolicy < ApplicationPolicy
  def create?
    user && (user.has_role?(:admin) || user.roles.where(resource_type: 'Chapter').any?)
  end

  def destroy?
    puts "Chapters: #{record.member.chapters.inspect}"
    user && (user.has_role?(:admin) || user == record.author || record.member.chapters.any? { |chapter| user.has_role?(:organiser, chapter) })
  end

  def update?
    user && (user.has_role?(:admin) || user == record.author || record.member.chapters.any? { |chapter| user.has_role?(:organiser, chapter) })
  end
end
