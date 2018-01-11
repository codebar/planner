class RenamePermissionsResourceTypeValueToWorkshop < ActiveRecord::Migration
  def change
    session_permissions = Permission.where(resource_type: 'Sessions')

    session_permissions.each do |permission|
      permission.update_attribute(:resource_type, 'Workshop')
    end
  end
end
