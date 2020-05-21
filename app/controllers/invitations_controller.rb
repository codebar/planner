class InvitationsController < ApplicationController
  before_action :is_logged_in?, only: [:index]
  before_action :set_invitation, only: %i[show attend reject]

  def index
    @upcoming_workshop = Workshop.next

    upcoming_invitations = WorkshopInvitation.where(member: current_user)
                                             .joins(:workshop)
                                             .merge(Workshop.upcoming)
                                             .includes(workshop: :chapter)
    upcoming_invitations += CourseInvitation.where(member: current_user)
                                            .joins(:course)
                                            .merge(Course.upcoming)
                                            .includes(:course)
    @upcoming_invitations = InvitationPresenter.decorate_collection(upcoming_invitations)

    @attended_invitations = WorkshopInvitation.where(member: current_user)
                                              .attended
                                              .includes(workshop: :chapter)
  end

  def show
    @event = EventPresenter.new(@invitation.event)
    @host_address = AddressPresenter.new(@event.venue.address)
    @member = @invitation.member
  end

  def attend
    event = @invitation.event
    return redirect_to :back, notice: t('messages.already_rsvped') if @invitation.attending?

    if @invitation.student_spaces? || @invitation.coach_spaces?
      @invitation.update_attribute(:attending, true)

      notice = t('messages.invitations.spot_confirmed', event: @invitation.event.name)

      unless event.confirmation_required || event.surveys_required
        @invitation.update_attribute(:verified, true)
        EventInvitationMailer.attending(@invitation.event, @invitation.member, @invitation).deliver_now
      end
      notice = t('messages.invitations.spot_not_confirmed') if event.surveys_required
      redirect_to :back, notice: notice
    else
      email = event.chapters.present? ? event.chapters.first.email : 'hello@codebar.io'
      redirect_to :back, notice: t('messages.invitations.event.no_available_seats', email: email)
    end
  end

  def reject
    return redirect_to :back, notice: t('messages.not_attending_already') unless @invitation.attending?

    @invitation.update_attribute(:attending, false)
    redirect_to :back, notice: t('messages.rejected_invitation', name: @invitation.member.name)
  end

  def rsvp_meeting
    return redirect_to :back, notice: 'Please login first' unless logged_in?

    meeting = Meeting.find_by(slug: params[:meeting_id])

    invitation = MeetingInvitation.find_or_create_by(meeting: meeting, member: current_user, role: 'Participant')

    invitation.update_attribute(:attending, true)

    if invitation.save
      MeetingInvitationMailer.attending(meeting, current_user).deliver_now
      redirect_to meeting_path(meeting), notice: t('messages.invitations.meeting.rsvp')
    else
      redirect_to :back, notice: 'Sorry, something went wrong'
    end
  end

  def cancel_meeting
    @invitation = MeetingInvitation.find_by(token: params[:token])

    @invitation.update_attribute(:attending, false)

    redirect_to :back, notice: t('messages.invitations.meeting.cancel')
  end

  private

  def set_invitation
    @invitation = Invitation.find_by(token: params[:token])
  end
end
