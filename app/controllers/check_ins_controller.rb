# frozen_string_literal: true

class CheckInsController < ApplicationController
  before_action :load_parent
  before_action :store_referer_path, only: [:new]
  before_action :authenticate_member!, only: [:new]

  def new
    @invitation = find_invitation
    @suggested_role = infer_role
    @already_checked_in = already_checked_in?(@invitation)
  end

  def create
    role = params[:role]
    invitation = find_or_create_invitation(role)
    mark_attended(invitation)
    redirect_to check_in_confirm_path
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

  helper_method :check_in_submit_path, :check_in_confirm_path

  def check_in_submit_path
    @parent.is_a?(Event) ?
      check_in_e_path(code: @parent.check_in_code) :
      check_in_w_path(code: @parent.check_in_code)
  end

  def check_in_confirm_path
    @parent.is_a?(Event) ?
      check_in_e_confirm_path(code: @parent.check_in_code) :
      check_in_w_confirm_path(code: @parent.check_in_code)
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

  def find_invitation
    if @parent.is_a?(Event)
      Invitation.find_by(event: @parent, member: current_user)
    else
      WorkshopInvitation.find_by(workshop: @parent, member: current_user)
    end
  end

  def find_or_create_invitation(role)
    if @parent.is_a?(Event)
      Invitation.find_or_create_by!(event: @parent, member: current_user, role: role)
    else
      WorkshopInvitation.find_or_create_by!(workshop: @parent, member: current_user, role: role)
    end
  end

  def mark_attended(invitation)
    attrs = { attending: true, source: "check_in" }
    if @parent.is_a?(Event)
      attrs[:verified] = true
    else
      attrs[:attended] = true
    end
    invitation.update!(attrs)
  end

  def infer_role
    return @invitation.role if @invitation.present?

    groups = current_user.groups
    student = groups.students.any?
    coach = groups.coaches.any?

    if student && !coach
      "Student"
    elsif coach && !student
      "Coach"
    else
      nil
    end
  end
end
