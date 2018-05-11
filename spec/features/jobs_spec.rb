require 'spec_helper'

feature 'Jobs' do
  context 'Listing' do
    context 'a visitor to the website' do
      scenario 'can see a message when there are no available jobs' do
        visit root_path
        click_link('Jobs', match: :first)

        expect(page).to have_content('Jobs')
        expect(page).to have_content('There are no jobs available')
      end

      scenario 'can view all active jobs' do
        jobs = Fabricate.times(3, :job)
        expired = 3.times.map { |i| Fabricate.create(:job, expiry_date: 2.days.ago) }
        visit jobs_path

        expect(page).to have_content('Jobs')
        jobs.each do |job|
          expect(page).to have_content(job.title)
          expired.each { |expired_job| expect(page).to_not have_content(expired_job.title) }
        end
      end

      context 'viewing individual job posts' do
        it 'when a job post is active' do
          job = Fabricate(:job)
          visit job_path(job)

          expect(page).to have_content(job.title)
        end

        it 'when a job post has expired' do
          job = Fabricate(:job, expiry_date: 1.week.ago)
          visit job_path(job)

          expect(page).to have_content(job.title)
          expect(page).to have_content('This job post has expired')
        end
      end
    end

    context 'a member' do
      let(:member) { Fabricate(:member) }

      before do
        login(member)
      end

      scenario 'can create a new job' do
        visit new_job_path

        fill_in 'Job title', with: 'Internship'
        fill_in 'Company', with: 'codebar'
        fill_in 'Location', with: 'London'
        fill_in 'Description', with: Faker::Lorem.paragraph
        fill_in 'Link to job post', with: Faker::Internet.url

        click_on 'Submit job'

        expect(page).to have_content('This is a preview. Submit to verify your post or Edit to amend.')
      end

      it 'can preview their job post' do
        job = Fabricate(:job, submitted: false, approved: false, created_by: member)

        visit job_preview_path(job)

        expect(page).to have_content('This is a preview. Submit to verify your post or Edit to amend.')
        expect(page).to have_content(job.title)
      end

      it 'can submit their job post' do
        job = Fabricate(:job, submitted: false, approved: false, created_by: member)

        visit job_preview_path(job)
        click_on 'Submit'

        expect(page).to have_content('Job submitted. You will receive an email when the job has ben approved.')
      end

      scenario 'can not edit an approved job' do
        approved_job =  Fabricate(:job, created_by: member)
        visit edit_job_path(approved_job)

        expect(page).to have_content('As the post has already been approved if you need to make any amendments please get in touch with the organisers at london@codebar.io.')
      end

      scenario 'can view job posts pending approval' do
        job =  Fabricate(:job, created_by: member, submitted: false)
        visit pending_jobs_path

        expect(page).to have_content(job.title)
      end
    end
  end
end
