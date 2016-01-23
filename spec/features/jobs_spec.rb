require 'spec_helper'

feature 'Jobs' do

  context 'Listing' do
    context 'a non-logged in visitor to the website' do
      scenario 'cannot access the job listing' do
        visit jobs_path

        expect(page).to_not have_content("Jobs")
        expect(page).to have_content("You must be logged in to access this page")

      end

      context 'a member' do
        let(:member) { Fabricate(:member) }

        before do
          login(member)
        end

        scenario 'can see a message when there are no available jobs' do
          visit root_path
          click_on "Jobs"

          expect(page).to have_content("Jobs")
          expect(page).to have_content("There are no jobs available at the moment")
        end


        scenario 'can see a listing of all non expired job posts' do
          jobs = 2.times.map {  Fabricate.create(:job) }
          expired = 3.times.map {  Fabricate.create(:job, expiry_date: Date.today-2.day) }

          visit root_path
          click_on "Jobs"
          jobs.each do |job|
            expect(page).to have_content(job.title)
          end
          expect(page).to_not have_content(expired.first.title)
        end
      end
    end
  end
end
