# frozen_string_literal: true

# Monthly new sign-ups for a chapter, split into its Students and Coaches groups.
#
# Months are bucketed in the chapter's own time zone, and the timestamps are
# converted in Ruby: the database session time zone is not pinned, so doing the
# arithmetic in SQL shifts sign-ups made in the first hour of a BST month into
# the previous month. A member counts once per group per month, so leaving and
# rejoining within a month does not count twice.
class ChapterSignUpsPresenter
  MONTHS = 3
  GROUPS = { 'students' => :students, 'coaches' => :coaches }.freeze

  def initialize(chapter)
    @chapter = chapter
  end

  def by_month
    counts = counts_by_month_and_group
    month_starts.map do |month|
      { month:,
        students: counts.fetch([month, :students], 0),
        coaches: counts.fetch([month, :coaches], 0) }
    end
  end

  private

  attr_reader :chapter

  # Legacy rows can carry a zone string that no longer resolves.
  def zone
    ActiveSupport::TimeZone[chapter.time_zone] || Time.zone
  end

  def now
    @now ||= Time.current.in_time_zone(zone)
  end

  def month_starts
    @month_starts ||= (0...MONTHS).map { |n| (now - n.months).to_date.beginning_of_month }.reverse
  end

  # Ends at now, not at the end of the month: a row with a future created_at
  # is not a sign-up yet.
  def window
    month_starts.first.in_time_zone(zone)...now
  end

  def counts_by_month_and_group
    members = Hash.new { |hash, key| hash[key] = Set.new }
    subscriptions_in_window.each do |member_id, signed_up_at, group_name|
      column = GROUPS[group_name.downcase]
      next unless column

      members[[month_of(signed_up_at), column]] << member_id
    end
    members.transform_values(&:size)
  end

  def month_of(time)
    time.in_time_zone(zone).to_date.beginning_of_month
  end

  def subscriptions_in_window
    Subscription
      .excluding_backfilled_tombstones
      .where(created_at: window)
      .joins(:group)
      .where(groups: { chapter_id: chapter.id })
      .pluck(:member_id, :created_at, 'groups.name')
  end
end
