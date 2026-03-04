class WorkshopSponsor < ApplicationRecord
  belongs_to :sponsor
  belongs_to :workshop, inverse_of: :workshop_sponsors

  validates :sponsor_id, uniqueness: { scope: :workshop_id, message: :already_sponsoring }
end
