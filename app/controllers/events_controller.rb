class EventsController < ApplicationController

  def index
    @past_events = Sessions.past
    @past_events << Course.past
    @past_events << Meeting.past
    @past_events.flatten!.sort_by!(&:date_and_time).reverse!

    @events = Sessions.upcoming
    @events << Course.upcoming
    @events << Meeting.upcoming
    @events.flatten!.sort_by!(&:date_and_time)
  end
end
