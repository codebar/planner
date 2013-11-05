class SponsorSession < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :sessions

  validates :host, uniqueness: { scope: :sessions_id }

end
