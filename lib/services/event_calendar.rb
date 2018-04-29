class EventCalendar
  attr_reader :event

  def initialize(event)
    @event = event
    setup_event
  end

  def calendar
    @calendar ||= Icalendar::Calendar.new
  end

  private

  def setup_event
    address = AddressPresenter.new(event.venue.address)
    calendar.event do |e|
      e.organizer = event.email.to_s
      e.dtstart = event.date_and_time
      e.dtend = event.ends_at
      e.summary = event.name
      e.location = address.to_s
      e.ip_class = 'PRIVATE'
    end
  end
end
