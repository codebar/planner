# frozen_string_literal: true

# Monthly new sign-ups for a chapter, split into its Students and Coaches groups.
#
# Months are bucketed in the chapter's own time zone, and the timestamps are
# converted in Ruby: the database session time zone is not pinned, so doing the
# arithmetic in SQL shifts sign-ups made in the first hour of a BST month into
# the previous month.
class ChapterSignUpsPresenter
  MONTHS = 3

  def initialize(chapter, months: MONTHS)
    @chapter = chapter
    @months = months
  end

  def by_month
    counts = counts_by_month_and_group
    month_starts.map do |month|
      { month:,
        students: counts.fetch([month, 'Students'], 0),
        coaches: counts.fetch([month, 'Coaches'], 0) }
    end
  end

  private

  attr_reader :chapter, :months

  def zone
    ActiveSupport::TimeZone[chapter.time_zone]
  end

  def now
    @now ||= Time.current.in_time_zone(zone)
  end

  def month_starts
    @month_starts ||= (0...months).map { |n| (now - n.months).to_date.beginning_of_month }.reverse
  end

  def window
    month_starts.first.in_time_zone(zone)...month_starts.last.next_month.in_time_zone(zone)
  end

  def counts_by_month_and_group
    subscriptions_in_window.each_with_object(Hash.new(0)) do |(signed_up_at, group_name), counts|
      counts[[signed_up_at.in_time_zone(zone).to_date.beginning_of_month, group_name]] += 1
    end
  end

  def subscriptions_in_window
    Subscription
      .excluding_backfilled_tombstones
      .where(created_at: window)
      .joins(:group)
      .where(groups: { chapter_id: chapter.id })
      .pluck(:created_at, 'groups.name')
  end
end
