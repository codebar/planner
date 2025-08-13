class MemberNotePolicy < ApplicationPolicy
  def create?
    user && (user.has_role?(:admin) || user.roles.where(resource_type: 'Chapter').any?)
  end

  def update?
    user&.has_role?(:admin)
  end

  def destroy?
    user&.has_role?(:admin)
  end
end
