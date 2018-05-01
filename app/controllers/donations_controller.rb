class DonationsController < ApplicationController
  def new; end

  def create
    @amount = params[:amount]

    customer = Stripe::Customer.create(
      email: params[:data][:email],
      description: params[:name],
      source: params[:data][:id]
    )

    charge = Stripe::Charge.create(
      amount: @amount,
      description: 'Donation to codebar',
      currency: 'gbp',
      customer: customer.id,
    )

    render layout: false
  end
end
