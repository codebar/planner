require 'spec_helper'

RSpec.feature 'Admin Jobs', type: :feature do
  let(:member) { Fabricate(:member) }

  context 'an admin' do
    before do
      login_as_admin(member)
    end

    scenario 'can view a list of all submitted job' do
      Fabricate.times(4, :published_job)
      Fabricate.times(3, :pending_job)
      Fabricate(:job, title: 'Expired developer', expiry_date: Time.zone.today - 1.week)

      visit admin_jobs_path
      expect(page.all(:xpath, "//td/span[text()='Approved']").count).to eq(4)
      expect(page.all(:xpath, "//td/span[text()='Pending approval']").count).to eq(3)
    end

    scenario 'can view a paginated listing' do
      Fabricate.times(3, :published_job)
      Fabricate.times(10, :pending_job)

      visit admin_jobs_path

      expect(page).to have_content("Displaying jobs 1 - 10 of 13 in total")
      expect(page.all(:xpath, "//td/span[text()='Pending approval']").count).to eq(10)
      click_on 'Next'
      expect(page.all(:xpath, "//td/span[text()='Approved']").count).to eq(3)
    end

    scenario 'can approve jobs' do
      job = Fabricate(:pending_job)
      visit admin_jobs_path
      click_on job.title

      click_on 'Approve'

      expect(page).to have_content("The job has been approved and an email has been sent out to #{job.created_by.full_name} at #{job.created_by.email}")

      visit admin_jobs_path
      click_on job.title

      expect(page).to have_content("Approved by #{job.reload.approved_by.full_name}")
    end
  end

  context 'an organiser' do
    before do
      login_as_organiser(member, Fabricate(:chapter))
    end

    scenario 'cannot access the jobs admin area' do
      visit admin_jobs_path

      expect(page).to have_content('You can\'t be here')
    end
  end
end
