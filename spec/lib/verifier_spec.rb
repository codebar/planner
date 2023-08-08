require 'spec_helper'
require 'verifier'

RSpec.describe Verifier do
  before do
    Rails.application.config.secret_key_base = '123'
  end

  it 'generates access_token for an id' do
    expect(Verifier.new(id: 1).access_token).to be_eql('BAhpBg==--30d45b871c77098a0ba79cf27dd532650ca75531')
  end

  it 'verifies a model' do
    member = Fabricate(:member)
    access_token = Verifier.new(id: member.id).access_token

    expect(Verifier.new(token: access_token).verify(Member)).to eq(member)
  end
end
