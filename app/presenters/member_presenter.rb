class MemberPresenter < BasePresenter

  def organiser?
    has_role? :organiser, :any
  end

  def is_admin?
    @admin ||= has_role?(:admin)
  end

  # Gather all the ids of all the events the member has organised or has organising permissions for
  def organising_events
    @organised_events ||= roles.preload(:resource).where(name: 'organiser').pluck(:resource_type, :resource_id).group_by(&:first).transform_values { |pairs | pairs.map(&:last)}
  end

  def event_organiser?(event)
    if model.nil?
      false
    else
      event_types = %w[Workshop Meeting Event]
      organising_events.slice(*event_types).values.any? { |ids| ids.include?(event.id) } || @organised_events['Chapter']&.include?(event.chapter.id) || is_admin?
    end

  end

  def newbie?
    !workshop_invitations.attended.exists?
  end

  def attending?(event)
    event.invitations.accepted.where(member: model).exists?
  end

  def subscribed_to_newsletter?
    opt_in_newsletter_at.present?
  end

  def pairing_details_array(role, tutorial, note)
    role.eql?('Coach') ? coach_pairing_details(note) : student_pairing_details(tutorial, note)
  end



  private

  def coach_pairing_details(note)
    [newbie?, full_name, 'Coach', 'N/A', note, skill_list.to_s]
  end

  def student_pairing_details(tutorial, note)
    [newbie?, full_name, 'Student', tutorial, note, 'N/A']
  end
end
