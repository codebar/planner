require 'capybara'

class JobPost
  include Capybara::DSL

  JOB_LINK = 'Jobs' unless const_defined?(:JOB_LINK)


  def click_job_link
    click_link(JOB_LINK)
  end


end
