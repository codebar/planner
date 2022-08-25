module EventHelper
  def venue_or_remote_must_be_present
    if !virtual && !venue
      errors.add(:venue, 'must be set, or event must be marked as virtual')
    end
  end
end
