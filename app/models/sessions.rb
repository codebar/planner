class Sessions < ActiveRecord::Base
  include Invitable
  include Listable

  has_many :invitations, class_name: "SessionInvitation"
  has_many :sponsor_sessions
  has_many :sponsors, through: :sponsor_sessions

  def host
    SponsorSession.hosts.for_session(self.id).first.sponsor
  end
end
