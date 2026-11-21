module WorkingGroups
  Group = Data.define(:id, :position, :participants) do
    delegate :size, to: :participants

    def contains?(entry_id) = participants.any? { |p| p.entry_id == entry_id }
    def add_participant(participant) = with(participants: participants + [participant])
    def remove_participant(entry_id) = with(participants: participants.reject { |p| p.entry_id == entry_id })
  end
end
