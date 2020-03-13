class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)

    render text: @workshop.attendees_csv if request.format.csv?
  end

  def update_note
    @invitation = WorkshopInvitation.find_by(token: params[:id])
    new_note = params[:note]

    if new_note.blank?
      redirect_to :back, notice: t('messages.error_blank_note')
    else
      @invitation.update_attribute(:note, params[:note])
      redirect_to :back, notice: t('messages.updated_note')
    end
  end

  def accept_with_note
    @invitation.update(note: params[:workshop_invitation][:note], rsvp_time: Time.zone.now)
    @workshop = WorkshopPresenter.decorate(@invitation.workshop)

    if @workshop.student_spaces?
      if @workshop.attendee?(current_user) || @workshop.waitlisted?(current_user)
        return redirect_to :back, notice: t('messages.already_invited')
      end

      @invitation.update_attribute(:attending, true)
      @workshop.send_attending_email(@invitation)

      redirect_to :back, notice: t('messages.accepted_invitation',
                                   name: @invitation.member.name)

    else
      redirect_to :back, notice: t('messages.no_available_seats')
    end
  end

  private

  def set_invitation
    @invitation = WorkshopInvitation.find_by(token: params[:id])
  end
end
