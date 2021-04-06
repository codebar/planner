require 'spec_helper'

RSpec.describe EventPresenter do
  let(:workshop) { Fabricate(:workshop) }
  let(:event) { described_class.new(workshop) }

  it '#venue' do
    allow(workshop).to receive(:venue)

    event.venue

    expect(workshop).to have_received(:venue)
  end

  it '#sponsors' do
    allow(workshop).to receive(:sponsors)

    event.sponsors

    expect(workshop).to have_received(:sponsors)
  end

  it '#description' do
    expect(event.description).to be(workshop.description)
  end

  describe '#short_description' do
    it 'when there is no short_description on the event model it fallsback to description' do
      expect(event.short_description).to be(workshop.description)
    end

    it 'when there is a short_description' do
      course = Fabricate(:course)
      event = described_class.new(course)

      expect(event.short_description).to be(course.short_description)
    end
  end

  describe '#organisers' do
    it 'when there are no organisers' do
      expect(event.organisers).to match_array([])
    end

    it 'when there are organisers' do
      permissions = Fabricate(:permission, resource: workshop, name: 'organiser')

      expect(event.organisers).to match_array(permissions.members)
    end
  end

  it '#month' do
    allow(workshop).to receive(:date_and_time).and_return(Time.zone.local(2014, 9, 3, 16, 30))

    expect(event.month).to eq('SEPTEMBER')
  end

  describe '#time' do
    it 'when no end_time is set it only returns the start_time' do
      event = double(:event, date_and_time: Time.zone.now,
                             start_time: Time.zone.now,
                             ends_at: nil)
      presenter = described_class.new(event)

      expect(presenter.time).to eq(I18n.l(event.date_and_time, format: :time_with_zone))
    end

    it 'when a start and an end_time are set it returns a formatted start and end_time' do
      event = double(:event, date_and_time: Time.zone.now,
                             start_time: Time.zone.now,
                             ends_at: 1.hour.from_now)
      presenter = described_class.new(event)

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

  describe '#day_temporal_pronoun' do
    it 'returns today if the date_and_time set set to today' do
      workshop.date_and_time = Time.zone.now

      expect(event.day_temporal_pronoun).to eq('today')
    end

    it 'returns yesteday if the date_and_time is not set to today' do
      workshop.date_and_time = Time.zone.now + 1.day

      expect(event.day_temporal_pronoun).to eq('tomorrow')
    end
  end

  describe '#rsvp_closing_date_and_time' do
    it 'returns the calculated RSVP closing time for an event' do
      workshop.date_and_time = Time.zone.local(2040, 10, 10, 16, 30)

      expect(event.rsvp_closing_date_and_time).to eq(Time.zone.local(2040, 10, 10, 13, 0))
    end
  end
end
