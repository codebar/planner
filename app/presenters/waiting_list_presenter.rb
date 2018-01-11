class WaitingListPresenter < SimpleDelegator
  def reminders
    @reminders ||= model.where(auto_rsvp: false)
  end

  def list
    model.where(auto_rsvp: true)
  end

    private

  def model
    __getobj__
  end
end
