# frozen_string_literal: true

class CheckInsController < ApplicationController
  before_action :load_parent
  before_action :store_referer_path, only: [:new]
  before_action :authenticate_member!, only: %i[new create confirm]

  def new
    @invitation = find_invitation
    @suggested_role = infer_role
    @already_checked_in = already_checked_in?(@invitation)
  end

  def create
    role = permitted_role
    existing = find_invitation

    if existing
      return redirect_to check_in_confirm_path if already_checked_in?(existing)
      return redirect_to check_in_new_path, alert: mismatch_role_message(existing.role) if existing.role != role
    end

    unless @parent.check_in_open?
      return redirect_to check_in_new_path, alert: 'Check-in is not currently open.'
    end

    if @parent.respond_to?(:waitlisted?) && @parent.waitlisted?(current_user)
      return redirect_to check_in_new_path, alert: 'You are on the waiting list and cannot check in.'
    end

    invitation = existing || find_or_create_invitation(role)

    unless @parent.spaces_available_for?(role) || invitation.attending?
      return redirect_to check_in_new_path, alert: "There are no #{role} spaces left."
    end

    mark_attended(invitation)
    redirect_to check_in_confirm_path
  rescue ActionController::ParameterMissing
    redirect_to check_in_new_path, alert: 'Please select a valid role (Student or Coach).'
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    redirect_to check_in_new_path, alert: e.message
  end

  def confirm
    @invitation = find_invitation
  end

  private

  def load_parent
    @parent = Event.find_by(check_in_code: params[:code]) ||
              Workshop.find_by(check_in_code: params[:code])
    raise ActiveRecord::RecordNotFound unless @parent
  end

  helper_method :check_in_new_path, :check_in_submit_path, :check_in_confirm_path

  def check_in_new_path
    if @parent.is_a?(Event)
      check_in_e_path(code: @parent.check_in_code)
    else
      check_in_w_path(code: @parent.check_in_code)
    end
  end

  def check_in_submit_path
    if @parent.is_a?(Event)
      check_in_e_path(code: @parent.check_in_code)
    else
      check_in_w_path(code: @parent.check_in_code)
    end
  end

  def check_in_confirm_path
    if @parent.is_a?(Event)
      check_in_e_confirm_path(code: @parent.check_in_code)
    else
      check_in_w_confirm_path(code: @parent.check_in_code)
    end
  end

  def store_referer_path
    session[:referer_path] = request.path unless logged_in?
  end

  def already_checked_in?(invitation)
    return false unless invitation

    if @parent.is_a?(Event)
      invitation.verified?
    else
      invitation.attended?
    end
  end

  def mismatch_role_message(role)
    "You are already registered as a #{role}. Please select that role."
  end

  def find_invitation
    if @parent.is_a?(Event)
      Invitation.find_by(event: @parent, member: current_user)
    else
      WorkshopInvitation.find_by(workshop: @parent, member: current_user)
    end
  end

  def find_or_create_invitation(role)
    if @parent.is_a?(Event)
      Invitation.create_or_find_by(event: @parent, member: current_user, role: role)
    else
      WorkshopInvitation.create_or_find_by(workshop: @parent, member: current_user, role: role)
    end
  end

  def mark_attended(invitation)
    attrs = { attending: true, source: InvitationConcerns::SOURCE_CHECK_IN }
    if @parent.is_a?(Event)
      attrs[:verified] = true
    else
      attrs[:attended] = true
      attrs[:automated_rsvp] = true
    end
    invitation.update!(attrs)
  end

  def permitted_role
    role = params.expect(:role)
    return role if %w[Student Coach].include?(role)

    raise ActionController::ParameterMissing, :role
  end

  def infer_role
    return @invitation.role if @invitation.present?

    groups = current_user.groups
    student = groups.students.any?
    coach = groups.coaches.any?

    if student && !coach
      'Student'
    elsif coach && !student
      'Coach'
    end
  end
end
