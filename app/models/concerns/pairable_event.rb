# Additive concern for Event pairing associations, queries, and summaries.
module PairableEvent
  extend ActiveSupport::Concern

  Summary = Data.define(:groups_count, :paired_count, :waiting_count, :students_count, :coaches_count)

  included do
    has_many :pairings, dependent: :destroy
  end

  def expected_students
    attendances.where(role: 'Student', verified: [false, nil]).order('members.name, members.surname')
  end

  def expected_coaches
    attendances.where(role: 'Coach', verified: [false, nil]).order('members.name, members.surname')
  end

  def synced_pairings
    Pairing.sync!(self)
    pairings.with_members
  end

  def pairing_summary(loaded_pairings = pairings.with_members)
    paired_count = loaded_pairings.count(&:mixed?)
    Summary.new(
      groups_count: loaded_pairings.size,
      paired_count:,
      waiting_count: loaded_pairings.size - paired_count,
      students_count: loaded_pairings.sum { |p| p.student_invitations.size },
      coaches_count: loaded_pairings.sum { |p| p.coach_invitations.size }
    )
  end
end
