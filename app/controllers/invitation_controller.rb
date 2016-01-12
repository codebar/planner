class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles
    @host_address = AddressDecorator.decorate(@invitation.parent.host.address)
    @workshop = WorkshopPresenter.new(@invitation.sessions)

    render text: @workshop.attendees_csv if request.format.csv?
  end

  def update_note
    @invitation = SessionInvitation.find_by_token(params[:id])

    new_note = params[:note]

    if new_note.blank?
      redirect_to :back, notice: "You must select a note"
    else
      @invitation.update_attribute(:note, params[:note])
      redirect_to :back, notice: t("messages.updated_note")
    end
  end

  def accept_with_note
    @invitation.update_attribute(:note, params[:session_invitation][:note])

    if @invitation.can_accept?
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
