source 'https://rubygems.org'
ruby '3.2.2'

gem 'rails', '7.0.8.1'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'acts-as-taggable-on'
gem 'carrierwave'
gem 'carrierwave-ftp', github: 'luan/carrierwave-ftp', ref: '5481c13', require: 'carrierwave/storage/sftp'
gem 'cocoon'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'font_awesome5_rails'
gem 'bootstrap', '~> 5'
gem 'friendly_id'
gem 'haml'
gem 'high_voltage'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'
gem 'nokogiri'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'pickadate-rails'
gem 'premailer-rails'

gem 'pundit'
gem 'rails4-autocomplete'
gem 'rolify'
# Use Sass to process CSS
gem 'sassc-rails'
gem 'simple_form'

gem 'terser'

gem 'pagy'

gem 'icalendar'
gem 'tzinfo-data'

gem 'chosen-rails'
gem 'commonmarker'

gem 'gibbon', '~> 3.5.0'

gem 'stripe'

gem 'rails-html-sanitizer', '~> 1.6.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.6'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'
gem 'public_activity'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.3'
  gem 'listen', '~> 3.9'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'fabrication'
  gem 'faker'
  gem 'launchy'
  gem 'pry-byebug'
  gem 'pry-remote'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'bullet'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 6.2'
  gem 'simplecov',      require: false
  gem 'simplecov-lcov', require: false
  gem 'timecop', '~> 0.9.8'
end

group :production do
  gem 'foreman'
  gem 'rails_12factor'
end

gem 'rollbar'
gem 'skylight'
