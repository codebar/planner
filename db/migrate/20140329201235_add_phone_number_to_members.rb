class AddPhoneNumberToMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :mobile, :string
  end
end
