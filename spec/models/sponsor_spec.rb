require 'spec_helper'

describe Sponsor do
  context 'validations' do
    context 'presence' do
      describe '#name' do
        subject(:sponsor) { Fabricate.build(:sponsor, name: nil) }

        it { should_not be_valid }
        it { should have(1).error_on(:name) }
      end
      describe '#description' do
        subject(:sponsor) { Fabricate.build(:sponsor, description: nil) }

        it { should_not be_valid}
        it { should have(1).error_on(:description) }
      end
    end
  end
end