class EventInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite_student(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation

    subject = "Invitation: #{@event.name}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def invite_coach(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation

    subject = "Coach Invitation: #{@event.name}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def attending(event, member, invitation)
    @event = EventPresenter.new(event)
    @member = member
    @invitation = invitation
    @host_address = AddressPresenter.new(@event.venue.address)

    require 'services/event_calendar'
    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: EventCalendar.new(@event).calendar.to_ical }

    subject = "Your spot to #{@event.name} has been confirmed."

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  private

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end
end
