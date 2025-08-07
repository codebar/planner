class MemberNotePolicy < ApplicationPolicy
  def create?
    user && (user.has_role?(:admin) || user.roles.where(resource_type: 'Chapter').any?)
  end

  def destroy?
    user && (user.has_role?(:admin) || user.has_role?(:organiser, record.chapter))
  end

  def update?
    user && (user.has_role?(:admin) || user.has_role?(:organiser, record.chapter))
  end
end
