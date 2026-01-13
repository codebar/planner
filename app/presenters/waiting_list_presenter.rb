class WaitingListPresenter < BasePresenter
  def list
    model.where(auto_rsvp: true)
  end
end
