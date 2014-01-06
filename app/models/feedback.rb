class Feedback < ActiveRecord::Base
  belongs_to :tutorial
  belongs_to :coach, class_name: "Member" 

  validates :rating, presence: true,  numericality: true, :inclusion => 1..5
  validates :coach, presence: true
  validates :tutorial, presence: true
  validate :coach_field_has_a_coach_role?

  def coach_field_has_a_coach_role?
  	return false unless coach_id

  	coach_roles = Member.find(coach_id).roles.select { |role| role.name == 'Coach' }
  	if coach_roles.empty?
  		errors.add(:coach, "Coach member doesn't have 'coach' role.")
  	end
  end

  def self.submit_feedback params
    return false unless Feedback.new(params).valid?
    
    feedback = Feedback.find_by_token(params[:token])
    
    if feedback
      feedback.update_attributes(params)
    else
      false
    end
  end

  def self.create_token token
    Feedback.new(token: token).save(validate: false) unless token.blank?
  end

end