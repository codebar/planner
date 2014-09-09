class CoursePresenter < EventPresenter

  def venue
    model.sponsor
  end

  def sponsors
    [ sponsor ].compact
  end

  def description
    model.short_description
  end

  private

  def model
    __getobj__
  end
end
