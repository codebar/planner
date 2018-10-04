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

      context 'can view job posts' do
        it 'when a job post is active' do
          job = Fabricate(:job)
          visit job_path(job)

          expect(page).to have_content(job.title)
        end

        context 'location' do
          it 'when a job post is remote is set to remote' do
            job = Fabricate(:published_job, remote: true)
            visit job_path(job)

            within('.location') do
              expect(page).to have_content("Remote")
            end
          end

          it 'when a job post is not set to remote' do
            job = Fabricate(:published_job)
            visit job_path(job)

            within('.location') do
              expect(page).to have_content(job.location)
            end
          end
        end

        context 'salary' do
          it 'is formatted correctly when the salary is set' do
            job = Fabricate(:published_job, salary: 30000)
            visit job_path(job)

            within('.salary') do
              expect(page).to have_content('£30,000')
            end
          end
        end

        it 'when a job post has expired' do
          job = Fabricate(:job, expiry_date: 1.week.ago)
          visit job_path(job)

          expect(page).to have_content(job.title)
          expect(page).to have_content('This job post has expired')
        end
      end
    end
  end
end
