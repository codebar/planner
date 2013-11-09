class SponsorSession < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :sessions

  validates :host, uniqueness: { scope: :sessions_id }

  scope :hosts, -> { where('sponsor_sessions.host = ?', true) }
  scope :for_session, ->(session_id)  { where('sponsor_sessions.sessions_id = ?', session_id) }
end
