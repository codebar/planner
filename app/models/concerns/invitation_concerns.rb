module InvitationConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    belongs_to :member

    before_create :set_token
    after_create :email

    validates :token, uniqueness: true

    scope :accepted, ->  { where(attending: true) }

  end

  module InstanceMethods
    def to_param
      token
    end

    def student_spaces?
      role.eql?("Student") and sessions.student_spaces?
    end

    def coach_spaces?
      role.eql?("Coach") and sessions.coach_spaces?
    end

    private

    def set_token
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless self.class.where(token: random_token).exists?
      end
    end
  end
end
