class AddSlugToMeeting < ActiveRecord::Migration[4.2]
  def change
    add_column :meetings, :slug, :string
  end
end
