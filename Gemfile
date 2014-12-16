source 'https://rubygems.org'
ruby '2.1.2'

gem 'rails', '4.1.5'

gem 'haml' # Simple markup for HTML and email templates
gem 'sass-rails', '~> 4.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'turbolinks' # Load new pages via AJAX for performance
gem 'simple_form' # Form generation library for more concise markup
gem 'draper' # Componentise view elements. Deprecated; use SimpleDelegator instead.
gem 'font-awesome-rails' # Icon font
gem 'github-markdown' # Use Github's markdown parser.
gem 'premailer-rails' # Automatically inline CSS rules in HTML emails
gem 'nokogiri' # XML parsing library
gem 'pickadate-rails' # Pickadate.js date picker component
gem 'rolify' # Role-based permissions for individual resources
gem "pundit" # Simple authorization/policy library
gem 'cloudinary' # Upload images to the cloud
gem 'carrierwave' # File attachments
gem 'mini_magick' # Smaller ImageMagick-like image processing library

gem 'omniauth'
gem 'omniauth-github'

gem 'foundation-rails' # Foundation CSS framework

gem 'tzinfo-data' # More timezone data

gem 'icalendar' # Export data in iCal format

group :development do
  gem 'letter_opener' # Open emails in the browser
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'fabrication' # Generator for fake models/objects
  gem 'faker' # Generator for fake names, emails, urls, and other data
  gem 'sqlite3'
  gem 'coveralls', require: false # Code coverage reports on Github
  gem 'launchy' # Open things in a browser automatically
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger' # A collection of debugging gems, mostly Pry
  gem 'pry-byebug'
  gem 'dotenv-rails' # Secret management in .env file
end

group :test do
  gem 'capybara'
  gem 'database_cleaner' # Quickly empty the database fter tests
  gem 'poltergeist' # Driver for PhantomJS, so we can unit test JavaScript
end

group :production do
  gem 'pg'
  gem 'puma' # Alternative Rack HTTP server
  gem 'rails_12factor' # Helper gem for configuring an app a la Heroku
end

gem 'jbuilder'

group :doc do
  gem 'sdoc', require: false
end
