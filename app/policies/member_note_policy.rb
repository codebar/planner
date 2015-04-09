class MemberNotePolicy < ApplicationPolicy

  def create?
    user and (user.has_role?(:admin) or user.roles.where(resource_type: "Chapter").any?)
  end
end
