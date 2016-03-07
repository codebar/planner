class SponsorSession < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :workshop

  validates :sponsor_id, uniqueness: { scope: :workshop_id, message: "already a sponsor" }

  scope :hosts, -> { where('sponsor_sessions.host = ?', true) }
  scope :for_session, ->(workshop_id)  { where('sponsor_sessions.workshop_id = ?', workshop_id) }
end
