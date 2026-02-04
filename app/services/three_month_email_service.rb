# frozen_string_literal: true

class ThreeMonthEmailService
  def self.send_chaser
recent_attendees = Member.joins(:workshop_invitations)
                         .merge(
                           WorkshopInvitation.attended.to_students
                             .joins(:workshop)
                             .where('workshops.date_and_time >= ?', 3.months.ago.beginning_of_day)
                         )
                         .distinct

members = Member.not_banned
                .accepted_toc
                .joins(:groups)
                .merge(Group.students)
                .left_joins(:member_email_deliveries)
                .where(member_email_deliveries: { id: nil })
                .where.not(id: recent_attendees.select(:id))
                .distinct
    return if members.empty?
    members.find_each do |member|
      MemberMailer.with(member: member).chaser.deliver_later
    end
  end
end
