
# Wrapped to autoload safely at boot time
Rails.application.reloader.to_prepare do
  Rolify.configure('Permission') do |config|
    # By default ORM adapter is ActiveRecord. uncomment to use mongoid
    # config.use_mongoid
  
    # Dynamic shortcuts for User class (user.is_admin? like methods). Default is: false
    # Enable this feature _after_ running rake db:migrate as it relies on the roles table
    config.use_dynamic_shortcuts
  end
end
