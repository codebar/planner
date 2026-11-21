# Pure functional state representation and reducer for event pairings.
#
# All state transitions are expressed as immutable transformations over
# value objects (Data.define), separated cleanly from ActiveRecord persistence.
class Pairing
  class Board
    Member = Data.define(:invitation_id, :role) do
      def opposite_role
        role == 'Student' ? 'Coach' : 'Student'
      end
    end

    Group = Data.define(:id, :position, :members) do
      delegate :empty?, to: :members

      def contains?(invitation_id)
        members.any? { |m| m.invitation_id == invitation_id }
      end

      def singleton_of?(role)
        members.one? && members.first.role == role
      end

      def solo?(invitation_id)
        members.one? && members.first.invitation_id == invitation_id
      end

      def add_member(member)
        with(members: members + [member])
      end

      def remove_member(invitation_id)
        with(members: members.reject { |m| m.invitation_id == invitation_id })
      end
    end

    CheckIn = Data.define(:invitation_id, :role)
    Assign = Data.define(:invitation_id, :role, :target_group_id)
    PullOut = Data.define(:invitation_id, :role)
    Remove = Data.define(:invitation_id)

    attr_reader :groups

    def initialize(groups = [])
      @groups = groups.sort_by(&:position).freeze
    end

    def self.from_pairings(pairings)
      groups = pairings.map do |pairing|
        members = pairing.pairing_invitations.map do |pi|
          Member.new(invitation_id: pi.invitation_id, role: pi.invitation.role)
        end
        Group.new(id: pairing.id, position: pairing.position, members:)
      end

      new(groups)
    end

    def reduce(action)
      case action
      when CheckIn then reduce_check_in(action)
      when Assign  then reduce_assign(action)
      when PullOut then reduce_pull_out(action)
      when Remove  then reduce_remove(action)
      else raise ArgumentError, "Unknown pairing action: #{action.class}"
      end
    end

    def ==(other)
      other.is_a?(self.class) && groups == other.groups
    end

    private

    def reduce_check_in(action)
      return self if groups.any? { |g| g.contains?(action.invitation_id) }

      member = Member.new(invitation_id: action.invitation_id, role: action.role)
      waiting = groups.find { |g| g.singleton_of?(member.opposite_role) }

      waiting ? replace_group(waiting.id, waiting.add_member(member)) : append_solo_group(member)
    end

    def reduce_assign(action)
      return self unless assignable?(action)

      member = Member.new(invitation_id: action.invitation_id, role: action.role)
      updated = groups.map { |g| move_into_group(g, member, action.target_group_id) }
      self.class.new(updated.reject(&:empty?))
    end

    def assignable?(action)
      target = groups.find { |g| g.id == action.target_group_id }
      target.present? && !target.contains?(action.invitation_id)
    end

    def reduce_pull_out(action)
      return self if groups.any? { |g| g.solo?(action.invitation_id) }

      member = Member.new(invitation_id: action.invitation_id, role: action.role)
      stripped = groups.map { |g| g.remove_member(action.invitation_id) }.reject(&:empty?)
      self.class.new(stripped).send(:append_solo_group, member)
    end

    def reduce_remove(action)
      updated = groups.map { |g| g.remove_member(action.invitation_id) }.reject(&:empty?)
      self.class.new(updated)
    end

    def move_into_group(group, member, target_group_id)
      stripped = group.remove_member(member.invitation_id)
      stripped.id == target_group_id ? stripped.add_member(member) : stripped
    end

    def replace_group(group_id, replacement)
      self.class.new(groups.map { |g| g.id == group_id ? replacement : g })
    end

    def append_solo_group(member)
      next_position = (groups.map(&:position).max || 0) + 1
      solo = Group.new(id: nil, position: next_position, members: [member])
      self.class.new(groups + [solo])
    end
  end
end
