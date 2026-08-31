class RemoveMemberTypeFromMemberEmailDeliveries < ActiveRecord::Migration[8.1]
  def change
    # Safe to drop in a single phase: no code reads or writes member_type
    # (introduced in PR #2449 for polymorphism that was never built, and
    # NULL in every production row). Recipients are always Members, so
    # re-add with a polymorphic association if non-member recipients arrive.
    safety_assured { remove_column :member_email_deliveries, :member_type, :string }
  end
end
