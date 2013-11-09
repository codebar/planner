class Sessions < ActiveRecord::Base
  include Invitable

  has_many :invitations, class_name: "SessionInvitation"
  has_many :sponsor_sessions
  has_many :sponsors, through: :sponsor_sessions

  scope :upcoming, -> { where("date_and_time >= ?", DateTime.now).order(:date_and_time) }
  scope :next, ->  { upcoming.first }

  def host
    SponsorSession.hosts.for_session(self.id).first.sponsor
  end
end
