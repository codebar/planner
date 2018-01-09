require 'spec_helper'

feature 'Managing subscriptions' do
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

  context 'a member gets a welcome email' do
    scenario 'Subscribing to a coach mailing list for the first time sends a coach email to the user' do
      coach_group = Fabricate(:coaches)
      expect_any_instance_of(MemberMailer).to receive(:welcome_coach)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_students)

      visit subscriptions_path
      click_on "#{coach_group.chapter.name}-coaches"
    end

    scenario 'Subscribing to a student mailing list for the first time sends a student email to the user' do
      expect_any_instance_of(MemberMailer).to receive(:welcome_student)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)

      visit subscriptions_path
      click_on "#{group.chapter.name}-students"
    end

    scenario "Subscribing to a second coach mailing list doesn't send another mail" do
      coach_groups = Fabricate.times(2, :coaches)
      expect_any_instance_of(MemberMailer).to receive(:welcome_coach).once
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_students)

      visit subscriptions_path
      click_on "#{coach_groups[0].chapter.name}-coaches"
      click_on "#{coach_groups[1].chapter.name}-coaches"
    end

    scenario "Subscribing to a second student mailing list doesn't send another mail" do
      expect_any_instance_of(MemberMailer).to receive(:welcome_student).once
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)
      extra_student_group = Fabricate(:students)

      visit subscriptions_path
      click_on "#{group.chapter.name}-students"
      click_on "#{extra_student_group.chapter.name}-students"
    end

    scenario "Unsubscribing and re-subscribing doesn't send a second mail to a coach" do
      coach_group = Fabricate(:coaches)
      expect_any_instance_of(MemberMailer).to receive(:welcome_coach).once
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_students)

      visit subscriptions_path
      click_on "#{coach_group.chapter.name}-coaches"
      click_on "#{coach_group.chapter.name}-coaches"
      click_on "#{coach_group.chapter.name}-coaches"
    end

    scenario "Unsubscribing and re-subscribing doesn't send a second mail to a student" do
      expect_any_instance_of(MemberMailer).to receive(:welcome_student).once
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)

      visit subscriptions_path
      click_on "#{group.chapter.name}-students"
      click_on "#{group.chapter.name}-students"
      click_on "#{group.chapter.name}-students"
    end
  end
end
