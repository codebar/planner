class Course < ActiveRecord::Base
  include Listable

  has_many :invitations, class_name: "CourseInvitation"
  has_many :course_tutors
  has_many :tutors, through: :course_tutors, class_name: "Member"
  belongs_to :sponsor

  belongs_to :tutor, class_name: 'Member', foreign_key: 'tutor_id'

  before_save :set_slug

  validates :title, presence: true

  def attending
    invitations.accepted
  end

  def to_param
    slug
  end

  def to_s
    title
  end

  private

  def set_slug
    self.slug = title.parameterize if self.slug.nil?
  end

end
