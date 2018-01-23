class RolifyCreatePermissions < ActiveRecord::Migration
  def change
    create_table(:permissions) do |t|
      t.string :name
      t.references :resource, polymorphic: true

      t.timestamps
    end

    create_table(:members_permissions, id: false) do |t|
      t.references :member
      t.references :permission
    end

    add_index(:permissions, :name)
    add_index(:permissions, %i[name resource_type resource_id])
    add_index(:members_permissions, %i[member_id permission_id])
  end
end
