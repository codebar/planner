class AdminPortalPresenter
  def jobs_pending_approval
    @jobs_pending_approval ||= Job.where(approved: false, submitted: true).count
  end

  def active_chapters
    @active_chapters ||= Chapter.active.all.order(name: :asc)
  end

  def upcoming_workshops
    @upcoming_workshops ||= Workshop.upcoming
  end

  def active_chapter_groups
    @active_chapter_groups ||= Group.joins(:chapter).merge(active_chapters)
  end

  def subscribers(limit: 20)
    @subscribers ||= Subscription.joins(:chapter).merge(active_chapters)
                                 .ordered.limit(limit).includes(:member, :group)
  end
end
