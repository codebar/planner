class MemberPresenter < BasePresenter
  def organiser?
    @organiser ||= has_role? :organiser, :any
  end

  def event_organiser?(event)
    event_types = %w[Workshop Meeting Event]
    organising_events.slice(*event_types).values.any? { |ids| ids.include?(event.id) } ||
      (event.chapter && organising_events['Chapter']&.include?(event.chapter.id)) ||
      admin?
  end

  def newbie?
    !workshop_invitations.attended.exists?
  end

  def attending?(event)
    model.attending_event_ids.include?(event.id)
  end

  def subscribed_to_newsletter?
    opt_in_newsletter_at.present?
  end

  def pairing_details_array(role, tutorial, note)
    role.eql?('Coach') ? coach_pairing_details(note) : student_pairing_details(tutorial, note)
  end

  def displayed_dietary_restrictions
    return [] if dietary_restrictions.nil?

    (dietary_restrictions - ['other']).map(&:humanize).tap do |drs|
      drs << other_dietary_restrictions if other_dietary_restrictions? && other_dietary_restrictions.present?
    end.map(&:upcase_first)
  end

  private

  def organising_events
    @organised_events ||= roles.where(name: 'organiser')
                               .pluck(:resource_type, :resource_id)
                               .group_by(&:first)
                               .transform_values { |pairs| pairs.map(&:last) }
  end

  def admin?
    @is_admin ||= has_role?(:admin)
  end

  def coach_pairing_details(note)
    [newbie?, full_name, 'Coach', 'N/A', note, skill_list.to_s]
  end

  def student_pairing_details(tutorial, note)
    [newbie?, full_name, 'Student', tutorial, note, 'N/A']
  end
end
