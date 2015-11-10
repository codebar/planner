class Admin::EventsController < Admin::ApplicationController
  before_filter :set_event, only: [:show]
  before_filter :find_event, only: [:edit, :update]

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    set_organisers(organiser_ids)

    if @event.save
      redirect_to [:admin, @event], notice: 'Event successfully created.'
    else
      render 'new', notice: 'Error'
    end
  end

  def edit
  end

  def show
    authorize @original_event

    @address = AddressDecorator.decorate(@event.venue.address) if @event.venue.present?
    @attending_students = InvitationPresenter.decorate_collection(@original_event.attending_students)
    @attending_coaches = InvitationPresenter.decorate_collection(@original_event.attending_coaches)
    @host_address = AddressDecorator.new(@event.venue.address)
  end

  def update
    set_organisers(organiser_ids)

    if @event.update_attributes(event_params)
      redirect_to [:admin, @event], notice: "You have just updated the event"
    else
      render 'edit', notice: 'Error'
    end
  end

  def invite
    @event = Event.find_by_slug(params[:event_id])
    authorize @event

    @event.chapters.each do |chapter|
      InvitationManager.new.send_event_emails(@event, chapter)
    end

    redirect_to admin_event_path(@event), notice: "Invitations will be emailed out soon."
  end

  private

  def set_event
    @original_event = Event.find_by_slug(params[:id])
    @event = EventPresenter.new(@original_event)
  end

  def event_params
    params.require(:event).permit(:name, :slug, :date_and_time, :begins_at, :ends_at, :description, :info, :schedule, :venue_id, :coach_spaces, :student_spaces, :email, :announce_only, :tito_url, :invitable, :student_questionnaire, :coach_questionnaire, :show_faq, :display_coaches, :display_students, sponsor_ids: [], chapter_ids: [])
  end

  def organiser_ids
    params[:event][:organisers]
  end

  def grant_organiser_access(organiser_ids=[])
    organiser_ids.each { |id| Member.find(id).add_role(:organiser, @event) }
  end

  def set_organisers(organiser_ids)
    organiser_ids.reject!(&:empty?)
    grant_organiser_access(organiser_ids)
    revoke_organiser_access(organiser_ids)
  end

  def revoke_organiser_access(organiser_ids)
    (@event.organisers.pluck(:id).map(&:to_s) - organiser_ids).each do |id|
      Member.find(id).revoke(:organiser, @event)
    end
  end

  def find_event
    @event = Event.find_by_slug(params[:id])
  end
end
