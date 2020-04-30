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
    start_date = workshop.date_and_time.strftime('%Y%m%d')
    start_time = workshop.time.strftime('%H%M')
    end_time = workshop.ends_at.strftime('%H%M')
    address = AddressPresenter.new(workshop.host.address)
    calendar.event do |e|
      e.url = invitation_url
      e.organizer = workshop.chapter.email.to_s
      e.dtstart = Time.zone.parse("#{start_date}#{start_time}")
      e.dtstart = Time.zone.parse("#{start_date}#{start_time}")
      e.dtend =  Time.zone.parse("#{start_date}#{end_time}")
      e.summary = I18n.t('workshop.calendar.summary', host_name: workshop.host.name)
      e.location = address.to_s
      e.description = I18n.t('workshop.calendar.description', invitation_link: invitation_url)
      e.ip_class = 'PRIVATE'
    end
  end

  def setup_virtual_event
    start_date = workshop.date_and_time.strftime('%Y%m%d')
    start_time = workshop.time.strftime('%H%M')
    end_time = workshop.ends_at.strftime('%H%M')
    calendar.event do |e|
      e.url = invitation_url
      e.organizer = workshop.chapter.email.to_s
      e.dtstart = Time.zone.parse("#{start_date}#{start_time}")
      e.dtend =  Time.zone.parse("#{start_date}#{end_time}")
      e.summary = I18n.t('workshop.calendar.summary', host_name: 'Slack')
      e.location = I18n.t('workshop.virtual.calendar.location')
      e.description = I18n.t('workshop.virtual.calendar.description',
                             slack_channel: workshop.slack_channel,
                             slack_channel_link: workshop.slack_channel_link,
                             discord_invitation: I18n.t('social_media_links.discord_invitation'))
      e.description << I18n.t('workshop.calendar.description', invitation_link: invitation_url)
      e.ip_class = 'PRIVATE'
    end
  end
end
