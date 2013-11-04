class Sessions < ActiveRecord::Base
  include Invitable

  has_many :invitations, class_name: "SessionInvitation"
  has_many :sponsor_sessions
  has_many :sponsors, through: :sponsor_sessions

  scope :upcoming, -> { where("date_and_time >= ?", DateTime.now).order(:date_and_time) }
  scope :next, ->  { upcoming.first }

  def host
    Sponsor.joins(:sponsor_sessions)
      .where('sponsor_sessions.host = ?', true)
      .where('sponsor_sessions.sessions_id = ?', self.id).first
  end
end
