class AddCompanyToJob < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :company, :string
  end
end
