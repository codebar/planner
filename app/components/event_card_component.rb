class EventCardComponent < ViewComponent::Base
  def initialize(event_card:)
    super()
    @event = event_card
  end

  private

  # The card renders the chapter (workshops), the venue (events, meetings) or
  # host (workshops), the sponsors and the organisers as well as the event, and
  # none of those records touch the event's updated_at when they change. Keying
  # the fragment on every rendered record busts it on a chapter rename, a
  # sponsor rename, a venue swap or an organiser change. The listing
  # controllers eager-load all of these, so building the key reads loaded
  # associations only.
  #
  # Sponsors are ordered before they reach the key: Event#sponsors has no order
  # clause, so a different join order would write a second fragment for an
  # unchanged card.
  def fragment_cache_key
    sponsors = @event.sponsors.to_a.sort_by(&:id)
    [@event, @event.chapter, @event.venue, *sponsors, *@event.organisers]
      .compact.map(&:cache_key_with_version) + [I18n.locale, :v4]
  end
end
