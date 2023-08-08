class ChangeTestimonialStringToText < ActiveRecord::Migration[4.2]
  def change
    change_column :testimonials, :text, :text
  end
end
