require 'json'
require 'services/flodesk'

RSpec.describe Flodesk do
  let(:stub)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stub) } }
  let(:client) { Flodesk::Client.new }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FLODESK_KEY').and_return('test')
    allow(Rails).to receive(:env).and_return('production'.inquiry)

    allow(client).to receive(:connection).and_return(conn)

    stub.strict_mode = true
  end

  context '#subscribe' do
    it 'adds a user to segments' do
      payload = {
        email: :email,
        first_name: :first_name,
        last_name: :last_name,
        segment_ids: [:segment_id],
        double_optin: true,
      }

      check = ->(request_body) { request_body == payload }
      stub.post('/subscribers', check) { [200, {}, '{}'] }

      client.subscribe(**payload)

      stub.verify_stubbed_calls
    end
  end

  context '#unsubscribe' do
    it 'removes a user from segments' do
      payload = {
        email: :email,
        segment_ids: [:segment_id],
      }

      check = ->(request_body) do
        request_body == payload.slice(:segment_ids)
      end

      # Faraday's `stub.delete` does not accept body at the time of writing
      stub.send(:new_stub, :delete, "/subscribers/#{payload[:email]}/segments", {}, check) { [200, {}, '{}'] }

      client.unsubscribe(**payload)

      stub.verify_stubbed_calls
    end
  end

  context '#subscribed?' do
    it 'confirms that a user is active and subscribed to a segment' do
      payload = {
        email: :email,
        segment_ids: ["segment_id"],
      }

      stub.get("/subscribers/#{payload[:email]}") { [200, {}, {
        "id": "123456789",
        "status": "active",
        "email": "email",
        "segments": [
          {
            "id": "segment_id",
            "name": "codebar"
          }
        ]
      }] }

      expect(client.subscribed?(**payload)).to be true

      stub.verify_stubbed_calls
    end

    it 'confirms that a user is active but not subscribed to a segment' do
      payload = {
        email: :email,
        segment_ids: ["segment_id"],
      }

      stub.get("/subscribers/#{payload[:email]}") { [200, {}, {
        "id": "123456789",
        "status": "active",
        "email": "email",
        "segments": [
          {
            "id": "some_other_segment_id",
            "name": "not codebar"
          }
        ]
      }] }

      expect(client.subscribed?(**payload)).to be false

      stub.verify_stubbed_calls
    end

    it 'confirms that a user is not active' do
      payload = {
        email: :email,
        segment_ids: ["segment_id"],
      }

      stub.get("/subscribers/#{payload[:email]}") { [200, {}, {
        "id": "123456789",
        "status": "unsubscribed",
        "email": "email",
        "segments": [
          {
            "id": "segment_id",
            "name": "codebar"
          }
        ]
      }] }

      expect(client.subscribed?(**payload)).to be false

      stub.verify_stubbed_calls
    end
  end
end
