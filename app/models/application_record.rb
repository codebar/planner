# See https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0
class ApplicationRecord < ActiveRecord::Base
    primary_abstract_class
end
