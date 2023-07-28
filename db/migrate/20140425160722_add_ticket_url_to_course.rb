class AddTicketUrlToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :ticket_url, :string
  end
end
