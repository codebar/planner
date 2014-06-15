class Admin::SponsorsController < Admin::ApplicationController

  def new
    @sponsor = Sponsor.new
    @sponsor.build_address
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)
    @sponsor.build_address unless @sponsor.address.present?
    if @sponsor.save
      flash[:notice] = "Sponsor #{@sponsor.name} created"
      redirect_to [:admin, @sponsor]
    else
      flash[:notice] = @sponsor.errors.full_messages.to_s
      render 'new'
    end
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  private
  def sponsor_params
    params.require(:sponsor).permit(:name, :avatar, :website, :seats, address: [])
  end
end
