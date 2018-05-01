class WorkshopCalendar
  attr_reader :workshop

  def initialize(workshop)
    @workshop = workshop
    setup_event
  end

  def calendar
    @calendar ||= Icalendar::Calendar.new
  end

  private

  def setup_event
    start_date = workshop.date_and_time.strftime('%Y%m%d')
    start_time = workshop.time.strftime('%H%M')
    address = AddressPresenter.new(workshop.host.address)
    calendar.event do |e|
      e.organizer = workshop.chapter.email.to_s
      e.dtstart = Time.zone.parse("#{start_date}#{start_time}")
      e.dtend = e.dtstart + 2.hours + 30.minutes
      e.summary = "codebar @ #{workshop.host.name}"
      e.location = address.to_s
      e.ip_class = 'PRIVATE'
    end
  end
end
