class Course < ActiveRecord::Base
  include Listable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :invitations, class_name: 'CourseInvitation'
  has_many :course_tutors
  has_many :tutors, through: :course_tutors, class_name: 'Member'
  belongs_to :sponsor
  belongs_to :chapter

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

  def time
    date_and_time.time
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  private

  def set_slug
    self.slug = title.parameterize if self.slug.nil?
  end
end
