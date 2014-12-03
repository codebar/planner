require 'spec_helper'

describe EventPresenter do
  let(:workshop) { Fabricate(:sessions) }
  let(:event) { EventPresenter.new(workshop) }

  it "#venue" do
    expect(workshop).to receive(:venue)

    event.venue
  end

  it "#sponsors" do
    expect(workshop).to receive(:sponsors)

    event.sponsors
  end

  it "#description" do
    expect(event.description).to be(workshop.description)
  end

  it "#organisers" do
    expect(event.organisers)
  end

  it "#month" do
    expect(workshop).to receive(:date_and_time).and_return(DateTime.new(2014,9,3,16,30))

    expect(event.month).to eq("SEPTEMBER")
  end

  it "#time" do
    expect(workshop).to receive(:date_and_time).and_return(DateTime.new)

    event.time
  end

  it "#path" do
    expect(event.path).to eq(workshop)
  end

  it "#class_string" do
    expect(event.class_string).to eq("sessions")
  end

end
