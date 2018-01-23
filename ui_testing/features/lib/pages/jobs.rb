require 'capybara/dsl'

class Jobs
  include Capybara::DSL

  def find_title_jobs
    find('h1', text: 'Jobs')
  end
end
