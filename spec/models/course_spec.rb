require 'spec_helper'

describe Course do
  let(:course) { Fabricate(:course) }

  context "validations" do
    it "#title" do
      member = Fabricate.build(:course, title: nil)

      member.should_not be_valid
      member.should have(1).error_on(:title)
    end
  end

  context "scopes" do
    let!(:next_course) { Fabricate(:course, date_and_time: DateTime.now+2.days) }

    before do
      Fabricate(:course, date_and_time: DateTime.now+1.week)
      Fabricate(:course, date_and_time: DateTime.now-1.week)
    end

    it "#upcoming" do
      Course.upcoming.count.should eq 2
    end

    it "#past" do
      Course.past.count.should eq 1
    end

    it "#next" do
      Course.next.should eq next_course
    end
  end

  it "#attending" do
    2.times { Fabricate(:course_invitation, course: course, attending: true) }
    1.times { Fabricate(:course_invitation, course: course, attending: false) }

    course.reload.attending_invitations.length.should eq 2
  end
end

