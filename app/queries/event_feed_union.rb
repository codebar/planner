class EventFeedUnion
  def self.call(upcoming:)
    new.call(upcoming:)
  end

  def call(upcoming:)
    build_event_feed_union(upcoming:)
  end

  private

  def build_event_feed_union(upcoming:)
    now = Time.zone.now
    comparator = upcoming ? :gteq : :lt

    # Pure Arel subqueries — no ActiveRecord relation bind params to leak
    workshop_subquery = workshop_feed_subquery(comparator:, now:)
    meeting_subquery = meeting_feed_subquery(comparator:, now:)
    event_subquery = event_feed_subquery(comparator:, now:)

    Arel::Nodes::UnionAll.new(
      Arel::Nodes::UnionAll.new(workshop_subquery, meeting_subquery), event_subquery
    )
  end

  def workshop_feed_subquery(comparator:, now:)
    workshops = Arel::Table.new(:workshops)
    chapters = Arel::Table.new(:chapters)

    query = timed_feed_subquery(table: workshops, type: 'Workshop', comparator:, now:)
    query.join(chapters).on(workshops[:chapter_id].eq(chapters[:id]))
    query.where(chapters[:active].eq(true).and(workshops[:date_and_time].public_send(comparator, now)))
    query
  end

  def timed_feed_subquery(table:, type:, comparator:, now:)
    query = Arel::SelectManager.new(table)
    query.project(table[:id], table[:date_and_time], Arel.sql("'#{type}' AS event_type"))
    query.where(table[:date_and_time].public_send(comparator, now))
    query
  end

  def meeting_feed_subquery(comparator:, now:)
    timed_feed_subquery(table: Arel::Table.new(:meetings), type: 'Meeting', comparator:, now:)
  end

  def event_feed_subquery(comparator:, now:)
    timed_feed_subquery(table: Arel::Table.new(:events), type: 'Event', comparator:, now:)
  end
end
