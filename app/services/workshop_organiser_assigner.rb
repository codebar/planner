class WorkshopOrganiserAssigner
  def initialize(workshop, organiser_ids, default_to_chapter: false)
    @workshop = workshop
    @organiser_ids = organiser_ids
    @default_to_chapter = default_to_chapter
  end

  def call
    if @default_to_chapter && @organiser_ids.blank?
      grant(@workshop.chapter.organisers.pluck(:id))
    else
      raise ArgumentError, 'organiser_ids is required' if @organiser_ids.nil?

      desired_ids = Array(@organiser_ids).reject(&:empty?).map(&:to_s)
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
