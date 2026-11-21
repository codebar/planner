# Additive concern keeping an Invitation's pairing membership in sync
# declaratively with its attendance and verification state.
module PairableInvitation
  extend ActiveSupport::Concern

  included do
    has_one :pairing_invitation, dependent: :destroy

    after_commit :sync_pairing_membership, if: :pairing_relevant_change?
  end

  def checked_in_for_pairing?
    attending? && verified? && !for_participant?
  end

  private

  def pairing_relevant_change?
    saved_change_to_verified? || saved_change_to_attending?
  end

  def sync_pairing_membership
    if checked_in_for_pairing?
      Pairing.check_in!(self)
    else
      Pairing.remove!(self)
    end
  end
end
