class MeetingsController < ApplicationController
  before_action :set_meeting

  def show
    @invitation = if params[:token].present?
      MeetingInvitation.find_by(token: params[:token], member: current_user)
    end
    @host_address = AddressPresenter.new(@meeting.venue.address)
    @attendees = @meeting.invitations.where(attending: true)
  end

  private

  def set_meeting
    @meeting = Meeting.find_by(slug: params[:id])
    @map_address = AddressPresenter.new(@meeting.venue.address).for_map
  end
end
