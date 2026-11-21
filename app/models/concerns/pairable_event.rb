# Additive concern for Event pairing associations, queries, and summaries.
module PairableEvent
  extend ActiveSupport::Concern

  Summary = Data.define(:groups_count, :paired_count, :waiting_count, :students_count, :coaches_count)

  included do
    has_many :pairings, dependent: :destroy
  end

  def expected_attendees
    attendances.order(Arel.sql('LOWER(members.name), LOWER(members.surname)'))
  end

  def check_in_counts
    {
      invited: invitations.count,
      students_checked_in: attendances.where(role: 'Student', verified: true).count,
      students_total: attendances.where(role: 'Student').count,
      coaches_checked_in: attendances.where(role: 'Coach', verified: true).count,
      coaches_total: attendances.where(role: 'Coach').count
    }
  end

  def expected_students
    expected_by_role('Student')
  end

  def expected_coaches
    expected_by_role('Coach')
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

  def pairing_board_etag(loaded_pairings = pairings.with_members)
    group_keys = loaded_pairings.map do |pairing|
      [pairing.id, pairing.position, pairing.updated_at.to_i, pairing.pairing_invitations.map(&:invitation_id).sort]
    end
    [id, expected_students.count, expected_coaches.count, group_keys]
  end

  private

  def expected_by_role(role)
    attendances.where(role:, verified: [false, nil])
               .order(Arel.sql('LOWER(members.name), LOWER(members.surname)'))
  end
end
