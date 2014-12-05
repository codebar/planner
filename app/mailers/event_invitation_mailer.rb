class EventInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite_student(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation

    subject = "Join us for a day long Codebar #{@event.name} event on the #{ActiveSupport::Inflector.ordinalize(l(@event.date_and_time, format: :day))}!"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def invite_coach(event, member, invitation)
    @event = event
    @member = member
    @invitation = invitation

    subject = "Join us for a day long Codebar #{@event.name} event on the #{ActiveSupport::Inflector.ordinalize(l(@event.date_and_time, format: :day))}!"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  def attending event, member, invitation
    @event = EventPresenter.new(event)
    @member = member
    @invitation = invitation
    @host_address = AddressDecorator.decorate(@event.venue.address)

    subject = "Attendance confirmation for #{@event.name}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  private

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
