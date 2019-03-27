class ExtendJobModel < ActiveRecord::Migration
  def change
    add_column :jobs, :company_website, :string
    add_column :jobs, :company_address, :string
    add_column :jobs, :company_postcode, :string
    add_column :jobs, :published_on, :datetime
    add_column :jobs, :remote, :boolean
    add_column :jobs, :salary, :integer
  end
end
