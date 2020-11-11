class Admin::SponsorsController < Admin::ApplicationController
  before_action :set_sponsor, only: %i[show edit update]

  def index
    authorize Sponsor

    @sponsors_search = SponsorsSearch.new(search_params)
    @sponsors = @sponsors_search.call

    @decorated_sponsors = SponsorPresenter.decorate_collection(@sponsors)
  end

  def show
    @sponsor = SponsorPresenter.new(@sponsor)
  end

  def new
    @sponsor = Sponsor.new
    @sponsor.build_address
    @sponsor.contacts.build
    authorize @sponsor
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)
    @sponsor.build_address if @sponsor.address.blank?
    authorize @sponsor

    if @sponsor.valid? && @sponsor.save
      return redirect_to [:admin, @sponsor], notice: "Sponsor #{@sponsor.name} created"
    end

    flash[:warning] = @sponsor.errors.full_messages
    render 'new'
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
    @sponsor.build_address if @sponsor.address.blank?
    @sponsor.contacts.build unless @sponsor.contacts.any?
  end

  def update
    @sponsor.assign_attributes(sponsor_params)

    if @sponsor.valid? && @sponsor.save
      @sponsor.contacts.each do |contact|
        audit_contact_subscription(contact)
      end

      flash[:notice] = 'Updated!'
      return redirect_to admin_sponsor_path(@sponsor)
    end

    flash[:warning] = @sponsor.errors.full_messages
    render 'edit'
  end

  private

  def sponsor_params
    params.require(:sponsor).permit(:name, :avatar, :website, :seats, :accessibility_info,
                                    :number_of_coaches, :level,
                                    address_attributes: %i[id flat street postal_code city
                                                           latitude longitude directions],
                                    contacts_attributes: %i[id name surname email mailing_list_consent
                                                            _destroy])
  end

  def set_sponsor
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
  end

  def page
    params.permit(:page)[:page]
  end

  def audit_contact_subscription(contact)
    return unless contact.previous_changes.key?(:mailing_list_consent)

    contact_audit_key = contact.mailing_list_consent ? 'subscribe' : 'unsubscribe'
    Auditor::Audit.new(@sponsor, "sponsor.admin_contact_#{contact_audit_key}", current_user, contact)
                  .log_with_note(contact.email)
  end

  def filter_search_params
    params[:sponsors_search] || ActionController::Parameters.new
  end

  def search_params
    { name: filter_search_params[:name], page: params[:page] }
  end
end
