class DashboardController < ApplicationController
  before_action :is_logged_in?, only: [:dashboard]
  DEFAULT_UPCOMING_EVENTS = 5

  def show
    @chapters = Chapter.all.order(:created_at)
    @user = current_user ? MemberPresenter.new(current_user) : nil
    @upcoming_workshops = upcoming_events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }

    @testimonials = Testimonial.order('RANDOM() ').limit(5).includes(:member)
  end

  def dashboard
    @user = MemberPresenter.new(current_user)
    @ordered_events = upcoming_events_for_user.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }
    @announcements = current_user.announcements.active
  end

  def code
  end

  def faq
  end

  def about
  end

  def wall_of_fame
    @coaches = order_by_attendance(attendance_stats_by_coach).map do |member_id, attendances|
      member = Member.unscoped.find(member_id)
      member.attendance = attendances
      member
    end
  end

  def participant_guide
  end

  private

  def attendance_stats_by_coach
    WorkshopInvitation.to_coaches.attended.by_member.count(:member_id)
  end

  def order_by_attendance(member_stats)
    member_stats.sort_by { |member_id, attendance| attendance }.reverse
  end

  def upcoming_events
    workshops = Workshop.upcoming.includes(:chapter, :sponsors)
    all_events(workshops).sort_by(&:date_and_time).group_by(&:date)
  end

  def upcoming_events_for_user
    chapter_workshops = Workshop.upcoming
                                .where(chapter: current_user.chapters)
                                .includes(:chapter, :sponsors)
                                .to_a

    accepted_workshops = current_user.workshop_invitations.accepted
                             .joins(:workshop)
                             .merge(Workshop.upcoming)
                             .includes(workshop: [:chapter, :sponsors])
                             .map(&:workshop)

    all_events(chapter_workshops + accepted_workshops)
      .sort_by(&:date_and_time)
      .group_by(&:date)
  end

  def all_events(workshops)
    course = Course.next
    meeting = Meeting.next
    events = Event.future(DEFAULT_UPCOMING_EVENTS)

    [*workshops, course, *events, meeting].compact
  end
end
