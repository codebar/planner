module WorkingGroups
  # Pure functional state representation and deterministic FIFO reducer for
  # session working groups (presented as "Pairings" in the organiser UI).
  #
  # Supports *:* working groups (e.g. 2 students + 1 coach). Groups stay fixed
  # in position once formed, while solo waiting participants stay ordered
  # strictly by check-in time.
  class Board
    CheckIn = Data.define(:entry_id, :role, :checked_in_at)
    Assign = Data.define(:entry_id, :target_group_id, :target_entry_id)
    Unassign = Data.define(:entry_id)
    CheckOut = Data.define(:entry_id)

    attr_reader :groups, :waiting

    def initialize(groups: [], waiting: [])
      @groups = groups.sort_by { |g| [g.position, g.id || Float::INFINITY] }.freeze
      @waiting = waiting.sort_by(&:sort_key).freeze
    end

    def reduce(action)
      case action
      when CheckIn then reduce_check_in(action)
      when Assign then reduce_assign(action)
      when Unassign then reduce_unassign(action)
      when CheckOut then reduce_check_out(action)
      else raise ArgumentError, "Unknown working group action: #{action.class}"
      end
    end

    def find_participant(entry_id) = waiting.find { |p| p.entry_id == entry_id } || grouped_participant(entry_id)
    def ==(other) = other.is_a?(self.class) && groups == other.groups && waiting == other.waiting

    private

    def reduce_check_in(action)
      return self if group_for(action.entry_id)

      incoming = existing_or_new_participant(action)
      others = without_entry(waiting, action.entry_id)
      partner = first_opposite_role(others, incoming)
      return pair_participants(groups, without_entry(others, partner.entry_id), partner, incoming) if partner

      self.class.new(groups:, waiting: others + [incoming])
    end

    def reduce_assign(action)
      source = find_participant(action.entry_id)
      return self unless source
      return pair_with_waiting(source, action.target_entry_id) if action.target_entry_id.present?
      return move_into_group(source, action.target_group_id) if action.target_group_id.present?

      self
    end

    def pair_with_waiting(source, target_entry_id)
      target = waiting.find { |p| p.entry_id == target_entry_id }
      return self unless target && target.entry_id != source.entry_id

      next_groups, next_waiting = detach(source.entry_id)
      pair_participants(next_groups, without_entry(next_waiting, target.entry_id), target, source)
    end

    def move_into_group(source, target_group_id)
      target_group = groups.find { |g| g.id == target_group_id }
      return self unless target_group && !target_group.contains?(source.entry_id)

      next_groups, next_waiting = detach(source.entry_id)
      updated = next_groups.map { |g| g.id == target_group.id ? g.add_participant(source) : g }
      self.class.new(groups: updated, waiting: next_waiting)
    end

    def reduce_unassign(action)
      source_group = group_for(action.entry_id)
      return self unless source_group

      source = source_group.participants.find { |p| p.entry_id == action.entry_id }
      next_groups, next_waiting = detach(source.entry_id)
      self.class.new(groups: next_groups, waiting: next_waiting + [source])
    end

    def reduce_check_out(action)
      return self unless find_participant(action.entry_id)

      next_groups, next_waiting = detach(action.entry_id)
      self.class.new(groups: next_groups, waiting: next_waiting)
    end

    def detach(entry_id)
      source_group = group_for(entry_id)
      return [groups, without_entry(waiting, entry_id)] unless source_group

      remaining = source_group.remove_participant(entry_id)
      return [without_group(source_group.id), waiting + remaining.participants] if remaining.size < 2

      [replace_group(source_group.id, remaining), waiting]
    end

    def pair_participants(current_groups, current_waiting, first, second)
      next_pos = (current_groups.map(&:position).max || 0) + 1
      self.class.new(groups: current_groups + [Group.new(id: nil, position: next_pos, participants: [first, second])],
                     waiting: current_waiting)
    end

    def replace_group(group_id, replacement) = groups.map { |g| g.id == group_id ? replacement : g }
    def group_for(entry_id) = groups.find { |g| g.contains?(entry_id) }
    def grouped_participant(entry_id) = groups.lazy.flat_map(&:participants).find { |p| p.entry_id == entry_id }
    def first_opposite_role(list, participant) = list.find { |p| p.role == participant.opposite_role }
    def without_entry(list, entry_id) = list.reject { |p| p.entry_id == entry_id }
    def without_group(group_id) = groups.reject { |g| g.id == group_id }

    def existing_or_new_participant(action)
      waiting.find { |p| p.entry_id == action.entry_id } ||
        Participant.new(entry_id: action.entry_id, role: action.role, checked_in_at: action.checked_in_at)
    end
  end
end
