RSpec.feature 'Member portal', type: :feature do
  subject { page }

  let(:member) { Fabricate(:member) }

  context 'A signed in member' do
    before do
      login(member)
    end

    context '#dashboard' do
      it 'can access the member dashboard' do
        visit dashboard_path

        expect(page).to have_content('Dashboard')
        expect(page).to have_content(member.full_name)
      end

      it 'can view attending workshops' do
        workshop = Fabricate(:workshop, chapter: Fabricate(:chapter_with_groups))
        Fabricate(:subscription, member: member, group: workshop.chapter.groups.first)
        Fabricate(:attending_workshop_invitation, member: member,
                                                               workshop: workshop)
        presenter = WorkshopPresenter.new(workshop)
        visit dashboard_path

        expect(page).to have_content("#{presenter} at #{presenter.venue.name}", count: 1)
      end

      it 'can view upcoming workshops for their chapters' do
        c1_workshop = Fabricate(:workshop, chapter: Fabricate(:chapter_with_groups))
        Fabricate(:subscription, member: member, group: c1_workshop.chapter.groups.first)

        c2_workshop = Fabricate(:workshop, chapter: Fabricate(:chapter_with_groups))
        Fabricate(:subscription, member: member, group: c2_workshop.chapter.groups.first)
        c1_workshop_presenter = WorkshopPresenter.new(c1_workshop)
        c2_workshop_presenter = WorkshopPresenter.new(c2_workshop)

        visit dashboard_path

        expect(page).to have_content("#{c1_workshop_presenter} at #{c1_workshop_presenter.venue.name}",
                                     count: 1)
        expect(page).to have_content("#{c2_workshop_presenter} at #{c2_workshop_presenter.venue.name}",
                                     count: 1)
      end
    end

    it 'can access and view their profile' do
      visit profile_path

      expect(page).to have_content('Details')
      expect(page).to have_content(member.full_name)

      expect(page).to have_content('Email')
      expect(page).to have_content(member.email)

      expect(page).to have_content('Phone number')
      expect(page).to have_content(member.mobile)

      expect(page).to have_content('About')
      expect(page).to have_content(member.about_you)

      expect(page).to have_content('How you found us')
      expect(page).to have_content(member.how_you_found_us.first)
    end

    it 'can access and update their profile' do
      visit profile_path

      within '#member_profile' do
        click_on 'Update your details'
      end

      fill_in 'member_name', with: 'Jane'
      fill_in 'member_surname', with: 'Doe'
      click_button 'Save'

      expect(page).to have_content('Jane Doe')
    end

    it 'can subscribe to groups' do
      group = Fabricate(:group)
      visit profile_path
      within '#member_profile' do
        click_on 'Manage subscriptions'
      end
      click_on 'Subscribe'

      expect(group.members).to include(member)
    end

    it 'can view the invitations they RSVPed to' do
      invitations = 2.times.map { Fabricate(:attending_workshop_invitation, member: member) }
      visit invitations_path

      expect(page).to have_content('Invitations')
      invitations.each do |invitation|
        expect(page).to have_content(invitation.parent.to_s)
        expect(page).to have_content(invitation.parent.chapter.name)
      end
    end
  end

  context 'A non authenticated visitor to the page' do
    it 'can not access the member portal' do
      visit dashboard_path

      expect(page).to_not have_selector('#profile')
    end

    it 'is redirected to sign_in page when they attempt not access the profile page' do
      mock_github_auth
      visit profile_path

      expect(page).to_not have_selector('#member_profile')
    end
  end
end
