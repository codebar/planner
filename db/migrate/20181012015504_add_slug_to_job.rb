class AddSlugToJob < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :slug, :string
  end
end
