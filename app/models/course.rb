class Course < ActiveRecord::Base
  has_many :course_invitations
  belongs_to :tutor, class_name: 'Member', foreign_key: 'tutor_id'

  before_save :set_slug

  validates :title, presence: true

  scope :upcoming, -> { where("date_and_time >= ?", DateTime.now).order(:date_and_time) }
  scope :past, -> { where("date_and_time < ?", DateTime.now).order(:date_and_time) }

  def attending_invitations
    course_invitations.accepted
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = title.parameterize if self.slug.nil?
  end

end
