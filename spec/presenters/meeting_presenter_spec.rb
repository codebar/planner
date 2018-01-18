require 'spec_helper'

describe MeetingPresenter do
  let(:meeting) { double(:meeting) }
  let(:event) { MeetingPresenter.new(meeting) }

  it '#sponsors' do
    expect(event.sponsors).to eq([])
  end

  it '#description' do
    expect(meeting).to receive(:description)

    event.description
  end
end
