require 'services/ticket'

class EventsController < ApplicationController
  before_action :is_logged_in?, only: [:student, :coach]

  def index
    record_limit = 30
    events = [ Workshop.past_display(record_limit) ]
    events << Course.past_display(record_limit)
    events << Meeting.past_display(record_limit)
    events << Event.past_display(record_limit)
    events = events.compact.flatten.sort_by(&:date_and_time).reverse[0...record_limit].group_by(&:date)
    @past_events_display = events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash}
    @all_past_events_count = Workshop.past_count + Course.past_count + Meeting.past_count + Event.past_count

    events = [ Workshop.upcoming.all ]
    events << Course.upcoming.all
    events << Meeting.upcoming.all
    events << Event.upcoming.all
    events = events.compact.flatten.sort_by(&:date_and_time).group_by(&:date)
    @events = events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash}
  end

  def show
    event = Event.find_by_slug(params[:id])

    @event = EventPresenter.new(event)
    @host_address = AddressDecorator.new(@event.venue.address)

    if logged_in?
      invitation = Invitation.where(member: current_user, event: event, attending: true).try(:first)
      if invitation
        redirect_to event_invitation_path(@event, invitation) and return
      end
    end
  end

  def student
    find_invitation_and_redirect_to_event("Student")
  end

  def coach
    find_invitation_and_redirect_to_event("Coach")
  end

  def rsvp
    set_event
    ticket = Ticket.new(request, params)
    member = Member.find_by_email(ticket.email)
    invitation = member.invitations.where(event: @event, role: "Student").try(:first)
    invitation ||= Invitation.create(event: @event, member: member, role: "Student")

    invitation.update_attributes attending: true
    head :ok
  end

  private

  def find_invitation_and_redirect_to_event(role)
    set_event
    @invitation = Invitation.where(event: @event, member: current_user, role: role).try(:first)
    if @invitation.nil?
      @invitation = Invitation.new(event: @event, member: current_user, role: role)
      @invitation.save
    end

    redirect_to event_invitation_path(@event, @invitation)
  end

  def set_event
    @event = Event.find_by_slug(params[:event_id])
  end
end
