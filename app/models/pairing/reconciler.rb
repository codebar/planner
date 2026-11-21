# Declarative persistence reconciler: applies the minimal DB delta required
# to match an immutable Pairing::Board state.
class Pairing
  class Reconciler
    def self.apply!(event, existing_pairings, next_board)
      new(event, existing_pairings, next_board).apply!
    end

    def initialize(event, existing_pairings, next_board)
      @event = event
      @existing_pairings = existing_pairings
      @next_board = next_board
    end

    def apply!
      destroy_stale_memberships!
      destroy_empty_pairings!
      persist_groups!
    end

    private

    def desired_group_by_invitation
      @desired_group_by_invitation ||= @next_board.groups.each_with_object({}) do |group, map|
        group.members.each { |m| map[m.invitation_id] = group.id }
      end
    end

    def destroy_stale_memberships!
      @existing_pairings.each do |pairing|
        pairing.pairing_invitations.each do |pi|
          pi.destroy! unless membership_retained?(pi, pairing.id)
        end
      end
    end

    def membership_retained?(pairing_invitation, pairing_id)
      desired_group_by_invitation.key?(pairing_invitation.invitation_id) &&
        desired_group_by_invitation[pairing_invitation.invitation_id] == pairing_id
    end

    def destroy_empty_pairings!
      kept_ids = @next_board.groups.filter_map(&:id)
      @existing_pairings.reject { |p| kept_ids.include?(p.id) }.each(&:destroy!)
    end

    def persist_groups!
      by_id = @existing_pairings.index_by(&:id)
      @next_board.groups.each { |group| persist_group!(by_id, group) }
    end

    def persist_group!(by_id, group)
      pairing = find_or_build_pairing(by_id, group)
      missing_ids = missing_invitation_ids(pairing, group)

      missing_ids.each { |inv_id| pairing.pairing_invitations.build(invitation_id: inv_id) }
      pairing.save! if pairing.new_record? || missing_ids.any?
    end

    def find_or_build_pairing(by_id, group)
      group.id ? by_id.fetch(group.id) : @event.pairings.build(position: group.position)
    end

    def missing_invitation_ids(pairing, group)
      existing_ids = pairing.persisted? ? pairing.pairing_invitations.reload.map(&:invitation_id) : []
      group.members.map(&:invitation_id) - existing_ids
    end
  end
end
