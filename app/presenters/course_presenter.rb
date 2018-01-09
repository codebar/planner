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

  private

  def model
    __getobj__
  end
end
