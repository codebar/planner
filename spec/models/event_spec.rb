require 'spec_helper'

RSpec.describe Event, type: :model  do
  subject(:event) { Fabricate(:event) }
  include_examples "Invitable", :invitation, :event

  it { should be_valid }

  context '#verified_students' do
    it 'returns all students who have verified their attendance' do
      event = Fabricate(:event)
      2.times.map { Fabricate(:invitation, event: event, attending: true) }
      3.times.map { Fabricate(:invitation, event: event, attending: true, verified: true) }

      expect(event.verified_students.count).to eq(3)
    end
  end

  context 'validations' do
    it '#slug' do
      event = Fabricate(:event, slug: 'event-slug')
      new_event = Fabricate.build(:event, slug: 'event-slug')
      new_event.valid?

      expect(new_event.errors.messages[:slug].first).to eq("has already been taken")
    end
  end
end
