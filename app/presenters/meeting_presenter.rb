class MeetingPresenter < EventPresenter

  def sponsors
    [ ]
  end

  def description
    model.description
  end

  def admin_path
  "#"
  end

  private

  def model
    __getobj__
  end
end
