module WorkshopPairingDemoSeeder
  DEMO_DESCRIPTION = 'Demo workshop for testing live check-in and pairings.'.freeze
  ROSTER = [
    { name: 'Amara', surname: 'Okafor', pronouns: 'they/them', role: 'Student',
      tutorial: 'HTML & CSS — Flexbox', note: 'Building a portfolio page', offset: 12 },
    { name: 'Elena', surname: 'Rossi', pronouns: 'she/her', role: 'Student',
      tutorial: 'Ruby — Arrays & Hashes', note: 'Practising loops and specs', offset: 7 },
    { name: 'Fatima', surname: 'Zahra', pronouns: 'she/her', role: 'Student',
      tutorial: 'JavaScript — DOM Events', note: 'First time building a form', offset: 3 },
    { name: 'Liam', surname: 'Chen', pronouns: 'he/him', role: 'Student',
      tutorial: 'Python — Variables', note: 'New to Python', offset: nil },
    { name: 'Ben', surname: 'Coyle', pronouns: 'he/him', role: 'Coach',
      tutorial: nil, note: 'Frontend CSS, JavaScript & accessibility', offset: 10 },
    { name: 'Chidi', surname: 'Eze', pronouns: 'he/him', role: 'Coach',
      tutorial: nil, note: 'Full-stack Ruby on Rails, SQL & testing', offset: nil },
    { name: 'Priya', surname: 'Patel', pronouns: 'she/her', role: 'Coach',
      tutorial: nil, note: 'Python, Django & data structures', offset: nil }
  ].freeze

  module_function

  def run!
    chapter = find_or_create_chapter
    host = Sponsor.joins(:address).first || raise('No sponsor with an address found; run db:seed first.')
    organiser = find_or_create_organiser(chapter)
    workshop = reset_demo_workshop(chapter, host)
    seed_roster(workshop)
    print_summary(workshop, organiser)
  end

  def find_or_create_chapter
    Chapter.first || Chapter.create!(name: 'London', email: 'london@codebar.io', city: 'London',
                                     time_zone: 'London', active: true)
  end

  def find_or_create_organiser(chapter)
    email = 'pairing-demo-organiser@codebar.io'
    member = Member.find_or_create_by!(email:) do |m|
      m.assign_attributes(name: 'Alex', surname: 'Organiser', pronouns: 'they/them',
                          about_you: 'Chapter organiser', accepted_toc_at: Time.zone.now)
      m.auth_services.build(provider: 'codebar', uid: "pairing-demo-#{email}")
    end
    member.add_role(:admin)
    member.add_role(:organiser, chapter)
    member
  end

  def reset_demo_workshop(chapter, host)
    workshop = Workshop.find_by(description: DEMO_DESCRIPTION)
    workshop&.workshop_working_groups&.destroy_all
    workshop&.invitations&.destroy_all
    workshop ||= Workshop.new(chapter:, description: DEMO_DESCRIPTION, invitable: true, virtual: false)
    workshop.assign_attributes(date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now,
                               selected_host_id: host.id)
    workshop.save!
    WorkshopSponsor.find_or_create_by!(workshop:, sponsor: host).update!(host: true)
    workshop
  end

  def seed_roster(workshop)
    service = WorkingGroups::Service.for(workshop)
    checked_in = ROSTER.filter_map { |spec| create_invitation(workshop, spec) }
    checked_in.sort_by(&:checked_in_at).each { |inv| service.on_check_in(inv) }
  end

  def create_invitation(workshop, spec)
    member = find_or_create_attendee(spec)
    checked_in_at = spec[:offset]&.minutes&.ago
    inv = WorkshopInvitation.create!(
      workshop:, member:, role: spec[:role], attending: true, attended: (true if checked_in_at),
      checked_in_at:, automated_rsvp: true, rsvp_time: 2.days.ago, tutorial: spec[:tutorial], note: spec[:note]
    )
    inv if checked_in_at
  end

  def find_or_create_attendee(spec)
    email = "pairing-demo-#{spec[:name].downcase}@codebar.io"
    Member.find_or_create_by!(email:) do |m|
      m.assign_attributes(name: spec[:name], surname: spec[:surname], pronouns: spec[:pronouns],
                          about_you: "#{spec[:role]} demo attendee", accepted_toc_at: Time.zone.now)
      m.auth_services.build(provider: 'codebar', uid: "pairing-demo-#{spec[:name].downcase}")
    end
  end

  def print_summary(workshop, organiser)
    puts "\nWorkshop Pairing Demo Ready!"
    puts "  URL:       http://localhost:3000/admin/workshops/#{workshop.id}"
    puts "  Organiser: #{organiser.email}"
    puts '  State:     1 pair (Amara + Ben), 2 waiting (Elena, Fatima), 1 unchecked student, 2 unchecked coaches'
    puts '  Try:       Tick Chidi in Coaches -> auto-pairs FIFO with Elena -> drag Fatima onto Amara & Ben!'
  end
end

namespace :workshop_pairing do
  desc 'Seed a repeatable in-person workshop inside the check-in window for testing Pairings'
  task demo: :environment do
    abort 'workshop_pairing:demo can only run in development.' unless Rails.env.development?

    WorkshopPairingDemoSeeder.run!
  end
end
