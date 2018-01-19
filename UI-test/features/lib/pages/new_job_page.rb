require 'capybara'

class NewJobPage
  include Capybara::DSL

  SIDEBAR_MENU = 'Menu' unless const_defined?(:SIDEBAR_MENU)
  JOB_LINK = 'List a job' unless const_defined?(:JOB_LINK)
  JOB_TITLE_ID = 'job_title' unless const_defined?(:JOB_TITLE_ID)
  JOB_COMPANY_ID = 'job_company' unless const_defined?(:JOB_COMPANY_ID)
  JOB_LOCATION_ID = 'job_location' unless const_defined?(:JOB_LOCATION_ID)
  JOB_DESCRIPTION_ID = 'job_description' unless const_defined?(:JOB_DESCRIPTION_ID)
  JOB_WEBPAGE_ID = 'job_link_to_job' unless const_defined?(:JOB_WEBPAGE_ID)
  JOB_DATE_DAY_ID = 'job_expiry_date_3i' unless const_defined?(:JOB_DATE_DAY_ID)


  def visit_homepage
    visit('localhost:3000/')
  end

  def open_sidebar_menu
    click_link(SIDEBAR_MENU)
  end

  def click_job_link
    click_link(JOB_LINK)
  end

  def post_a_job_page
    find('h2', text: 'Post a job', exact: true)
  end

  def job_checkbox_work_details
    check('work-details')
    check('roles')
    check('pay')
    check('short')
    uncheck('short')
  end

  def job_title_form_details
    find_field(JOB_TITLE_ID)
    fill_in(JOB_TITLE_ID, with: 'Tutor')
  end

  def job_company_form_details
    find_field(JOB_COMPANY_ID)
    fill_in(JOB_COMPANY_ID, with: 'Sparta Global')
  end

  def job_location_form_details
    find_field(JOB_LOCATION_ID)
    fill_in(JOB_LOCATION_ID, with: 'Richmond, London')
  end

  def job_description_form_details
    find_field(JOB_DESCRIPTION_ID)
    fill_in(JOB_DESCRIPTION_ID, with: 'This is a job description')
  end

  def job_webpage_form_details
    find_field(JOB_WEBPAGE_ID)
    fill_in(JOB_WEBPAGE_ID, with: 'https://indeed.co.uk')
  end

  def job_day_sel_form
    # find_field(JOB_DATE_DAY_ID)
    find(JOB_DATE_DAY_ID).click
    select('3', from: JOB_DATE_DAY_ID)
  end




end
