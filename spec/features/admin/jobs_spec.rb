require 'spec_helper'

feature 'Admin Jobs' do
  let(:member) { Fabricate(:member) }

  before do
    login_as_admin(member)
  end

  context 'admins/jobs' do
    scenario 'Renders a list of all submitted job' do
      Fabricate.times(4, :published_job)
      Fabricate.times(3, :pending_job)
      Fabricate(:job, title: 'Expired developer', expiry_date: Time.zone.today - 1.week)

      visit admin_jobs_path
      expect(page.all(:xpath, "//td/span[text()='Approved']").count).to eq(4)
      expect(page.all(:xpath, "//td/span[text()='Pending approval']").count).to eq(3)
    end

    scenario 'The listing is paginated' do
      Fabricate.times(3, :published_job)
      Fabricate.times(10, :pending_job)

      visit admin_jobs_path

      expect(page).to have_content("Displaying jobs 1 - 10 of 13 in total")
      expect(page.all(:xpath, "//td/span[text()='Pending approval']").count).to eq(10)
      click_on 'Next'
      expect(page.all(:xpath, "//td/span[text()='Approved']").count).to eq(3)
    end
  end

  scenario 'An organiser can approve jobs' do
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
