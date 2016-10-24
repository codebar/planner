class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles
    @host_address = AddressDecorator.decorate(@invitation.parent.host.address)
    @workshop = WorkshopPresenter.new(@invitation.workshop)

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
    @workshop = WorkshopPresenter.new(@invitation.workshop)
    @invitation.update_attributes(note: params[:session_invitation][:note], rsvp_time: DateTime.now)

    if @workshop.student_spaces?
      return redirect_to :back, notice: "You have already RSVPd or joined the waitlist for this workshop." if @workshop.attendee?(current_user) or @workshop.waitlisted?(current_user)

      @invitation.update_attribute(:attending, true)
      SessionInvitationMailer.attending(@invitation.workshop, @invitation.member, @invitation).deliver_now

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
