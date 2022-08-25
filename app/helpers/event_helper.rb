module EventHelper
  def venue_or_remote_must_be_present
    if !virtual && !venue
      errors.add(:venue, 'must be set, or event must be marked as virtual')
    end
  end

  def sponsors_uniqueness
    errors.add(:sponsors, :duplicated_sponsor) unless (sponsors.map(&:id) & duplicated_sponsors).empty?
  end

  def bronze_sponsors_uniqueness
    errors.add(:bronze_sponsors, :duplicated_sponsor) unless (bronze_sponsors.map(&:id) & duplicated_sponsors).empty?
  end

  def silver_sponsors_uniqueness
    errors.add(:silver_sponsors, :duplicated_sponsor) unless (silver_sponsors.map(&:id) & duplicated_sponsors).empty?
  end

  def gold_sponsors_uniqueness
    errors.add(:gold_sponsors, :duplicated_sponsor) unless (gold_sponsors.map(&:id) & duplicated_sponsors).empty?
  end
end
