class MigrationsController < SecureController
  def create
    order = Order.build migration_params, current_partner

    if order.save
      order.complete!

      render  json: order,
              status: :created,
              location: orders_url(1)
    else
      render validation_failed order
    end
  end

  private

  def migration_params
    params.permit(:partner, :currency_code, :ordered_at, order_details: [:type, :domain, :authcode, :registrant_handle, :registered_at, :expires_at])
  end
end
