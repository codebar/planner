class AddEmailTypeToMemberEmailDeliveries < ActiveRecord::Migration[8.1]
  def change
    # 'chaser' backfills existing rows (the only mailer action logging today);
    # the default is then dropped so every writer must set the type explicitly.
    add_column :member_email_deliveries, :email_type, :string, default: 'chaser', null: false
    change_column_default :member_email_deliveries, :email_type, from: 'chaser', to: nil
  end
end
