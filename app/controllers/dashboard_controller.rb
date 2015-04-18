class DashboardController < ApplicationController
  before_action :is_logged_in?, only: [:dashboard]

  def show
    @chapters = Chapter.all.order(:created_at)
    @user = current_user ? MemberPresenter.new(current_user) : nil
    @upcoming_workshops = upcoming_events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash}

    @testimonials = Testimonial.order("RANDOM() ").limit(10)

    @sponsors = Sponsor.latest
  end

  def dashboard
    @user = MemberPresenter.new(current_user)
    @ordered_events = upcoming_events_for_user.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash}
    @announcements = current_user.announcements.active

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
    all_events(workshops).sort_by(&:date_and_time).group_by(&:date)
  end

  def upcoming_events_for_user
    chapters = current_user.groups.map(&:chapter).uniq!
    workshops = chapters.collect { |c| c.workshops.upcoming } if chapters
    workshops ||= []
    workshops << current_user.session_invitations.accepted.joins(:sessions).where("sessions.date_and_time > ?", DateTime.now).map(&:sessions)
    all_events(workshops).sort_by(&:date_and_time).group_by(&:date)
  end

  def all_events(workshops)
    course = Course.next
    meeting = Meeting.next
    event = Event.next

    all_events = workshops << course << meeting << event
    all_events = all_events.compact.flatten
  end
end
