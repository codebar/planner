# frozen_string_literal: true

module PairingDemoData
  Attendee = Data.define(:role, :verified, :email, :name, :surname, :pronouns, :note)

  ATTENDEES = [
    Attendee.new('Student', true, 'amara.okafor@pairing-demo.example', 'Amara', 'Okafor', 'they/them',
                 'Building a personal portfolio with HTML & CSS Grid'),
    Attendee.new('Coach', true, 'ben.coyle@pairing-demo.example', 'Ben', 'Coyle', 'he/him',
                 'Frontend CSS, JavaScript & accessibility'),
    Attendee.new('Student', false, 'elena.rossi@pairing-demo.example', 'Elena', 'Rossi', 'she/her',
                 'Ruby arrays, hashes & RSpec exercises'),
    Attendee.new('Student', false, 'fatima.zahra@pairing-demo.example', 'Fatima', 'Zahra', 'she/her',
                 'JavaScript DOM events & fetch API basics'),
    Attendee.new('Student', false, 'jonas.weber@pairing-demo.example', 'Jonas', 'Weber', 'he/him',
                 'Getting started with Git branches & pull requests'),
    Attendee.new('Student', false, 'leo.fontaine@pairing-demo.example', 'Leo', 'Fontaine', 'they/them',
                 'Python loops & reading CSV files'),
    Attendee.new('Student', false, 'maya.lindqvist@pairing-demo.example', 'Maya', 'Lindqvist', 'she/her',
                 'Responsive Flexbox layout for my first web app'),
    Attendee.new('Coach', false, 'chidi.eze@pairing-demo.example', 'Chidi', 'Eze', 'he/him',
                 'Full-stack Ruby on Rails, SQL & testing'),
    Attendee.new('Coach', false, 'dev.patel@pairing-demo.example', 'Dev', 'Patel', 'he/him',
                 'JavaScript, TypeScript, React & Node.js'),
    Attendee.new('Coach', false, 'hana.suzuki@pairing-demo.example', 'Hana', 'Suzuki', 'she/her',
                 'Python, Git workflows & backend APIs'),
    Attendee.new('Coach', false, 'ingrid.berg@pairing-demo.example', 'Ingrid', 'Berg', 'she/her',
                 'HTML, CSS, design systems & Ruby')
  ].freeze

  SUMMARY_TEMPLATE = <<~MSG

    == Pairing Demo Event Ready ==
    Event URL:       http://localhost:3000/admin/events/%<slug>s
    Organiser email: %<email>s
    Checked in:      1 paired group (Amara Okafor + Ben Coyle)
    Expected:        5 students & 4 coaches ready to Verify

    How to sign in locally:
      1. Visit http://localhost:3001/login/magic-link and submit: %<email>s
      2. Open the magic link printed in auth stdout (or fetch http://localhost:3001/api/test/magic-links)
      3. Visit http://localhost:3000/login to complete OAuth into planner
      4. Open http://localhost:3000/admin/events/%<slug>s

    Re-run anytime to reset the demo board:
      ./bin/pairing-demo

  MSG
end

class PairingDemoSetup
  def self.run!(slug:, organiser_email:)
    new(slug:, organiser_email:).run!
  end

  def initialize(slug:, organiser_email:)
    @slug = slug
    @organiser_email = organiser_email
  end

  def run!
    event, organiser = seed_records!
    puts format(PairingDemoData::SUMMARY_TEMPLATE, slug: event.slug, email: organiser.email)
  end

  private

  def seed_records!
    ActiveRecord::Base.transaction do
      organiser = find_or_create_organiser!
      event = upsert_event!(find_or_create_chapter!, Sponsor.joins(:address).first, organiser)
      reset_invitations!(event, organiser)
      [event, organiser]
    end
  end

  def find_or_create_chapter!
    Chapter.find_or_create_by!(name: 'Pairing Demo') do |c|
      c.email = 'demo@codebar.io'
      c.city = 'London'
      c.time_zone = 'London'
    end
  end

  def find_or_create_organiser!
    Member.find_or_create_by!(email: @organiser_email) do |m|
      m.name = 'Ola'
      m.surname = 'Organiser'
      m.pronouns = 'she/her'
      m.about_you = 'Chapter organiser'
      m.accepted_toc_at = Time.zone.now
      m.auth_services.build(provider: 'github', uid: "pairing-demo-#{@organiser_email}")
    end
  end

  def upsert_event!(chapter, venue, organiser)
    event = Event.find_or_initialize_by(slug: @slug)
    event.assign_attributes(event_attributes(venue))
    event.save!
    event.chapters << chapter unless event.chapters.include?(chapter)
    organiser.add_role(:organiser, event) unless organiser.has_role?(:organiser, event)
    event
  end

  def event_attributes(venue)
    {
      name: 'Pairing Demo Night', info: 'Pairing demo', time_zone: 'London',
      description: 'Interactive sample event for reviewing the inline check-in & drag-and-drop pairing board.',
      schedule: "18:30 Doors & food\n19:00 Lightning talk\n19:15 Coding & pairing",
      date_and_time: 1.day.from_now.change(hour: 18, min: 30), ends_at: 1.day.from_now.change(hour: 21, min: 0),
      venue:, virtual: venue.nil?, invitable: true, confirmation_required: true, student_spaces: 12, coach_spaces: 10
    }
  end

  def reset_invitations!(event, organiser)
    event.pairings.destroy_all
    event.invitations.destroy_all
    PairingDemoData::ATTENDEES.each { |attrs| create_invitation!(event, organiser, attrs) }
  end

  def create_invitation!(event, organiser, attrs)
    member = find_or_create_member!(attrs)
    event.invitations.create!(
      member:, role: attrs.role, attending: true, verified: attrs.verified,
      verified_by: attrs.verified ? organiser : nil, note: attrs.note
    )
  end

  def find_or_create_member!(attrs)
    Member.find_or_create_by!(email: attrs.email) do |m|
      m.assign_attributes(name: attrs.name, surname: attrs.surname, pronouns: attrs.pronouns,
                          about_you: attrs.note, accepted_toc_at: Time.zone.now)
      m.auth_services.build(provider: 'github', uid: "pairing-demo-#{attrs.email}")
    end
  end
end

namespace :pairing_demo do
  desc 'Create or reset a realistic demo event to try out the pairing UI locally'
  task setup: :environment do
    PairingDemoSetup.run!(
      slug: ENV.fetch('EVENT_SLUG', 'pairing-demo-night'),
      organiser_email: ENV.fetch('ORGANISER_EMAIL', 'organiser@codebar.io')
    )
  end

  desc 'Alias for pairing_demo:setup (resets the demo event to a clean starting state)'
  task reset: :setup
end
