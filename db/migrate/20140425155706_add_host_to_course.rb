class AddHostToCourse < ActiveRecord::Migration[4.2]
  def change
    add_reference :courses, :sponsor, index: true
  end
end
