class MeetingsController < ApplicationController
  before_action :set_meeting, only: [:show, :rsvp]

  def show
    if @meeting.attending?(current_user)
      @invitation = MeetingInvitation.where(meeting: @meeting, member: current_user).last
    end
    @host_address = AddressDecorator.decorate(@meeting.venue.address)
  end

  private

  def set_meeting
    @meeting = Meeting.find_by_slug(params[:id])
  end
end
