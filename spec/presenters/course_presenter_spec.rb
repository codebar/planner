require 'spec_helper'

describe CoursePresenter do
  let(:course) { double(:course) }
  let(:event) { CoursePresenter.new(course) }

  it "#venue" do
    expect(course).to receive(:sponsor)

    event.venue
  end

  it "#sponsors" do
    expect(course).to receive(:sponsor)

    event.sponsors
  end

  it "#description" do
    expect(course).to receive(:short_description)

    event.description
  end
end
