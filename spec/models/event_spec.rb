require 'spec_helper'

describe Event do
  subject(:event) { Fabricate(:event) }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:slug) }
  it { should respond_to(:info) }
  it { should respond_to(:schedule) }
  it { should respond_to(:description) }
  it { should respond_to(:venue) }
  it { should respond_to(:sponsorships) }
  it { should respond_to(:sponsors) }
  it { should respond_to(:organisers) }
  it { should respond_to(:chapters) }

  context '#verified_students' do
    it 'returns all students who have verified their attendance' do
      event = Fabricate(:event)
      2.times.map { Fabricate(:invitation, event: event, attending: true) }
      3.times.map { Fabricate(:invitation, event: event, attending: true, verified: true) }

      expect(event.verified_students.count).to eq(3)
    end
  end
end
