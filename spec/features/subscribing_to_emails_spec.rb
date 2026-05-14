RSpec.feature 'Managing subscriptions', type: :feature do
  let(:member) { Fabricate(:member) }
  let!(:group) { Fabricate(:group) }

  before do
    login(member)
  end

  context 'a member can manage its subscriptions' do
    scenario '#subscribe' do
      visit subscriptions_path

      click_on 'Subscribe'
      expect(page).to have_content("You have subscribed to #{group.chapter.city}'s #{group.name} group")
    end

    scenario '#unsubscribe' do
      subscription = Fabricate.create(:subscription, member: member, group: group)
      visit subscriptions_path

      click_on 'Subscribed'
      expect(page).to have_content("You have unsubscribed from #{group.chapter.city}'s #{group.name} group")
    end
  end

  context 'a member receives a welcome email' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    scenario 'Subscribing to a coach mailing list for the first time sends a coach email to the user' do
      coach_group = Fabricate(:coaches)

      visit subscriptions_path
      click_on "#{coach_group.chapter.name}-coaches"

      welcome_emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(member.email) }
      expect(welcome_emails.count).to eq(1)
      expect(welcome_emails.first.body.encoded).to include('coach')
    end

    scenario 'Subscribing to a student mailing list for the first time sends a student email to the user' do
      visit subscriptions_path
      click_on "#{group.chapter.name}-students"

      welcome_emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(member.email) }
      expect(welcome_emails.count).to eq(1)
      expect(welcome_emails.first.body.encoded).to include('student')
    end

    scenario "Subscribing to a second coach mailing list doesn't send another mail" do
      coach_groups = Fabricate.times(2, :coaches)

      visit subscriptions_path
      click_on "#{coach_groups[0].chapter.name}-coaches"
      ActionMailer::Base.deliveries.clear
      click_on "#{coach_groups[1].chapter.name}-coaches"

      welcome_emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(member.email) }
      expect(welcome_emails.count).to eq(0)
    end

    scenario "Subscribing to a second student mailing list doesn't send another mail" do
      extra_student_group = Fabricate(:students)

      visit subscriptions_path
      click_on "#{group.chapter.name}-students"
      ActionMailer::Base.deliveries.clear
      click_on "#{extra_student_group.chapter.name}-students"

      welcome_emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(member.email) }
      expect(welcome_emails.count).to eq(0)
    end

    scenario "Unsubscribing and re-subscribing doesn't send a second mail to a coach" do
      coach_group = Fabricate(:coaches)

      visit subscriptions_path
      click_on "#{coach_group.chapter.name}-coaches"
      ActionMailer::Base.deliveries.clear
      click_on "#{coach_group.chapter.name}-coaches"
      click_on "#{coach_group.chapter.name}-coaches"

      welcome_emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(member.email) }
      expect(welcome_emails.count).to eq(0)
    end

    scenario "Unsubscribing and re-subscribing doesn't send a second mail to a student" do
      visit subscriptions_path
      click_on "#{group.chapter.name}-students"
      ActionMailer::Base.deliveries.clear
      click_on "#{group.chapter.name}-students"
      click_on "#{group.chapter.name}-students"

      welcome_emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(member.email) }
      expect(welcome_emails.count).to eq(0)
    end
  end
end
