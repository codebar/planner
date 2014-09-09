class EventsController < ApplicationController

  def index
    events = [ Sessions.past.all ]
    events << Course.past.all
    events << Meeting.past.all
    events.flatten!.sort_by!(&:date_and_time).reverse!
    @past_events = EventPresenter.decorate_collection(events)

    events = [ Sessions.upcoming.all ]
    events << Course.upcoming.all
    events << Meeting.upcoming.all
    events.flatten!.sort_by!(&:date_and_time)
    @events = EventPresenter.decorate_collection(events)
  end
end
