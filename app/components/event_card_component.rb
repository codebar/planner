class EventCardComponent < ViewComponent::Base
  def initialize(event_card:)
    super()
    @event = event_card
  end
end
