class CreateTestimonials < ActiveRecord::Migration[4.2]
  def change
    create_table :testimonials do |t|
      t.references :member, index: true
      t.string :text

      t.timestamps
    end
  end
end
