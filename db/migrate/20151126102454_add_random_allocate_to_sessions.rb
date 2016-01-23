class AddRandomAllocateToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :random_allocate_at, :datetime
  end
end
