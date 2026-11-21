require 'digest'

module WorkingGroups
  class BoardView < Data.define(:visible, :groups, :waiting, :counts, :etag, :checked_in_ids)
    Group = Data.define(:id, :position, :students, :coaches, :participants) do
      def mixed? = students.any? && coaches.any?
      def solo? = participants.one?
      def student = students.first
      def coach = coaches.first
    end

    Counts = Data.define(:groups_count, :waiting_count, :checked_in_students, :checked_in_coaches) do
      def to_h
        {
          groups_count:,
          waiting_count:,
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
        students: entries.select(&:for_student?),
        coaches: entries.select(&:for_coach?),
        participants: entries
      )
    end

    def self.build_counts(groups, waiting, all_entries)
      Counts.new(
        groups_count: groups.size + waiting.size,
        waiting_count: waiting.size + groups.count { |g| !g.mixed? },
        checked_in_students: all_entries.count(&:for_student?),
        checked_in_coaches: all_entries.count(&:for_coach?)
      )
    end

    def self.compute_etag(session_id, entries, board)
      entry_sig = entries.sort_by(&:id).map { |e| [e.id, e.checked_in_at.to_i, e.updated_at.to_i] }
      group_sig = board.groups.map { |g| [g.id, g.position, g.participants.map(&:entry_id).sort] }
      Digest::SHA256.hexdigest([session_id, entry_sig, group_sig].to_json)
    end

    def visible? = visible
    def empty? = groups.empty? && waiting.empty?
  end
end
