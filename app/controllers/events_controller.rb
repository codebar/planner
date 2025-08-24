require 'services/ticket'

class EventsController < ApplicationController
  before_action :is_logged_in?, only: %i[student coach]

  RECENT_EVENTS_DISPLAY_LIMIT = 40

  def index
    fresh_when(latest_model_updated, etag: latest_model_updated)

    events = [Workshop.past.includes(:chapter).joins(:chapter).merge(Chapter.active).limit(RECENT_EVENTS_DISPLAY_LIMIT)]
    events << Meeting.past.includes(:venue).limit(RECENT_EVENTS_DISPLAY_LIMIT)
    events << Event.past.includes(:venue, :sponsors).limit(RECENT_EVENTS_DISPLAY_LIMIT)
    events = events.compact.flatten.sort_by(&:date_and_time).reverse.first(RECENT_EVENTS_DISPLAY_LIMIT)
    events_hash_grouped_by_date = events.group_by(&:date)
    @past_events = events_hash_grouped_by_date.map.inject({}) do |hash, (key, value)|
      hash[key] = EventPresenter.decorate_collection(value)
      hash
    end

    events = [Workshop.includes(:chapter).upcoming.joins(:chapter).merge(Chapter.active)]
    events << Meeting.upcoming.all
    events << Event.upcoming.includes(:venue, :sponsors).all
    events = events.compact.flatten.sort_by(&:date_and_time).group_by(&:date)
    @events = events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }
    @attending_ids = MemberPresenter.new(current_user).attending_events
  end

  def show
    event = Event.find_by!(slug: params[:id])

    @event = EventPresenter.new(event)
    @host_address = AddressPresenter.new(@event.venue.address) if @event.venue.present?

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
    set_event
    ticket = Ticket.new(request, params)
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
end
