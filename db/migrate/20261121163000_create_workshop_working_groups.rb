class CreateWorkshopWorkingGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :workshop_working_groups do |t|
      t.references :workshop, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :workshop_working_groups, %i[workshop_id position]

    create_table :workshop_invitation_working_groups do |t|
      t.references :workshop_working_group,
                   null: false,
                   foreign_key: true,
                   index: { name: 'index_wi_working_groups_on_working_group_id' }
      t.references :workshop_invitation,
                   null: false,
                   foreign_key: true,
                   index: { unique: true, name: 'index_wi_working_groups_on_invitation_id' }

      t.timestamps
    end

    add_column :workshop_invitations, :checked_in_at, :datetime
  end
end
