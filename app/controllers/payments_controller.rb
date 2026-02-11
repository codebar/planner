class PaymentsController < ApplicationController
  before_action :is_logged_in?

  def new; end

  def create
    payment_params = params.permit(:amount, :name, data: [:email, :id])

    @amount = payment_params[:amount]

    customer = Stripe::Customer.create(
      email: payment_params[:data][:email],
      description: payment_params[:name],
      source: payment_params[:data][:id]
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
