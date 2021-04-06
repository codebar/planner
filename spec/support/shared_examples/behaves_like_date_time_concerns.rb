RSpec.shared_examples DateTimeConcerns do |date_time_type|
  let(:date_time_able_type) { date_time_type.to_s.camelize.constantize }

  it { is_expected.to respond_to(:future?) }

  it '#date returns formatted date' do
    travel_to Time.zone.local(2010, 12, 31, 23, 59, 42) do
      date_time_able = Fabricate(date_time_type, date_and_time: Time.zone.now)
      expect(date_time_able.date).to eq 'Fri, 31 Dec 2010'
    end
  end

  it '#date returns the date in dashboard format' do
    date_time_able = Fabricate(date_time_type, date_and_time: Time.zone.local(2018, 8, 22, 18, 30))

    expect(date_time_able.date).to eq('Wed, 22 Aug 2018')
  end

  context '#time' do
    it 'returns nil if not available' do
      travel_to Time.zone.local(2010, 12, 31, 23, 59, 42) do
        date_time_able = Fabricate.build(date_time_type)
        date_time_able.date_and_time = nil
        expect(date_time_able.time).to be_nil
      end
    end

    it 'returns Time object' do
      travel_to Time.zone.local(2010, 12, 31, 23, 59, 42) do
        date_time_able = Fabricate(date_time_type, date_and_time: Time.zone.now)
        expect(date_time_able.time).to eq Time.zone.local(2010, 12, 31, 23, 59, 42)
      end
    end
  end

  it '#date_and_time returns TimeWithZone' do
    travel_to Time.zone.local(2010, 12, 31, 23, 59, 42) do
      date_time_able = Fabricate(date_time_type, date_and_time: Time.zone.now)
      expect(date_time_able.date_and_time).to eq Time.zone.local(2010, 12, 31, 23, 59, 42)
    end
  end

  context '#past?' do
    it 'returns true for object with datetime before today' do
      travel_to Time.zone.local(2010, 12, 31, 23, 59, 42) do
        date_time_able = Fabricate(date_time_type,
                                   date_and_time: Time.zone.local(2010, 12, 30, 23, 59, 59))
        expect(date_time_able.past?).to be true
      end
    end

    it 'returns false for object with datetime from today' do
      travel_to Time.zone.local(2010, 12, 31, 23, 59, 42) do
        date_time_able = Fabricate(date_time_type,
                                   date_and_time: Time.zone.local(2010, 12, 31, 0, 0, 0))
        expect(date_time_able.past?).to be false
      end
    end
  end
end
