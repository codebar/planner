class AddPreferredPronounToMember < ActiveRecord::Migration
  def change
    add_column :members, :preferred_pronoun, :string
  end
end
