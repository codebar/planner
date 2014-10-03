class CreateTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.references :member, index: true
      t.text :text

      t.timestamps
    end
  end
end
