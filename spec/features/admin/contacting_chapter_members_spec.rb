require 'rails_helper'

RSpec.feature 'Contacting chapter members' do
  let(:organiser) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }

  context 'when a chapter organiser' do
    let(:students) { Fabricate(:group, name: 'Students', chapter:) }
    let(:coaches) { Fabricate(:group, name: 'Coaches', chapter:) }
    let(:student) { Fabricate(:member) }
    let(:coach) { Fabricate(:member) }
    let(:both) { Fabricate(:member) }
    let(:former_member) { Fabricate(:member) }
    let(:other_chapter) { Fabricate(:chapter) }
    let(:other_chapter_member) { Fabricate(:member) }

    before do
      organiser.add_role(:organiser, chapter)
      Fabricate(:subscription, member: student, group: students)
      Fabricate(:subscription, member: coach, group: coaches)
      Fabricate(:subscription, member: both, group: students)
      Fabricate(:subscription, member: both, group: coaches)
      Fabricate(:discarded_subscription, member: former_member, group: students)
      other_group = Fabricate(:group, name: 'Students', chapter: other_chapter)
      Fabricate(:subscription, member: other_chapter_member, group: other_group)
    end

    scenario 'previews current subscribers and emails each individually after confirmation' do
      login(organiser)
      open_contact_menu
      expect(page).to have_no_link('Contact members', href: new_admin_chapter_contact_path(other_chapter))
      click_on 'Contact members'
      expect(page).to have_text('3 recipients')
      fill_in 'Subject', with: 'Workshop update'
      fill_in 'Message', with: 'The workshop starts at 6pm.'
      ActionMailer::Base.deliveries.clear

      click_on 'Preview recipients'

      expect_preview([student, coach, both])
      expect(page).to have_field('chapter_contact[confirmation_token]', type: 'hidden')
      expect(page).to have_no_field('chapter_contact[subject]')
      expect(page).to have_no_field('chapter_contact[message]')
      click_on 'Confirm and send'

      expect(page).to have_text('Email sent to 3 chapter members')
      expect_email_fanout(
        recipients: [student, coach, both],
        excluded: [former_member, other_chapter_member]
      )
    end

    scenario 'previews and emails chapter organisers when leadership is selected' do
      another_organiser = Fabricate(:member)
      another_organiser.add_role(:organiser, chapter)
      login(organiser)
      visit new_admin_chapter_contact_path(chapter)
      select 'Chapter organisers', from: 'Audience'
      fill_in 'Subject', with: 'Leadership update'
      fill_in 'Message', with: 'A message for chapter organisers.'
      ActionMailer::Base.deliveries.clear

      click_on 'Preview recipients'

      expect_preview([organiser, another_organiser])
      click_on 'Confirm and send'

      expect(page).to have_text('Email sent to 2 chapter members')
      expect_email_fanout(
        recipients: [organiser, another_organiser],
        excluded: [student, coach, both, former_member, other_chapter_member],
        subject: 'Leadership update',
        message: 'A message for chapter organisers.'
      )
    end
  end

  scenario 'admin can access any chapter contact form' do
    admin = Fabricate(:member)
    Fabricate(:group, name: 'Students', chapter:)
    login_as_admin(admin)

    visit root_path
    click_on 'Menu'
    click_on 'Contact chapter'
    click_on 'Contact members'

    expect(page).to have_current_path(new_admin_chapter_contact_path(chapter))
  end

  scenario 'regular members cannot see or directly access chapter contact' do
    member = Fabricate(:member)
    Fabricate(:group, name: 'Students', chapter:)
    login(member)
    ActionMailer::Base.deliveries.clear

    visit root_path
    click_on 'Menu'
    expect(page).to have_no_link('Contact chapter')

    visit new_admin_chapter_contact_path(chapter)
    expect(current_url).to eq(root_url)
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  scenario 'organiser of another chapter cannot access this chapter contact' do
    other_chapter = Fabricate(:chapter)
    other_organiser = Fabricate(:member)
    other_organiser.add_role(:organiser, other_chapter)
    login(other_organiser)

    visit new_admin_chapter_contact_path(chapter)

    expect(current_url).to eq(root_url)
  end

  scenario 'does not send when the chapter has no current subscribers' do
    organiser.add_role(:organiser, chapter)
    login(organiser)
    visit new_admin_chapter_contact_path(chapter)
    fill_in 'Subject', with: 'Workshop update'
    fill_in 'Message', with: 'The workshop starts at 6pm.'
    ActionMailer::Base.deliveries.clear

    click_on 'Preview recipients'

    expect(page).to have_text('There are no current chapter subscribers to email.')
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def open_contact_menu
    visit root_path
    click_on 'Menu'
    click_on 'Contact chapter'
  end

  def expect_email_fanout(recipients:, excluded:, subject: 'Workshop update',
    message: 'The workshop starts at 6pm.')
    expect_delivered_to(recipients)
    expect_no_delivery_to(excluded)
    expect_individual_emails(recipients.size, subject:, message:)
  end

  def expect_preview(recipients)
    expect_preview_count(recipients.size)
    expect_recipient_names(recipients)
    expect_recipient_addresses_hidden(recipients)
    expect_no_preview_delivery
  end

  def expect_preview_count(count)
    expect(page).to have_text("#{count} recipients will receive this email")
  end

  def expect_recipient_names(recipients)
    recipients.each { |recipient| expect(page).to have_text(recipient.full_name) }
  end

  def expect_recipient_addresses_hidden(recipients)
    recipients.each { |recipient| expect(page).to have_no_text(recipient.email) }
  end

  def expect_no_preview_delivery
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def expect_delivered_to(recipients)
    recipients.each { |member| expect(delivered_emails_to(member).one?).to be(true) }
  end

  def expect_no_delivery_to(members)
    members.each { |member| expect(delivered_emails_to(member)).to be_empty }
  end

  def expect_individual_emails(count, subject:, message:)
    emails = ActionMailer::Base.deliveries
    expect(emails.size).to eq(count)
    emails.each { |email| expect_individual_email(email, subject:, message:) }
  end

  def expect_individual_email(email, subject:, message:)
    expect_mail_privacy(email)
    expect_mail_content(email, subject:, message:)
  end

  def expect_mail_privacy(email)
    expect(email.to.size).to eq(1)
    expect(email.cc).to be_empty
    expect(email.bcc).to be_empty
  end

  def expect_mail_content(email, subject:, message:)
    expect(email.subject).to eq(subject)
    expect(email.body.encoded).to include(message)
  end
end
