require 'rails_helper'

require 'json'
require 'flodesk'

RSpec.describe Flodesk do
  let(:stub) { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stub) } }
  let(:client) { Flodesk::Client.new }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FLODESK_KEY').and_return('test')
    allow(Rails).to receive(:env).and_return('production'.inquiry)

    allow(client).to receive(:connection).and_return(conn)

    stub.strict_mode = true
  end

  describe '#subscribe' do
    it 'adds a user to segments' do
      payload = {
        email: :email,
        first_name: :first_name,
        last_name: :last_name,
        segment_ids: [:segment_id],
        double_optin: true
      }

      check = ->(request_body) { request_body == payload }
      stub.post('/subscribers', check) { [200, {}, '{}'] }

      expect(client.subscribe(**payload)).to include(status: 200)

      stub.verify_stubbed_calls
    end
  end

  describe '#unsubscribe' do
    it 'removes a user from segments' do
      payload = {
        email: :email,
        segment_ids: [:segment_id]
      }

      check = lambda do |request_body|
        request_body == payload.slice(:segment_ids)
      end

      # Faraday's `stub.delete` does not accept body at the time of writing
      stub.send(:new_stub, :delete, "/subscribers/#{payload[:email]}/segments", {}, check) { [200, {}, '{}'] }

      expect(client.unsubscribe(**payload)).to include(status: 200)

      stub.verify_stubbed_calls
    end
  end

  describe 'when the API call fails' do
    # The real connection raises on error statuses; mirror that here.
    let(:conn) do
      Faraday.new do |b|
        b.response :raise_error
        b.response :json
        b.adapter(:test, stub)
      end
    end

    it 'raises a FlodeskError for an error status' do
      stub.post('/subscribers') { [503, { 'Content-Type' => 'application/json' }, '{"message":"Service unavailable"}'] }

      expect { client.subscribe(email: :email, first_name: :first, last_name: :last, segment_ids: [:id]) }
        .to raise_error(Flodesk::FlodeskError, /Service unavailable/) { |e| expect(e.status_code).to eq(503) }
    end

    it 'raises a FlodeskError when the request times out' do
      stub.delete('/subscribers/email/segments') { raise Faraday::TimeoutError }

      expect { client.unsubscribe(email: :email, segment_ids: [:id]) }
        .to raise_error(Flodesk::FlodeskError)
    end
  end
end
