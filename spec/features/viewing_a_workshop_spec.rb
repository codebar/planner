require 'spec_helper'
RSpec.feature 'Viewing a workshop page', type: :feature do
  context 'visitor' do
    before do
      visit workshop_path(workshop)
    end

    context 'workshop' do
      let(:workshop) { Fabricate(:workshop) }

      describe '#details' do
        scenario 'workshop and page title' do
          expect(page).to have_title("Workshop at #{workshop.host.name} - #{humanize_date(workshop.date_and_time)}")
          expect(page).to have_content("Workshop at #{workshop.host.name}")
        end

        scenario 'venue name and address' do
          within '#venue' do
            expect(page).to have_content(workshop.host.name)

            within '#address' do
              expect(page).to have_content(workshop.host.address.street)
              expect(page).to have_content(workshop.host.address.city)
            end
          end
        end

        scenario 'sponsors' do
          within '#sponsors' do
            workshop.sponsors.each do |sponsor|
              expect(page).to have_content(sponsor.name)
            end
          end
        end

        scenario 'organisers' do
          within '#organisers' do
            expect(page).to have_content('Organisers')

            workshop.organisers.each do |organiser|
              expect(page).to have_content(organiser.full_name)
            end
          end
        end
      end

      describe '#actions' do
        scenario 'signing up or signing in' do
          expect(page).to have_content('Sign up')
          expect(page).to have_content('Log in')
        end
      end
    end

    context 'virtual workshop' do
      let(:workshop) { Fabricate(:virtual_workshop) }

      describe '#details' do
        scenario 'workshop and page title' do
          expect(page)
            .to have_title("Virtual workshop for #{workshop.chapter.name} - #{humanize_date(workshop.date_and_time)}")
          expect(page).to have_content("Virtual workshop for #{workshop.chapter.name}")
        end

        scenario 'workshop info' do
          within '#banner' do
            expect(page).to have_content('Participate in our workshops')
            expect(page).to have_content('Our virtual workshops take place online')

            within '.lead.description' do
              expect(page).to have_content(workshop.description)
            end
          end
        end

        scenario 'sponsors' do
          within '#sponsors' do
            workshop.sponsors.each do |sponsor|
              expect(page).to have_content(sponsor.name)
            end
          end
        end

        scenario 'organisers' do
          within '#organisers' do
            expect(page).to have_content('Organisers')

            workshop.organisers.each do |organiser|
              expect(page).to have_content(organiser.full_name)
            end
          end
        end
      end

      describe '#actions' do
        scenario 'signing up or signing in' do
          expect(page).to have_content('Sign up')
          expect(page).to have_content('Log in')
        end
      end
    end
  end
end
