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
    if @invitation.attending?
      flash[:notice] = t('messages.already_rsvped')
      return redirect_back(fallback_location: root_path)
    end

    if @invitation.student_spaces? || @invitation.coach_spaces?
      @invitation.update_attribute(:attending, true)

      flash[:notice] = t('messages.invitations.spot_confirmed', event: @invitation.event.name)

      unless event.confirmation_required || event.surveys_required
        @invitation.update_attribute(:verified, true)
        EventInvitationMailer.attending(@invitation.event, @invitation.member, @invitation).deliver_now
      end
      flash[:notice] = t('messages.invitations.spot_not_confirmed') if event.surveys_required
      return redirect_back(fallback_location: root_path)
    else
      email = event.chapters.present? ? event.chapters.first.email : 'hello@codebar.io'
      flash[:notice] = t('messages.no_available_seats', email: email)
      redirect_back(fallback_location: root_path)
    end
  end

  def reject
    unless @invitation.attending?
      flash[:notice] = t('messages.not_attending_already')
      return redirect_back(fallback_location: root_path)
    end

    @invitation.update_attribute(:attending, false)
    flash[:notice] = t('messages.rejected_invitation', name: @invitation.member.name)
    redirect_back(fallback_location: root_path)
  end

  def rsvp_meeting
    unless logged_in?
      flash[:notice] = 'Please login first'
      return redirect_back(fallback_location: root_path)
    end

    meeting = Meeting.find_by(slug: params[:meeting_id])

    invitation = MeetingInvitation.find_or_create_by(meeting: meeting, member: current_user, role: 'Participant')

    invitation.update_attribute(:attending, true)

    if invitation.save
      MeetingInvitationMailer.attending(meeting, current_user).deliver_now
      redirect_to meeting_path(meeting), notice: 'Your RSVP was successful. We look forward to seeing you at the Monthly!'
    else
      flash[:notice] = 'Sorry, something went wrong'
      redirect_back(fallback_location: root_path)
    end
  end

  def cancel_meeting
    @invitation = MeetingInvitation.find_by(token: params[:token])

    @invitation.update_attribute(:attending, false)

    flash[:notice] = "Thanks for letting us know you can't make it."
    redirect_back(fallback_location: root_path)
  end

  private

  def set_invitation
    @invitation = Invitation.find_by(token: params[:token])
  end
end
