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
          .merge(unemailed(NUDGE))
          .merge(never_subscribed)
          .find_each { |member| MemberMailer.with(member:).signup_nudge.deliver_later }
  end

  def self.send_signup_nudge_followup
    Member.not_banned
          .joins(:member_email_deliveries)
          .where(member_email_deliveries: { email_type: NUDGE, created_at: ..1.month.ago })
          .merge(unemailed(FOLLOWUP))
          .merge(never_subscribed)
          .distinct
          .find_each { |member| MemberMailer.with(member:).signup_nudge_followup.deliver_later }
  end

  def self.unemailed(email_type)
    Member.where.not(id: MemberEmailDelivery.where(email_type:).select(:member_id))
  end

  def self.never_subscribed
    Member.where.not(id: Subscription.select(:member_id))
  end

  def self.nudge_window
    14.days.ago.beginning_of_day..7.days.ago.end_of_day
  end

  private_class_method :send_signup_nudge, :send_signup_nudge_followup, :unemailed, :never_subscribed,
                       :nudge_window
end
