class MeetingPresenter < EventPresenter

  def sponsors
    model.sponsors
  end

  def description
    model.description
  end

  def organisers
    @organisers ||= model.permissions.find_by_name("organiser").members rescue []
  end

  private

  def model
    __getobj__
  end
end
