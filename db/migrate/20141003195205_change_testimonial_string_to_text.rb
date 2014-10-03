class ChangeTestimonialStringToText < ActiveRecord::Migration
  def change
    change_column :testimonials, :text, :mediumtext
  end
end
