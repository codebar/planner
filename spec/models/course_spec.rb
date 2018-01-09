require 'spec_helper'

describe Course do
  let(:course) { Fabricate(:course) }

  context 'validations' do
    it '#title' do
      member = Fabricate.build(:course, title: nil)

      expect(member).to_not be_valid
      expect(member).to have(1).error_on(:title)
    end
  end

  context 'scopes' do
    let!(:next_course) { Fabricate(:course, date_and_time: Time.zone.now + 2.days) }

    before do
      Fabricate(:course, date_and_time: Time.zone.now + 1.week)
      Fabricate(:course, date_and_time: Time.zone.now - 1.week)
    end

    it '#upcoming' do
      expect(Course.upcoming.count).to eq(2)
    end

    it '#past' do
      expect(Course.past.count).to eq(1)
    end

    it '#next' do
      expect(Course.next).to eq(next_course)
    end
  end

  it '#attending' do
    2.times { Fabricate(:course_invitation, course: course, attending: true) }
    1.times { Fabricate(:course_invitation, course: course, attending: false) }

    expect(course.reload.attending.length).to eq(2)
  end
end
