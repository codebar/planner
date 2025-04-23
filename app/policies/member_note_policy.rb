class MemberNotePolicy < ApplicationPolicy
  def create?
    user && (user.has_role?(:admin) || user.roles.where(resource_type: 'Chapter').any?)
  end

  def destroy?
    user && (user.has_role?(:admin) || user == record.author)
  end

  def edit?
    user && (user.has_role?(:admin) || user == record.author)
  end
end
