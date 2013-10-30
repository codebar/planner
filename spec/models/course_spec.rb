require 'spec_helper'

describe Course do

  context "validations" do
    it "#title" do
      member = Fabricate.build(:course, title: nil)

      member.should_not be_valid
      member.should have(1).error_on(:title)
    end
  end

  context "scopes" do
    before do
      2.times { Fabricate(:course, date_and_time: DateTime.now+1.week) }
      1.times { Fabricate(:course, date_and_time: DateTime.now-1.week) }
    end

    it "#upcoming" do
      Course.upcoming.count.should eq 2
    end

    it "#past" do
      Course.past.count.should eq 1
    end
  end
end

