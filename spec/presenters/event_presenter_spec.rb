require 'spec_helper'

RSpec.describe EventPresenter do
  let(:workshop) { Fabricate(:workshop) }
  let(:event) { EventPresenter.new(workshop) }

  it '#venue' do
    expect(workshop).to receive(:venue)

    event.venue
  end

  it '#sponsors' do
    expect(workshop).to receive(:sponsors)

    event.sponsors
  end

  it '#description' do
    expect(event.description).to be(workshop.description)
  end

  it '#organisers' do
    expect(event.organisers)
  end

  it '#month' do
    expect(workshop).to receive(:date_and_time).and_return(Time.zone.local(2014, 9, 3, 16, 30))

    expect(event.month).to eq('SEPTEMBER')
  end

  context '#time' do
    it 'when no end_time is set it only returns the start_time' do
      event =  double(:event, date_and_time: Time.zone.now, start_time: Time.zone.now, ends_at: nil)
      presenter = EventPresenter.new(event)

      expect(presenter.time).to eq(I18n.l(event.date_and_time, format: :time_with_zone))
    end

    it 'when a start and an end_time are set it returns a formatted start and end_time' do
      event =  double(:event, date_and_time: Time.zone.now, start_time: Time.zone.now, ends_at: 1.hour.from_now)
      presenter = EventPresenter.new(event)

      expect(presenter.time)
        .to eq("#{presenter.start_time} - #{presenter.end_time} #{I18n.l(event.date_and_time, format: :time_zone)}")
    end
  end

  it '#path' do
    expect(event.path).to eq(workshop)
  end

  it '#class_string' do
    expect(event.class_string).to eq('workshop')
  end

  context '#day_temporal_pronoun' do
    it 'returns today if the date_and_time set set to today' do
      workshop.date_and_time = Time.zone.now

      expect(event.day_temporal_pronoun). to eq('today')
    end

    it 'returns yesteday if the date_and_time is not set to today' do
      workshop.date_and_time = Time.zone.now+1.day

      expect(event.day_temporal_pronoun). to eq('tomorrow')
    end
  end
end
