class Admin::EventsController < Admin::ApplicationController
  before_filter :set_event, ony: [:show]
  before_filter :find_event, only: [:edit, :update]

  def edit
  end

  def show
    authorize @original_event

    @address = AddressDecorator.decorate(@event.venue.address) if @event.venue.present?
    @attending_students = InvitationPresenter.decorate_collection(@original_event.attending_students)
    @attending_coaches = InvitationPresenter.decorate_collection(@original_event.attending_coaches)
    @host_address = AddressDecorator.new(@event.venue.address)
  end

  def update
    if @event.update_attributes(event_params)
      redirect_to [:admin, @event], notice: "You have just updated the event"
    end
  end

  private

  def set_event
    @original_event = Event.find_by_slug(params[:id])
    @event = EventPresenter.new(@original_event)
  end

  def event_params
    params.require(:event).permit(:name, :slug, :date_and_time, :begins_at, :ends_at, :description, :schedule, :venue_id, sponsor_ids: [])
  end

  def find_event
    @event = Event.find_by_slug(params[:id])
  end
end
