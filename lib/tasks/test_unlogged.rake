namespace :db do
  namespace :test do
    desc "Convert all tables to UNLOGGED for faster test performance"
    task unlogged: :environment do
      raise "This task only works in test environment" unless Rails.env.test?

      tables = ActiveRecord::Base.connection.tables
      tables.each do |table|
        next if table == "schema_migrations" || table == "ar_internal_metadata"
        puts "Converting #{table} to UNLOGGED..."
        ActiveRecord::Base.connection.execute("ALTER TABLE #{table} SET UNLOGGED")
      end
      puts "Converted #{tables.size} tables to UNLOGGED"
    end
  end
end
