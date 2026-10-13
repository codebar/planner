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
    now = Time.zone.now
    direction = upcoming ? 'ASC' : 'DESC'
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
    count_query.from(union.as('events'))
    count_query.project(Arel.star.count)
    total = ActiveRecord::Base.connection.select_value(count_query.to_sql).to_i
    return nil if total.zero?

    pagy_opts = { count: total, page: @page, limit: 20, request: @request }
    pagy_opts[:request] = Pagy::Request.new(pagy_opts)
    pagy = Pagy::Offset.new(**pagy_opts)

    # Only 20 rows leave the database
    pagination_query = Arel::SelectManager.new
    pagination_query.from(union.as('events'))
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
      (hash[row['event_type']] ||= []) << row['id'].to_i
    end

    # workshop_host must be preloaded: eager_loading it alongside :sponsors
    # routes both through the workshop_sponsors table in one join, and the
    # host scope then binds to the wrong table alias — the host comes back
    # nil or points at a non-host sponsor. Same pattern as Listable.most_recent.
    workshops = Workshop.eager_load(:sponsors, :organisers,
                                    chapter: { permissions: :members })
                        .preload(workshop_host: :sponsor)
                        .where(id: grouped['Workshop'])
                        .to_a.index_by(&:id)
    meetings = Meeting.eager_load(:venue, :organisers).where(id: grouped['Meeting'])
                      .to_a.index_by(&:id)
    events = Event.eager_load(:venue, :sponsors, :organisers)
                  .where(id: grouped['Event'])
                  .to_a.index_by(&:id)

    rows.filter_map do |row|
      case row['event_type']
      when 'Workshop' then workshops[row['id'].to_i]
      when 'Meeting' then meetings[row['id'].to_i]
      when 'Event' then events[row['id'].to_i]
      end
    end
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
end
