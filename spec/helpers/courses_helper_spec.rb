require 'spec_helper'

describe CoursesHelper do

  it "#twitter_url_for" do

    helper.twitter_url_for("Picard").should eq "http://twitter.com/Picard"
  end

end
