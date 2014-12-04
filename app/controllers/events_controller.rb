class EventsController < ApplicationController
  before_action :is_member?, only: [:student, :coach]

  def index
    events = [ Sessions.past.all ]
    events << Course.past.all
    events << Meeting.past.all
    events << Event.past.all
    events.flatten!.sort_by!(&:date_and_time).reverse!
    @past_events = EventPresenter.decorate_collection(events)

    events = [ Sessions.upcoming.all ]
    events << Course.upcoming.all
    events << Meeting.upcoming.all
    events << Event.upcoming.all
    events.flatten!.sort_by!(&:date_and_time)
    @events = EventPresenter.decorate_collection(events)
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

  private

  def find_invitation_and_redirect_to_event(role)
    event = Event.find_by_slug(params[:event_id])
    @invitation = Invitation.where(event: event, member: current_user, role: role).try(:first)
    if @invitation.nil?
      @invitation = Invitation.new(event: event, member: current_user, role: role)
      @invitation.save
    end

    redirect_to event_invitation_path(event, @invitation)
  end
end
