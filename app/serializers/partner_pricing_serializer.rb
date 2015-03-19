class PartnerPricingSerializer < ActiveModel::Serializer
  attributes :id, :action, :period, :price

  def price
    object.price.to_f
  end
end
