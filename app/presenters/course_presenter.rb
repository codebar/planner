class CoursePresenter < EventPresenter
  def venue
    model.sponsor
  end

  def sponsors
    [sponsor].compact
  end

  def admin_path
    '#'
  end

  def time
    I18n.l(model.date_and_time, format: :time_with_zone)
  end
end
