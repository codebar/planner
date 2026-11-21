class PairingInvitation < ApplicationRecord
  belongs_to :pairing
  belongs_to :invitation

  # An invitation can only belong to one active pairing/group at a time.
  validates :invitation_id, uniqueness: true
end
