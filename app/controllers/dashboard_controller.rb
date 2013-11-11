class DashboardController < ApplicationController
  def show
    @next_session = Sessions.next
    @next_course = Course.next
    @sponsors = Sponsor.latest
  end

  def code
  end

  def about
  end

  def coaches
    sessions_count = Sessions.count
    @coaches = order_by_attendance(attendance_stats_by_coach).map do |member_id, attendances|
      member = Member.find(member_id)
      member.attendance = attendances
      member
    end
  end

  private

  def attendance_stats_by_coach
    SessionInvitation.to_coaches.attended.by_member.count(:member_id)
  end

  def order_by_attendance member_stats
    member_stats.sort_by { |member_id, attendance| attendance }.reverse
  end
end
