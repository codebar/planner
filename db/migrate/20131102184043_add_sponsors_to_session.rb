class AddSponsorsToSession < ActiveRecord::Migration
  def change
    add_reference :sponsors, :sessions, index: true
  end
end
