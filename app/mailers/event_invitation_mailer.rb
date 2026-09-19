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

    mail_to_member(member, subject, &:html)
  end

  def invite_coach(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?
    # Coach emails are labelled as such only when the event is actually for
    # coaches; blank or missing audience means a general invitation.
    @everyone_is_invited = !event.audience.eql?('Coaches')

    mail_to_member(member, @everyone_is_invited ? "Invitation: #{@event.name}" : "Coach Invitation: #{@event.name}",
                   &:html)
  end

  def attending(event, member, invitation)
    @event = EventPresenter.new(event)
    @member = member
    @invitation = invitation
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?

    require 'services/event_calendar'
    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: Services::EventCalendar.new(@event).calendar.to_ical }

    subject = "Your spot to #{@event.name} has been confirmed."

    mail_to_member(member, subject, &:html)
  end
end
