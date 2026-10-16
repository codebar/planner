# frozen_string_literal: true

# Role choice for members subscribed as both student and coach (issue #3040).
# The member's choice wins and the role can change until they accept or join a
# waiting list; a cancelled member can choose again. Same semantics as
# WorkshopsController#find_or_create_invitation.
module RoleChoiceConcerns
  extend ActiveSupport::Concern

  ROLES = %w[Student Coach].freeze

  private

  # The role the request asks for. Falls back to the invitation's role unless
  # the member may choose: they must be subscribed to the role and the
  # invitation must still be changeable. Callers write it in the same update
  # that completes the action, so a refused request changes nothing.
  def chosen_role(invitation)
    role = params[:role]
    return invitation.role unless role.in?(ROLES)
    return invitation.role unless role_changeable?(invitation)
    return invitation.role unless role_permitted?(invitation.member, role)

    role
  end

  # A member may only take a role they are subscribed to. Members subscribed as
  # both student and coach can therefore choose, and the choice is open on the
  # server for anyone the views already offer it to.
  def role_permitted?(member, role)
    role.eql?('Student') ? member.student? : member.coach?
  end

  def not_subscribed_role_message(role)
    "You are not subscribed as a #{role}."
  end

  def role_changeable?(invitation)
    return false if invitation.attending?
    return false if invitation.respond_to?(:waiting_list) && invitation.waiting_list.present?

    true
  end

  def role_choice_available?(invitation)
    member = invitation.member
    member.student? && member.coach? && role_changeable?(invitation)
  end
end
