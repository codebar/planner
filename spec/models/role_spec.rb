require 'spec_helper'

describe Role do
  context 'scopes' do
    let(:student_role) { Fabricate(:student_role) }
    let(:coach_role) { Fabricate(:coach_role) }
    before { Fabricate(:admin_role) }

    describe '#no_admins' do
      it { expect(Role.no_admins).to eq([student_role, coach_role]) }
    end
  end
end
