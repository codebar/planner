class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)

    render plain: @workshop.attendees_csv if request.format.csv?
  end

  def update
    @invitation.assign_attributes(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
    return back_with_message(@invitation.errors.full_messages) unless @invitation.valid?

    @invitation.update(invitation_params)
    back_with_message(t('messages.invitations.updated_details'))
  end

  private

  def invitation_params
    if params.key?(:workshop_invitation)
      params.expect(workshop_invitation: [:tutorial, :note])
    else
      {}
    end
  end

  def available_spaces?(workshop, invitation)
    (invitation.role.eql?('Student') && workshop.student_spaces?) ||
      (invitation.role.eql?('Coach') && workshop.coach_spaces?)
  end

  def token
    params[:id]
  end
end
