require 'spec_helper'

describe Sponsor do
  subject(:sponsor) { Fabricate.build(:sponsor) }

  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:address) }
  it { should be_valid }

  context 'validations' do
    context 'presence' do
      describe '#name' do
        before { sponsor.name = nil }

        it { should_not be_valid }
        it { should have(1).error_on(:name) }
      end
      describe '#description' do
        before { sponsor.description = nil }

        it { should_not be_valid}
        it { should have(1).error_on(:description) }
      end
      describe '#address' do
        before { sponsor.address = nil }

        it { should_not be_valid}
        it { should have(1).error_on(:address) }
      end
    end
  end

end