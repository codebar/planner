# frozen_string_literal: true

# Thanks coaches once per attendance milestone (issue #2386). Run daily by
# chaser:coach_milestones. Only the highest milestone reached is sent, so a
# coach already past several milestones at launch gets one email rather than
# one per milestone; the delivery log then keeps every milestone send-once.
class CoachMilestoneEmailService
  MILESTONES = [5].freeze
  EMAIL_TYPE_PREFIX = 'coach_milestone_'

  def self.send_milestone_emails
    due = milestones_due
    return if due.empty?

    Member.not_banned.accepted_toc.where(id: due.keys).find_each do |member|
      MemberMailer.with(member:, milestone: due[member.id]).coach_milestone.deliver_later
    end
  end

  # { member_id => milestone } for coaches owed an email: the highest milestone
  # at or below their count, unless that milestone or a higher one was already sent.
  def self.milestones_due
    sent = sent_milestones
    attended_counts.each_with_object({}) do |(member_id, count), due|
      milestone = milestone_for(count)
      next unless milestone
      next if sent.fetch(member_id, []).any? { |previous| previous >= milestone }

      due[member_id] = milestone
    end
  end

  # Attended past workshops per coach. The WHERE matches the partial index
  # index_workshop_invitations_coach_attended_on_member_id.
  def self.attended_counts
    WorkshopInvitation.to_coaches.attended
                      .joins(:workshop)
                      .where('workshops.date_and_time < ?', Time.zone.now)
                      .group(:member_id)
                      .having('COUNT(*) >= ?', MILESTONES.min)
                      .count
  end

  def self.milestone_for(count)
    MILESTONES.select { |milestone| milestone <= count }.max
  end

  # { member_id => [milestones already emailed] }
  def self.sent_milestones
    MemberEmailDelivery.where('email_type LIKE ?', "#{EMAIL_TYPE_PREFIX}%")
                       .where.not(member_id: nil)
                       .pluck(:member_id, :email_type)
                       .group_by(&:first)
                       .transform_values { |rows| rows.map { |(_, type)| type.delete_prefix(EMAIL_TYPE_PREFIX).to_i } }
  end

  private_class_method :milestones_due, :attended_counts, :milestone_for, :sent_milestones
end
