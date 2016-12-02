class OrdersController < SecureController
  def index
    if current_partner.admin
      render json: Order.latest
    else
      render json: current_partner.order_history(params[:month], params[:year])
    end
  end

  def create
    order = Order.build order_params, current_partner

    if order.save and order.complete!
      sync order

      render  json: order,
        status: :created,
        location: order_url(order.id)
    else
      render validation_failed order
    end
  end

  def show
    order = Order.find(params[:id])

    if order.partner == current_partner or current_partner.admin
      render json: order
    else
      render not_found
    end
  end

  private

  def order_params
    params.permit :partner, :currency_code, :ordered_at, order_details: [
      :type, :domain, :authcode, :period, :registrant_handle, :registered_at, :credits
    ]
  end

  def sync order
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      order.order_details.each do |order_detail|
        if order_detail.is_a? OrderDetail::RegisterDomain
          SyncRegisterDomainJob.perform_later registry.url, order
        elsif order_detail.is_a? OrderDetail::RenewDomain
          SyncRenewDomainJob.perform_later registry.url, order
        end
      end
    end
  end
end
