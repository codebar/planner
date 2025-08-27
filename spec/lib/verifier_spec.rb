require 'verifier'

RSpec.describe Verifier do
  before do
    Rails.application.config.secret_key_base = '123'
  end

  it 'generates access_token for an id' do
    expect(Verifier.new(id: 1).access_token).to eq('MQ==--a3487195ba15b69d4aa07b7da0234463b82c96b3')
  end

  it 'verifies a model' do
    member = Fabricate(:member)
    access_token = Verifier.new(id: member.id).access_token

    expect(Verifier.new(token: access_token).verify(Member)).to eq(member)
  end

  context 'with an access token from Rails 7.0' do
    it 'verifies a model' do
      member = Fabricate(:member)
      access_token = build_access_token_from_rails70(member.id)

      expect(Verifier.new(token: access_token).verify(Member)).to eq(member)
    end

    def build_access_token_from_rails70(id)
      # Old Rails 7.0 default was Marshal. Rails 7.1 (the default) is :json_allow_marshal.
      # Old Rails 7.0 default was "SHA1". Rails 7.1 (the default) is "SHA256".
      verifier = ActiveSupport::MessageVerifier.new(Rails.application.config.secret_key_base, serializer: Marshal, digest: 'SHA1')
      verifier.generate(id)
    end
  end
end
