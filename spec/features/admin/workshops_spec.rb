RSpec.feature 'An admin managing workshops', type: :feature do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }
  let!(:sponsor) { Fabricate(:sponsor) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, Chapter)
  end

  describe '#views' do
    scenario 'list of all chapter workshops' do
      workshops = Fabricate.times(2, :workshop, chapter: chapter)
      visit admin_chapter_workshops_path(chapter)

      workshops.each do |workshop|
        expect(page).to have_text(humanize_date(workshop.date_and_time, with_time: true, with_year: true))
      end
    end

    context 'with a virtual workshop' do
      let(:workshop) { Fabricate(:virtual_workshop) }

      before do
        visit admin_workshop_path(workshop)
      end

      scenario 'displays details specific to a virtual workshop' do
        expect(page).to have_text('Virtual workshop details')
        expect(page).to have_text("Slack channel: ##{workshop.slack_channel}")
        expect(page).to have_text('codebar Discord')
      end

      scenario 'displays the available student coach workshop spots' do
        expect(page).to have_text("#{workshop.student_spaces} student spots, #{workshop.coach_spaces} coach spots")
      end
    end
  end

  describe '#creation' do
    context 'when creating a workshop' do
      around do |example|
        travel_to Time.zone.local(2020, 12, 0o1, 0, 0, 0)
        example.run
        travel_back
      end

      scenario 'requires a host and a start and end datetime to be set' do
        visit new_admin_workshop_path

        fill_in 'workshop[chapter_id]', with: chapter.id
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'
        fill_in 'Ends at', with: '12:45'

        within '#host' do
          select sponsor.name
        end

        click_on 'Save'

        expect(page).to have_text('Workshop successfully created')
        expect(page).to have_text '11:30 - 12:45 GMT (GMT+00:00)'
        expect(page).to have_text 'Invite'
      end

      scenario 'must have a chapter set' do
        visit new_admin_workshop_path

        within '#host' do
          select sponsor.name
        end

        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'

        click_on 'Save'

        expect(page).to have_text('Chapter can\'t be blank')
      end

      scenario 'must have a host set' do
        visit new_admin_workshop_path

        fill_in 'workshop[chapter_id]', with: chapter.id
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'

        click_on 'Save'

        expect(page).to have_text("Host can't be blank")
      end

      scenario 'can have sponsors assigned' do
        workshop = Fabricate(:workshop)
        visit edit_admin_workshop_path(workshop)

        select sponsor.name, from: 'workshop_sponsor_ids'

        click_on 'Save'

        within '#sponsors' do
          expect(page).to have_text sponsor.name
        end
      end

      scenario 'displays the correct timezone for the workshop' do
        chapter = Fabricate(:chapter, time_zone: 'Berlin')
        visit new_admin_workshop_path

        fill_in 'workshop[chapter_id]', with: chapter.id
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '18:30'
        fill_in 'Ends at', with: '20:45'

        within '#host' do
          select sponsor.name
        end

        click_on 'Save'

        expect(page).to have_text('Workshop successfully created')
        expect(page).to have_text '18:30 - 20:45 CET (GMT+01:00)'
      end
    end

    context 'when creating a virtual workshop' do
      scenario 'must have all the required details set' do
        visit new_admin_workshop_path

        check 'Virtual'

        fill_in 'workshop[chapter_id]', with: chapter.id
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'

        click_on 'Save'

        expect(page).to have_text("Slack channel can't be blank")
        expect(page).to have_text("Slack channel link can't be blank")
        expect(page).to have_text('Student spaces must be greater than 0')
        expect(page).to have_text('Coach spaces must be greater than 0')
      end

      scenario 'does not require a host to be set' do
        visit new_admin_workshop_path

        check 'Virtual'
        fill_in 'Slack channel', with: '#channel'
        fill_in 'Slack channel link', with: 'https://channel-link'
        fill_in 'Student spaces', with: '10'
        fill_in 'Coach spaces', with: '5'

        fill_in 'workshop[chapter_id]', with: chapter.id
        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'
        fill_in 'Ends at', with: '14:30'

        click_on 'Save'

        expect(page).to have_text('Workshop successfully created')
        expect(page).to have_text 'Invite'
      end
    end

    context 'when creating a workshop from a chapter page' do
      around do |example|
        travel_to Time.zone.local(2020, 12, 0o1, 0, 0, 0)
        example.run
        travel_back
      end

      scenario 'pre-selects the chapter and allows organisers to be assigned' do
        kept_organiser = Fabricate(:member)
        removed_organiser = Fabricate(:member)
        kept_organiser.add_role(:organiser, chapter)
        removed_organiser.add_role(:organiser, chapter)

        visit admin_chapter_path(chapter)

        within('.col-12.col-lg-8') do
          click_on 'New workshop'
        end

        expect(page).to have_css('h1', text: "New Workshop for #{chapter.name}")
        expect(page).to have_title("New Workshop for #{chapter.name}")
        expect(page).to have_no_select('workshop_chapter_id')
        expect(page).to have_select('workshop_organisers', with_options: [kept_organiser.full_name, removed_organiser.full_name])

        unselect removed_organiser.full_name, from: 'workshop_organisers'

        fill_in 'Date', with: Date.current
        fill_in 'Begins at', with: '11:30'
        fill_in 'Ends at', with: '12:45'

        within '#host' do
          select sponsor.name
        end

        click_on 'Save'

        expect(page).to have_text('Workshop successfully created')
        workshop = Workshop.last
        expect(workshop.chapter).to eq(chapter)
        expect(workshop.organisers.map(&:id)).to include(kept_organiser.id)
        expect(workshop.organisers.map(&:id)).not_to include(removed_organiser.id)
      end

      scenario 'falls back to the standard form when chapter_id is invalid' do
        visit new_admin_workshop_path(chapter_id: 0)

        expect(page).to have_css('h1', text: 'New Workshop')
        expect(page).to have_title('New Workshop')
        expect(page).to have_field('workshop[chapter_id]')
        expect(page).to have_no_select('workshop_organisers')
      end
    end
  end

  context 'with dietary restrictions' do
    scenario 'displays dietary restriction badges for attendees' do
      workshop = Fabricate(:workshop)
      attendee = Fabricate(:attending_workshop_invitation, workshop: workshop)
      attendee.member.update(dietary_restrictions: %w[vegan gluten_free])

      visit admin_workshop_path(workshop)

      member_link = find('a', exact_text: attendee.member.full_name)
      sibling = member_link.find(:xpath, 'following-sibling::p')
      expect(sibling).to have_text('Vegan')
      expect(sibling).to have_text('Gluten free')
    end
  end

  describe '#actions' do
    context 'when sending invitations to attendees' do
      scenario 'for a workshop' do
        workshop = Fabricate(:workshop)
        allow(InvitationManager).to receive(:new).and_return(double.as_null_object)

        visit admin_workshop_send_invites_path(workshop)
        click_on 'Students'

        expect(InvitationManager).to have_received(:new)
        expect(page).to have_text('Invitations to students are being emailed out')
      end

      scenario 'for a virtual workshop' do
        workshop = Fabricate(:virtual_workshop)
        allow(InvitationManager).to receive(:new).and_return(double.as_null_object)

        visit admin_workshop_send_invites_path(workshop)
        click_on 'Students'

        expect(InvitationManager).to have_received(:new)
        expect(page).to have_text('Invitations to students are being emailed out')
      end
    end

    scenario 'viewing a text file with all attendee emails' do
      workshop = Fabricate(:workshop)
      attendees = Fabricate.times(2, :attending_workshop_invitation, workshop: workshop)
      attendees_emails = attendees.map(&:member).map(&:email)
      visit admin_workshop_attendees_emails_path(workshop, format: :text)

      attendees_emails.each do |email|
        expect(page).to have_text(email)
      end
    end

    context 'when viewing the attendee names list' do
      scenario 'viewing a text file with all names' do
        workshop = Fabricate(:workshop)
        attendees = Fabricate.times(2, :attending_workshop_invitation, workshop: workshop)
        visit admin_workshop_attendees_checklist_path(workshop, format: :text)
        attendees.map(&:member).map(&:full_name).each do |name|
          expect(page).to have_text(name)
        end
      end

      scenario 'viewing an error message when the requested list format is invalid' do
        workshop = Fabricate(:workshop)
        visit admin_workshop_attendees_checklist_path(workshop)

        expect(page).to have_current_path(admin_workshop_path(workshop), ignore_query: true)
        expect(page).to have_text('The requested format is invalid: text/html')
      end
    end

    context 'when viewing the attendee CSV' do
      it 'returns a CSV with all workshop attendees' do
        workshop = Fabricate(:workshop)
        visit admin_workshop_path(workshop)
        click_on 'Pairing CSV'

        expect(page).to have_current_path(admin_workshop_path(workshop, format: 'csv'), ignore_query: true)
        expect(page).to have_text(WorkshopPresenter::PAIRING_HEADINGS.join(','))
        expect(page).to have_no_text('ORGANISER')
      end
    end

    context 'with labels' do
      it 'returns a CSV with all workshop participants that can be used to generate the labels' do
        workshop = Fabricate(:workshop)
        # Add an organiser to ensure ORGANISER appears in the CSV
        organiser = Fabricate(:member)
        organiser.add_role :organiser, workshop.chapter

        visit admin_workshop_path(workshop)
        click_on 'Labels'

        expect(page).to have_current_path(admin_workshop_path(workshop, format: 'csv'), ignore_query: true)
        expect(page).to have_text('ORGANISER')
        expect(page).to have_no_text(WorkshopPresenter::PAIRING_HEADINGS.join(','))
      end
    end
  end
end
