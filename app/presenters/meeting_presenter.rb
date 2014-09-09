class MeetingPresenter < EventPresenter

  def sponsors
    [ ]
  end

  def description
    model.description
  end

  private

  def model
    __getobj__
  end
end
