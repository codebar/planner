class AddTicketUrlToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :ticket_url, :string
  end
end
