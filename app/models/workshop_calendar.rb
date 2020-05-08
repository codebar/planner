class WorkshopCalendar
  attr_reader :workshop, :invitation_url

  def initialize(workshop, invitation_url)
    @workshop = workshop
    @invitation_url = invitation_url
    @workshop.virtual? ? setup_virtual_event : setup_event
  end

  def calendar
    @calendar ||= Icalendar::Calendar.new
  end

  private

  def setup_event
    calendar.event do |e|
      configure(e)

      e.summary = I18n.t('workshop.calendar.summary', host_name: workshop.host.name)
      e.location = address(workshop)
      e.description = I18n.t('workshop.calendar.description', invitation_link: invitation_url)
    end
  end

  def setup_virtual_event
    calendar.event do |e|
      configure(e)

      e.summary = I18n.t('workshop.calendar.summary', host_name: 'Slack')
      e.location = I18n.t('workshop.virtual.calendar.location')
      e.description = I18n.t('workshop.virtual.calendar.description',
                             slack_channel: workshop.slack_channel,
                             slack_channel_link: workshop.slack_channel_link,
                             discord_invitation: I18n.t('social_media_links.discord_invitation'))
      e.description << I18n.t('workshop.calendar.description', invitation_link: invitation_url)
    end
  end

  def configure(event)
    event.url = invitation_url
    event.organizer = workshop.chapter.email.to_s
    event.dtstart = Time.zone.parse(start_datetime(workshop))
    event.dtend =  Time.zone.parse(end_datetime(workshop))
    event.ip_class = 'PRIVATE'
  end

  def address(workshop)
    AddressPresenter.new(workshop.host.address).to_s
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
end
