namespace :chaser do
  desc "Send emails to users who've not attended in a while"
  task three_months: :environment do
    SendThreeMonthEmailJob.perform_later
  end

  desc 'Send emails to new members who have not subscribed to a chapter'
  task signup_nudges: :environment do
    SendSignupNudgeEmailJob.perform_later
  end
end
