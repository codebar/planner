class InvitationsController < ApplicationController
  before_action :is_logged_in?, only: [:index]
  before_action :set_invitation, only: [ :show, :attend, :reject ]

  def index
    @upcoming_session = Workshop.next

    @upcoming_invitations = SessionInvitation.where(member: current_user).joins(:workshop).where("date_and_time >= ?", Time.zone.now)
    @upcoming_invitations += CourseInvitation.where(member: current_user).joins(:course).where("date_and_time >= ?", Time.zone.now)

    @attended_invitations = SessionInvitation.where(member: current_user).attended
  end

  def show
    @event = EventPresenter.new(@invitation.event)
    @host_address = AddressDecorator.new(@event.venue.address)
  end

  def attend
    event = @invitation.event

    if @invitation.attending.eql?(true)
      redirect_to :back, notice: t("messages.already_rsvped")
    end

    if @invitation.student_spaces? or @invitation.coach_spaces?
      @invitation.update_attribute(:attending, true)

      notice = "You have RSVPed to #{@invitation.event.name}."

      unless event.confirmation_required or event.surveys_required
        @invitation.update_attribute(:verified, true)
        EventInvitationMailer.attending(@invitation.event, @invitation.member, @invitation).deliver_now
      end

      if event.surveys_required
        notice += " We will verify your attendance after you complete the questionnaire!"
      end

      redirect_to :back, notice: notice
    else
      email = event.chapters.present? ? event.chapters.first.email : "hello@codebar.io"
      redirect_to :back, notice: t("messages.no_available_seats", email: email)
    end
  end

  def reject
    if @invitation.attending.eql?(false)
      redirect_to :back, notice: t("messages.not_attending_already")
    else
      @invitation.update_attribute(:attending, false)
    end

    redirect_to :back, notice: t("messages.rejected_invitation", name: @invitation.member.name)
  end

  def rsvp_meeting
    return redirect_to :back, notice: "Please login first" unless logged_in?

    meeting = Meeting.find_by_slug(params[:meeting_id])

    invitation = MeetingInvitation.where(meeting: meeting, member: current_user, role: "Participant").first_or_create

    invitation.update_attribute(:attending, true)

    if invitation.save
      MeetingInvitationMailer.attending(meeting, current_user, invitation).deliver_now
      redirect_to meeting_path(meeting), notice: "Your RSVP was successful. We look forward to seeing you at the Monthly!"
    else
      redirect_to :back, notice: "Sorry, something went wrong"
    end
  end

  def cancel_meeting
    @invitation = MeetingInvitation.find_by_token(params[:token])

    @invitation.update_attribute(:attending, false)

    redirect_to :back, notice: "Thanks for letting us know you can't make it."
  end

  private

  def set_invitation
    @invitation = Invitation.find_by_token(params[:token])
  end
end
