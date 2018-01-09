require 'spec_helper'

describe Address do
  subject(:address) { Fabricate.build(:address) }

  it { should respond_to(:sponsor) }
  it { should respond_to(:flat) }
  it { should respond_to(:street) }
  it { should respond_to(:postal_code) }
end
