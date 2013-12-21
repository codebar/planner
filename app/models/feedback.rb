class Feedback < ActiveRecord::Base
  belongs_to :tutorial
  belongs_to :coach, class_name: "Member" 

  validates :coach, presence: true
  validate :coach_field_has_a_coach_role?

  def coach_field_has_a_coach_role?
  	return false unless coach_id

  	coach_roles = Member.find(coach_id).roles.select { |role| role.name == 'Coach' }
  	if coach_roles.empty?
  		errors.add(:coach, "Coach member doesn't have 'coach' role.")
  	end
  end
end