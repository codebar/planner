class AddExternalEventLinkToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :external_url, :string
  end
end
