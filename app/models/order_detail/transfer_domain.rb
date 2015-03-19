class OrderDetail::TransferDomain < OrderDetail
  def self.build params, partner
    new params
  end

  def action
    'transfer_domain'
  end

  def complete!
    true
  end

  def as_json options = nil
    {
      type: 'domain_transfer',
      price: self.price.to_f,
      domain: self.domain
    }
  end
end
