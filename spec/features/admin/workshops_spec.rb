require 'spec_helper'

RSpec.feature 'An admin managing workshops', type: :feature do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }
  let!(:sponsor) { Fabricate(:sponsor) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, Chapter)
  end

  context '#views' do
    scenario 'list of all chapter workshops' do
      workshops = Fabricate.times(5, :workshop, chapter: chapter)
      visit admin_chapter_workshops_path(chapter)

      workshops.each do |workshop|
        expect(page).to have_content(humanize_date(workshop.date_and_time, with_time: true, with_year: true))
      end
    end

    context 'virtual workshop' do
      let(:workshop) { Fabricate(:virtual_workshop) }

      before do
        visit admin_workshop_path(workshop)
      end

      scenario 'displays details specific to a virtual workshop' do
        expect(page).to have_content('Virtual workshop details')
        expect(page).to have_content("Slack channel: ##{workshop.slack_channel}")
        expect(page).to have_content('codebar Discord')
      end

      scenario 'displays the available student coach workshop spots' do
        expect(page).to have_content("#{workshop.student_spaces} student spots, #{workshop.coach_spaces} coach spots")
      end
    end
  end

  context '#creation' do
    context 'creating a workshop' do
      scenario 'requires a host and a start and end datetime to be set' do
        visit new_admin_workshop_path

        select chapter.name
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'
        fill_in 'Ends at', with: '12:45'

        within '#host' do
          select sponsor.name
        end

        click_on 'Save'

        expect(page).to have_content('Workshop successfully created')
        expect(page).to have_content '11:30 - 12:45 BST (GMT+01:00)'
        expect(page).to have_content 'Invite'
      end

      scenario 'must have a chapter set' do
        visit new_admin_workshop_path

        within '#host' do
          select sponsor.name
        end

        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'

        click_on 'Save'

        expect(page).to have_content('Chapter can\'t be blank')
      end

      scenario 'must have a host set' do
        visit new_admin_workshop_path

        select chapter.name
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'

        click_on 'Save'

        expect(page).to have_content("Host can't be blank")
      end

      scenario 'can have sponsors assigned' do
        workshop = Fabricate(:workshop)
        visit edit_admin_workshop_path(workshop)

        select sponsor.name, from: 'workshop_sponsor_ids'

        click_on 'Save'

        within '#sponsors' do
          expect(page).to have_content sponsor.name
        end
      end

      scenario 'displays the correct timezone for the workshop' do
        chapter = Fabricate(:chapter, time_zone: 'Berlin')
        visit new_admin_workshop_path

        select chapter.name
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '18:30'
        fill_in 'Ends at', with: '20:45'

        within '#host' do
          select sponsor.name
        end

        click_on 'Save'

        expect(page).to have_content('Workshop successfully created')
        expect(page).to have_content '18:30 - 20:45 CEST (GMT+02:00)'
      end
    end

    context 'creating a virtual workshop' do
      scenario 'must have all the required details set' do
        visit new_admin_workshop_path

        check 'Virtual'

        select chapter.name
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'

        click_on 'Save'

        expect(page).to have_content("Slack channel can't be blank")
        expect(page).to have_content("Slack channel link can't be blank")
        expect(page).to have_content('Student spaces must be greater than 0')
        expect(page).to have_content('Coach spaces must be greater than 0')
      end

      scenario 'does not require a host to be set' do
        visit new_admin_workshop_path

        check 'Virtual'
        fill_in 'Slack channel', with: '#channel'
        fill_in 'Slack channel link', with: 'https://channel-link'
        fill_in 'Student spaces', with: '10'
        fill_in 'Coach spaces', with: '5'

        select chapter.name
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'
        fill_in 'Ends at', with: '14:30'

        click_on 'Save'

        expect(page).to have_content('Workshop successfully created')
        expect(page).to have_content 'Invite'
      end
    end
  end


  context '#actions' do
    context 'sending invitations to attendees' do
      scenario 'for a workshop' do
        workshop = Fabricate(:workshop)
        expect(InvitationManager).to receive_message_chain(:new, :send_workshop_emails)

        visit admin_workshop_send_invites_path(workshop)
        click_on 'Students'

        expect(page).to have_content('Invitations to students are being emailed out')
      end

      scenario 'for a virtual workshop' do
        workshop = Fabricate(:virtual_workshop)
        expect(InvitationManager).to receive_message_chain(:new, :send_virtual_workshop_emails)

        visit admin_workshop_send_invites_path(workshop)
        click_on 'Students'

        expect(page).to have_content('Invitations to students are being emailed out')
      end
    end

    scenario 'viewing a text file with all attendee emails' do
      workshop = Fabricate(:workshop)
      attendees = Fabricate.times(4, :attending_workshop_invitation, workshop: workshop)
      attendees_emails = attendees.map(&:member).map(&:email)
      visit admin_workshop_attendees_emails_path(workshop, format: :text)

      attendees_emails.each do |email|
        expect(page).to have_content(email)
      end
    end

    context 'attendee names list' do
      scenario 'viewing a text file with all names' do
        workshop = Fabricate(:workshop)
        attendees = Fabricate.times(4, :attending_workshop_invitation, workshop: workshop)
        visit admin_workshop_attendees_checklist_path(workshop, format: :text)
        attendees.map(&:member).map(&:full_name).each do |name|
          expect(page).to have_content(name)
        end
      end

      scenario 'viewing an error message when the requested list format is invalid' do
        workshop = Fabricate(:workshop)
        visit admin_workshop_attendees_checklist_path(workshop)

        expect(page.current_path).to eq(admin_workshop_path(workshop))
        expect(page).to have_content('The requested format is invalid: text/html')
      end
    end

    context 'attendee CSV' do
      it 'returns a CSV with all workshop attendees' do
        workshop = Fabricate(:workshop)
        visit admin_workshop_path(workshop)
        click_on 'Pairing CSV'

        expect(page.current_path).to eq(admin_workshop_path(workshop, format: 'csv'))
        expect(page).to have_content(WorkshopPresenter::PAIRING_HEADINGS.join(','))
        expect(page).not_to have_content('ORGANISER')
      end
    end

    context 'Labels' do
      it 'returns a CSV with all workshop participants that can be used to generate the labels' do
        workshop = Fabricate(:workshop)
        visit admin_workshop_path(workshop)
        click_on 'Labels'

        expect(page.current_path).to eq(admin_workshop_path(workshop, format: 'csv'))
        expect(page).to have_content('ORGANISER')
        expect(page).not_to have_content(WorkshopPresenter::PAIRING_HEADINGS.join(','))
      end
    end
  end
end
