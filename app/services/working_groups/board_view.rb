require 'digest'

module WorkingGroups
  class BoardView < Data.define(:visible, :groups, :waiting, :counts, :etag, :checked_in_ids)
    Group = Data.define(:id, :position, :student, :coach, :participants) do
      def paired?
        student.present? && coach.present?
      end
    end

    Counts = Data.define(:pairs, :waiting_students, :waiting_coaches, :checked_in_students, :checked_in_coaches) do
      def waiting_total
        waiting_students + waiting_coaches
      end

      def to_h
        {
          pairs:,
          waiting_students:,
          waiting_coaches:,
          waiting_total:,
          checked_in_students:,
          checked_in_coaches:
        }
      end
    end

    def self.build(session_id:, visible:, board:, entries_by_id:)
      groups = board.groups.map { |group| build_group(group, entries_by_id) }
      waiting = board.waiting.filter_map { |p| entries_by_id[p.entry_id] }
      all_entries = entries_by_id.values
      counts = build_counts(groups, waiting, all_entries)
      etag = compute_etag(session_id, all_entries, board)

      new(visible:, groups:, waiting:, counts:, etag:, checked_in_ids: entries_by_id.keys.sort)
    end

    def self.build_group(group, entries_by_id)
      entries = group.participants.filter_map { |p| entries_by_id[p.entry_id] }
      Group.new(
        id: group.id,
        position: group.position,
        student: entries.find(&:for_student?),
        coach: entries.find(&:for_coach?),
        participants: entries
      )
    end

    def self.build_counts(group_views, waiting_entries, all_entries)
      Counts.new(
        pairs: group_views.count(&:paired?),
        waiting_students: waiting_entries.count(&:for_student?),
        waiting_coaches: waiting_entries.count(&:for_coach?),
        checked_in_students: all_entries.count(&:for_student?),
        checked_in_coaches: all_entries.count(&:for_coach?)
      )
    end

    def self.compute_etag(session_id, entries, board)
      entry_sig = entries.sort_by(&:id).map { |e| [e.id, e.checked_in_at.to_i, e.updated_at.to_i] }
      group_sig = board.groups.map { |g| [g.id, g.position, g.participants.map(&:entry_id).sort] }
      Digest::SHA256.hexdigest([session_id, entry_sig, group_sig].to_json)
    end

    def visible?
      visible
    end

    def empty?
      groups.empty? && waiting.empty?
    end
  end
end
