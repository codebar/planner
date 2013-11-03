class SponsorSession < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :sessions
end