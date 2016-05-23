class AddMoreFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :confirmation_required, :boolean, default: false
    add_column :events, :surveys_required, :boolean, default: false
  end
end
