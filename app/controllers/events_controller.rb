class EventsController < ApplicationController

  def index
    @past_events = [ Sessions.past.all ]
    @past_events << Course.past.all
    @past_events << Meeting.past.all
    @past_events.flatten!.sort_by!(&:date_and_time).reverse!

    @events = [ Sessions.upcoming.all ]
    @events << Course.upcoming.all
    @events << Meeting.upcoming.all
    @events.flatten!.sort_by!(&:date_and_time)
  end
end
