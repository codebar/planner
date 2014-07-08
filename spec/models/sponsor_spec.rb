require 'spec_helper'

describe Sponsor do
  subject(:sponsor) { Fabricate.build(:sponsor) }

  it { should respond_to(:name) }
  it { should respond_to(:website) }
  it { should respond_to(:address) }
  it { should respond_to(:sessions) }
  it { should respond_to(:sponsor_sessions) }
  it { should respond_to(:avatar) }
  it { should respond_to(:seats) }
  it { should be_valid }

  context 'validations' do
    context 'presence' do
      describe '#name' do
        before { sponsor.name = nil }

        it { should_not be_valid }
        it { should have(1).error_on(:name) }
      end
      describe '#website' do
        before { sponsor.website = nil }

        it { should_not be_valid}
        it { should have(1).error_on(:website) }
      end
      describe '#address' do
        before { sponsor.address = nil }

        it { should_not be_valid}
        it { should have(1).error_on(:address) }
      end

      describe '#avatar' do
        before { sponsor.avatar = nil }

        it{ should_not be_valid }
        it{ should have(1).error_on(:avatar) }
      end

      describe '#seats' do
        before { sponsor.seats = nil }

        it { should have(1).error_on(:seats) }
      end
    end
  end

  context "scopes" do
    let!(:past) { 2.times.map { Fabricate(:sponsor) } }
    let!(:latest) { 4.times.map { Fabricate(:sponsor) } }

    it "#latest" do
      expect(Sponsor.latest).to eq(latest.reverse)
    end
  end

end
