# Computes, in a bounded number of queries, the per-attendee flags the admin
# workshop show page renders (newbie / flag-to-organisers / recent-notes).
# Replaces per-row N+1 queries (Member#flag_to_organisers?, #recent_notes and
# MemberPresenter#newbie?) with a small set of aggregate queries.
class AdminWorkshopAttendeeFlags
  def self.for_members(member_ids)
    new(member_ids).to_h
  end

  def initialize(member_ids)
    @member_ids = member_ids
  end

  def to_h
    return {} if @member_ids.empty?

    @member_ids.index_with do |id|
      {
        newbie: newbies.include?(id),
        flag_to_organisers: flag_for?(id),
        recent_notes: recent_notes_member_ids.include?(id)
      }
    end
  end

  private

  def newbies
    @newbies ||= @member_ids - attended_ever
  end

  def attended_ever
    WorkshopInvitation.where(member_id: @member_ids, attended: true).distinct.pluck(:member_id)
  end

  def flag_for?(member_id)
    (no_shows.fetch(member_id, 0) > 3) && (warning_counts.fetch(member_id, 0) >= 2)
  end

  # Accepted (attending) invitations for taken-place workshops in the last six
  # months, grouped by member (mirrors Member#multiple_no_shows?).
  def accepted_counts
    @accepted_counts ||= six_months_taken_place.group(:member_id).count
  end

  def attended_counts
    @attended_counts ||= six_months_taken_place.where(attended: true).group(:member_id).count
  end

  def no_shows
    @no_shows ||= accepted_counts.merge(attended_counts) do |_id, accepted, attended|
      accepted - attended
    end
  end

  def warning_counts
    @warning_counts ||= AttendanceWarning.where(member_id: @member_ids)
                                         .last_six_months
                                         .group(:member_id)
                                         .count
  end

  def six_months_taken_place
    WorkshopInvitation.joins(:workshop)
                      .where(member_id: @member_ids, attending: true)
                      .where(workshops: { date_and_time: 6.months.ago...Time.zone.now })
  end

  # Members with a note created after the (date - 1 day) of their fifth most
  # recent attended workshop, replicating Member#recent_notes.
  RECENT_NOTES_SQL = <<~SQL.freeze
    SELECT DISTINCT mn.member_id
    FROM member_notes mn
    JOIN (
      SELECT member_id, (MIN(d.date_and_time) - INTERVAL '1 day') AS cutoff
      FROM (
        SELECT wi.member_id, ws.date_and_time,
               ROW_NUMBER() OVER (
                 PARTITION BY wi.member_id ORDER BY ws.date_and_time DESC
               ) AS rn
        FROM workshop_invitations wi
        JOIN workshops ws ON ws.id = wi.workshop_id
        WHERE wi.member_id IN (%<member_ids>s)
          AND wi.attended = TRUE
          AND ws.date_and_time IS NOT NULL
      ) d
      WHERE d.rn <= 5
      GROUP BY d.member_id
    ) c ON c.member_id = mn.member_id
    WHERE mn.created_at > c.cutoff
  SQL

  def recent_notes_member_ids
    @recent_notes_member_ids ||= begin
      rows = WorkshopInvitation.connection.select_rows(
        format(RECENT_NOTES_SQL, member_ids: @member_ids.join(',')),
        'admin-workshop-recent-notes'
      )
      rows.flatten.map(&:to_i)
    end
  end
end
