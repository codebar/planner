class Event < ActiveRecord::Base
  include Listable
  include Invitable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  belongs_to :venue, class: Sponsor
  has_many :sponsorships
  has_many :sponsors, through: :sponsorships

  has_many :invitations

  validates :info, :schedule, :description, :coach_description, presence: true

  def to_s
    self.name
  end

  def to_param
    self.slug
  end

  def verified_coaches
    invitations.coaches.accepted.verified.map(&:member)
  end

  def verified_students
    invitations.students.accepted.verified.map(&:member)
  end

  def coach_spaces?
    coach_spaces > attending_coaches.count
  end

  def student_spaces?
    student_spaces > attending_students.count
  end
end
