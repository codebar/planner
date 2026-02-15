class WorkshopSponsor < ApplicationRecord
  belongs_to :sponsor
  belongs_to :workshop

  validates :sponsor_id, uniqueness: { scope: :workshop_id, message: :already_sponsoring }

  def set_as_host!
    update!(host: true)
  end

  def remove_as_host!
    update!(host: false)
  end
end
