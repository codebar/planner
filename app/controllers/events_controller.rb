class EventsController < ApplicationController

  def index
    events = [ Sessions.past.all ]
    events << Course.past.all
    events << Meeting.past.all
    events << Event.past.all
    events.flatten!.sort_by!(&:date_and_time).reverse!
    @past_events = EventPresenter.decorate_collection(events)

    events = [ Sessions.upcoming.all ]
    events << Course.upcoming.all
    events << Meeting.upcoming.all
    events << Event.upcoming.all
    events.flatten!.sort_by!(&:date_and_time)
    @events = EventPresenter.decorate_collection(events)
  end

  def show
    event = Event.find_by_slug(params[:id])
    @event = EventPresenter.new(event)
    @host_address = AddressDecorator.new(@event.venue.address)

  end
end
