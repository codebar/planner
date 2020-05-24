require 'spec_helper'

RSpec.describe Course, type: :model  do
  include_examples Listable, :course

  let(:course) { Fabricate(:course) }

  context 'validations' do
    it '#title' do
      member = Fabricate.build(:course, title: nil)

      expect(member).to_not be_valid
      expect(member).to have(1).error_on(:title)
    end
  end

  it '#attending' do
    2.times { Fabricate(:course_invitation, course: course, attending: true) }
    1.times { Fabricate(:course_invitation, course: course, attending: false) }

    expect(course.reload.attending.length).to eq(2)
  end
end
