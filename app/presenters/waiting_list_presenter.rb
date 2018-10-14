class WaitingListPresenter < BasePresenter
  def reminders
    @reminders ||= model.where(auto_rsvp: false)
  end

  def list
    model.where(auto_rsvp: true)
  end
end
