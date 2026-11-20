module ChapterContactAudience
  CONFIG = {
    'all_members' => { fields: [], query: :members },
    'chapter_organisers' => { fields: [], query: :organisers },
    'leadership_team' => { fields: [], query: :leadership_team },
    'custom_list' => { fields: %w[custom_list], query: :selected_members },
    'active_last_month' => { fields: %w[activity_period], query: :active_members },
    'inactive_last_month' => { fields: %w[activity_period], query: :inactive_members },
    'event_rsvp' => { fields: %w[event_rsvp], query: :event_rsvp }
  }.freeze
  AUDIENCES = CONFIG.keys.freeze
  ACTIVITY_MONTHS = %w[1 3 6 12].freeze
  RSVP_STATUSES = %w[attending declined unanswered].freeze
  FIELD_AUDIENCES = CONFIG.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(audience, config), fields|
    config[:fields].each { |field| fields[field] << audience }
  end.transform_values(&:freeze).freeze

  def self.options
    CONFIG.keys.map { |value| [I18n.t("admin.chapter_contacts.audiences.#{value}"), value] }
  end

  def self.activity_period_options
    ACTIVITY_MONTHS.map do |months|
      [I18n.t('admin.chapter_contacts.activity_period', count: months.to_i), months]
    end
  end

  def self.rsvp_status_options
    RSVP_STATUSES.map do |status|
      [I18n.t("admin.chapter_contacts.rsvp_statuses.#{status}"), status]
    end
  end

  def self.error(audience)
    I18n.t("admin.chapter_contacts.errors.#{audience}", default: I18n.t('admin.chapter_contacts.errors.no_recipients'))
  end

  def self.valid_activity_months?(audience, months)
    !FIELD_AUDIENCES.fetch('activity_period').include?(audience) || ACTIVITY_MONTHS.include?(months)
  end
end
