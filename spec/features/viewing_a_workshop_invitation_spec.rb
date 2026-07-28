RSpec.feature 'Viewing a workshop invitation', :wip, type: :feature do
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop) }

  before do
    visit invitation_path(invitation)
  end

  context 'physical workshop' do
    let(:workshop) { Fabricate(:workshop) }

    scenario 'workshop and page title' do
      expect(page).to have_title("Workshop invitation - #{humanize_date(workshop.date_and_time)}")
      expect(page).to have_text("Workshop at #{workshop.host.name}")
    end

    describe '#introduction' do
      context 'student' do
        scenario 'displays information for a physical workshop' do
          expect(page).to have_text('Please make sure you bring your laptop')
        end
      end

      context 'coach' do
        scenario 'displays information for a physical workshop' do
          expect(page).to have_text('PS: There will also be food at the workshop.')
        end
      end
    end

    scenario 'venue name and address' do
      within '#venue' do
        expect(page).to have_text(workshop.host.name)

        within '#address' do
          expect(page).to have_text(workshop.host.address.street)
          expect(page).to have_text(workshop.host.address.city)
        end
      end
    end

    describe '#description' do
      let(:workshop) { Fabricate(:workshop, description: "<a href='http://a.link.com'> Follow link </a>") }

      it 'contains details about the workshop and renders user defined HTML' do
        within '#info' do
          expect(page).to have_text('Information about the workshop')
          expect(page).to have_link('Follow link', href: 'http://a.link.com')
          expect(page).to have_no_text('How to join')
        end
      end
    end

    include_examples 'viewing workshop details'
  end

  context 'virtual workshop' do
    let(:workshop) { Fabricate(:virtual_workshop_sponsored) }

    scenario 'workshop and page title' do
      expect(page).to have_title("Workshop invitation - #{humanize_date(workshop.date_and_time)}")
      expect(page).to have_text("Virtual workshop for #{workshop.chapter.name}")
    end

    describe '#introduction' do
      context 'student' do
        scenario 'does not display information about the physical workshop' do
          expect(page).to have_no_text('Please make sure you bring your laptop')
        end
      end

      context 'coach' do
        scenario 'does not displays information about the physical workshop' do
          expect(page).to have_no_text('PS: There will also be food at the workshop.')
        end
      end
    end

    describe '#description' do
      context 'when RSVPed' do
        let(:invitation) { Fabricate(:attending_workshop_invitation, workshop: workshop) }

        it 'contains details about the workshop' do
          within '#info' do
            expect(page).to have_text('Information about the workshop')
          end
        end

        it 'contains details about how to join the workshop' do
          expect(page).to have_text('How to join')
          within '#join-info' do
            expect(page).to have_text("Join ##{workshop.slack_channel}")
            expect(page).to have_link(href: I18n.t('social_media_links.slack_html'))
          end
        end
      end
    end

    include_examples 'viewing workshop details'
  end
end
