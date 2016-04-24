class AddExternalEventLinkToEvent < ActiveRecord::Migration
  def change
    add_column :events, :external_url, :string
  end
end
