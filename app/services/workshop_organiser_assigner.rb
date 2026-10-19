# Encapsulates organiser role management for workshops.
# Handles granting and revoking organiser roles based on explicit organiser IDs
# or falling back to the chapter's default organisers.

class WorkshopOrganiserAssigner
  def initialize(workshop, organiser_ids, chapter)
    @workshop = workshop
    @organiser_ids = organiser_ids
    @chapter = chapter
  end

  # Executes the organiser role changes.
  # Adds roles for provided IDs, revokes roles for IDs not present.
  def call
    desired_ids = desired_organiser_ids
    current_ids = @workshop.organisers.pluck(:id).map(&:to_s)

    (desired_ids - current_ids).each { |id| Member.find(id).add_role(:organiser, @workshop) }
    (current_ids - desired_ids).each { |id| Member.find(id).revoke(:organiser, @workshop) }
  end

  private

  # Determines which organiser IDs to act on.
  # If organiser_ids is present and non-empty, use them.
  # Otherwise, fall back to the chapter's current organisers.
  def desired_organiser_ids
    if @organiser_ids.any?
      @organiser_ids.map(&:to_s)
    else
      @chapter.organisers.pluck(:id).map(&:to_s)
    end
  end
end
