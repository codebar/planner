class Sessions < ActiveRecord::Base

  has_many :invitations
  has_many :sponsors

  scope :upcoming, ->  { where("date_and_time > ?",  DateTime.now) }

  def attending_invitations
    invitations.accepted
  end
end
