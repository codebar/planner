require 'spec_helper'
RSpec.feature 'Viewing a workshop invitation', type: :feature, wip: true do
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop) }

  before do
    visit invitation_path(invitation)
  end

  context 'physical workshop' do
    let(:workshop) { Fabricate(:workshop) }

    scenario 'workshop and page title' do
      expect(page).to have_title("Workshop invitation - #{humanize_date(workshop.date_and_time)}")
      expect(page).to have_content("Workshop at #{workshop.host.name}")
    end

    context '#introduction' do
      context 'student' do
        scenario 'displays information for a physical workshop' do
          expect(page).to have_content('Please make sure you bring your laptop')
        end
      end

      context 'coach' do
        scenario 'displays information for a physical workshop' do
          expect(page).to have_content('PS: There will also be food at the workshop.')
        end
      end
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

    context '#description' do
      it 'contains details about the workshop' do
        within '#info' do
          expect(page).to have_content('Information about the workshop')
          expect(page).to_not have_content('How to join')
        end
      end
    end

    include_examples "viewing workshop details"
  end

  context 'virtual workshop' do
    let(:workshop) { Fabricate(:virtual_workshop) }

    scenario 'workshop and page title' do
      expect(page).to have_title("Workshop invitation - #{humanize_date(workshop.date_and_time)}")
      expect(page).to have_content("Virtual workshop for #{workshop.chapter.name}")
    end

    context '#introduction' do
      context 'student' do
        scenario 'does not display information about the physical workshop' do
          expect(page).to_not have_content('Please make sure you bring your laptop')
        end
      end

      context 'coach' do
        scenario 'does not displays information about the physical workshop' do
          expect(page).to_not have_content('PS: There will also be food at the workshop.')
        end
      end
    end

    context '#description' do
      it 'contains details about the workshop' do
        within '#info' do
          expect(page).to have_content('Information about the workshop')
        end
      end

      context 'when RSVPed' do
        let(:invitation) { Fabricate(:attending_workshop_invitation, workshop: workshop) }

        it 'contains details about how to join the workshop' do
          expect(page).to have_content('How to join')
        end
      end
    end

    include_examples "viewing workshop details"

  end
end
