require 'spec_helper'

RSpec.feature 'Admin::Sponsors', type: :feature do
  let(:manager) { Fabricate(:member) }

  before do
    login_as_admin(manager)
  end

  context 'Sponsor page' do
    let(:sponsor) { Fabricate(:sponsor_full) }

    before(:each) do
      visit admin_sponsor_path(sponsor)
    end

    scenario 'displays all sponsor details' do
      expect(page).to have_content(sponsor.name)
      expect(page).to have_content(sponsor.description)
      expect(page).to have_link(sponsor.website)
      expect(page).to have_content(sponsor.level)
      expect(page).to have_content(SponsorPresenter.new(sponsor).contact_info)

      expect(page).to have_content(sponsor.seats)
      expect(page).to have_content(sponsor.coach_spots)
      expect(page).to have_content(sponsor.accessibility_info)
      expect(page).to have_content(sponsor.address.street)
    end

    context 'sponsorships' do
      scenario 'when no sponsorships' do
        within '#sponsorships' do
          expect(page).to have_content('No sponsorships')
          expect(page).to_not have_content('Workshops')
          expect(page).to_not have_content('Events')
          expect(page).to_not have_content('Meetings')
        end
      end

      scenario 'when there are workshop sponsorships' do
        sponsored_workshop = Fabricate(:workshop_sponsor, sponsor: sponsor).workshop
        hosted_workshop = Fabricate(:workshop_sponsor, sponsor: sponsor, host: true).workshop
        visit admin_sponsor_path(sponsor)

        within '#sponsorships' do
          expect(page).to have_content('Workshops')
          expect(page).to have_content("#{sponsored_workshop.chapter.name}")
          expect(page).to have_content("#{hosted_workshop.chapter.name} (host)")
        end
      end

      scenario 'when there are event sponsorships' do
        gold_event = Fabricate(:sponsorship, sponsor: sponsor, level: 'gold').event
        silver_event = Fabricate(:sponsorship, sponsor: sponsor, level: 'silver').event

        visit admin_sponsor_path(sponsor)

        within '#sponsorships' do
          expect(page).to have_content('Events')
          expect(page).to have_content("#{gold_event.to_s} - GOLD")
          expect(page).to have_content("#{silver_event} - SILVER")
        end
      end

      scenario 'when there are meeting sponsorships' do
        meeting = Fabricate(:meeting, venue: sponsor)

        visit admin_sponsor_path(sponsor)

        within '#sponsorships' do
          expect(page).to have_content('Meetings')
          expect(page).to have_content(meeting.title)
        end
      end
    end
  end

  context 'Sponsor contacts page' do
    let!(:sponsor) { Fabricate(:sponsor_with_contacts) }
    let!(:sponsor_no_contacts) { Fabricate(:sponsor) }

    scenario 'displays all sponsor contacts' do
      visit admin_contacts_path

      expect(page).to have_content(sponsor.name)
      expect(page).to have_content(sponsor.contacts.first.name)
      expect(page).to_not have_content(sponsor_no_contacts.name)
    end
  end
end
