class AddCreatedByIdToWorkshops < ActiveRecord::Migration[8.1]
  def change
    add_column :workshops, :created_by_id, :integer
    safety_assured do
      add_foreign_key :workshops, :members, column: :created_by_id, on_delete: :nullify
    end
  end
end
