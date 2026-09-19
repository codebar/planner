RSpec.shared_examples 'RsvpClosable' do
  describe '#effective_rsvp_closes_at' do
    it 'defaults to 3.5 hours before the start' do
      subject.date_and_time = Time.zone.local(2026, 3, 1, 18, 30)

      expect(subject.effective_rsvp_closes_at).to eq(Time.zone.local(2026, 3, 1, 15, 0))
    end
  end

  describe '#rsvp_available?' do
    it 'is available more than 3.5 hours before the start' do
      subject.date_and_time = 4.hours.from_now

      expect(subject.rsvp_available?).to be(true)
    end

    it 'is not available exactly 3.5 hours before the start' do
      subject.date_and_time = 3.5.hours.from_now

      expect(subject.rsvp_available?).to be(false)
    end

    it 'is available one second before the 3.5-hour boundary' do
      subject.date_and_time = 3.5.hours.from_now + 1.second

      expect(subject.rsvp_available?).to be(true)
    end

    it 'is not available within 3.5 hours of the start' do
      subject.date_and_time = 3.hours.from_now

      expect(subject.rsvp_available?).to be(false)
    end

    it 'is not available after the start' do
      subject.date_and_time = 1.hour.ago

      expect(subject.rsvp_available?).to be(false)
    end
  end
end
