require 'spec_helper'

RSpec.feature 'Admin::Sponsors', type: :feature do
  let(:manager) { Fabricate(:member) }

  before do
    login_as_admin(manager)
  end

  context 'Sponsors list' do
    let(:sponsor) { Fabricate(:sponsor_with_contacts) }
    let(:sponsor2) { Fabricate(:sponsor_with_contacts) }

    scenario 'can filter by chapter' do
      sponsored_workshop = Fabricate(:workshop_sponsor, sponsor: sponsor).workshop
      hosted_workshop = Fabricate(:workshop_sponsor, sponsor: sponsor2, host: true).workshop

      visit admin_sponsors_path

      expect(page).to have_content(sponsor.name)
      expect(page).to have_content(sponsor2.name)

      expect(page.all(:css, 'tbody tr', count: 2))

      expect(page).to have_content(hosted_workshop.chapter.name)
      expect(page).to have_content(sponsored_workshop.chapter.name)

      select sponsored_workshop.chapter.name, from: 'sponsors_search[chapter]'
      click_on 'Filter'

      expect(page.all(:css, 'tbody tr', count: 1))
    end

    scenario 'can filter by sponsor' do
      # Single workshop
      Fabricate(:workshop_sponsor, sponsor: sponsor)
      # Multiple works with the same sponsor and chapter
      chapter = Fabricate(:chapter)
      5.times do
        Fabricate(:workshop_sponsor, sponsor: sponsor2, workshop: Fabricate(:workshop_no_sponsor, chapter: chapter))
      end

      visit admin_sponsors_path

      expect(page).to have_content(sponsor.name)
      expect(page).to have_content(sponsor2.name)

      expect(page.all(:css, 'tbody tr', count: 2))

      # Make sure both sponsors can be filtered by
      [sponsor.name, sponsor2.name].each do |name|
        fill_in 'sponsors_search[name]', with: name
        click_on 'Filter'

        expect(page.all(:css, 'tbody tr', count: 1))
      end

      # Invalid sponsor name should return no results
      fill_in 'sponsors_search[name]', with: 'this-sponsor-does-not-exist'
      click_on 'Filter'

      expect(page.all(:css, 'tbody tr', count: 0))
      expect(page).to have_content('No sponsors found')
    end

    scenario 'can clear filtering form' do
      sponsored_workshop = Fabricate(:workshop_sponsor, sponsor: sponsor).workshop
      hosted_workshop = Fabricate(:workshop_sponsor, sponsor: sponsor2, host: true).workshop

      visit admin_sponsors_path

      expect(page).to have_content(sponsor.name)
      expect(page).to have_content(sponsor2.name)

      expect(page.all(:css, 'tbody tr', count: 2))

      expect(page).to have_content(hosted_workshop.chapter.name)
      expect(page).to have_content(sponsored_workshop.chapter.name)

      select sponsored_workshop.chapter.name, from: 'sponsors_search[chapter]'
      click_on 'Filter'

      expect(page.all(:css, 'tbody tr', count: 1))

      click_on 'Reset form'
      expect(page.all(:css, 'tbody tr', count: 2))
    end
  end

  context 'Sponsor page' do
    let(:sponsor) { Fabricate(:sponsor_with_contacts) }

    before(:each) do
      visit admin_sponsor_path(sponsor)
    end

    scenario 'displays all sponsor details' do
      expect(page).to have_content(sponsor.name)
      expect(page).to have_content(sponsor.description)
      expect(page).to have_link(sponsor.website, href: sponsor.website)
      expect(page).to have_content(sponsor.level)
      expect(page).to have_content(ContactPresenter.new(sponsor.contacts.first).full_name)

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
        standard_event = Fabricate(:sponsorship, sponsor: sponsor, level: nil).event

        visit admin_sponsor_path(sponsor)

        within '#sponsorships' do
          expect(page).to have_content('Events')
          expect(page).to have_content("#{gold_event.to_s} - GOLD")
          expect(page).to have_content("#{silver_event} - SILVER")
          expect(page).to have_content("#{standard_event} - Standard")
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

    context 'activities' do
      scenario 'when there are activities' do
        contact = sponsor.contacts.first
        audit = Auditor::Audit.new(sponsor, 'sponsor.admin_contact_subscribe', manager, contact)
        audit.log_with_note(contact.email)

        visit admin_sponsor_path(sponsor)

        within '#activities' do
          expect(page).to have_content("#{manager.full_name} subscribed #{contact.name} #{contact.surname} with email #{contact.email} to the Sponsor newsletter")
        end
      end

      scenario 'when an activity is associated with a deleted contact' do
        contact = sponsor.contacts.first
        audit = Auditor::Audit.new(sponsor, 'sponsor.admin_contact_subscribe', manager, contact)
        audit.log_with_note(contact.email)

        contact.delete

        visit admin_sponsor_path(sponsor)

        within '#activities' do
          expect(page).to_not have_content("#{manager.full_name} subscribed #{contact.name} #{contact.surname} with email #{contact.email} to the Sponsor newsletter")
        end
      end
    end
  end

  context 'Editing a sponsor' do
    let(:sponsor) { Fabricate(:sponsor_full) }

    it 'can set contact information' do
      visit edit_admin_sponsor_path(sponsor)


      click_on 'Add contact'
      fill_in 'sponsor_contacts_attributes_0_name', with: 'Jane'
      fill_in 'sponsor_contacts_attributes_0_surname', with: 'Doe'
      fill_in 'sponsor_contacts_attributes_0_email', with: 'jane@codebar.io'
      click_on 'Save changes'

      expect(page).to have_link('Jane Doe', href: 'mailto:jane@codebar.io')
    end

    it 'can subscribe a contact to the sponsor newsletter' do
      visit edit_admin_sponsor_path(sponsor)

      click_on 'Add contact'
      fill_in 'sponsor_contacts_attributes_0_name', with: 'Jane'
      fill_in 'sponsor_contacts_attributes_0_surname', with: 'Doe'
      fill_in 'sponsor_contacts_attributes_0_email', with: 'jane@codebar.io'
      check 'sponsor_contacts_attributes_0_mailing_list_consent'

      click_on 'Save changes'
      expect(page).to have_content("#{manager.full_name} subscribed Jane Doe with email jane@codebar.io to the Sponsor newsletter")
    end

    it 'can unsubscribe a contact to the sponsor newsletter', wip: true do
      contact = Fabricate(:contact, sponsor: sponsor, mailing_list_consent: true)
      visit edit_admin_sponsor_path(sponsor)

      uncheck 'sponsor_contacts_attributes_0_mailing_list_consent'
      click_on 'Save changes'

      expect(page).to have_content("#{manager.full_name} unsubscribed #{contact.name} #{contact.surname} with email #{contact.email} from the Sponsor newsletter")
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
