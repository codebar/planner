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
    invitation = member.invitations.where(event: @event, role: 'Student').first
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
    @event = Event.find_by!(slug: params[:event_id])
  end

  def fetch_upcoming_events
    result = paginated_events(upcoming: true)
    return [{}, nil] if result.nil?

    rows, pagy = result
    events = load_events(rows)
    grouped = events.group_by(&:date)
    decorated = grouped.transform_values { |items| EventPresenter.decorate_collection(items) }

    [decorated, pagy]
  end

  def fetch_past_events
    result = paginated_events(upcoming: false)
    return [{}, nil] if result.nil?

    rows, pagy = result
    events = load_events(rows)
    grouped = events.group_by(&:date)
    decorated = grouped.transform_values { |items| EventPresenter.decorate_collection(items) }

    [decorated, pagy]
  end

  # Builds a UNION ALL query across Workshops, Meetings, and Events,
  # paginates at the database level, and returns (id, event_type) pairs
  # for the current page. Only the 20 visible rows come back from the DB.
  def paginated_events(upcoming:)
    now = Time.zone.now
    page = (params[:page] || 1).to_i
    direction = upcoming ? "ASC" : "DESC"
    comparator = upcoming ? :gteq : :lt

    # Pure Arel subqueries — no ActiveRecord relation bind params to leak
    w = Arel::Table.new(:workshops)
    ch = Arel::Table.new(:chapters)
    ws = Arel::SelectManager.new(w)
    ws.project(w[:id], w[:date_and_time], Arel.sql("'Workshop' AS event_type"))
    ws.join(ch).on(w[:chapter_id].eq(ch[:id]))
    ws.where(ch[:active].eq(true).and(w[:date_and_time].public_send(comparator, now)))

    m = Arel::Table.new(:meetings)
    ms = Arel::SelectManager.new(m)
    ms.project(m[:id], m[:date_and_time], Arel.sql("'Meeting' AS event_type"))
    ms.where(m[:date_and_time].public_send(comparator, now))

    e = Arel::Table.new(:events)
    es = Arel::SelectManager.new(e)
    es.project(e[:id], e[:date_and_time], Arel.sql("'Event' AS event_type"))
    es.where(e[:date_and_time].public_send(comparator, now))

    union = Arel::Nodes::UnionAll.new(
      Arel::Nodes::UnionAll.new(ws, ms), es
    )

    # COUNT at DB level — single query
    count_query = Arel::SelectManager.new
    count_query.from(union.as("events"))
    count_query.project(Arel.star.count)
    total = ActiveRecord::Base.connection.select_value(count_query.to_sql).to_i
    return nil if total.zero?

    pagy_opts = { count: total, page: page, limit: 20, request: request }
    pagy_opts[:request] = Pagy::Request.new(pagy_opts)
    pagy = Pagy::Offset.new(**pagy_opts)

    # Only 20 rows leave the database
    pagination_query = Arel::SelectManager.new
    pagination_query.from(union.as("events"))
    pagination_query.project(:id, :event_type)
    pagination_query.order(Arel.sql("date_and_time #{direction}"))
    pagination_query.skip(pagy.offset).take(pagy.limit)

    rows = ActiveRecord::Base.connection.select_all(pagination_query.to_sql)
    [rows, pagy]
  end

  # Loads full ActiveRecord objects for the paginated (id, event_type) pairs
  # with eager loading, preserving the UNION order.
  def load_events(rows)
    grouped = rows.each_with_object({}) do |row, hash|
      (hash[row["event_type"]] ||= []) << row["id"].to_i
    end

    workshops = Workshop.includes(:chapter, :sponsors, :permissions, :organisers, :workshop_host)
                        .where(id: grouped["Workshop"])
                        .to_a.index_by(&:id)
    meetings = Meeting.where(id: grouped["Meeting"])
                      .to_a.index_by(&:id)
    events = Event.includes(:venue, :sponsors, :sponsorships, :permissions, :organisers)
                  .where(id: grouped["Event"])
                  .to_a.index_by(&:id)

    rows.filter_map do |row|
      case row["event_type"]
      when "Workshop" then workshops[row["id"].to_i]
      when "Meeting" then meetings[row["id"].to_i]
      when "Event" then events[row["id"].to_i]
      end
    end
  end
end
