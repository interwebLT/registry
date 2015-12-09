class CreditsController < SecureController
  def index
    render  json: current_user.partner.credit_history,
            each_serializer: CreditSerializer
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

  private

  def order_params
    params.permit(:partner, :currency_code, :ordered_at, order_details: [:type, :credits, :remarks])
  end

  def create_order
    order = Order.build order_params, order_partner

    if order.save
      # if current_user.admin?
        unless order.complete!
          render validation_failed order
          return
        end
      #end

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
