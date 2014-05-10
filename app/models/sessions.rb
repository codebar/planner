class Sessions < ActiveRecord::Base
  include Invitable
  include Listable

  has_many :invitations, class_name: "SessionInvitation"
  has_many :sponsor_sessions
  has_many :sponsors, through: :sponsor_sessions

  default_scope { order('date_and_time DESC') }

  def host
    SponsorSession.hosts.for_session(self.id).first.sponsor
  end

  def to_s
    "Workshop"
  end

  def location
    host.address.city rescue ""
  end
end
