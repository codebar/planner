class MeetingsController < ApplicationController

  def show
    @meeting = Meeting.find_by_slug(params[:id])
    @map_address = AddressDecorator.new(@meeting.venue.address).for_map
  end
end

