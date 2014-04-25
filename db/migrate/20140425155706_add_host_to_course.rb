class AddHostToCourse < ActiveRecord::Migration
  def change
    add_reference :courses, :sponsor, index: true
  end
end
