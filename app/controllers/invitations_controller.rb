class InvitationsController < ApplicationController
  before_action :is_logged_in?, only: [:index]
  before_action :set_invitation, only: %i[show attend reject]

  def index
    @upcoming_workshop = Workshop.next

    upcoming_invitations = WorkshopInvitation.where(member: current_user)
                                             .joins(:workshop)
                                             .merge(Workshop.upcoming)
                                             .includes(workshop: :chapter)
    @upcoming_invitations = InvitationPresenter.decorate_collection(upcoming_invitations)

    @attended_invitations = WorkshopInvitation.where(member: current_user)
                                              .attended
                                              .includes(workshop: :chapter)
  end

  def show
    @event = EventPresenter.new(@invitation.event)
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?
    @member = @invitation.member
  end

  def attend
    event = @invitation.event
    return redirect_back fallback_location: root_path, notice: t('messages.already_rsvped') if @invitation.attending?

    if @invitation.student_spaces? || @invitation.coach_spaces?
      @invitation.accept!

      notice = t('messages.invitations.spot_confirmed', event: @invitation.event.name)

      unless event.confirmation_required || event.surveys_required
        @invitation.verify!
        EventInvitationMailer.attending(@invitation.event, @invitation.member, @invitation).deliver_now
      end
      notice = t('messages.invitations.spot_not_confirmed') if event.surveys_required
      redirect_back fallback_location: root_path, notice: notice
    else
      email = event.chapters.present? ? event.chapters.first.email : 'hello@codebar.io'
      redirect_back(
        fallback_location: root_path,
        notice: t('messages.invitations.event.no_available_seats', email: email)
      )
    end
  end

  def reject
    unless @invitation.attending?
      return redirect_back(
        fallback_location: root_path,
        notice: t('messages.not_attending_already')
      )
    end

    @invitation.decline!
    redirect_back(
      fallback_location: root_path,
      notice: t('messages.rejected_invitation', name: @invitation.member.name)
    )
  end

  def rsvp_meeting
    return redirect_back fallback_location: root_path, notice: 'Please login first' unless logged_in?

    invitation = load_invitation
    meeting = invitation.meeting

    if invitation.update(attending: true)
      MeetingInvitationMailer.attending(meeting, current_user).deliver_now
      redirect_to meeting_path(meeting, token: invitation.token),
                  notice: t('messages.invitations.meeting.rsvp')
    else
      redirect_back fallback_location: root_path, notice: 'Sorry, something went wrong'
    end
  end

  def cancel_meeting
    @invitation = MeetingInvitation.find_by(token: params[:token])

    @invitation.decline!

    redirect_back fallback_location: root_path, notice: t('messages.invitations.meeting.cancel')
  end

  private

  def set_invitation
    @invitation = Invitation.find_by(token: params[:token])
  end

  def load_invitation
    if params[:token].present?
      MeetingInvitation.find_by(token: params[:token], member: current_user)
    else
      meeting = Meeting.find_by(slug: params[:meeting_id])
      MeetingInvitation.new(meeting: meeting, member: current_user, role: 'Participant')
    end
  end
end
