class OrderDetail::CheckoutReplenishCredits < OrderDetail::ReplenishCredits
  validates :remarks, presence: true
  validates :authcode, presence: true

  def self.build params, partner
    order_detail = self.new
    order_detail.price = params[:credits].money
    order_detail.credits = params[:credits].money
    order_detail.remarks = params[:remarks]
    order_detail.authcode = params[:authcode]

    order_detail
  end
  
  def complete!
    payment_verified? ? super : false
  end
    
  private

  def payment_verified?
    response = HTTParty.get Rails.configuration.checkout_endpoint + "/charges/#{authcode}",
                            headers: checkout_headers
    hash = JSON.parse response.body
    
    hash["responseMessage"] == "Approved"
  end
  
  def checkout_headers
    {
      "Content-Type" => "application/json",
      "Authorization" => Rails.configuration.checkout_sk
    }
  end

end