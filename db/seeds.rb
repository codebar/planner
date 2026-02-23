if Rails.env.development?
  # Check for ImageMagick before seeding
  imagemagick_available = system('convert --version > /dev/null 2>&1') ||
                          system('magick --version > /dev/null 2>&1')

  unless imagemagick_available
    Rails.logger.error '=' * 80
    Rails.logger.error 'ERROR: ImageMagick is required to run db:seed'
    Rails.logger.error '=' * 80
    Rails.logger.error ''
    Rails.logger.error 'The seed task processes sponsor logo images, which requires ImageMagick.'
    Rails.logger.error ''
    Rails.logger.error 'Install ImageMagick:'
    Rails.logger.error '  macOS:         brew install imagemagick'
    Rails.logger.error '  Ubuntu/Debian: apt-get install imagemagick'
    Rails.logger.error '  Windows:       https://imagemagick.org/script/download.php'
    Rails.logger.error ''
    Rails.logger.error 'See native-installation-instructions.md for details.'
    Rails.logger.error '=' * 80
    exit 1
  end

  begin
    Rails.logger.info 'Running migrations...'
    Rails.application.config.log_level = :info
    Rails.logger.info 'Creating chapters...'
    chapters = ['London', 'Brighton', 'Cambridge', 'Barcelona', 'Paris', 'Merlbourne', 'Berlin',
                'New York'].map do |name|
      Fabricate(:chapter_with_groups, name: name)
    end

    Rails.logger.info 'Creating workshops...'

    Rails.logger.info 'Creating 1000 past workshops...'
    past_workshops = []
    1000.times do
      months_ago = rand(0..60)
      start = Time.zone.now - months_ago.months + rand(0..28).days + rand(0..23).hours
      workshop = Fabricate(:workshop,
                           title: 'Workshop',
                           chapter: chapters.sample,
                           date_and_time: start,
                           ends_at: start + 3.hours)
      past_workshops << workshop
    end

    Rails.logger.info 'Creating 100 future workshops...'
    future_workshops = []
    100.times do
      months_ahead = rand(1..3)
      start = Time.zone.now + months_ahead.months + rand(0..28).days + rand(0..23).hours
      workshop = Fabricate(:workshop,
                           title: 'Workshop',
                           chapter: chapters.sample,
                           date_and_time: start,
                           ends_at: start + 3.hours)
      future_workshops << workshop
    end

    future_workshops.first(10)

    Rails.logger.info 'Creating events...'
    events = 20.times.map do |n|
      Fabricate(:event, name: 'Event',
                        chapters: chapters.sample(4),
                        date_and_time: Time.zone.now + 2.months - n.months)
    end

    Rails.logger.info 'Creating meetings...'

    20.times.map do |n|
      Fabricate(:meeting, name: 'Meeting',
                          date_and_time: Time.zone.now + 1.month - n.months)
    end

    Rails.logger.info 'Creating coaches...'
    coaches_group = Group.coaches.to_a
    students_group = Group.students.to_a
    coaches = 500.times.map { Fabricate(:coach, groups: coaches_group.sample(2)) }
    tutorials = Fabricate.times(20, :tutorial)
    30.times { Fabricate(:feedback_request, workshop: past_workshops.sample) }
    20.times { Fabricate(:feedback, tutorial: tutorials.sample, coach: coaches.sample) }
    10.times { Fabricate(:testimonial, member: coaches.sample) }

    # Add skills to some coaches using acts_as_taggable_on
    skill_lists = [
      'javascript, ruby, rails',
      'python, django, sql',
      'react, typescript, node',
      'java, spring, kotlin',
      'css, html, bootstrap',
      'go, kubernetes, docker',
      'c++, rust, systems',
      'swift, ios, android',
      'php, laravel, mysql',
      'git, linux, devops'
    ]

    coaches.each do |coach|
      next if rand > 0.7 # 70% of coaches get skills

      coach.skill_list.add(skill_lists.sample(rand(1..4)).split(', '))
      coach.save(validate: false)
    end

    Rails.logger.info 'Creating students...'
    students = 500.times.map { Fabricate(:student, groups: students_group.sample(2)) }

    Rails.logger.info 'Creating event invitations...'
    10.times do |_n|
      Fabricate(:invitation, member: students.sample, event: events.sample)
      Fabricate(:coach_invitation, member: coaches.sample, event: events.sample)
    end

    Rails.logger.info 'Creating workshop invitations for past workshops...'
    past_workshops.each do |workshop|
      invitation_count = rand(8..15)
      invitation_count.times do
          Fabricate(:coach_workshop_invitation, member: coaches.sample, workshop: workshop)
      rescue StandardError
          nil
      end
      invitation_count.times do
          Fabricate(:student_workshop_invitation, member: students.sample, workshop: workshop)
      rescue StandardError
          nil
      end

      # Create some attended invitations so coaches appear on wall_of_fame
      # Track which coaches already have invitations to avoid duplicates
      existing_invitees = WorkshopInvitation.where(workshop: workshop, role: 'Coach').pluck(:member_id)
      available_coaches = coaches.reject { |c| existing_invitees.include?(c.id) }
      rand(3..8).times do
        break if available_coaches.empty?

        coach = available_coaches.sample
        available_coaches.delete(coach)
        Fabricate(:attended_coach, member: coach, workshop: workshop)
      rescue StandardError
        nil
      end
    end

    Rails.logger.info 'Creating workshop invitations for future workshops...'
    future_workshops.each do |workshop|
      invitation_count = rand(10..20)
      invitation_count.times do
          Fabricate(:coach_workshop_invitation, member: coaches.sample, workshop: workshop)
      rescue StandardError
          nil
      end
      invitation_count.times do
          Fabricate(:student_workshop_invitation, member: students.sample, workshop: workshop)
      rescue StandardError
          nil
      end
    end
    Rails.logger.info '..done!'
  rescue Exception => e
    Rails.logger.error 'Something went wrong. Try running `bundle exec rake db:drop db:create db:migrate` first'
    Rails.logger.error e.message
  end
end
