require 'icalendar/tzinfo'
class WorkshopCalendar
  attr_reader :workshop, :invitation_url

  def initialize(workshop, invitation_url)
    @workshop = workshop
    @invitation_url = invitation_url
    setup
  end

  def setup
    calendar.add_timezone(timezone)
    @workshop.virtual? ? setup_virtual_event : setup_event
  end

  def ical
    calendar.to_ical
  end

  def calendar
    @calendar ||= Icalendar::Calendar.new
  end

  private

  def setup_event
    calendar.event do |e|
      configure(e, host_name: workshop.host.name)

      e.location = address(workshop)
      e.description = I18n.t('workshop.calendar.description', invitation_link: invitation_url)
    end
  end

  def setup_virtual_event
    calendar.event do |e|
      configure(e, host_name: 'Slack')

      e.location = I18n.t('workshop.virtual.calendar.location')
      e.description = I18n.t('workshop.virtual.calendar.description',
                             slack_channel: workshop.slack_channel,
                             slack_channel_link: workshop.slack_channel_link,
                             discord_invitation: I18n.t('social_media_links.discord_invitation'))
      e.description << I18n.t('workshop.calendar.description', invitation_link: invitation_url)
    end
  end

  def configure(event, host_name:)
    start_and_end_time(event)

    event.url = invitation_url
    event.organizer = workshop.chapter.email.to_s
    event.summary = I18n.t('workshop.calendar.summary', host_name: host_name)
    event.ip_class = 'PRIVATE'
  end

  def address(workshop)
    AddressPresenter.new(workshop.host.address).to_s
  end

  def start_and_end_time(event)
    event.dtstart = Icalendar::Values::DateTime.new(Time.zone.parse(start_datetime(workshop)), 'tzid': tzinfo.name)
    event.dtend = Icalendar::Values::DateTime.new(Time.zone.parse(end_datetime(workshop)), 'tzid': tzinfo.name)
  end

  def start_datetime(workshop)
    date = workshop.date_and_time.strftime('%Y%m%d')
    start_time = workshop.time.strftime('%H%M')
    "#{date}#{start_time}"
  end

  def end_datetime(workshop)
    date = workshop.date_and_time.strftime('%Y%m%d')
    end_time = workshop.ends_at.strftime('%H%M')
    "#{date}#{end_time}"
  end

  def timezone
    # NOTE: this is because tzinfo.ical_timezone now complains: String values are not supported
    @timezone ||= tzinfo.ical_timezone workshop.date_and_time
  end

  def tzinfo
    @tzinfo ||= ActiveSupport::TimeZone[workshop.time_zone].tzinfo
  end
end
