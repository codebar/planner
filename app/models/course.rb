class Course < ActiveRecord::Base
  include Invitable
  include Listable

  has_many :invitations, class_name: "CourseInvitation"
  belongs_to :tutor, class_name: 'Member', foreign_key: 'tutor_id'

  before_save :set_slug

  validates :title, presence: true

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = title.parameterize if self.slug.nil?
  end

end
