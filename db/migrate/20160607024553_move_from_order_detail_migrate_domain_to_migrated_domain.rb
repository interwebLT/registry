class MoveFromOrderDetailMigrateDomainToMigratedDomain < ActiveRecord::Migration
  def change
    OrderDetail::MigrateDomain.all.each do |order_detail|
      MigratedDomain.create name:               order_detail.domain,
                            registrant_handle:  order_detail.registrant_handle,
                            registered_at:      order_detail.registered_at,
                            expires_at:         order_detail.expires_at,
                            authcode:           order_detail.authcode,
                            created_at:         order_detail.order.ordered_at,
                            updated_at:         order_detail.order.created_at

      order_detail.order.destroy
    end
  end
end
