class ChangePreferredPronounToPronounsInMember < ActiveRecord::Migration[4.2]
  def change
    rename_column :members, :preferred_pronoun, :pronouns
  end
end
