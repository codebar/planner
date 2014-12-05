class InvitationsController < ApplicationController
  before_action :is_member?, only: [:index]
  before_action :set_invitation, only: [ :show, :attend, :reject ]

  def index
    @upcoming_session = Sessions.next

    @upcoming_invitations = SessionInvitation.where(member: current_user).joins(:sessions).where("date_and_time >= ?", DateTime.now)
    @upcoming_invitations += CourseInvitation.where(member: current_user).joins(:course).where("date_and_time >= ?", DateTime.now)

    @attended_invitations = SessionInvitation.where(member: current_user).attended
  end

  def show
    @event = EventPresenter.new(@invitation.event)
    @host_address = AddressDecorator.new(@event.venue.address)
  end

  def attend
    if @invitation.attending.eql?(true)
      redirect_to :back, notice: t("messages.already_rsvped")
    end

    if @invitation.student_spaces? or @invitation.coach_spaces?
      @invitation.update_attribute(:attending, true)

      redirect_to :back, notice: "You have RSVPed to #{@invitation.event.name}. We will verify your attendance after you complete the questionnaire!"
    else
      redirect_to :back, notice: t("messages.no_available_seats", email: @invitation.chapter.first.email)
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

  private

  def set_invitation
    @invitation = Invitation.find_by_token(params[:token])
  end
end
