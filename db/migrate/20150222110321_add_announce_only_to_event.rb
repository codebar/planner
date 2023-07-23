class AddAnnounceOnlyToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :announce_only, :boolean, defaults: false
    add_column :events, :url, :string, defaults: nil
    add_column :events, :email, :string, defaults: nil
  end
end
