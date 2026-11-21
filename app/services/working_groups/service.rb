module WorkingGroups
  # Session-agnostic service for managing working groups ("Pairings" in UI).
  #
  # Read operations (#board, #visible?) are strictly side-effect free (zero DB
  # writes or locks). Write operations (#on_check_in, #on_check_out, #assign,
  # #unassign) lock the session, compute the next state via the pure
  # WorkingGroups::Board reducer, and persist only the diff.
  class Service
    def self.for(session)
      record = session.respond_to?(:__getobj__) ? session.__getobj__ : session
      return new(WorkshopAdapter.new(record)) if record.is_a?(Workshop)

      raise ArgumentError, "Unsupported working groups session: #{record.class}"
    end

    def initialize(adapter)
      @adapter = adapter
    end

    delegate :visible?, to: :@adapter

    def board
      board_state, entries_by_id = @adapter.load_board_and_entries
      BoardView.build(session_id: @adapter.session_id, visible: visible?, board: board_state, entries_by_id:)
    end

    def on_check_in(entry)
      return unless @adapter.enabled? && entry.attending? && entry.attended?

      participant = @adapter.participant_for(entry)
      action = Board::CheckIn.new(
        entry_id: participant.entry_id, role: participant.role, checked_in_at: participant.checked_in_at
      )
      mutate_board { |board_state| board_state.reduce(action) }
    end

    def on_check_out(entry)
      return unless @adapter.enabled?

      @adapter.with_session_lock { @adapter.remove_entry_membership!(entry.id) }
    end

    def assign(entry_id:, target_group_id: nil, target_entry_id: nil)
      action = Board::Assign.new(
        entry_id: entry_id.to_i,
        target_group_id: target_group_id&.to_i,
        target_entry_id: target_entry_id&.to_i
      )
      mutate_board { |board_state| board_state.reduce(action) }
      board
    end

    def unassign(entry_id:)
      mutate_board { |board_state| board_state.reduce(Board::Unassign.new(entry_id: entry_id.to_i)) }
      board
    end

    private

    def mutate_board
      @adapter.with_session_lock do
        before_board, = @adapter.load_board_and_entries
        after_board = yield(before_board)
        @adapter.persist_diff!(before_board, after_board)
      end
    end
  end
end
