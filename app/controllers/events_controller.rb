require 'services/ticket'

class EventsController < ApplicationController
  before_action :is_logged_in?, only: %i[student coach]

  def index
    redirect_to upcoming_events_path
  end

  def upcoming
    fresh_when(latest_model_updated, etag: latest_model_updated)

    @events, @pagy = fetch_upcoming_events
  end

  def past
    fresh_when(latest_model_updated, etag: latest_model_updated)

    @past_events, @pagy = fetch_past_events
  end

  def show
    event = Event.find_by!(slug: params[:id])

    @event = EventPresenter.new(event)
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?

    return unless logged_in?

    invitation = Invitation.find_by(member: current_user, event: event, attending: true)
    redirect_to event_invitation_path(@event, invitation) if invitation
  end

  def student
    find_invitation_and_redirect_to_event('Student')
  end

  def coach
    find_invitation_and_redirect_to_event('Coach')
  end

  def rsvp
    set_event
    ticket = Services::Ticket.new(request, params)
    member = Member.find_by(email: ticket.email)
    invitation = member.invitations.where(event: @event, role: 'Student').try(:first)
    invitation ||= Invitation.create(event: @event, member: member, role: 'Student')

    invitation.update(attending: true)
    head :ok
  end

  private

  def latest_model_updated
    [
      Workshop.maximum(:updated_at),
      Meeting.maximum(:updated_at),
      Event.maximum(:updated_at),
      Member.maximum(:updated_at)
    ].compact.max
  end

  def find_invitation_and_redirect_to_event(role)
    set_event
    @invitation = Invitation.find_or_create_by(event: @event, member: current_user, role: role)
    redirect_to event_invitation_path(@event, @invitation)
  end

  def set_event
    @event = Event.find_by(slug: params[:event_id])
  end

  def fetch_upcoming_events
    events = [Workshop.includes(:chapter, :sponsors).upcoming.joins(:chapter).merge(Chapter.active)]
    events << Meeting.upcoming.all
    events << Event.upcoming.includes(:venue, :sponsors, :sponsorships).all

    sorted = events.compact.flatten.sort_by(&:date_and_time)
    pagy, paginated = pagy(sorted, items: 20)

    grouped = paginated.group_by(&:date)
    decorated = grouped.transform_values { |items| EventPresenter.decorate_collection(items) }

    [decorated, pagy]
  end

  def fetch_past_events
    events = [Workshop.past.includes(:chapter, :sponsors).joins(:chapter).merge(Chapter.active)]
    events << Meeting.past.all
    events << Event.past.includes(:venue, :sponsors, :sponsorships).all

    sorted = events.compact.flatten.sort_by(&:date_and_time).reverse
    pagy, paginated = pagy(sorted, items: 20)

    grouped = paginated.group_by(&:date)
    decorated = grouped.transform_values { |items| EventPresenter.decorate_collection(items) }

    [decorated, pagy]
  end
end
