class AddSlugToMeeting < ActiveRecord::Migration
  def change
    add_column :meetings, :slug, :string
  end
end
