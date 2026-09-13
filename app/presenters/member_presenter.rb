class MemberPresenter < BasePresenter
  def newbie?
    return model.admin_workshop_flags[:newbie] if model.admin_workshop_flags

    !workshop_invitations.attended.exists?
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

  def coach_pairing_details(note)
    [newbie?, full_name, 'Coach', 'N/A', note, skill_list.to_s]
  end

  def student_pairing_details(tutorial, note)
    [newbie?, full_name, 'Student', tutorial, note, 'N/A']
  end
end
