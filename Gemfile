source 'https://rubygems.org'
ruby '2.1.5'

gem 'rails', '4.1.9'

gem 'haml'
gem 'sass-rails', '~> 4.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'turbolinks'
gem 'simple_form'
gem 'draper'
gem 'font-awesome-rails'
gem 'github-markdown'
gem 'premailer-rails'
gem 'nokogiri'
gem 'pickadate-rails'
gem 'rolify'
gem "pundit"
gem 'carrierwave'
gem 'carrierwave-ftp', :require => 'carrierwave/storage/sftp'
gem 'mini_magick'

gem 'omniauth'
gem 'omniauth-github'

gem 'foundation-rails'
gem 'tzinfo-data'
gem 'icalendar'

gem 'gibbon'

group :development do
  #  gem 'letter_opener'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'fabrication' # Generator for fake models/objects
  gem 'faker' # Generator for fake names, emails, urls, and other data
  gem 'pg'
  gem 'coveralls', require: false # Code coverage reports on Github
  gem 'launchy' # Open things in a browser automatically
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger' # A collection of debugging gems, mostly Pry
  gem 'pry-byebug'
  gem 'pry-remote' # Connect to Pry remotely, handy if you're using Pow
  gem 'dotenv-rails' # Secret management in .env file
end

group :test do
  gem 'capybara'
  gem 'database_cleaner' # Quickly empty the database fter tests
  gem 'poltergeist' # Driver for PhantomJS, so we can unit test JavaScript
end

group :production do
  gem 'puma' # Alternative Rack HTTP server
  gem 'rails_12factor' # Helper gem for configuring an app a la Heroku
end

gem 'jbuilder'

group :doc do
  gem 'sdoc', require: false
end
