class MeetingsController < ApplicationController
  before_action :set_meeting, only: [:show, :rsvp]

  def show
  end

  def rsvp
    redirect_to :back, notice: "This event is not open for registration yet" unless @meeting.invitable

    @invitation =
  end

  private

  def find_invitation_and_redirect_to_event(member)
    set_meeting
    @invitation = Invitation.where(event: @event, member: current_user, role: role).try(:first)
    if @invitation.nil?
      @invitation = Invitation.new(event: @event, member: current_user, role: role)
      @invitation.save
    end

    redirect_to event_invitation_path(@event, @invitation)
  end

  def set_meeting
    @meeting = Meeting.find_by_slug(params[:id])
  end

end
