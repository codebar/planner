module WorkingGroups
  Participant = Data.define(:entry_id, :role, :checked_in_at) do
    def opposite_role = role == 'Student' ? 'Coach' : 'Student'
    def sort_key = [checked_in_at ? 0 : 1, checked_in_at ? checked_in_at.to_f : 0.0, entry_id]
  end
end
