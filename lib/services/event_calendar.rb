class Services::EventCalendar
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
    calendar.event do |e|
      e.organizer = event.email.to_s
      e.dtstart = event.date_and_time
      e.dtend = event.ends_at
      e.summary = event.name
      e.location = address_string
      e.ip_class = 'PRIVATE'
    end
  end

  def address_string
    address = event.venue&.address
    return unless address

    [address.flat, address.street, address.city, address.postal_code]
      .delete_if(&:empty?)
      .join(', ')
  end
end
