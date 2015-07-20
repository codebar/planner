require 'spec_helper'

describe Event do
  subject(:event) { Fabricate(:event) }

  it { should be_valid }
  it { should validate_presence_of(:name) }

end
