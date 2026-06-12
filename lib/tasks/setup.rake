# frozen_string_literal: true

namespace :setup do
  desc 'Inspect your local development environment and report what is missing or misconfigured'
  task check: :environment do
    checker = SetupChecker.new
    checker.run
    exit(checker.all_ok? ? 0 : 1)
  end

  class SetupChecker
    CHECKS = [
      :check_ruby_version,
      :check_bundler,
      :check_mise,
      :check_postgresql,
      :check_imagemagick,
      :check_github_credentials,
      :check_bundle,
      :check_database_connection,
      :check_database_exists,
      :check_database_migrated,
      :check_test_database
    ].freeze

    def initialize
      @results = []
      @expected_ruby = File.read('.ruby-version').strip
    end

    def run
      puts
      puts '== codebar planner setup check =='
      puts
      puts 'This command inspects your local development environment and reports'
      puts 'anything that needs attention before you can run the application.'
      puts

      CHECKS.each { |check| send(check) }

      print_summary
    end

    def all_ok?
      @results.none? { |r| r[:status] == :error }
    end

    private

    def ok(title, message)
      @results << { status: :ok, title:, message: }
      puts "  ✅  #{title}: #{message}"
    end

    def warn(title, message, fix)
      @results << { status: :warn, title:, message:, fix: }
      puts "  ⚠️  #{title}: #{message}"
      puts "      → #{fix}"
    end

    def error(title, message, fix)
      @results << { status: :error, title:, message:, fix: }
      puts "  ❌  #{title}: #{message}"
      puts "      → #{fix}"
    end

    def check_ruby_version
      current = RUBY_VERSION
      if current == @expected_ruby
        ok('Ruby version', "#{current} (matches .ruby-version)")
      else
        error('Ruby version', "#{current} (expected #{@expected_ruby})",
              "Install Ruby #{@expected_ruby}. See docs/development-setup.md for options.")
      end
    end

    def check_bundler
      if system('which bundle > /dev/null 2>&1')
        ok('Bundler', 'installed')
      else
        error('Bundler', 'not found',
              'Run: gem install bundler')
      end
    end

    def check_mise
      if system('which mise > /dev/null 2>&1')
        ok('mise', 'installed')
      else
        warn('mise', 'not found',
             'Optional but recommended. Install: brew install mise (macOS) or see https://mise.jdx.dev')
      end
    end

    def check_postgresql
      if !system('which psql > /dev/null 2>&1')
        error('PostgreSQL', 'psql not found',
              'Install: brew install postgresql && brew services start postgresql (macOS) or see docs/development-setup.md')
        return
      end

      # Check if postgres is accepting connections
      db_config = ActiveRecord::Base.connection_db_config.configuration_hash
      host = db_config[:host] || 'localhost'
      port = db_config[:port] || 5432
      user = db_config[:username] || ENV['USER']
      password = db_config[:password]

      env = password ? { 'PGPASSWORD' => password } : {}
      cmd = "PGPASSWORD=#{password} psql -h #{host} -p #{port} -U #{user} -c 'SELECT 1' > /dev/null 2>&1"
      if system(env, cmd)
        ok('PostgreSQL', "running and accepting connections on #{host}:#{port}")
      else
        error('PostgreSQL', "not accepting connections on #{host}:#{port}",
              'Start PostgreSQL: brew services start postgresql (macOS). Check credentials in config/database.yml or env vars.')
      end
    end

    def check_imagemagick
      if system('which convert > /dev/null 2>&1')
        ok('ImageMagick', 'installed')
      else
        error('ImageMagick', 'not found (convert command missing)',
              'Install: brew install imagemagick (macOS) or see docs/development-setup.md')
      end
    end

    def check_github_credentials
      if !File.exist?('mise.local.toml')
        error('GitHub OAuth', 'mise.local.toml not found',
              'Copy: cp mise.local.toml.example mise.local.toml, then edit with your GitHub app credentials.')
        return
      end

      content = File.read('mise.local.toml')
      if content.include?('your_github_oauth') || content.include?('your_') || content.include?('fill_in')
        error('GitHub OAuth', 'mise.local.toml contains placeholder values',
              'Edit mise.local.toml with real GITHUB_KEY and GITHUB_SECRET from your GitHub OAuth app.')
      else
        ok('GitHub OAuth', 'mise.local.toml configured')
      end
    end

    def check_bundle
      if system('bundle check > /dev/null 2>&1')
        ok('Ruby dependencies', 'all gems installed')
      else
        error('Ruby dependencies', 'missing gems',
              'Run: bundle install')
      end
    end

    def check_database_connection
      begin
        ActiveRecord::Base.connection.execute('SELECT 1')
        ok('Database connection', 'can connect to PostgreSQL')
      rescue StandardError => e
        error('Database connection', "cannot connect (#{e.class}: #{e.message})",
              'Check PostgreSQL is running and credentials in config/database.yml are correct.')
      end
    end

    def check_database_exists
      begin
        ActiveRecord::Base.connection.execute('SELECT 1')
        if ActiveRecord::Base.connection.execute("SELECT 1 FROM pg_database WHERE datname = 'planner_development'").any?
          ok('Development database', 'planner_development exists')
        else
          error('Development database', 'planner_development does not exist',
                'Run: bundle exec rake db:create')
        end
      rescue StandardError => e
        error('Development database', "cannot check (#{e.class}: #{e.message})",
              'Run: bundle exec rake db:create')
      end
    end

    def check_database_migrated
      begin
        if ActiveRecord::Base.connection.execute("SELECT 1 FROM schema_migrations LIMIT 1")
          latest = ActiveRecord::Base.connection.execute(
            "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
          ).first
          if latest
            ok('Database migrations', "up to date (latest: #{latest['version']})")
          else
            error('Database migrations', 'no migrations found',
                  'Run: bundle exec rake db:migrate')
          end
        end
      rescue StandardError => e
        error('Database migrations', "cannot check (#{e.class}: #{e.message})",
              'Run: bundle exec rake db:migrate')
      end
    end

    def check_test_database
      db_config = Rails.configuration.database_configuration['test']
      host = db_config['host'] || 'localhost'
      port = db_config['port'] || 5432
      user = db_config['username'] || ENV['USER']
      password = db_config['password']
      database = db_config['database']

      env = password ? { 'PGPASSWORD' => password } : {}
      cmd = "PGPASSWORD=#{password} psql -h #{host} -p #{port} -U #{user} -c 'SELECT 1' #{database} > /dev/null 2>&1"
      if system(env, cmd)
        ok('Test database', "#{database} exists and is accessible")
      else
        error('Test database', "#{database} missing or not accessible",
              'Run: bundle exec rake db:test:prepare')
      end
    end

    def print_summary
      puts
      errors = @results.count { |r| r[:status] == :error }
      warnings = @results.count { |r| r[:status] == :warn }
      ok_count = @results.count { |r| r[:status] == :ok }

      if errors.zero? && warnings.zero?
        puts "✅ All checks passed! Your environment is ready for development."
        puts
        puts "Next steps:"
        puts "  bundle exec rails server       # Start the app"
        puts "  bundle exec rspec              # Run the test suite"
        puts "  bundle exec rake db:seed       # (Optional) Add sample data"
      elsif errors.zero?
        puts "⚠️  #{warnings} warning(s). You can probably start developing, but review the warnings above."
      else
        puts "❌  #{errors} error(s) and #{warnings} warning(s) need attention before you can start developing."
      end
      puts
    end
  end
end
