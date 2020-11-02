require 'spec_helper'

RSpec.describe 'Auditor::Audit' do
  let(:sponsor) { Fabricate.build(:sponsor) }
  let(:member) { Fabricate(:member) }

  describe '#log' do
    it 'audits setting values to a model' do
      sponsor.name = 'A new name'
      audit = Auditor::Audit.new(sponsor, 'sponsor.create', member)
      audit.log { sponsor.save }
      audit_log = sponsor.activities.last

      expect(audit_log.parameters.symbolize_keys).to include(name: [nil, sponsor.name])
    end

    it 'audits any changes to a model' do
      sponsor.save
      name = sponsor.name
      sponsor.name = 'A new name'
      audit = Auditor::Audit.new(sponsor, 'sponsor.test', member)
      audit.log { sponsor.save }
      audit_log = sponsor.activities.last

      expect(audit_log.parameters.symbolize_keys).to eq(name: [name, 'A new name'])
    end
  end

  describe '#log_with_note' do
    it 'audits with a member specified note' do
      sponsor.name = 'A new name'
      audit = Auditor::Audit.new(sponsor, 'sponsor.request_changes', member)
      audit.log_with_note('A note')
      audit_log = sponsor.activities.last

      expect(audit_log.parameters.symbolize_keys).to include(note: 'A note')
    end
  end
end
