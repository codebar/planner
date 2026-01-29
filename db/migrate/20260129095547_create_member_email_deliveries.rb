class CreateMemberEmailDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :member_email_deliveries, id: :serial do |t|
      t.references :member, foreign_key: true
      t.text    :subject
      t.text    :body
      t.text    :to,  array: true, default: []
      t.text    :cc,  array: true, default: []
      t.text    :bcc, array: true, default: []

      t.timestamps
    end
  end
end
