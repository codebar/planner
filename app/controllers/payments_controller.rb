class PaymentsController < ApplicationController
  before_action :is_logged_in?

  def new; end

  def create
    payment_params = params.expect(payment: [:amount, :name, :stripe_email, :stripe_token_id])

    @amount = payment_params[:amount]

    customer = Stripe::Customer.create(
      email: payment_params[:stripe_email],
      description: payment_params[:name],
      source: payment_params[:stripe_token_id]
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
