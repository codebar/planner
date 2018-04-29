require 'spec_helper'

feature 'Jobs' do
  context 'Listing' do
    context 'a non-logged in visitor to the website' do
      scenario 'to be able to access the job listing' do
        visit jobs_path

        expect(page).to have_content('Jobs')
        expect(page).to have_content('There are no jobs available at the moment')
      end

      context 'a member' do
        let(:member) { Fabricate(:member) }

        before do
          login(member)
        end

        scenario 'can see a message when there are no available jobs' do
          visit root_path
          click_link('Jobs', match: :first)

          expect(page).to have_content('Jobs')
          expect(page).to have_content('There are no jobs available at the moment')
        end


        scenario 'can see a listing of all non expired job posts' do
          jobs = 2.times.map { |i| Fabricate.create(:job, title: "Current Dev #{i}") }
          expired = 3.times.map { |i| Fabricate.create(:job, title: "Expired Dev #{i}", expiry_date: Time.zone.today - 2.days) }

          visit root_path
          click_link('Jobs', match: :first)
          jobs.each do |job|
            expect(page).to have_content(job.title)
          end
          expect(page).to_not have_content(expired.first.title)
        end

        scenario 'can view an approved job listing' do
          job = Fabricate.create(:job)

          visit root_path
          click_link('Jobs', match: :first)
          click_on job.title

          expect(page).to have_content(job.description)
          expect(page).to have_content("Posted by #{job.created_by.full_name}")
        end

        scenario 'can preview and list a new job' do
          visit new_job_path

          fill_in 'Job title', with: 'Internship'
          fill_in 'Company', with: 'codebar'
          fill_in 'Location', with: 'London'
          fill_in 'Description', with: Faker::Lorem.paragraph
          fill_in 'Link to job post', with: Faker::Internet.url

          click_on 'Submit job'

          expect(page).to have_content('This is a preview. Submit to verify your post or Edit to amend.')

          click_on 'Submit'
          expect(page).to have_content('Job submitted. You will receive an email when the job has ben approved.')
        end

        scenario 'can preview, edit and list a new job' do
          visit new_job_path

          fill_in 'Job title', with: 'Internship'
          fill_in 'Company', with: 'codebar'
          fill_in 'Location', with: 'London'
          fill_in 'Description', with: Faker::Lorem.paragraph
          fill_in 'Link to job post', with: Faker::Internet.url

          click_on 'Submit job'

          expect(page).to have_content('This is a preview. Submit to verify your post or Edit to amend.')
          expect(page).to have_content('Internship')

          click_on 'Edit'

          fill_in 'Job title', with: 'Junior developer'
          click_on 'Submit job'

          expect(page).to have_content('Junior developer')

          click_on 'Submit'

          expect(page).to have_content('Job submitted. You will receive an email when the job has ben approved.')
        end

        scenario 'can not edit their listing after it''s approved' do
          approved_job =  Fabricate(:job, created_by: member)
          visit edit_job_path(approved_job)

          expect(page).to have_content('As the post has already been approved if you need to make any amendments please get in touch with the organisers at london@codebar.io.')
        end
      end
    end
  end
end
