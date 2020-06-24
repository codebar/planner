require 'spec_helper'

RSpec.describe Address, type: :model do
  subject(:address) { Fabricate.build(:address) }
end
