class Course::InvitationController < ApplicationController
  include InvitationControllerConcerns

  private
  def set_invitation
    @invitation = CourseInvitation.find_by_token(params[:id])
  end

  def has_remaining_seats? invitation
    invitation.course.seats > invitation.course.attending_invitations.length
  end
end

