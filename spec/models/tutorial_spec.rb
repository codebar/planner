require 'spec_helper'

describe Tutorial do
  subject(:tutorial) { Fabricate.build(:tutorial) }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:url) }
  it { should respond_to(:course)}

  context "validations" do
    it "#title" do
      tutorial = Fabricate.build(:tutorial, title: nil)

      tutorial.should_not be_valid
      tutorial.should have(1).error_on(:title)
    end
  end
end
