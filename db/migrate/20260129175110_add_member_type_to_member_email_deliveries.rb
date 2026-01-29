class AddMemberTypeToMemberEmailDeliveries < ActiveRecord::Migration[7.2]
  def change
    add_column :member_email_deliveries, :member_type, :string
  end
end
