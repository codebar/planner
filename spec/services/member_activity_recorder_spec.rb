# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberActivityRecorder do
  let(:member) { Fabricate(:member) }

  it 'creates an activity row owned by the actor' do
    described_class.record(actor: member, key: 'member.login')

    activity = PublicActivity::Activity.find_by(owner: member)
    expect(activity.key).to eq('member.login')
  end

  it 'stores trackable and recipient' do
    other = Fabricate(:member)

    described_class.record(actor: member, key: 'member.banned', recipient: other)

    activity = PublicActivity::Activity.order(:created_at).last
    expect(activity.recipient).to eq(other)
    # trackable defaults to actor when nil
    expect(activity.trackable).to eq(member)
  end

  it 'never raises on persistence failure' do
    allow(PublicActivity::Activity).to receive(:create!)
      .and_raise(ActiveRecord::RecordInvalid)
    allow(Rails.logger).to receive(:warn)

    expect { described_class.record(actor: member, key: 'member.login') }.not_to raise_error
    expect(Rails.logger).to have_received(:warn).with(/MemberActivityRecorder failed/)
  end

  it 'warns when a key is outside the documented vocabulary' do
    allow(Rails.logger).to receive(:warn)

    described_class.record(actor: member, key: 'unknown.key')

    expect(PublicActivity::Activity.exists?(owner: member, key: 'unknown.key')).to be(true)
    expect(Rails.logger).to have_received(:warn).with(/unregistered key 'unknown.key'/)
  end
end
