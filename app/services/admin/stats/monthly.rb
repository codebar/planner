# frozen_string_literal: true

module Admin
  module Stats
    # Computes organisation-wide monthly metric rows for a resolved
    # Admin::Stats::Range. All aggregation happens in SQL: each metric
    # query groups by calendar month (app time zone) and returns a
    # handful of rows, so request cost is independent of row counts.
    # Attendance counts come from workshop_invitations bucketed by the
    # workshop's date_and_time; sign-up rows come from members.created_at
    # with role assignment by current group membership and a
    # distinct-member total. Totals are range totals only: each totals
    # cell sums its row across exactly the range's months.
    class Monthly
      Row = Data.define(:section, :label, :cells, :total)
      Result = Data.define(:months, :rows)

      ATTENDANCE_LABELS = { student_check_ins: 'Student check-ins',
                            coach_check_ins: 'Coach check-ins',
                            student_rsvps: 'Student RSVPs',
                            coach_rsvps: 'Coach RSVPs' }.freeze
      SIGN_UP_LABELS = { students: 'New students',
                         coaches: 'New coaches',
                         uncategorised: 'Uncategorised',
                         total: 'Total new members' }.freeze
      ROLE_KEYS = { 'Student' => { check_in: :student_check_ins, rsvp: :student_rsvps },
                    'Coach' => { check_in: :coach_check_ins, rsvp: :coach_rsvps } }.freeze

      class << self
        def call(range)
          months = range.months
          return Result.new(months: [], rows: []) if months.empty?

          @month_keys = months.index_by(&:itself)
          rows = attendance_rows(months) + sign_up_rows(months) + [workshop_row(months)]
          Result.new(months:, rows:)
        end

        private

        def attendance_rows(months)
          counts = blank_counts(months, ATTENDANCE_LABELS.keys)
          grouped_attendance(months).each do |month, role, attended, attending, count|
            key = @month_keys[month]
            next unless key

            attendance_keys(role, attended, attending).each { |row_key| counts[row_key][key] += count }
          end
          ATTENDANCE_LABELS.map { |key, label| row(:attendance, label, months, counts[key]) }
        end

        def grouped_attendance(months)
          scope = WorkshopInvitation.joins(:workshop).where(workshops: { date_and_time: window(months) })
          scope.where(attending: true)
               .or(scope.where(attended: true))
               .group(month_bucket('workshops.date_and_time'), :role, :attended, :attending)
               .pluck(month_bucket('workshops.date_and_time'), :role, :attended, :attending,
                      Arel.sql('COUNT(*)'))
        end

        # A check-in invitation carries both flags (attending is set when
        # attendance is recorded), so it counts in the check-in row AND the
        # RSVP row — the rows are independent bases.
        def attendance_keys(role, attended, attending)
          keys = ROLE_KEYS[role] || {}
          [].tap do |selected|
            selected << keys[:check_in] if attended && keys[:check_in]
            selected << keys[:rsvp] if attending && keys[:rsvp]
          end
        end

        def sign_up_rows(months) # rubocop:disable Metrics/AbcSize
          counts = blank_counts(months, SIGN_UP_LABELS.keys)
          grouped_sign_ups(months).each do |month, total, students, coaches, uncategorised|
            key = @month_keys[month]
            next unless key

            counts[:students][key] += students
            counts[:coaches][key] += coaches
            counts[:uncategorised][key] += uncategorised
            counts[:total][key] += total
          end
          SIGN_UP_LABELS.map { |key, label| row(:sign_ups, label, months, counts[key]) }
        end

        # Left join keeps members with no group subscription in the
        # uncategorised row; distinct counts keep dual-group members in
        # both role rows but once in the total.
        def grouped_sign_ups(months)
          Member.where(created_at: window(months))
                .left_joins(:groups)
                .group(month_bucket('members.created_at'))
                .pluck(month_bucket('members.created_at'),
                       Arel.sql('COUNT(DISTINCT members.id)'),
                       Arel.sql("COUNT(DISTINCT CASE WHEN groups.name = 'Students' THEN members.id END)"),
                       Arel.sql("COUNT(DISTINCT CASE WHEN groups.name = 'Coaches' THEN members.id END)"),
                       Arel.sql('COUNT(DISTINCT CASE WHEN groups.name IS NULL THEN members.id END)'))
        end

        def workshop_row(months)
          row(:workshops, 'Workshops', months, workshop_counts(months))
        end

        def workshop_counts(months)
          counts = default_cells(months)
          Workshop.where(date_and_time: window(months))
                  .unscope(:order)
                  .group(month_bucket('workshops.date_and_time'))
                  .pluck(month_bucket('workshops.date_and_time'), Arel.sql('COUNT(*)'))
                  .each do |month, count|
                    key = @month_keys[month]
                    counts[key] = count if key
                  end
          counts
        end

        def row(section, label, months, counts)
          cells = months.index_with { |m| counts.fetch(m, 0) }
          Row.new(section:, label:, cells:, total: cells.values.sum)
        end

        def blank_counts(months, keys)
          keys.index_with { default_cells(months) }
        end

        def default_cells(months)
          months.index_with { 0 }
        end

        def window(months)
          months.first.beginning_of_day..months.last.end_of_month.end_of_day
        end

        # Calendar-month bucket in the app time zone, cast to a
        # first-of-month date so it matches the months list.
        def month_bucket(column)
          Arel.sql("DATE_TRUNC('month', #{column} AT TIME ZONE '#{Time.zone.tzinfo.identifier}')::date")
        end
      end
    end
  end
end
