class OrdersController < SecureController
  def index
    if current_user.admin
      render json: Order.latest
    else
      render json: current_user.partner.order_history
    end
  end

  def create
    if current_user.admin? and not order_params.include? :partner
      render missing_fields [:partner]
    elsif order_params.empty?
      render bad_request
    else
      create_order
    end
  end

  def show
    order = Order.find(params[:id])

    if order.partner == current_user.partner or current_user.admin
      render json: order
    else
      render not_found
    end
  end

  private

  def order_params
    params.permit(:partner, :currency_code, :ordered_at, order_details: [:type, :domain, :authcode, :period, :registrant_handle, :registered_at, :credits, :renewed_at])
  end

  def create_order
    order = Order.build order_params, order_partner

    if order.save
      if current_user.admin?
        unless order.complete!
          render validation_failed order
          return
        end
      end

      render  json: order,
              status: :created,
              location: order_url(order.id)
    else
      render validation_failed order
    end
  end

  def order_partner
    current_user.admin? ?  Partner.find_by(name: order_params[:partner]) : current_user.partner
  end
end
