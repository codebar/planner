class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles
    @host_address = AddressPresenter.new(@invitation.parent.host.address)
    @workshop = WorkshopPresenter.new(@invitation.workshop)

    render plain: @workshop.attendees_csv if request.format.csv?
  end

  def update_note
    @invitation = WorkshopInvitation.find_by(token: params[:id])
    new_note = params[:note]

    if new_note.blank?
      flash[:notice] = 'You must select a note'
    else
      @invitation.update_attribute(:note, params[:note])
      flash[:notice] = t('messages.updated_note')
    end
    redirect_back(fallback_location: root_path)
  end

  def accept_with_note
    @workshop = WorkshopPresenter.new(@invitation.workshop)
    @invitation.update(note: params[:workshop_invitation][:note], rsvp_time: Time.zone.now)

    if @workshop.student_spaces?
      if @workshop.attendee?(current_user) || @workshop.waitlisted?(current_user)
        flash[:notice] = 'You have already RSVPd or joined the waitlist for this workshop.'
        return redirect_back(fallback_location: root_path)
      end

      @invitation.update_attribute(:attending, true)
      WorkshopInvitationMailer.attending(@invitation.workshop, @invitation.member, @invitation).deliver_now

      flash[:notice] = t('messages.accepted_invitation', name: @invitation.member.name)
    else
      flash[:notice] = t('messages.no_available_seats')
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def set_invitation
    @invitation = WorkshopInvitation.find_by(token: params[:id])
  end
end
