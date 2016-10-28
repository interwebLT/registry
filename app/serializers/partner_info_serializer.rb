class PartnerInfoSerializer < PartnerSerializer
  attributes :default_nameservers, :pricing, :credit_limit

  def default_nameservers
    object.default_nameservers.collect do |default_nameserver|
      {
        name: default_nameserver
      }
    end
  end

  def pricing
    object.partner_pricings.sorted_by_transfer_register_renew.collect do |pricing|
      PartnerPricingSerializer.new(pricing).serializable_hash
    end
  end

  def credit_limit
    object.credit_limit
  end
end
