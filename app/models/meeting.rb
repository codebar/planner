class Meeting < ActiveRecord::Base
  include Listable
  include Invitable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :organisers, -> { where("permissions.name" => "organiser") }, through: :permissions, source: :members
  belongs_to :venue, class_name: "Sponsor"
  has_many :meeting_invitations

  validates :date_and_time, :venue, presence: true

  before_save :set_slug

  def title
    self.name or "#{I18n.l(date_and_time, format: :month)} Meeting"
  end

  def to_s
    title
  end

  def to_param
    slug
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  def attending?(member)
    MeetingInvitation.where(meeting: self, member: member, attending: true).present?
  end

  private

  def set_slug
    self.slug = "#{I18n.l(date_and_time, format: :year_month).downcase}-#{title.parameterize}" if self.slug.nil?
  end

end
