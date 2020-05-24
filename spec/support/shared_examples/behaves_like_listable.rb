RSpec.shared_examples Listable do |listable_type|
  let(:listable_constant) { listable_type.to_s.camelize.constantize }

  context 'scope' do
    context '#upcoming' do
      it 'selects recent' do
        listable = Fabricate(listable_type, date_and_time: Time.zone.now + 10.minutes)

        expect(listable_constant.upcoming).to include(listable)
      end

      it 'ignores past' do
        Fabricate(listable_type, date_and_time: Time.zone.now - 10.minutes)

        expect(listable_constant.upcoming).to eq []
      end

      it 'orders by date time ascending' do
        l3 = Fabricate(listable_type, date_and_time: Time.zone.now + 30.minutes)
        l1 = Fabricate(listable_type, date_and_time: Time.zone.now + 10.minutes)
        l2 = Fabricate(listable_type, date_and_time: Time.zone.now + 20.minutes)

        expect(listable_constant.unscoped.upcoming).to eq [l1, l2, l3]
      end
    end

    context '#past' do
      it 'selects past' do
        listable = Fabricate(listable_type, date_and_time: Time.zone.now - 10.minutes)

        expect(listable_constant.past).to include(listable)
      end

      it 'ignores recent' do
        Fabricate(listable_type, date_and_time: Time.zone.now + 10.minutes)

        expect(listable_constant.past).to eq []
      end

      it 'orders by date time descending' do
        l2 = Fabricate(listable_type, date_and_time: Time.zone.now - 20.minutes)
        l1 = Fabricate(listable_type, date_and_time: Time.zone.now - 10.minutes)
        l3 = Fabricate(listable_type, date_and_time: Time.zone.now - 30.minutes)

        expect(listable_constant.past).to eq [l1, l2, l3]
      end
    end
  end

  context '#completed_since_yesterday' do
    it 'ignores future events' do
      Fabricate(listable_type, date_and_time: Time.zone.now + 10.minutes)

      expect(listable_constant.completed_since_yesterday).to eq []
    end

    it 'selects recent events' do
      listable = Fabricate(listable_type, date_and_time: Time.zone.now - 10.minutes)

      expect(listable_constant.completed_since_yesterday).to include(listable)
    end

    it 'selects events within 24 hours' do
      listable = Fabricate(listable_type, date_and_time: Time.zone.now - 24.hours + 10.minutes)

      expect(listable_constant.completed_since_yesterday).to include(listable)
    end

    it 'ignores events outside 24 hours' do
      listable = Fabricate(listable_type, date_and_time: Time.zone.now - 24.hours - 10.minutes)

      expect(listable_constant.completed_since_yesterday).to eq []
    end

    it 'orders by date time descending' do
      l2 = Fabricate(listable_type, date_and_time: Time.zone.now - 20.minutes)
      l1 = Fabricate(listable_type, date_and_time: Time.zone.now - 10.minutes)
      l3 = Fabricate(listable_type, date_and_time: Time.zone.now - 30.minutes)

      expect(listable_constant.completed_since_yesterday).to eq [l1, l2, l3]
    end
  end

  it '#next returns the next workshop to take place' do
    next_listable = Fabricate(listable_type, date_and_time: Time.zone.now + 24.hours)
    Fabricate(listable_type, date_and_time: Time.zone.now + 29.hours)

    expect(listable_constant.next).to eq(next_listable)
  end

  it '#most_recent returns the latest workshop to have taken place' do
    past_most_recent = Fabricate(listable_type, date_and_time: 2.hours.ago)
    Fabricate(listable_type, date_and_time: 2.days.ago)

    expect(listable_constant.most_recent).to eq(past_most_recent)
  end
end
