class WorkshopOrganiserAssigner
  def self.validation_error(workshop, organiser_ids, default_to_chapter: false)
    return if default_to_chapter && default_selection?(organiser_ids)
    return 'organiser_ids is required' if organiser_ids.nil?
    return 'organiser_ids must be an array of ids' unless organiser_ids.is_a?(Array)

    validate_ids(workshop, organiser_ids.reject(&:blank?))
  end

  def self.default_selection?(organiser_ids)
    organiser_ids.nil? || organiser_ids == [] || (organiser_ids.is_a?(Array) && organiser_ids.all?(&:blank?))
  end

  def self.validate_ids(workshop, ids)
    return if ids.empty?
    return 'Select valid chapter organisers.' unless valid_ids?(ids)
    return 'Select organisers from this chapter.' unless chapter_organisers?(workshop, ids)

    nil
  end

  def self.valid_ids?(ids)
    ids.all? { |id| valid_id?(id) }
  end

  def self.chapter_organisers?(workshop, ids)
    eligible_ids = workshop.chapter&.organisers&.where(id: ids.map(&:to_i))&.pluck(:id).to_a.map(&:to_s)
    (ids.map(&:to_s).uniq - eligible_ids).empty?
  end

  private_class_method :validate_ids, :valid_ids?, :chapter_organisers?

  def self.valid_id?(id)
    (id.is_a?(String) || id.is_a?(Integer)) && id.to_s.match?(/\A[1-9]\d*\z/)
  end

  private_class_method :valid_id?

  def initialize(workshop, organiser_ids, default_to_chapter: false)
    @workshop = workshop
    @organiser_ids = organiser_ids
    @default_to_chapter = default_to_chapter
  end

  def call
    error = self.class.validation_error(@workshop, @organiser_ids, default_to_chapter: @default_to_chapter)
    raise ArgumentError, error if error

    if @default_to_chapter && self.class.default_selection?(@organiser_ids)
      grant(@workshop.chapter.organisers.pluck(:id))
    else
      raise ArgumentError, 'organiser_ids must be an array of ids' unless @organiser_ids.is_a?(Array)

      desired_ids = @organiser_ids.reject(&:blank?).map(&:to_s)
      grant(desired_ids)
      revoke_other_organisers(desired_ids)
    end
  end

  private

  def grant(organiser_ids)
    organiser_ids.each { |id| Member.find(id).add_role(:organiser, @workshop) }
  end

  def revoke_other_organisers(desired_ids)
    current_ids = @workshop.organisers.pluck(:id).map(&:to_s)
    (current_ids - desired_ids).each { |id| Member.find(id).revoke(:organiser, @workshop) }
  end
end
