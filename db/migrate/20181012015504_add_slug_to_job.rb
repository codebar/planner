class AddSlugToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :slug, :string
  end
end
