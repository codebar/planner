module WorkingGroups
  # Persistence adapter backing WorkingGroups::Service with strong-FK workshop
  # tables (workshop_working_groups + workshop_invitation_working_groups).
  # Storage details stay encapsulated here so polymorphic or Event adapters can
  # be added later without changing callers or the Board reducer.
  class WorkshopAdapter
    CHECK_IN_WINDOW_LEAD = 30.minutes

    def initialize(workshop)
      @workshop = workshop
    end

    def session_id = @workshop.id
    def enabled? = !@workshop.virtual?
    def with_session_lock(&) = @workshop.with_lock(&)

    def visible?
      !@workshop.virtual? && (check_in_window_open? || @workshop.workshop_working_groups.exists?)
    end

    def load_board_and_entries
      entries = checked_in_entries
      entries_by_id = entries.index_by(&:id)
      grouped_ids = Set.new
      groups = build_groups(entries_by_id, grouped_ids)
      waiting = entries.reject { |e| grouped_ids.include?(e.id) }.map { |e| participant_for(e) }
      [Board.new(groups:, waiting:), entries_by_id]
    end

    def persist_diff!(before_board, after_board)
      return if before_board == after_board

      before_by_id = before_board.groups.index_by(&:id)
      destroy_removed_groups!(before_by_id.keys - after_board.groups.filter_map(&:id))
      update_existing_groups!(before_by_id, after_board.groups)
      create_new_groups!(after_board.groups)
    end

    def remove_entry_membership!(entry_id)
      link = WorkshopInvitationWorkingGroup.find_by(workshop_invitation_id: entry_id)
      return unless link

      group = link.workshop_working_group
      link.destroy!
      group.destroy! if group.workshop_invitation_working_groups.count < 2
    end

    def participant_for(entry)
      WorkingGroups::Participant.new(entry_id: entry.id, role: entry.role, checked_in_at: entry.checked_in_at)
    end

    private

    def check_in_window_open?
      @workshop.date_and_time.present? && (@workshop.date_and_time - CHECK_IN_WINDOW_LEAD).past?
    end

    def checked_in_entries
      entries = @workshop.invitations.accepted.attended
                         .joins(:member).merge(Member.not_banned)
                         .with_notes_and_their_authors.to_a
      preload_member_flags(entries)
      entries
    end

    def preload_member_flags(entries)
      members = entries.map(&:member).uniq(&:id)
      return if members.empty?

      flags = AdminWorkshopAttendeeFlags.for_members(members.map(&:id))
      members.each { |member| member.admin_workshop_flags = flags[member.id] }
    end

    def build_groups(entries_by_id, grouped_ids)
      @workshop.workshop_working_groups.ordered.includes(:workshop_invitation_working_groups).filter_map do |record|
        participants = active_participants_for(record, entries_by_id)
        next if participants.size < 2

        participants.each { |p| grouped_ids.add(p.entry_id) }
        WorkingGroups::Group.new(id: record.id, position: record.position, participants:)
      end
    end

    def active_participants_for(record, entries_by_id)
      record.workshop_invitation_working_groups.filter_map do |link|
        entry = entries_by_id[link.workshop_invitation_id]
        participant_for(entry) if entry
      end
    end

    def destroy_removed_groups!(removed_ids)
      @workshop.workshop_working_groups.where(id: removed_ids).destroy_all if removed_ids.any?
    end

    def update_existing_groups!(before_by_id, after_groups)
      changed = after_groups.select { |g| g.id && before_by_id[g.id] != g }
      return if changed.empty?

      WorkshopInvitationWorkingGroup.where(workshop_working_group_id: changed.map(&:id)).delete_all
      changed.each { |group| sync_group_record!(group) }
    end

    def sync_group_record!(group)
      record = @workshop.workshop_working_groups.find(group.id)
      record.update!(position: group.position) if record.position != group.position
      attach_memberships!(record, group.participants)
    end

    def create_new_groups!(after_groups)
      after_groups.select { |g| g.id.nil? }.each do |group|
        record = @workshop.workshop_working_groups.create!(position: group.position)
        attach_memberships!(record, group.participants)
      end
    end

    def attach_memberships!(record, participants)
      participants.each do |p|
        WorkshopInvitationWorkingGroup.create!(workshop_working_group: record, workshop_invitation_id: p.entry_id)
      end
    end
  end
end
