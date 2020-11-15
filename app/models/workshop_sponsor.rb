class WorkshopSponsor < ApplicationRecord
  belongs_to :sponsor
  belongs_to :workshop

  validates :sponsor_id, uniqueness: { scope: :workshop_id, message: :already_sponsoring }

  scope :hosts, -> { where('workshop_sponsors.host = ?', true) }
  scope :for_workshop, ->(workshop_id) { where('workshop_sponsors.workshop_id = ?', workshop_id) }
end
