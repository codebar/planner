class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @host_address = AddressDecorator.decorate(@invitation.parent.host.address)
    @workshop = WorkshopPresenter.new(@invitation.sessions)

    flash[:warning] = "This is a private link. Don't share it with others."

    render text: @workshop.attendees_csv if request.format.csv?
  end

  def accept_with_note
    @invitation.update_attribute(:note, params[:session_invitation][:note])

    if available_student_slots?(@invitation)
      @invitation.update_attribute(:attending, true)
      SessionInvitationMailer.attending(@invitation.sessions, @invitation.member, @invitation).deliver

      redirect_to :back, notice: t("messages.accepted_invitation",
                                   name: @invitation.member.name)

    else
      redirect_to :back, notice: t("messages.no_available_seats")
    end
  end

  private

  def set_invitation
    @invitation = SessionInvitation.find_by_token(params[:id])
  end
end
