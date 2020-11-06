class Admin::ContactsController < Admin::ApplicationController
  def index
    authorize Contact
    @contacts = Contact.includes(:sponsor).all.order('sponsors.name')
  end
end
