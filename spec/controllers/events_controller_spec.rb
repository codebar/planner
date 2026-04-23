RSpec.describe EventsController do
  describe '#fetch_upcoming_events' do
    context 'when no events exist' do
      it 'returns empty hash and nil pagy' do
        expect(controller.send(:fetch_upcoming_events)).to eq([{}, nil])
      end
    end
  end

  describe '#fetch_past_events' do
    context 'when no events exist' do
      it 'returns empty hash and nil pagy' do
        expect(controller.send(:fetch_past_events)).to eq([{}, nil])
      end
    end
  end
end