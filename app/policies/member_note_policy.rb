class MemberNotePolicy < ApplicationPolicy
  def create?
    user && (user.has_role?(:admin) || user.roles.where(resource_type: 'Chapter').any?)
  end
end
