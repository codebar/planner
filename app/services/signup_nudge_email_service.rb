class SignupNudgeEmailService
  NUDGE = 'signup_nudge'.freeze
  FOLLOWUP = 'signup_nudge_followup'.freeze

  def self.send_nudges
    send_signup_nudge
    send_signup_nudge_followup
  end

  def self.send_signup_nudge
    Member.not_banned
          .where(created_at: nudge_window)
          .where.not(id: emailed_ids(NUDGE))
          .where.not(id: subscribed_ids)
          .find_each { |member| MemberMailer.with(member:).signup_nudge.deliver_later }
  end

  def self.send_signup_nudge_followup
    Member.not_banned
          .joins(:member_email_deliveries)
          .where(member_email_deliveries: { email_type: NUDGE, created_at: ..1.month.ago })
          .where.not(id: emailed_ids(FOLLOWUP))
          .where.not(id: subscribed_ids)
          .distinct
          .find_each { |member| MemberMailer.with(member:).signup_nudge_followup.deliver_later }
  end

  # NULL-safe NOT IN: a NULL member_id in the subquery would exclude every member
  def self.emailed_ids(email_type)
    MemberEmailDelivery.where(email_type:).where.not(member_id: nil).select(:member_id)
  end

  def self.subscribed_ids
    Subscription.where.not(member_id: nil).select(:member_id)
  end

  def self.nudge_window
    30.days.ago.beginning_of_day..7.days.ago.end_of_day
  end

  private_class_method :send_signup_nudge, :send_signup_nudge_followup, :emailed_ids, :subscribed_ids,
                       :nudge_window
end
