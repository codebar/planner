require 'services/ticket'

class EventsController < ApplicationController
  before_action :is_logged_in?, only: %i[student coach]
  before_action :set_event, only: %i[rsvp student coach]
  
  def index
    fresh_when(latest_model_updated, etag: latest_model_updated)
    @past_events = EventsService.new.past_events 
    @events = EventsService.new.events
  end

  def show
    event = Event.find_by(slug: params[:id])

    @event = EventPresenter.new(event)
    @host_address = AddressPresenter.new(@event.venue.address)
    return unless logged_in?

    invitation = Invitation.find_by(member: current_user, event: event, attending: true)
    return redirect_to event_invitation_path(@event, invitation) if invitation
  end

  def student
    find_invitation_and_redirect_to_event('Student')
  end

  def coach
    find_invitation_and_redirect_to_event('Coach')
  end

  def rsvp
    ticket = Ticket.new(request, params)
    member = Member.find_by(email: ticket.email)
    invitation = member.invitations.where(event: @event, role: 'Student').try(:first)
    invitation ||= Invitation.create(event: @event, member: member, role: 'Student')

    invitation.update(attending: true)
    head :ok
  end

  private

  def latest_model_updated
    EventsService.new.latest_model_updated
  end

  def find_invitation_and_redirect_to_event(role)
    @invitation = Invitation.find_or_create_by(event: @event, member: current_user, role: role)
    redirect_to event_invitation_path(@event, @invitation)
  end

  def set_event
    @event = Event.find_by(slug: params[:event_id])
  end
end

