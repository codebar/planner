require 'spec_helper'

describe Sponsor do
  subject(:sponsor) { Fabricate.build(:sponsor) }

  it { should respond_to(:name) }
  it { should respond_to(:website) }
  it { should respond_to(:address) }
  it { should respond_to(:workshops) }
  it { should respond_to(:workshop_sponsors) }
  it { should respond_to(:avatar) }
  it { should respond_to(:seats) }
  it { should respond_to(:email) }
  it { should respond_to(:contact_first_name) }
  it { should respond_to(:contact_surname) }
  it { should respond_to(:accessibility_info) }
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

        it { should_not be_valid }
        it { should have(2).errors_on(:website) }
      end
      describe '#address' do
        before { sponsor.address = nil }

        it { should_not be_valid }
        it { should have(1).error_on(:address) }
      end

      describe '#avatar' do
        subject(:sponsor) { Fabricate.build(:sponsor, avatar: nil) }

        it{ should_not be_valid }
        it{ should have(1).error_on(:avatar) }
      end

      describe '#seats' do
        before { sponsor.seats = nil }

        it { should have(1).error_on(:seats) }
      end
    end

    context 'format' do
      describe '#website' do
        describe 'nonsense is not valid.' do
          before { sponsor.website = 'lkjdlkfgjj' }
          it { should_not be_valid }
          it { should have(1).error_on(:website) }
        end

        describe 'websites without a protocol are not valid' do
          before { sponsor.website = 'www.google.com' }

          it { should_not be_valid }
          it { should have(1).error_on(:website) }
        end

        describe 'full URLs are valid' do
          before { sponsor.website = 'http://google.com' }
          it { should be_valid }
        end
      end
    end
  end
end
