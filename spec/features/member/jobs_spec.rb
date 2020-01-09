require 'spec_helper'

RSpec.feature 'Member managing jobs', type: :feature do
  let(:member) { Fabricate(:member) }

  before do
    login(member)
  end

  context 'viewing their jobs' do
    scenario 'can view all jobs they posted' do
      jobs = Fabricate.times(3, :published_job, created_by: member)
      pending_jobs = Fabricate.times(2, :pending_job, created_by: member)
      drafts = Fabricate.times(3, :job, created_by: member)
      visit member_jobs_path

      expect(page.all(:xpath, "//td/span[text()='Published']").count).to eq(3)
      expect(page.all(:xpath, "//td/span[text()='Pending approval']").count).to eq(2)
      expect(page.all(:xpath, "//td/span[text()='Draft']").count).to eq(3)
    end

    it 'an approved job renders the member job page' do
      job = Fabricate(:job, approved: true, created_by: member)

      visit member_jobs_path
      click_on job.title

      expect(page.current_path).to eq(member_job_path(job.id))
    end

    it 'drafts job post take a user to the member job page' do
      job = Fabricate(:job, submitted: true, approved: false, created_by: member)

      visit member_jobs_path
      click_on job.title

      expect(page.current_path).to eq(member_job_path(job.id))
    end

    it 'pending job post take a user to the member job post' do
      job = Fabricate(:job, submitted: false, approved: false, created_by: member)

      visit member_jobs_path
      click_on job.title

      expect(page.current_path).to eq(member_job_path(job.id))
    end
  end

  context 'creating a new job' do
    scenario 'is unsuccessful unless all mandatory fields are submitted' do
      visit new_member_job_path

      fill_in 'Name', with: 'codebar'
      click_on 'Submit job'

      expect(page).to have_content('Title can\'t be blank')
    end

    scenario 'is succesful when all madantory fields are submitted' do
      visit new_member_job_path

      fill_in 'Title', with: 'Internship'
      fill_in 'Description', with: Faker::Lorem.paragraph
      fill_in 'Name', with: 'codebar'
      fill_in 'Website', with: 'https://codebar.io'
      fill_in 'Location', with: 'London'
      fill_in 'Link to job post', with: Faker::Internet.url
      fill_in 'Application closing date', with: (Time.zone.now + 3.months).strftime('%d/%m/%y')

      click_on 'Submit job'

      expect(page).to have_content('This is a preview of your job.Edit to amend or Submit for approval')
    end

    scenario 'can view text that address and postcode fields are optional' do
      visit new_member_job_path

      expect(page).to have_content('The information below is only required if you want this job post to be shared with Google Search UK.')
    end
  end

  context 'viewing a job' do
    it 'renders a preview of the job' do
      job = Fabricate(:job, submitted: false, approved: false, created_by: member)

      visit member_job_path(job.id)

      expect(page).to have_content('This is a preview of your job.Edit to amend or Submit for approval')
      expect(page).to have_content(job.title)
    end

    it 'informs the user if a job has already been submitted' do
      job = Fabricate(:pending_job, created_by: member)
      visit member_job_path(job.id)

      expect(page).to have_content("This job is pending approval. Edit to amend your post.")
    end

    it 'allows the user to submit draft jobs' do
      job = Fabricate(:job, created_by: member)
      visit member_job_path(job.id)

      expect(page).to have_content('This is a preview of your job.Edit to amend or Submit for approval.')

      click_on 'Submit'
      expect(page).to have_content("Job submitted for approval. You will receive an email when it's been approved.")
    end
  end

  context '#edit' do
    scenario 'can edit their job' do
      job =  Fabricate(:job, approved: false, created_by: member)
      visit edit_member_job_path(job.id)

      fill_in 'Title', with: 'JavaScript Internship'
      click_on 'Submit'

      expect(page).to have_content('Your job has been updated')
    end

    scenario 'can not reset  mandatory fields' do
      job =  Fabricate(:job, approved: false, created_by: member)
      visit edit_member_job_path(job.id)

      fill_in 'Title', with: ''
      click_on 'Submit'

      expect(page).to have_content('Title can\'t be blank')
    end

    scenario 'can not edit an approved job' do
      approved_job =  Fabricate(:published_job, created_by: member)
      visit edit_member_job_path(approved_job.id)

      expect(page).to have_content('You cannot edit a job that has already been approved.')
    end
  end
end
