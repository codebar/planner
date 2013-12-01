require 'spec_helper'

describe Feedback do
  subject(:feedback) { Fabricate.build(:feedback) }

  it { should respond_to(:request) }
  it { should respond_to(:suggestions) }
  it { should respond_to(:coach) }
  it { should respond_to(:tutorial)}
end
