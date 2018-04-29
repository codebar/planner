class Meeting < ActiveRecord::Base
  include Listable
  include Invitable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :organisers, -> { where('permissions.name' => 'organiser') }, through: :permissions, source: :members
  belongs_to :venue, class_name: 'Sponsor'
  has_many :invitations, foreign_key: 'meeting_id', class_name: 'MeetingInvitation'
  has_and_belongs_to_many :chapters

  validates :date_and_time, :venue, presence: true

  before_save :set_slug

  def invitees
    chapters.map{ |c| c.members }.flatten.uniq
  end

  def title
    self.name || "#{I18n.l(date_and_time, format: :month)} Meeting"
  end

  def to_param
    slug
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  def past?
    date_and_time < Time.zone.today
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

  def set_slug
    self.slug = "#{I18n.l(date_and_time, format: :year_month).downcase}-#{title.parameterize}" if self.slug.nil?
  end

  def attendees_array
    invitations.accepted.map { |a| [a.member.full_name] }
  end
end
