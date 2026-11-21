module WorkingGroups
  Group = Data.define(:id, :position, :participants) do
    delegate :size, to: :participants

    def contains?(entry_id) = participants.any? { |p| p.entry_id == entry_id }
    def participant_with_role(role) = participants.find { |p| p.role == role }
    def add_participant(participant) = with(participants: participants + [participant])
    def remove_participant(entry_id) = with(participants: participants.reject { |p| p.entry_id == entry_id })

    def replace_participant(old_id, replacement)
      with(participants: participants.map { |p| p.entry_id == old_id ? replacement : p })
    end
  end
end
