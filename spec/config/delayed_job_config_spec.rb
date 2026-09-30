# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delayed job configuration' do # rubocop:disable RSpec/DescribeClass
  describe 'signal handling' do
    it 'lets TERM finish the current job instead of failing it' do
      expect(Delayed::Worker.raise_signal_exceptions).to be_falsey
    end
  end

  describe 'failure reporting' do
    let(:job) do
      instance_double(
        Delayed::Job,
        id: 42,
        attempts: 3,
        last_error: "SIGTERM\n/app/vendor/bundle/...",
        handler: "--- !ruby/object:InvitationManager {}\nmethod_name: send_event_emails"
      )
    end

    it 'reports permanently failed jobs to Rollbar' do
      allow(Rollbar).to receive(:warning)

      Delayed::Worker.lifecycle.run_callbacks(:failure, nil, job) { nil }

      expect(Rollbar).to have_received(:warning).with(
        'Delayed job permanently failed',
        job_id: 42,
        attempts: 3,
        error: 'SIGTERM',
        handler: '--- !ruby/object:InvitationManager {}'
      )
    end
  end
end
