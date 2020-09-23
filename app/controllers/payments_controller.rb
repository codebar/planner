class PaymentsController < ApplicationController
  def new; end

  def create
    @amount = params[:amount]

    customer = Stripe::Customer.create(
      email: params[:data][:email],
      description: params[:name],
      source: params[:data][:id]
    )

    charge_customer(customer, @amount)

    render layout: false
  end

  private

  def charge_customer(customer, amount)
    Stripe::Charge.create(
      amount: amount,
      description: 'Payment to codebar',
      currency: 'gbp',
      customer: customer.id
    )
  end
end
