require 'rails_helper'

RSpec.describe SponsorLogoRestore::Http do
  let(:http) { Class.new { include SponsorLogoRestore::Http }.new }

  describe '#get!' do
    it 'raises on a non-2xx response' do
      stub_request(:get, 'https://example.com/broken').to_return(status: 502)

      expect { http.get!('https://example.com/broken') }.to raise_error(/HTTP 502 fetching/)
    end
  end

  describe 'redirect handling' do
    it 'follows a relative Location header' do
      stub_request(:get, 'https://example.com/a').to_return(status: 302, headers: { 'Location' => '/b' })
      stub_request(:get, 'https://example.com/b').to_return(body: 'final')

      expect(http.get!('https://example.com/a')).to eq('final')
    end

    it 'gives up after the redirect limit and raises the last non-2xx status' do
      stub_request(:get, %r{https://example\.com/redirect-})
        .to_return(status: 302, headers: { 'Location' => '/redirect-next' })

      expect { http.get!('https://example.com/redirect-start') }.to raise_error(/HTTP 302/)
      expect(a_request(:get, %r{https://example\.com/redirect-})).to have_been_made.times(6)
    end
  end
end
