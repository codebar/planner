require 'spec_helper'

describe Address do
  subject(:address) { Fabricate.build(:address) }

  it { should respond_to(:sponsor) }
  it { should respond_to(:flat) }
  it { should respond_to(:street) }
  it { should respond_to(:postal_code) }
  it { should respond_to(:city) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:accessible) }
  it { should respond_to(:note) }
end