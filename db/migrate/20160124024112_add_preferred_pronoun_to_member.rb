class AddPreferredPronounToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :preferred_pronoun, :string
  end
end
