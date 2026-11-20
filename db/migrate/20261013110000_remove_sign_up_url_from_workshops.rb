class RemoveSignUpUrlFromWorkshops < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :workshops, :sign_up_url, :string }
  end
end
