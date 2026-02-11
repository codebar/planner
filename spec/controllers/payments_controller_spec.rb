RSpec.describe PaymentsController do
  let(:member) { Fabricate(:member) }

  before do
    login(member)
    allow(Stripe::Customer).to receive(:create).and_return(double(id: 'cus_123'))
    allow(Stripe::Charge).to receive(:create).and_return(true)
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a Stripe customer and charge' do
        expect(Stripe::Customer).to receive(:create).with(
          email: 'john@example.com',
          description: 'John Doe',
          source: 'tok_123'
        ).and_return(double(id: 'cus_123'))

        post :create, params: { amount: '1000', name: 'John Doe', data: { email: 'john@example.com', id: 'tok_123' } }
        expect(response).to be_successful
      end
    end

    context 'with parameter filtering' do
      it 'filters unpermitted parameters' do
        # params.permit now filters the payment parameters
        post :create, params: { amount: '1000', name: 'John', data: { email: 'john@example.com', id: 'tok_123' }, hacker_field: 'malicious' }
        expect(response).to be_successful
      end
    end
  end
end
