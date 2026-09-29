Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3

# The rake jobs:workoff task in Heroku scheduler is configured to run every 10 minutes
Delayed::Worker.max_run_time = 9.minutes

Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.logger = Logger.new(Rails.root.join('log/delayed_job.log').to_s)

# The :failure callback runs when a job exhausts max_attempts, so anything
# reaching it is permanently lost unless someone notices.
Delayed::Worker.lifecycle.after(:failure) do |_worker, job|
  Rollbar.warning(
    'Delayed job permanently failed',
    job_id: job.id,
    attempts: job.attempts,
    error: job.last_error.to_s.lines.first&.strip,
    handler: job.handler.to_s.lines.first&.strip
  )
end
