class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)

    render text: @workshop.attendees_csv if request.format.csv?
  end

  def update
    @invitation = WorkshopInvitation.find_by(token: params[:id])

    if @invitation.role.eql?('Student') && new_note.blank?
      redirect_to :back, notice: t('messages.error_blank_note')
    else
      @invitation.update(note: new_note)
      redirect_to :back, notice: t('messages.updated_note')
    end
  end

  private

  def new_note
    @invitation.role.eql?('Student') ? params[:note] : params[:workshop_invitation][:note]
  end

  def available_spaces?(workshop, invitation)
    (invitation.role.eql?('Student') && workshop.student_spaces?) ||
      (invitation.role.eql?('Coach') && workshop.coach_spaces?)
  end

  def set_invitation
    @invitation = WorkshopInvitation.find_by(token: params[:id])
  end
end
