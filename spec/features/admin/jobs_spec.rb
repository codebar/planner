require 'spec_helper'

feature 'Admin Jobs' do
  let(:member) { Fabricate(:member) }

  before do
    login_as_admin(member)
  end

  scenario 'An admin can view jobs pending approval' do
    job = Fabricate(:job, approved: false)
    approved_job = Fabricate(:job)

    visit admin_jobs_path
    expect(page).to have_content(job.title)
    expect(page).to_not have_content(approved_job.title)
  end

  scenario 'An admin can view jobs pending approval' do
    job = Fabricate(:job, approved: false)
    approved_job = Fabricate(:job)

    visit admin_jobs_path
    expect(page).to have_content(job.title)
    expect(page).to_not have_content(approved_job.title)
  end

  scenario 'An organiser can approve jobs' do
    job = Fabricate(:job, approved: false)
    visit admin_jobs_path
    click_on job.title

    click_on "Approve"

    expect(page).to have_content("The job has been approved and an email has been sent out to #{job.created_by.full_name} at #{job.created_by.email}")

    visit admin_jobs_path

    expect(page).to_not have_content(job.title)

  end

end
