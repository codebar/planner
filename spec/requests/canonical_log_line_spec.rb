# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'canonical request log line' do
  let(:events) do
    capture = SemanticLogger::Test::CaptureLogEvents.new
    appender = SemanticLogger.add_appender(appender: capture)
    get '/faq'
    SemanticLogger.flush
    capture.events
  ensure
    SemanticLogger.remove_appender(appender)
  end

  it 'logs one structured Completed event with the canonical fields' do
    completed = events.find { |event| event.message.to_s.start_with?('Completed') }
    expect(completed).to be_present, 'expected a Completed log event for the request'

    payload = completed.payload
    expect(payload[:controller]).to eq('DashboardController')
    expect(payload[:action]).to eq('faq')
    expect(payload[:method]).to eq('GET')
    expect(payload[:status]).to eq(200)
    expect(payload[:path]).to eq('/faq')
    expect(payload[:path_template]).to eq('/faq(.:format)')
    expect(payload).to include(:db_runtime)
  end

  it 'carries the request id as a named tag' do
    completed = events.find { |event| event.message.to_s.start_with?('Completed') }

    expect(completed.named_tags[:request_id]).to be_present
  end

  it 'normalizes parameterized routes and excludes query strings' do
    capture = SemanticLogger::Test::CaptureLogEvents.new
    appender = SemanticLogger.add_appender(appender: capture)

    get '/unsubscribe/some-token?utm_source=email'
    SemanticLogger.flush

    completed = capture.events.find { |event| event.message.to_s.start_with?('Completed') }
    expect(completed).to be_present, 'expected a Completed log event for the request'
    payload = completed.payload
    expect(payload[:path_template]).to eq('/unsubscribe/:token(.:format)')
    expect(payload[:path]).to eq('/unsubscribe/some-token')
  ensure
    SemanticLogger.remove_appender(appender)
  end
end
