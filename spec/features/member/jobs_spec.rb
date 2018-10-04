require 'spec_helper'

feature 'Member managing jobs' do
  let(:member) { Fabricate(:member) }

  before do
    login(member)
  end

  context 'viewing their jobs' do
    scenario 'can view all jobs they posted' do
      jobs = Fabricate.times(3, :job, created_by: member)
      pending = Fabricate.times(2, :job, approved: false, created_by: member)
      drafts = Fabricate.times(3, :job, submitted: false, approved: false, created_by: member)
      visit member_jobs_path

      expect(page).to have_content('Posted (3)')
      expect(page).to have_content('Pending (2)')
      expect(page).to have_content('Drafts (3)')
    end

    it 'an approved job redirects to the job post' do
      job = Fabricate(:job, approved: true, created_by: member)

      visit member_jobs_path
      click_on job.title

      expect(page.current_path).to eq(job_path(job))
    end

    it 'drafts job post take a user to the preview job post' do
      job = Fabricate(:job, submitted: true, approved: false, created_by: member)

      visit member_jobs_path
      click_on job.title

      expect(page.current_path).to eq(member_job_preview_path(job))
    end

    it 'pending job post take a user to the preview job post' do
      job = Fabricate(:job, submitted: false, approved: false, created_by: member)

      visit member_jobs_path
      click_on job.title

      expect(page.current_path).to eq(member_job_preview_path(job))
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

      expect(page).to have_content('This is a preview. Submit to verify your post or Edit to amend.')
    end
  end

  it 'can preview their job post' do
    job = Fabricate(:job, submitted: false, approved: false, created_by: member)

    visit member_job_preview_path(job)

    expect(page).to have_content('This is a preview. Submit to verify your post or Edit to amend.')
    expect(page).to have_content(job.title)
  end

  it 'can submit their job post' do
    job = Fabricate(:job, submitted: false, approved: false, created_by: member)

    visit member_job_preview_path(job)
    click_on 'Submit'

    expect(page).to have_content('Job submitted. You will receive an email when the job has ben approved.')
  end

  context '#edit' do
    scenario 'can edit their job' do
      job =  Fabricate(:job, approved: false, created_by: member)
      visit edit_member_job_path(job)

      fill_in 'Title', with: 'JavaScript Internship'
      click_on 'Submit'

      expect(page).to have_content('The job has been updated')
    end

    scenario 'can not reset  mandatory fields' do
      job =  Fabricate(:job, approved: false, created_by: member)
      visit edit_member_job_path(job)

      fill_in 'Title', with: ''
      click_on 'Submit'

      expect(page).to have_content('Title can\'t be blank')
    end

    scenario 'can not edit an approved job' do
      approved_job =  Fabricate(:job, created_by: member)
      visit edit_member_job_path(approved_job)

      expect(page).to have_content('You cannot edit a job that has already been approved.')
    end
  end
end
