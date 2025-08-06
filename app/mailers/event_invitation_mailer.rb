class EventInvitationMailer < ApplicationMailer
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite_student(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?

    subject = "Invitation: #{@event.name}"

    mail(mail_args(member, subject), &:html)
  end

  def invite_coach(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?
    @everyone_is_invited = !event.audience

    mail(mail_args(member, @everyone_is_invited ? "Invitation: #{@event.name}" : "Coach Invitation: #{@event.name}"),
         &:html)
  end

  def attending(event, member, invitation)
    @event = EventPresenter.new(event)
    @member = member
    @invitation = invitation
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?

    require 'services/event_calendar'
    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: ServicesEventCalendar.new(@event).calendar.to_ical }

    subject = "Your spot to #{@event.name} has been confirmed."

    mail(mail_args(member, subject), &:html)
  end

  private

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end
end
