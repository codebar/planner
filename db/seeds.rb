if Rails.env.development?
  begin
    Rails.logger.info 'Running migrations...'
    Planner::Application.config.log_level = :info
    Rails.logger.info "Creatings chapters..."
    chapters = [ 'London', 'Brighton', 'Cambridge', 'Barcelona', 'Paris', 'Merlbourne', 'Berlin', 'New York'].map do |name|
      Fabricate(:chapter_with_groups, name: name)
    end

    Rails.logger.info "Creatings workshops..."
    workshops = 6.times.map do |n|
      start = Time.zone.now + 1.months - n.weeks
      ends_at = start + 3.hours
      Fabricate(:workshop, title: 'Workshop',
                chapter: chapters.sample,
                date_and_time: start,
                ends_at: ends_at)
    end

    workshops.concat Fabricate.times(2, :workshop, title: 'Workshop', chapter: chapters.sample)

    Rails.logger.info "Creatings a lot of old workshops..."
    past_workshops = 100.times.map do |n|
      Fabricate(:workshop, title: 'Workshop',
                chapter: chapters.sample,
                date_and_time:  Time.zone.now - 9.year + n.months)
    end


    Rails.logger.info "Creatings events..."
    20.times.map do |n|
      Fabricate(:event, name: 'Event',
                        chapters: chapters.sample(4),
                        date_and_time: Time.zone.now + 2.months - n.months)
    end

    Rails.logger.info "Creatings courses..."

    20.times do |n|
      Fabricate(:course, chapter: chapters.sample,
                          title: 'Course',
                          date_and_time: Time.zone.now + 1.months - n.months)
    end


    Rails.logger.info "Creatings meetings..."

    20.times.map do |n|
      Fabricate(:meeting, name: 'Meeting',
                          date_and_time: Time.zone.now + 1.months - n.months)
    end

    Rails.logger.info "Creatings coaches..."
    coaches = 200.times.map { Fabricate(:coach, groups: Group.coaches.order('RANDOM()').limit(2)) }
    tutorials = Fabricate.times(20, :tutorial)
    30.times { Fabricate(:feedback_request, workshop: past_workshops.sample) }
    20.times { Fabricate(:feedback, tutorial: tutorials.sample, coach: coaches.sample) }
    10.times { Fabricate(:testimonial, member: coaches.sample) }

    job_titles = [
      'Software Engineer',
      'Software Developer',
      'Front-end Developer',
      'Back-end Developer',
      'Full-stack Developer'
    ]

    job_companies = %w[
      ACME
      Globex
      Soylent
      Initech
      Umbrella
      Wonka
    ]

    Rails.logger.info "Creatings jobs..."
    15.times do |n|
      Fabricate(:job, title: job_titles.sample, company: job_companies.sample, expiry_date: Time.zone.today + 3.weeks - n.weeks)
    end

    Rails.logger.info "Creatings students..."
    students = 200.times.map { Fabricate(:student, groups: Group.students.order('RANDOM()').limit(2)) }

    Rails.logger.info "Creatings invitations..."
    300.times do |n|
      Fabricate(:coach_workshop_invitation, member: coaches.sample, workshop: workshops.sample) rescue nil
      Fabricate(:student_workshop_invitation, member: students.sample, workshop: workshops.sample) rescue nil
    end
    Rails.logger.info '..done!'
  rescue Exception => e
    Rails.logger.error 'Something went wrong. Try running `bundle exec rake db:drop db:create db:migrate` first'
    Rails.logger.error e.message
  end
end
