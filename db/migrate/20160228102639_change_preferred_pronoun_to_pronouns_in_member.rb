class ChangePreferredPronounToPronounsInMember < ActiveRecord::Migration
  def change
    rename_column :members, :preferred_pronoun, :pronouns
  end
end
