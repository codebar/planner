# frozen_string_literal: true

class ThreeMonthEmailService
  def self.send_chaser
    members = Member.joins(:workshop_invitations).where("workshop_invitations.create_at >= ?", 3.months.ago).distinct
    members.each do |member|
      MemberMailer.with(member: member).chaser.deliver_later
    end
  end
end
