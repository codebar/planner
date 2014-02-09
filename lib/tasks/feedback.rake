namespace :feedback do
  desc "Request feedback from students that attendanted last session"

  task request: :environment do
    raise 'Sorry. No recent sessions found.' if Sessions.most_recent.nil?

    STDOUT.puts "Do you want to send feedback requests for session: #{Sessions.most_recent.title}? (y/N)"
    
    if STDIN.gets.chomp == 'y'
      Sessions.most_recent.invitations.attended.each do |invitation|
        FeedbackRequest.create(memeber: invitation.member, session: invitation.sessions, submited: false)
      end
    end
  end
end
