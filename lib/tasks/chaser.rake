namespace :chaser do
  desc "Send emails to users who've not attended in a while"

  task three_months: :environment do
    SendThreeMonthEmailJob.perform_later
  end
end
