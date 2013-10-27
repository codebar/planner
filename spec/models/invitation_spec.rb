require 'spec_helper'

describe Invitation do
  it "has a token set on creation" do
    invitation = Fabricate(:invitation)

    invitation.token.should_not be nil
  end

  context "scopes" do
    before do
      3.times { Fabricate(:student) }
      6.times { Fabricate(:coach) }
      2.times { Fabricate(:member) }
    end

    it "#students" do
      Member.students.count.should eq 3
    end

    it "#coaches" do
      Member.coaches.count.should eq 6
    end
  end
end
