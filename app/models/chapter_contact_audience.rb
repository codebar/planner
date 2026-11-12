module ChapterContactAudience
  CONFIG = {
    'all_members' => { label: 'All chapter members', fields: [], query: :members },
    'chapter_organisers' => { label: 'Chapter organisers', fields: [], query: :organisers,
                              error: 'There are no chapter organisers to email.' },
    'custom_list' => { label: 'Custom list', fields: %w[custom_list], query: :selected_members,
                       error: 'Select at least one current chapter member.' },
    'active_last_month' => { label: 'Active in the last month', fields: %w[activity_period], query: :active_members,
                             error: 'There are no members active in the selected period.' },
    'inactive_last_month' => { label: 'Inactive for the last month', fields: %w[activity_period],
                               query: :inactive_members,
                               error: 'There are no members inactive for the selected period.' },
    'event_rsvp' => { label: 'Event RSVP status', fields: %w[event_rsvp], query: :event_rsvp,
                      error: 'No current chapter members match that event RSVP status.' }
  }.freeze
  AUDIENCES = CONFIG.keys.freeze
  ACTIVITY_MONTHS = %w[1 3 6 12].freeze
  RSVP_STATUSES = { 'attending' => 'Attending', 'declined' => 'Declined', 'unanswered' => 'No response' }.freeze
  FIELD_AUDIENCES = CONFIG.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(audience, config), fields|
    config[:fields].each { |field| fields[field] << audience }
  end.transform_values(&:freeze).freeze

  def self.options
    CONFIG.map { |value, config| [config[:label], value] }
  end

  def self.activity_period_options
    ACTIVITY_MONTHS.map { |months| ["#{months} #{months == '1' ? 'month' : 'months'}", months] }
  end

  def self.valid_activity_months?(audience, months)
    !FIELD_AUDIENCES.fetch('activity_period').include?(audience) || ACTIVITY_MONTHS.include?(months)
  end
end
