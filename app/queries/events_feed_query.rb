require 'pagy/classes/request'

class EventsFeedQuery
  def self.call(...)
    new(...).call
  end

  def initialize(upcoming:, page:, request:)
    @upcoming = upcoming
    @page = page
    @request = request
  end

  def call
    fetch_events(upcoming: @upcoming)
  end

  private

  # Builds a UNION ALL query across Workshops, Meetings, and Events,
  # paginates at the database level, and returns (id, event_type) pairs
  # for the current page. Only the 20 visible rows come back from the DB.
  def paginated_events(upcoming:)
    direction = upcoming ? 'ASC' : 'DESC'
    union = EventFeedUnion.call(upcoming:)
    total = count_query(union:)
    return nil if total.zero?

    pagy_opts = { count: total, page: @page, limit: 20, request: @request }
    pagy_opts[:request] = Pagy::Request.new(pagy_opts)
    pagy = Pagy::Offset.new(**pagy_opts)

    # Only 20 rows leave the database
    pagination_query = pagination_query(union:, pagy:, direction:)

    rows = ActiveRecord::Base.connection.select_all(pagination_query.to_sql)
    [rows, pagy]
  end

  # Loads full ActiveRecord objects for the paginated (id, event_type) pairs
  # with eager loading, preserving the UNION order.
  def load_events(rows)
    grouped = rows.each_with_object({}) do |row, hash|
      (hash[row['event_type']] ||= []) << row['id'].to_i
    end

    # workshop_host must be preloaded: eager_loading it alongside :sponsors
    # routes both through the workshop_sponsors table in one join, and the
    # host scope then binds to the wrong table alias — the host comes back
    # nil or points at a non-host sponsor. Same pattern as Listable.most_recent.
    workshops = load_workshops_by_id(grouped:)
    meetings = load_meetings_by_id(grouped:)
    events = load_events_by_id(grouped:)

    resolve_events_in_order(rows:, workshops:, meetings:, events:)
  end

  def fetch_events(upcoming:)
    result = paginated_events(upcoming:)
    return [{}, nil] if result.nil?

    rows, pagy = result
    events = load_events(rows)
    grouped = events.group_by(&:date)
    decorated = grouped.transform_values { |items| EventPresenter.decorate_collection(items) }

    [decorated, pagy]
  end

  def count_query(union:)
    # COUNT at DB level — single query
    count_query = Arel::SelectManager.new
    count_query.from(union.as('events'))
    count_query.project(Arel.star.count)
    ActiveRecord::Base.connection.select_value(count_query.to_sql).to_i
  end

  def pagination_query(union:, pagy:, direction:)
    pagination_query = Arel::SelectManager.new
    pagination_query.from(union.as('events'))
    pagination_query.project(:id, :event_type)
    pagination_query.order(Arel.sql("date_and_time #{direction}"))
    pagination_query.skip(pagy.offset).take(pagy.limit)
    pagination_query
  end

  def load_workshops_by_id(grouped:)
    Workshop
      .eager_load(:sponsors, :organisers, chapter: { permissions: :members })
      .preload(workshop_host: :sponsor)
      .where(id: grouped['Workshop'])
      .to_a
      .index_by(&:id)
  end

  def load_meetings_by_id(grouped:)
    Meeting
      .eager_load(:venue, :organisers).where(id: grouped['Meeting'])
      .to_a
      .index_by(&:id)
  end

  def load_events_by_id(grouped:)
    Event
      .eager_load(:venue, :sponsors, :organisers)
      .where(id: grouped['Event'])
      .to_a
      .index_by(&:id)
  end

  def resolve_events_in_order(rows:, workshops:, meetings:, events:)
    rows.filter_map do |row|
      case row['event_type']
      when 'Workshop' then workshops[row['id'].to_i]
      when 'Meeting' then meetings[row['id'].to_i]
      when 'Event' then events[row['id'].to_i]
      end
    end
  end
end
