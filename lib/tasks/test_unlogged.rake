namespace :db do
  namespace :test do
    desc "Convert all tables to UNLOGGED for faster test performance"
    task unlogged: :environment do
      raise "This task only works in test environment" unless Rails.env.test?

      tables = ActiveRecord::Base.connection.tables
      converted = 0
      tables.each do |table|
        next if table == "schema_migrations" || table == "ar_internal_metadata"
        result = ActiveRecord::Base.connection.execute(
          "SELECT relpersistence FROM pg_class WHERE relname = '#{table}'"
        )
        if result.first && result.first["relpersistence"] != "u"
          ActiveRecord::Base.connection.execute("ALTER TABLE #{table} SET UNLOGGED")
          converted += 1
        end
      end
      puts "Converted #{converted} tables to UNLOGGED" if converted > 0
    end
  end
end

# Auto-run after db:test:prepare
Rake::Task["db:test:prepare"].enhance do
  Rake::Task["db:test:unlogged"].invoke if Rails.env.test?
end