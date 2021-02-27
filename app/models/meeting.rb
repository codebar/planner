class Meeting < ActiveRecord::Base
  include DateTimeConcerns
  include Listable
  include Invitable

  attr_accessor :local_date, :local_time, :local_end_time

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :organisers, -> { where('permissions.name' => 'organiser') }, through: :permissions, source: :members
  belongs_to :venue, class_name: 'Sponsor'
  has_many :invitations, class_name: 'MeetingInvitation'
  has_and_belongs_to_many :chapters

  validates :date_and_time, :ends_at, :venue, presence: true
  validates :slug, uniqueness: true, if: proc { |model| model.slug.present? }

  before_validation :set_date_and_time, :set_end_date_and_time
  before_save :set_slug

  def invitees
    Member.distinct.joins(:chapters).merge(chapters)
  end

  def title
    name || "#{I18n.l(date_and_time, format: :month)} Meeting"
  end

  def to_param
    slug
  end

  def attending?(member)
    invitations.accepted.where(member: member).present?
  end

  def not_full
    invitations.accepted.count < spaces
  end

  def attendees_csv
    CSV.generate { |csv| attendees_array.each { |a| csv << a } }
  end

  private

  def time_zone
    'London'
  end

  def attendees_array
    invitations.accepted.map { |a| [a.member.full_name] }
  end

  def set_slug
    return if slug.present?

    self.slug = loop.with_index do |_, index|
      url = "#{I18n.l(date_and_time, format: :year_month).downcase}-#{title.parameterize}-#{index + 1}"
      break url unless Meeting.where(slug: url).exists?
    end
  end
end
