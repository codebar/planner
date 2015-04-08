class Admin::EventsController < Admin::ApplicationController
  before_filter :set_event

  def show
    authorize @original_event

    @attending_students = InvitationPresenter.decorate_collection(@original_event.attending_students)
    @attending_coaches = InvitationPresenter.decorate_collection(@original_event.attending_coaches)
    @host_address = AddressDecorator.new(@event.venue.address)
  end

  private

  def set_event
    @original_event = Event.find_by_slug(params[:id])
    @event = EventPresenter.new(@original_event)
  end
end
