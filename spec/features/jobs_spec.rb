require 'spec_helper'

RSpec.feature 'Jobs', type: :feature do
  context 'Listing' do
    context 'a visitor to the website' do
      scenario 'can see the correct page title' do
        visit jobs_path

        expect(page).to have_title('Jobs | codebar.io')
      end

      scenario 'can see a message when there are no available jobs' do
        visit root_path
        click_link('Jobs', match: :first)

        expect(page).to have_content('Jobs')
        expect(page).to have_content('There are no jobs listed at this time. Please check back soon as positions get added regularly.')
      end

      scenario 'can view all active jobs' do
        jobs = Fabricate.times(3, :published_job)
        visit jobs_path

        expect(page).to have_content('Jobs')
        expect(page).to have_content('There are 3 jobs listed')

        jobs.each { |job| expect(page).to have_content(job.title) }
      end

      context 'can view job posts' do
        it 'can see the correct page title' do
          job = Fabricate(:published_job)
          visit job_path(job)

          expect(page).to have_title("#{job.title} | Jobs | codebar.io")
        end

        it 'when a job post is active' do
          job = Fabricate(:published_job)
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
          job = Fabricate(:published_job, expiry_date: 1.week.ago)
          visit job_path(job)

          expect(page).to have_content(job.title)
          expect(page).to have_content('This job post has expired')
        end
      end
    end
  end

  context 'The job page must contain JobPosting schema.org mark up' do
    it 'contains all the required data' do
      job = Fabricate(:published_job)
      visit job_path(job)

      expect(script_tag_content(wrapper_class: '.jobref'))
        .to eq(job_json_ld(job).to_json)
    end

    it 'correctly sets an additional property for remote jobs' do
      job = Fabricate(:published_job, remote: true)
      visit job_path(job)

      expect(script_tag_content(wrapper_class: '.jobref'))
        .to eq(remote_job_json_ld(job).to_json)
    end
  end
end
