require 'spec_helper'

describe Event do
  subject(:event) { Fabricate(:event) }

  it { should be_valid }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:info) }
  it { should validate_presence_of(:schedule) }
  it { should validate_presence_of(:description) }
  it { should belong_to(:venue) }
  it { should have_many(:sponsorships) }
  it { should have_many(:sponsors) }
  it { should have_many(:organisers) }
  it { should have_and_belong_to_many(:chapters) }

end
