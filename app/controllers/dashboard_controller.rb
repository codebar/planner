class DashboardController < ApplicationController
  def show
    @upcoming_workshops = EventPresenter.decorate_collection(upcoming_events)
    @testimonials = Testimonial.order("RANDOM() ").limit(10)

    @sponsors = Sponsor.latest
  end

  def code
  end

  def faq
  end

  def about
  end

  def wall_of_fame
    sessions_count = Sessions.count
    @coaches = order_by_attendance(attendance_stats_by_coach).map do |member_id, attendances|
      member = Member.unscoped.find(member_id)
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

  def upcoming_events
    workshops = Sessions.upcoming || []
    course = Course.next
    meeting = Meeting.next
    event = Event.next

    all_events = workshops << course << meeting << event
    all_events = all_events.compact.flatten
    all_events.sort_by!(&:date_and_time)
  end
end
