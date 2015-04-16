class LinkOrderDetailToProduct < ActiveRecord::Migration
  def change
    link_register_domain_orders
    link_renew_domain_orders
  end

  private

  def link_register_domain_orders
    OrderDetail::RegisterDomain.where(product: nil).each do |od|
      domain = Domain.named(od.domain)

      next unless domain

      od.product = domain.product
      od.authcode = domain.authcode
      od.save!
    end
  end

  def link_renew_domain_orders
    OrderDetail::RenewDomain.where(product: nil).each do |od|
      domain = Domain.named(od.domain)

      next unless domain

      od.product = domain.product
      od.authcode = domain.authcode
      od.save!
    end
  end
end
