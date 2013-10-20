require 'spec_helper'

describe Sessions do

  context "#scopes" do
    it "#upcoming" do
      Sessions.create date_and_time: DateTime.now-1.week
      2.times { |n| Sessions.create date_and_time: DateTime.now+(n+1).week }

      Sessions.upcoming.length.should eq 2
    end
  end
end
