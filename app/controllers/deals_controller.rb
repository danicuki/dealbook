class DealsController < ApplicationController
  load_and_authorize_resource :except => [:create, :update]
  respond_to :html, :json

  # GET /deals
  # GET /deals.json
  def index
    @deals = Deal.page(params[:page]).order("close_date DESC")
    respond_with(@deals)
  end

  # GET /deals/1
  # GET /deals/1.json
  def show
    @deal = Deal.find(params[:id])
    respond_with(@deal)
  end

  # GET /deals/new
  # GET /deals/new.json
  def new
    @deal = Deal.new
    respond_with(@deal)
  end

  # GET /deals/1/edit
  def edit
    @deal = Deal.find(params[:id])
  end

  # POST /deals
  # POST /deals.json
  def create
    # TODO: wrap in transaction
    buyers = params[:deal][:offerings][:buyers]
    params[:deal].delete(:offerings)
    @deal = Deal.new(params[:deal])
    authorize! :read, @deal # CanCan gem

    update_offerings_for(buyers)

    if @deal.save
      flash[:notice] = 'Deal was successfully created.'
    end
    respond_with(@deal, :location => deals_url)
  end

  # PUT /deals/1
  # PUT /deals/1.json
  def update
    # TODO: wrap in transaction
    buyers = params[:deal][:offerings][:buyers]
    params[:deal].delete(:offerings)

    @deal = Deal.find(params[:id])
    authorize! :read, @deal # CanCan gem

    update_offerings_for(buyers)

    @deal.verified = false
    if @deal.update_attributes(params[:deal])
      flash[:notice] = 'Deal was successfully updated.'
    end
    respond_with(@deal, :location => deals_url)
  end

  # DELETE /deals/1
  # DELETE /deals/1.json
  def destroy
    @deal = Deal.find(params[:id])
    @deal.destroy
    flash[:notice] = 'Deal was successfully deleted.'
    respond_with(@deal)
  end

  # TODO: check if RESTful. Can refactor into update?
  def verify
    @deal = Deal.find(params[:id])
    @deal.verified = true

    if @deal.update_attributes(params[:deal])
      flash[:notice] = 'Deal was marked as verified.'
    end
    respond_with(@deal)
  end

  def unverify
    @deal = Deal.find(params[:id])
    @deal.verified = false

    if @deal.update_attributes(params[:deal])
      flash[:notice] = 'Deal was marked as unverified.'
    end
    respond_with(@deal)
  end
end

private
def update_offerings_for(buyers)
  current_offerings = @deal.offerings(true)
  current_offerings.each do |current_offering|
    current_buyer = current_offering.buyer
    unless current_buyer.blank?
      current_buyer_string = "#{current_buyer.class.name}:#{current_buyer.id}"
      if buyers.include?(current_buyer_string)
        buyers.delete(current_buyer_string)
      else
        current_offerings.delete(current_offering)
      end
    end
  end
  buyers.each do |buyer|
    unless buyer.blank?
      buyer_type, buyer_id = buyer.split(":")
      new_offering = @deal.offerings.find_or_create_by_buyer_id_and_buyer_type(
        :buyer_type => buyer_type,
        :buyer_id => buyer_id.to_i)
    end
  end
end



