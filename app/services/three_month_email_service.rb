# frozen_string_literal: true

class ThreeMonthEmailService
  def self.send_chaser
    three_month_cutoff = 3.months.ago.beginning_of_day
    one_year_cutoff = 1.year.ago.beginning_of_day

    recent_attendee_ids = WorkshopInvitation.to_students
                                            .attended
                                            .joins(:workshop)
                                            .where('workshops.date_and_time >= ?', three_month_cutoff)
                                            .select(:member_id)

    past_year_attendee_ids = WorkshopInvitation.to_students
                                               .attended
                                               .joins(:workshop)
                                               .where('workshops.date_and_time >= ?', one_year_cutoff)
                                               .select(:member_id)

    members = Member.not_banned
                    .accepted_toc
                    .joins(:groups)
                    .merge(Group.students)
                    .left_joins(:member_email_deliveries)
                    .where(member_email_deliveries: { id: nil })
                    .where.not(id: recent_attendee_ids)
                    .where(id: past_year_attendee_ids)
                    .distinct
    return if members.empty?

    members.find_each do |member|
      MemberMailer.with(member: member).chaser.deliver_later
    end
  end
end
