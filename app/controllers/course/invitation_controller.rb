class Course::InvitationController < ApplicationController

  def accept
    @invitation = CourseInvitation.find_by_token(params[:id])

    if @invitation.attending.eql? true
      redirect_to root_path, notice: t("messages.already_rsvped")

    elsif has_remaining_seats?(@invitation)
      @invitation.update_attribute(:attending, true)

      redirect_to root_path, notice: t("messages.accepted_invitation",
                             name: @invitation.member.name)
    else
      redirect_to root_path, notice: t("messages.no_available_seats")
    end
  end

  private
  def has_remaining_seats? invitation
    invitation.course.seats > invitation.course.attending_invitations.length
  end
end

