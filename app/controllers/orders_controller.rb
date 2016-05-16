class OrdersController < SecureController
  def index
    if current_partner.admin
      render json: Order.latest
    else
      render json: current_partner.order_history
    end
  end

  def create
    if current_partner.admin? and not order_params.include? :partner
      render missing_fields [:partner]
    elsif order_params.empty?
      render bad_request
    else
      create_order
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
    params.permit(:partner, :currency_code, :ordered_at, order_details: [:type, :domain, :authcode, :period, :registrant_handle, :registered_at, :credits])
  end

  def create_order
    order = Order.build order_params, order_partner

    if order.save and order.complete!
      order.sync! if Rails.configuration.x.cocca_api_sync and not current_partner.admin

      render  json: order,
              status: :created,
              location: order_url(order.id)
    else
      render validation_failed order
    end
  end

  def order_partner
    current_partner.admin? ?  Partner.find_by(name: order_params[:partner]) : current_partner
  end
end
