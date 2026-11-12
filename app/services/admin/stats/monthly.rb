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
      RETURNING_LABELS = { returning_students: 'Returning students',
                           returning_coaches: 'Returning coaches' }.freeze
      RETURNING_KEYS = { 'Student' => :returning_students, 'Coach' => :returning_coaches }.freeze
      TRANSITION_LABEL = 'Students who became coaches'
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
          rows = attendance_rows(months) + sign_up_rows(months) + [workshop_row(months), *transition_rows(months)]
          Result.new(months:, rows:)
        end

        private

        def attendance_rows(months)
          counts = blank_counts(months, ATTENDANCE_LABELS.keys)
          tally_attendance(counts, grouped_attendance(months))
          ATTENDANCE_LABELS.map { |key, label| row(:attendance, label, months, counts[key]) } + returning_rows(months)
        end

        def tally_attendance(counts, rows)
          rows.each do |month, role, attended, attending, count|
            key = @month_keys[month]
            next unless key

            attendance_keys(role, attended, attending).each { |row_key| counts[row_key][key] += count }
          end
        end

        # A returning member attended at least one workshop in an earlier
        # calendar month than the one being counted, so the same-month repeat
        # does not count. Distinct per month and role.
        def returning_rows(months)
          counts = blank_counts(months, RETURNING_LABELS.keys)
          grouped_returning(months).each do |month, role, count|
            key = @month_keys[month]
            next unless key

            row_key = RETURNING_KEYS[role]
            counts[row_key][key] += count if row_key
          end
          RETURNING_LABELS.map { |key, label| row(:attendance, label, months, counts[key]) }
        end

        def grouped_returning(months)
          WorkshopInvitation.joins(:workshop)
                            .where(workshops: { date_and_time: window(months) }, attended: true)
                            .where(prior_attendance_exists)
                            .group(month_bucket('workshops.date_and_time'), :role)
                            .pluck(month_bucket('workshops.date_and_time'), :role,
                                   Arel.sql('COUNT(DISTINCT workshop_invitations.member_id)'))
        end

        def prior_attendance_exists
          Arel.sql(<<~SQL.squish)
            EXISTS (
              SELECT 1 FROM workshop_invitations AS prior_invitations
              INNER JOIN workshops AS prior_workshops ON prior_workshops.id = prior_invitations.workshop_id
              WHERE prior_invitations.member_id = workshop_invitations.member_id
                AND prior_invitations.attended = TRUE
                AND #{month_bucket('prior_workshops.date_and_time')} < #{month_bucket('workshops.date_and_time')}
            )
          SQL
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

        # Bucketed by the month of the member's first Coaches subscription.
        # Subscriptions are append-only (unsubscribes set discarded_at), so a
        # Students subscription created earlier marks the transition. Chapter is
        # ignored and a still-kept Students subscription does not disqualify.
        def transition_rows(months)
          counts = default_cells(months)
          grouped_transitions(months).each do |month, count|
            key = @month_keys[month]
            counts[key] += count if key
          end
          [row(:transitions, TRANSITION_LABEL, months, counts)]
        end

        def grouped_transitions(months)
          Subscription.from("(#{first_coach_sql}) first_coaches")
                      .where('first_coaches.first_coach_at BETWEEN ? AND ?',
                             window(months).begin, window(months).end)
                      .where(prior_student_exists)
                      .group(month_bucket('first_coaches.first_coach_at'))
                      .pluck(month_bucket('first_coaches.first_coach_at'), Arel.sql('COUNT(*)'))
        end

        def first_coach_sql
          <<~SQL.squish
            SELECT s.member_id, MIN(s.created_at) AS first_coach_at
            FROM subscriptions s
            INNER JOIN groups g ON g.id = s.group_id
            WHERE g.name = 'Coaches'
            GROUP BY s.member_id
          SQL
        end

        def prior_student_exists
          Arel.sql(<<~SQL.squish)
            EXISTS (
              SELECT 1 FROM subscriptions student_subs
              INNER JOIN groups student_groups ON student_groups.id = student_subs.group_id
              WHERE student_subs.member_id = first_coaches.member_id
                AND student_groups.name = 'Students'
                AND student_subs.created_at < first_coaches.first_coach_at
            )
          SQL
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

        # Manual LEFT JOINs (Group's default_scope turns left_joins(:groups) into an
        # inner join). Tombstoned-only members land in uncategorised (#2920).
        def grouped_sign_ups(months)
          Member.where(created_at: window(months))
                .joins(sign_ups_joins)
                .group(month_bucket('members.created_at'))
                .pluck(month_bucket('members.created_at'),
                       Arel.sql('COUNT(DISTINCT members.id)'),
                       Arel.sql("COUNT(DISTINCT CASE WHEN groups.name = 'Students' THEN members.id END)"),
                       Arel.sql("COUNT(DISTINCT CASE WHEN groups.name = 'Coaches' THEN members.id END)"),
                       Arel.sql('COUNT(DISTINCT CASE WHEN groups.name IS NULL THEN members.id END)'))
        end

        def sign_ups_joins
          'LEFT JOIN subscriptions ON subscriptions.member_id = members.id AND subscriptions.discarded_at IS NULL ' \
            'LEFT JOIN groups ON groups.id = subscriptions.group_id'
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

        # Calendar-month bucket in the app time zone, cast to a first-of-month date.
        def month_bucket(column)
          Arel.sql("DATE_TRUNC('month', #{column} AT TIME ZONE '#{Time.zone.tzinfo.identifier}')::date")
        end
      end
    end
  end
end
