class SponsorSession < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :sessions

  validates :sponsor_id, uniqueness: { scope: :sessions_id, message: "already a sponsor" }

  scope :hosts, -> { where('sponsor_sessions.host = ?', true) }
  scope :for_session, ->(session_id)  { where('sponsor_sessions.sessions_id = ?', session_id) }
end
