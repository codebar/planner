require 'spec_helper'

RSpec.describe CoursePresenter do
  let(:course) { double(:course) }
  let(:event) { CoursePresenter.new(course) }

  it '#venue' do
    expect(course).to receive(:sponsor)

    event.venue
  end

  it '#sponsors' do
    expect(course).to receive(:sponsor)

    event.sponsors
  end

  it '#admin_path' do
    expect(event.admin_path).to eq('#')
  end

  it '#time' do
    expect(course).to receive(:date_and_time).and_return(Time.zone.now)

    event.time
  end
end
