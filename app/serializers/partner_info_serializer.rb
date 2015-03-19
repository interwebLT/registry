class PartnerInfoSerializer < PartnerSerializer
  attributes :default_nameservers, :pricing

  def default_nameservers
    object.default_nameservers.collect do |default_nameserver|
      {
        name: default_nameserver
      }
    end
  end

  def pricing
    object.partner_pricings.collect do |pricing|
      PartnerPricingSerializer.new(pricing).serializable_hash
    end
  end
end
