require 'spec_helper'

describe Event do
  subject(:event) { Fabricate(:event) }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:slug) }
  it { should respond_to(:info) }
  it { should respond_to(:schedule) }
  it { should respond_to(:description) }
  it { should respond_to(:venue) }
  it { should respond_to(:sponsorships) }
  it { should respond_to(:sponsors) }
  it { should respond_to(:organisers) }
  it { should respond_to(:chapters) }

end
