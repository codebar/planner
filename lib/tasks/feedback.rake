namespace :feedback do
  desc "Request feedback from students that attended our last session"

  task request: :environment do

    workshop = Sessions.most_recent
    STDOUT.puts "Sending feedback requests for Workshop #{I18n.l(workshop.date_and_time, format: :date)}" unless Rails.env == 'test'

    if workshop.date_and_time < DateTime.now+12.hours and workshop.date_and_time < DateTime.now+36.hours

      workshop.invitations.where(role: "Student").accepted.map do |invitation|
        STDOUT.puts "#{invitation.member.full_name} <#{invitation.member.email}>" unless Rails.env == 'test'
        FeedbackRequest.create(member: invitation.member, sessions: invitation.sessions, submited: false)
      end
      STDOUT.puts "\nTotal requests sent: #{FeedbackRequest.where(sessions: workshop).count}" unless Rails.env == 'test'

    end
  end
end
