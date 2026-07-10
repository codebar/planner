module InvitationConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    belongs_to :member

    validates :token, uniqueness: true

    scope :accepted, -> { where(attending: true) }
    scope :not_accepted, -> { where('attending is NULL or attending = false') }
    scope :upcoming_rsvps, -> { accepted.where('date_and_time >= ?', Time.zone.now) }
    scope :past_rsvps, -> { accepted.taken_place }
    scope :taken_place, -> { where('date_and_time < ?', Time.zone.now) }

    before_create :set_token
    after_save :clear_member_cache, if: :saved_change_to_attending?
  end

  module InstanceMethods
    def to_param
      token
    end

    def for_student?
      role.eql?('Student')
    end

    def for_coach?
      role.eql?('Coach')
    end

    def for_participant?
      role.eql?('Participant') # meetings do not distinguish
    end

    private

    def clear_member_cache
      member.clear_attending_event_ids_cache!
    end

    def set_token
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless self.class.where(token: random_token).exists?
      end
    end
  end
end
