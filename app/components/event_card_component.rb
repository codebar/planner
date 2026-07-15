class EventCardComponent < ViewComponent::Base
  def initialize(event_card:, user: nil)
    @event = event_card
    @user = user
  end

  # Wraps raw Member in MemberPresenter; double-wrapping a presenter is a no-op.
  def user_presenter
    @user && MemberPresenter.new(@user)
  end
end
